// ponds.service.ts
import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { PondEntity } from './entities/pond.entity/pond.entity';
import { CreatePondDto } from './dto/create-pond.dto';
import { UpdatePondDto } from './dto/update-pond.dto';
import { SensorDataEntity } from '../sensors/entities/sensor-data.entity';
import { FeedScheduleEntity } from '../feeding/entities/feed-schedule.entity';
import { FeedingScheduleItemDto } from './dto/create-pond.dto';
import { AddFeedScheduleDto } from './dto/add-feed-schedule.dto';

/**
 * Shape shared by both pond DTOs regarding feeding data.
 */
interface PondFeedingInput {
  feedingTimes?: string[];
  amount?: number;
  feedingSchedules?: Array<{ time: string; amount?: number }>;
}

/** Round to 2 dp to match the decimal(10,2) column. */
function roundAmount(value: number): number {
  return Math.round(value * 100) / 100;
}

/** Format a Postgres `time` value ("12:00:00") the way the app shows it ("12:00 PM"). */
function formatTime12(value: string): string {
  const match = /^(\d{1,2}):(\d{2})/.exec(value ?? '');
  if (!match) return value;
  let hours = Number(match[1]);
  const minutes = match[2];
  const meridiem = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12 || 12;
  return `${hours}:${minutes} ${meridiem}`;
}

/**
 * The Flutter app sends a structured `feedingSchedules` array
 * ([{ time, amount }]) alongside (or instead of) the plain
 * `feedingTimes` list.  The database stores the plain times plus the total
 * amount, so derive those values from the schedule and strip the raw array
 * before persisting (it is not a column on the entity).
 */
function normalizePondPayload(dto: PondFeedingInput): Record<string, unknown> {
  const source = dto as PondFeedingInput & Record<string, unknown>;
  const { feedingSchedules, feedingTimes, amount, ...rest } = source;

  // Keep only defined values so a partial update never wipes existing
  // columns with undefined/NULL (Object.assign would copy them otherwise).
  const result: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(rest)) {
    if (value !== undefined) {
      result[key] = value;
    }
  }

  if (Array.isArray(feedingSchedules) && feedingSchedules.length > 0) {
    result.feedingTimes = feedingSchedules.map((item) => item.time);

    if (amount === undefined) {
      const total = feedingSchedules.reduce(
        (sum, item) =>
          sum + (typeof item.amount === 'number' ? item.amount : 0),
        0,
      );
      result.amount = roundAmount(total);
    }
  }

  // Legacy plain feedingTimes still applies when no schedule array is sent.
  if (result.feedingTimes === undefined && Array.isArray(feedingTimes)) {
    result.feedingTimes = feedingTimes;
  }
  if (amount !== undefined) {
    result.amount = amount;
  }

  return result;
}

@Injectable()
export class PondsService {
  constructor(
    @InjectRepository(PondEntity)
    private pondsRepository: Repository<PondEntity>,
    @InjectRepository(SensorDataEntity)
    private sensorDataRepository: Repository<SensorDataEntity>,
    @InjectRepository(FeedScheduleEntity)
    private feedSchedulesRepository: Repository<FeedScheduleEntity>,
  ) {}

  /**
   * Water-quality status buckets shown by the Flutter detail page.
   * Thresholds follow common tropical aquaculture ranges.
   */
  private static oxygenStatus(v?: number | null): string {
    if (v == null) return 'Unknown';
    if (v >= 5) return 'Good';
    if (v >= 3) return 'Moderate';
    return 'Low';
  }

  private static phStatus(v?: number | null): string {
    if (v == null) return 'Unknown';
    if (v >= 6.5 && v <= 8.5) return 'Good';
    if (v >= 6 && v <= 9) return 'Moderate';
    return 'Abnormal';
  }

  private static temperatureStatus(v?: number | null): string {
    if (v == null) return 'Unknown';
    if (v >= 25 && v <= 32) return 'Good';
    if (v >= 20 && v <= 35) return 'Moderate';
    return 'Abnormal';
  }

  /**
   * Attach the latest ESP32 readings to a pond.
   *
   * Sensor rows are stored per hardware `deviceId` (e.g. "fishcap_001") with
   * no direct pond foreign key, so the pond is matched through:
   *   1. pond.hardware_id  (set when creating/editing the pond), and
   *   2. any device registered for this pond in the `devices` table.
   *
   * The extra keys mirror what the Flutter DashboardScreen expects:
   * oxygen/oxygenStatus, pH/pHStatus (+ lowercase `ph` for the list model),
   * temperature/temperatureStatus, fishCount/fishType aliases and the pond's
   * feedSchedules.
   */
  private async withLatestReadings(
    pond: PondEntity,
  ): Promise<Record<string, unknown>> {
    let deviceIds = [pond.hardwareId, ...(pond.devices ?? []).map((d) => d.deviceCode)]
      .filter((v): v is string => typeof v === 'string' && v.length > 0);

    deviceIds = [...new Set(deviceIds)];

    const latest = deviceIds.length
      ? await this.sensorDataRepository.findOne({
          where: { deviceId: In(deviceIds) },
          order: { createdAt: 'DESC' },
        })
      : null;

    // NOTE: Postgres `decimal` columns are returned as strings by the pg
    // driver despite the entity typing, so coerce explicitly.
    const oxygen = latest?.dissolvedOxygen != null ? Number(latest.dissolvedOxygen) : null;
    const pH = latest?.ph != null ? Number(latest.ph) : null;
    const temperature = latest?.temperature != null ? Number(latest.temperature) : null;
    // HX711 load-cell telemetry (feed stock weight) sent by the ESP32.
    const weightGrams = latest?.weightGrams != null ? Number(latest.weightGrams) : null;
    const remainingStockGrams =
      latest?.remainingStockGrams != null ? Number(latest.remainingStockGrams) : null;

    // Stocking duration = whole days since start_date, when parsable.
    let stockingDuration: string | null = null;
    if (pond.startDate) {
      const start = new Date(pond.startDate);
      if (!Number.isNaN(start.getTime())) {
        const days = Math.max(
          0,
          Math.floor((Date.now() - start.getTime()) / 86_400_000),
        );
        stockingDuration = `${days} days`;
      }
    }

    // Feed schedules for the detail page. The UI reads {time, title, status},
    // so map the relation rows into that shape. Ponds saved before feed
    // schedules were persisted only have the feedingTimes jsonb column —
    // synthesize placeholder items from it so those ponds still list times.
    const scheduleRows = pond.feedSchedules ?? [];
    const feedSchedules = scheduleRows.length
      ? scheduleRows.map((s) => ({
          id: s.id,
          time: formatTime12(s.feedTime),
          title:
            s.title && s.title.trim().length > 0
              ? s.title.trim()
              : Number(s.feedAmount) > 0
                ? `${Number(s.feedAmount).toFixed(2)} kg`
                : 'Feed',
          amount: s.feedAmount != null ? Number(s.feedAmount) : null,
          status: s.isActive === false ? 'Done' : 'Scheduled',
        }))
      : (pond.feedingTimes ?? []).map((time) => ({
          time: formatTime12(time),
          title: 'Feed',
          status: 'Scheduled',
        }));

    return {
      ...pond,
      oxygen,
      oxygenStatus: PondsService.oxygenStatus(oxygen),
      pH,
      ph: pH, // the list screen's Pond.fromJson reads the lowercase key
      pHStatus: PondsService.phStatus(pH),
      temperature: temperature != null ? temperature.toFixed(1) : pond.temperature,
      temperatureStatus: PondsService.temperatureStatus(temperature),
      fishCount: pond.estimatedCount ?? null,
      fishType: pond.species ?? null,
      stockingDuration,
      expectedHarvest: pond.endDate ?? null,
      // Live feed-stock weight from the load cell + low-stock flag so the
      // Flutter dashboard can render the sensor section.
      weightGrams,
      remainingStockGrams,
      lowStock: latest?.lowStock ?? null,
      feeding: latest?.feeding ?? null,
      lastReadingAt: latest?.createdAt ?? null,
      sensorDeviceId: latest?.deviceId ?? null,
      feedSchedules,
    };
  }

  /** Raw entity lookup shared by update/remove (no enrichment). */
  private async findOwnedEntity(id: string, userId: string): Promise<PondEntity> {
    const pond = await this.pondsRepository.findOne({
      where: { id, owner: { id: userId } },
      relations: { owner: true },
    });
    if (!pond)
      throw new NotFoundException('Pond not found or not owned by user');
    return pond;
  }

  /**
   * Replace-all sync of the pond's feed_schedules rows from the structured
   * array the Flutter form sends (feedingSchedules: [{time, amount}]).
   * Keeps per-time amounts in the feed_schedules table while the legacy
   * feedingTimes/amount pond columns stay untouched for compatibility.
   */
  private async syncFeedSchedules(
    pondId: string,
    items: FeedingScheduleItemDto[],
  ): Promise<void> {
    await this.feedSchedulesRepository.delete({ pondId });
    const rows = (items ?? [])
      .filter((item) => typeof item.time === 'string' && item.time.trim().length > 0)
      .map((item) =>
        this.feedSchedulesRepository.create({
          pondId,
          feedTime: item.time.trim(),
          feedAmount: item.amount ?? 0,
          isActive: true,
        }),
      );
    if (rows.length) {
      await this.feedSchedulesRepository.save(rows);
    }
  }

  /** Map a schedule row into the shape the Flutter detail page renders. */
  private toScheduleDto(row: FeedScheduleEntity) {
    return {
      id: row.id,
      time: formatTime12(row.feedTime),
      title:
        row.title && row.title.trim().length > 0
          ? row.title.trim()
          : Number(row.feedAmount) > 0
            ? `${Number(row.feedAmount).toFixed(2)} kg`
            : 'Feed',
      amount: row.feedAmount != null ? Number(row.feedAmount) : null,
      status: row.isActive === false ? 'Done' : 'Scheduled',
    };
  }

  /** "Add New Time" button: append one schedule to an owned pond. */
  async addFeedSchedule(pondId: string, userId: string, dto: AddFeedScheduleDto) {
    const pond = await this.findOwnedEntity(pondId, userId);
    const feedTime = this.normalizeTimeInput(dto.time);
    if (!feedTime) {
      throw new BadRequestException(
        `Invalid time "${dto.time}". Use e.g. "8:00 AM", "14:30" or "07:05".`,
      );
    }
    const row = await this.feedSchedulesRepository.save(
      this.feedSchedulesRepository.create({
        pondId: pond.id,
        feedTime,
        feedAmount: 0,
        title: dto.title?.trim() || undefined,
        isActive: true,
      }),
    );
    return this.toScheduleDto(row);
  }

  /**
   * Accept the loose time strings users type in the "Add New Time" dialog
   * ("8:00 AM", "8AM", "14:30", "07:05") and normalize them to a Postgres
   * `time` literal (HH:MM:00). Returns null when unparseable.
   */
  private normalizeTimeInput(raw: string): string | null {
    const match = /^\s*(\d{1,2})(?::(\d{2}))?\s*([AP]M)?\s*$/i.exec(raw ?? '');
    if (!match) return null;
    let hours = Number(match[1]);
    const minutes = match[2] ?? '00';
    const meridiem = match[3]?.toUpperCase();
    if (minutes.length !== 2 || Number(minutes) > 59) return null;
    if (meridiem) {
      if (hours < 1 || hours > 12) return null;
      if (meridiem === 'PM' && hours !== 12) hours += 12;
      if (meridiem === 'AM' && hours === 12) hours = 0;
    } else if (hours > 23) {
      return null;
    }
    return `${String(hours).padStart(2, '0')}:${minutes}:00`;
  }

  async create(
    createPondDto: CreatePondDto,
    userId: string,
  ): Promise<PondEntity> {
    const schedules = createPondDto.feedingSchedules;
    const values = normalizePondPayload(createPondDto);
    const pond = this.pondsRepository.create({
      ...values,
      owner: { id: userId },
    });
    const saved = await this.pondsRepository.save(pond);
    if (Array.isArray(schedules)) {
      await this.syncFeedSchedules(saved.id, schedules);
    }
    return saved;
  }

  async findAll(userId: string): Promise<Record<string, unknown>[]> {
    const ponds = await this.pondsRepository.find({
      where: { owner: { id: userId } },
      relations: { owner: true, devices: true },
      order: { created_at: 'DESC' },
    });
    return Promise.all(ponds.map((pond) => this.withLatestReadings(pond)));
  }

  async findOne(id: string, userId: string): Promise<Record<string, unknown>> {
    const pond = await this.pondsRepository.findOne({
      where: { id, owner: { id: userId } },
      relations: { owner: true, devices: true, feedSchedules: true },
    });
    if (!pond)
      throw new NotFoundException('Pond not found or not owned by user');
    return this.withLatestReadings(pond);
  }

  async update(
    id: string,
    updatePondDto: UpdatePondDto,
    userId: string,
  ): Promise<PondEntity> {
    const pond = await this.findOwnedEntity(id, userId);
    const schedules = updatePondDto.feedingSchedules;
    const values = normalizePondPayload(updatePondDto);
    Object.assign(pond, values);
    const saved = await this.pondsRepository.save(pond);
    // Only re-sync when the form actually sent the schedule array (an empty
    // array intentionally clears all rows).
    if (Array.isArray(schedules)) {
      await this.syncFeedSchedules(saved.id, schedules);
    }
    return saved;
  }

  async remove(id: string, userId: string): Promise<void> {
    // Ensure the pond exists AND belongs to this user before deleting.
    await this.findOwnedEntity(id, userId);
    await this.pondsRepository.delete(id);
  }
}
