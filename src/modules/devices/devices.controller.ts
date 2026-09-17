import { BadRequestException, Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DeviceEntity } from '../sensors/entities/device.entity';
import { FeedScheduleEntity } from '../feeding/entities/feed-schedule.entity';
import { DevicesService } from './devices.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AssignDeviceDto } from './dto/assign-device.dto';

@Controller('devices')
export class DevicesController {
  constructor(
    private readonly devicesService: DevicesService,
    @InjectRepository(FeedScheduleEntity)
    private readonly feedScheduleRepo: Repository<FeedScheduleEntity>,
  ) {}

  /**
   * List all devices (with pond info). Requires authentication.
   */
  @Get()
  @UseGuards(JwtAuthGuard)
  async findAll() {
    const devices = await this.devicesService.findAll();
    return { success: true, data: devices };
  }

  /**
   * List only devices available for assignment to a new pond.
   * Used by the "Create Pond" screen to show selectable hardware.
   */
  @Get('available')
  @UseGuards(JwtAuthGuard)
  async findAvailable() {
    const devices = await this.devicesService.findAvailable();
    return { success: true, data: devices };
  }

  /**
   * Assign a device to a pond.
   * Body: { pondId: "<uuid>" } (or legacy { pond_id: "<uuid>" })
   *
   * Clears the device's previous pond assignment, binds the new pond, and
   * rejects with 409 when the target pond already has a different device.
   */
  @Post(':id/assign')
  @UseGuards(JwtAuthGuard)
  async assignToPond(
    @Param('id') deviceId: string,
    @Body() dto: AssignDeviceDto,
  ) {
    const pondId = dto.resolvePondId();
    if (!pondId) {
      throw new BadRequestException(
        'pondId is required (send { "pondId": "<pond uuid>" })',
      );
    }
    const device = await this.devicesService.assignDeviceToPond(deviceId, pondId);
    return { success: true, data: device };
  }

  // Device polls pending schedules (fallback for devices that cannot use WS)
  @Get(':code/pending')
  async getPending(@Param('code') code: string) {
    const device = await this.devicesService.findByDeviceCode(code);
    if (!device) return { success: false, message: 'Unknown device' };
    const pondId = device.pondId;
    if (!pondId) return { success: true, data: [] };

    const schedules = await this.feedScheduleRepo.find({ where: { pondId } });
    // Return minimal fields for device consumption. Inactive ("Done")
    // schedules must never fire the feeder servo again.
    return {
      success: true,
      data: schedules
        .filter((s) => s.isActive !== false)
        .map((s) => ({ id: s.id, feedTime: s.feedTime, feedAmount: Number(s.feedAmount) })),
    };
  }

  // Device acknowledges a schedule
  @Post(':code/ack')
  async postAck(@Param('code') code: string, @Body() body: { scheduleId: string; status: string }) {
    const { scheduleId, status } = body ?? {};
    if (!scheduleId) return { success: false, message: 'scheduleId required' };
    const schedule = await this.feedScheduleRepo.findOne({ where: { id: scheduleId } });
    if (!schedule) return { success: false, message: 'Unknown schedule' };
    schedule['lastSyncedAt'] = new Date();
    schedule['lastSyncStatus'] = status ?? 'unknown';
    schedule['syncAttempts'] = (schedule['syncAttempts'] || 0) + 1;
    await this.feedScheduleRepo.save(schedule);
    return { success: true };
  }
}
