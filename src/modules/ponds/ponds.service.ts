// ponds.service.ts
import { BadRequestException, ConflictException, Injectable, NotFoundException, Optional } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, In, Repository } from 'typeorm';
import { PondEntity } from './entities/pond.entity/pond.entity';
import { CreatePondDto } from './dto/create-pond.dto';
import { UpdatePondDto } from './dto/update-pond.dto';
import { SensorDataEntity } from '../sensors/entities/sensor-data.entity';
import { DeviceEntity } from '../sensors/entities/device.entity';
import { FeedScheduleEntity } from '../feeding/entities/feed-schedule.entity';
import { FeedingLogEntity } from '../feeding/entities/feeding-log.entity';
import { FishSpeciesEntity } from '../feeding/entities/fish-species.entity';
import { DeviceGateway } from '../devices/device.gateway';
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
    @InjectRepository(FeedingLogEntity)
    private feedingLogsRepository: Repository<FeedingLogEntity>,
    @InjectRepository(FishSpeciesEntity)
    private fishSpeciesRepository: Repository<FishSpeciesEntity>,
    @InjectRepository(DeviceEntity)
    private deviceRepository: Repository<DeviceEntity>,
    @Optional() private deviceGateway?: DeviceGateway,
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

  private static tdsStatus(v?: number | null): string {
    if (v == null) return 'Unknown';
    if (v >= 50 && v <= 500) return 'Good';
    if (v >= 20 && v <= 1000) return 'Moderate';
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
    const tds = latest?.tds != null ? Number(latest.tds) : null;
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

    // Attempt to enrich with species-specific environment thresholds when
    // a matching species exists in the fish_species table.
    let temperatureStatus = PondsService.temperatureStatus(temperature);
    let pHStatus = PondsService.phStatus(pH);
    try {
      if (pond.species) {
        const allSpecies = await this.fishSpeciesRepository.find();
        const normalized = (pond.species || '').toString().trim().toLowerCase();
        const match = allSpecies.find((s) => {
          if ((s.nameEn || '').toString().toLowerCase() === normalized) return true;
          if ((s.nameKm || '').toString().toLowerCase() === normalized) return true;
          if (Array.isArray(s.aliases) && s.aliases.map((a) => String(a).toLowerCase()).includes(normalized)) return true;
          return false;
        });
        if (match && match.environment) {
          const env = match.environment as any;
          if (temperature != null && env.temperature) {
            const tmin = env.temperature.min as number | undefined;
            const tmax = env.temperature.max as number | undefined;
            if (tmin != null && tmax != null) {
              if (temperature >= tmin && temperature <= tmax) temperatureStatus = 'Good';
              else if (temperature >= (tmin - 5) && temperature <= (tmax + 5)) temperatureStatus = 'Moderate';
              else temperatureStatus = 'Abnormal';
            }
          }
          if (pH != null && env.ph) {
            const pmin = env.ph.min as number | undefined;
            const pmax = env.ph.max as number | undefined;
            if (pmin != null && pmax != null) {
              if (pH >= pmin && pH <= pmax) pHStatus = 'Good';
              else if (pH >= (pmin - 0.5) && pH <= (pmax + 0.5)) pHStatus = 'Moderate';
              else pHStatus = 'Abnormal';
            }
          }
        }
      }
    } catch (err) {
      // Non-fatal: fallback to global thresholds above.
    }

    return {
      ...pond,
      oxygen,
      oxygenStatus: PondsService.oxygenStatus(oxygen),
      tds,
      tdsStatus: PondsService.tdsStatus(tds),
      pH,
      ph: pH, // the list screen's Pond.fromJson reads the lowercase key
      pHStatus,
      temperature: temperature != null ? temperature.toFixed(1) : pond.temperature,
      temperatureStatus,
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
    // Detach historical feeding logs from the schedules that are about to be
    // deleted. Production databases may still carry the legacy FK constraint
    // (NO ACTION) on feeding_logs.schedule_id, which makes the plain delete
    // below fail with:
    //   "update or delete on table feed_schedules violates foreign key
    //    constraint FK_... on table feeding_logs"
    // Setting schedule_id to NULL first preserves the logs (they keep their
    // pond_id/feed_amount/status history) and makes this work on databases
    // that have not had the ON DELETE SET NULL migration applied yet.
    await this.feedingLogsRepository
      .createQueryBuilder()
      .update(FeedingLogEntity)
      .set({ scheduleId: null })
      .where('pond_id = :pondId', { pondId })
      .execute();

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
      // After persisting feed schedules, push them to all registered devices.
      await this.pushSchedulesToDevices(pondId);
    }
  }

  /**
   * Push the pond's current feed schedules to every device registered for
   * it (Socket.IO `schedule_update`). Best-effort: devices that are offline
   * pick the schedule up via the GET /api/devices/:code/pending polling
   * fallback instead.
   */
  private async pushSchedulesToDevices(pondId: string): Promise<void> {
    try {
      const devices = await this.deviceRepository.find({ where: { pond: { id: pondId } } });
      const rows = await this.feedSchedulesRepository.find({ where: { pondId } });
      const payload = rows
        .filter((r) => r.isActive !== false)
        .map((r) => ({ id: r.id, feedTime: r.feedTime, feedAmount: Number(r.feedAmount) }));
      for (const dev of devices) {
        if (!dev?.deviceCode) continue;
        await this.deviceGateway?.sendScheduleToDevice(dev.deviceCode, { pondId, schedules: payload });
      }
    } catch (err) {
      // Swallow: best-effort notify; fallback REST/polling covers offline devices.
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
    // Push the updated schedule list to the pond's devices immediately so
    // the feeder servo follows the new time without waiting for its next
    // polling cycle.
    await this.pushSchedulesToDevices(pond.id);
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
      // feedSchedules included so the Schedule tab can render each pond's
      // feeding times + amounts with per-row edit/delete actions.
      relations: { owner: true, devices: true, feedSchedules: true },
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
    const wasDone = (pond.status || 'active').toString().toLowerCase() === 'done';
    Object.assign(pond, values);

    // "Mark as Done" from the app uses PATCH /ponds/:id { status: 'done' }.
    // The canonical complete endpoint is PATCH /ponds/:id/complete, but ANY
    // status transition to 'done' must release the bound hardware, otherwise
    // the device keeps polling the finished pond's schedules (devices.pond_id
    // is the only source of truth for GET /devices/:code/pending).
    const isNowDone =
      (pond.status || 'active').toString().toLowerCase() === 'done';
    const releasesHardware = !wasDone && isNowDone;
    if (releasesHardware && !pond.endDate) {
      pond.endDate = new Date().toISOString().split('T')[0];
    }

    // Atomically save the pond and (when completing) release its device so a
    // crash between the two writes can never leave a stranded binding.
    let releasedDevices: DeviceEntity[] = [];
    const saved = await this.pondsRepository.manager.transaction(
      async (em) => {
        const savedPond = await em.getRepository(PondEntity).save(pond);
        if (releasesHardware) {
          releasedDevices = await this.releaseDevicesForPond(em, savedPond.id);
        }
        return savedPond;
      },
    );

    // Notify the released device(s) after the transaction committed.
    if (releasedDevices.length > 0 && this.deviceGateway) {
      for (const device of releasedDevices) {
        this.deviceGateway.sendDeviceConfig(device.deviceCode, {
          hardware_id: device.deviceCode,
          pond_id: '',
          status: 'AVAILABLE',
        });
      }
    }

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

  /**
   * Mark a pond as completed/done and release its hardware for reassignment.
   *
   * Steps:
   * 1. Verify pond exists and belongs to user
   * 2. In one transaction: set pond status to 'done' + stamp endDate + release
   *    the assigned device (devices.pond_id = NULL, status AVAILABLE)
   * 3. Preserve all historical data (sensor readings, feeding logs, schedules)
   * 4. Notify the device over WS after the commit
   *
   * Returns the updated pond and device info.
   */
  async completePond(
    id: string,
    userId: string,
  ): Promise<{ pond: PondEntity; device: DeviceEntity | null }> {
    const pond = await this.findOwnedEntity(id, userId);

    // Mark pond as done + release hardware atomically: devices.pond_id is the
    // single source of truth for schedule polling, so it must never be left
    // pointing at a finished pond if the pond write succeeds but the process
    // dies before the device write (or vice versa).
    const { savedPond, releasedDevices } =
      await this.pondsRepository.manager.transaction(async (em) => {
        pond.status = 'done';
        pond.endDate = pond.endDate || new Date().toISOString().split('T')[0];
        const saved = await em.getRepository(PondEntity).save(pond);
        const devices = await this.releaseDevicesForPond(em, saved.id);
        return { savedPond: saved, releasedDevices: devices };
      });

    // Notify the ESP32 that it has been released (after commit).
    const releasedDevice = releasedDevices[0] ?? null;
    if (releasedDevice) {
      const deviceCode = releasedDevice.deviceCode;
      if (this.deviceGateway) {
        this.deviceGateway.sendDeviceConfig(deviceCode, {
          hardware_id: deviceCode,
          pond_id: '',
          status: 'AVAILABLE',
        });
      }
    }

    return { pond: savedPond, device: releasedDevice };
  }

  /**
   * Release every device currently bound to a pond inside the caller's
   * transaction: clears devices.pond_id (the schedule-polling source of truth)
   * and marks the hardware AVAILABLE for reassignment. Returns the released
   * devices (empty when the pond had none).
   */
  private async releaseDevicesForPond(
    em: EntityManager,
    pondId: string,
  ): Promise<DeviceEntity[]> {
    const deviceRepo = em.getRepository(DeviceEntity);
    const devices = await deviceRepo.find({ where: { pondId } });
    for (const device of devices) {
      // Targeted update(): clear devices.pond_id (the schedule-polling
      // source of truth) explicitly instead of save()-diffing, so the write
      // can never be optimized away.
      await deviceRepo.update(device.id, {
        pondId: null,
        status: 'AVAILABLE',
        releasedAt: new Date(),
      });
    }
    return devices;
  }

  /**
   * Create a new pond and optionally assign an available device to it.
   * Overrides the base create method to handle device assignment.
   */
  async createWithDevice(
    createPondDto: CreatePondDto,
    userId: string,
  ): Promise<{ pond: PondEntity; device: DeviceEntity | null }> {
    const pond = await this.create(createPondDto, userId);

    let assignedDevice: DeviceEntity | null = null;
    if (createPondDto.deviceId) {
      // Find the device by its ID (UUID) and validate it's available
      const device = await this.deviceRepository.findOne({
        where: { id: createPondDto.deviceId },
      });
      if (!device) {
        throw new NotFoundException(`Device ${createPondDto.deviceId} not found`);
      }
      if (device.status !== 'AVAILABLE' || device.pondId !== null) {
        throw new ConflictException(
          `Device ${device.deviceCode} is currently assigned to another pond and cannot be reassigned until the previous pond is completed.`,
        );
      }
      // Assign device to pond
      device.pondId = pond.id;
      device.status = 'ASSIGNED';
      device.assignedAt = new Date();
      assignedDevice = await this.deviceRepository.save(device);

      // Push new configuration to the ESP32
      if (this.deviceGateway) {
        this.deviceGateway.sendDeviceConfig(device.deviceCode, {
          hardware_id: device.deviceCode,
          pond_id: pond.id,
          status: 'ACTIVE',
        });
      }
    }

    return { pond, device: assignedDevice };
  }
}
