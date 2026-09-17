import { Body, Controller, Delete, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FeedingService } from './feeding.service';
import { CreateFeedScheduleDto } from './dto/create-feed-schedule.dto';
import { UpdateFeedScheduleDto } from './dto/update-feed-schedule.dto';
import { CreateFeedingLogDto } from './dto/create-feeding-log.dto';
import { CreateFeedingLogFromDeviceDto } from './dto/create-feeding-log-dto';
import { FeedingLogEntity } from './entities/feeding-log.entity';
import { FeedScheduleEntity } from './entities/feed-schedule.entity';
import { DeviceEntity } from '../sensors/entities/device.entity';
import { log } from 'console';

@Controller('feeding')
export class FeedingController {
  constructor(private readonly feedingService: FeedingService) {}

  @Post('schedules')
  createSchedule(@Body() createFeedScheduleDto: CreateFeedScheduleDto) {
    return this.feedingService.createSchedule(createFeedScheduleDto);
  }

  @Get('schedules')
  findAllSchedules() {
    return this.feedingService.findAllSchedules();
  }

  @Get('schedules/:id')
  findSchedule(@Param('id') id: string) {
    return this.feedingService.findSchedule(id);
  }

  @Patch('schedules/:id')
  updateSchedule(@Param('id') id: string, @Body() updateFeedScheduleDto: UpdateFeedScheduleDto) {
    return this.feedingService.updateSchedule(id, updateFeedScheduleDto);
  }

  @Delete('schedules/:id')
  removeSchedule(@Param('id') id: string) {
    return this.feedingService.removeSchedule(id);
  }

  @Post('logs')
  createLog(@Body() createFeedingLogDto: CreateFeedingLogDto) {
    return this.feedingService.createLog(createFeedingLogDto);
  }

  @Get('logs')
  findAllLogs() {
    return this.feedingService.findAllLogs();
  }

  @Get('logs/grouped')
  findLogsGrouped(@Query('pondId') pondId?: string) {
    return this.feedingService.getLogsGrouped(pondId);
  }

  @Get('logs/:id')
  findLog(@Param('id') id: string) {
    return this.feedingService.findLog(id);
  }

  @Get('species/search')
  searchSpecies(@Query('q') q?: string) {
    return this.feedingService.searchSpecies(q || '');
  }

  @Post('calculate')
  calculate(@Body() body: { batchId: string; targetDate?: string; language?: 'km' | 'en' }) {
    const { batchId, targetDate, language } = body;
    return this.feedingService.calculateDailyFeed(batchId, targetDate || new Date(), language || 'km');
  }
}

/**
 * Device-facing ingest route for the ESP32 feeder.
 *
 * The sketch POSTs detailed dispense results to
 *   POST /api/feeding-logs
 * with a payload that includes scheduleId/deviceId/status and the full
 * weight-based verification (target/previous/final/actual/remaining).
 *
 * This route persists a FeedingLogEntity linked to the correct pond.
 * Pond resolution prefers the device's current assignment; if the device
 * is not (yet) registered or has no pond, it falls back to the schedule's
 * pond so the log still lands somewhere useful.
 */
@Controller('feeding-logs')
export class FeedingLogsIngestController {
  constructor(
    private readonly feedingService: FeedingService,
    @InjectRepository(FeedingLogEntity)
    private readonly feedingLogRepo: Repository<FeedingLogEntity>,
    @InjectRepository(FeedScheduleEntity)
    private readonly scheduleRepo: Repository<FeedScheduleEntity>,
    @InjectRepository(DeviceEntity)
    private readonly deviceRepo: Repository<DeviceEntity>,
  ) {}

  @Post()
  async createFromDevice(@Body() dto: CreateFeedingLogFromDeviceDto) {
    const { scheduleId, deviceId, status, fedAt } = dto;

    // Resolve pond id.
    let pondId: string | null = null;

    const device = await this.deviceRepo.findOne({
      where: { deviceCode: deviceId },
      relations: { pond: true },
    });
    if (device?.pondId) {
      pondId = device.pondId;
    }

    // Fallback: if we don't know the device's pond, ask the schedule.
    if (!pondId) {
      const schedule = await this.scheduleRepo.findOne({
        where: { id: scheduleId },
        relations: { pond: true },
      });
      if (schedule?.pondId) {
        pondId = schedule.pondId;
      }
    }

    // ── Timestamp ──
    const completedAt = dto.completedAt
      ? new Date(dto.completedAt * 1000)          // epoch s → ms
      : dto.fedAt
        ? new Date(dto.fedAt)
        : new Date();

    // ── Persist ──
    // create() typing may not match the entity's exact property names (e.g. relation ids vs relation objects).
    // Cast to any to avoid TS overload/type issues while keeping runtime shape as intended.
    const log = this.feedingLogRepo.create({
      pondId: pondId || undefined,
      scheduleId: scheduleId || undefined,
      feedAmount: dto.actualDispensedKg ?? undefined, // kg, not ×1000
      status: status || 'UNKNOWN',
      fedAt: completedAt,

      targetFeedKg: dto.targetFeedKg ?? null,
      previousHopperWeightKg: dto.previousHopperWeightKg ?? null,
      finalHopperWeightKg: dto.finalHopperWeightKg ?? null,
      actualDispensedKg: dto.actualDispensedKg ?? null,
      remainingFeedKg: dto.remainingFeedKg ?? null,
      toleranceKg: dto.toleranceKg ?? null,
      failureReason: dto.failureReason ?? null,
    } as any);

    const saved = await this.feedingLogRepo.save(log);
    return { success: true, data: saved };
  }
}

