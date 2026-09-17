import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
  Optional,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DeviceEntity } from './entities/device.entity';
import { SensorDataEntity } from './entities/sensor-data.entity';
import { CreateDeviceDto } from './dto/create-device.dto';
import { CreateSensorDataDto } from './dto/create-sensor-data.dto';
import { DeviceGateway } from '../devices/device.gateway';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class SensorsService {
  constructor(
    @InjectRepository(DeviceEntity)
    private readonly deviceRepository: Repository<DeviceEntity>,
    @InjectRepository(SensorDataEntity)
    private readonly sensorDataRepository: Repository<SensorDataEntity>,
    @Optional() private readonly notificationsService?: NotificationsService,
    @Optional() private deviceGateway?: DeviceGateway,
  ) {}

  async createDevice(createDeviceDto: CreateDeviceDto): Promise<DeviceEntity> {
    const deviceCode = createDeviceDto.deviceCode?.trim();
    if (!deviceCode) {
      throw new BadRequestException('deviceCode is required');
    }
    const device = this.deviceRepository.create({
      ...createDeviceDto,
      deviceCode,
      status: createDeviceDto.status ?? 'AVAILABLE',
    });
    try {
      return await this.deviceRepository.save(device);
    } catch (err) {
      // Postgres unique_violation on devices.device_code → the hardware
      // label is already registered. Surface a clear 409 instead of a 500.
      if ((err as { code?: string })?.code === '23505') {
        throw new ConflictException(
          `Device "${deviceCode}" is already registered.`,
        );
      }
      throw err;
    }
  }

  async findAllDevices(): Promise<DeviceEntity[]> {
    return this.deviceRepository.find({ relations: { pond: true } });
  }

  async findDevice(id: string): Promise<DeviceEntity> {
    const device = await this.deviceRepository.findOne({
      where: { id },
      relations: { pond: true },
    });
    if (!device) {
      throw new NotFoundException('Device not found');
    }
    return device;
  }

  // ── Alert windows ─────────────────────────────────────────────
  // Water temperature (°C). Matches PondsService.temperatureStatus.
  private static readonly TEMP_ALERT_MIN = 20;
  private static readonly TEMP_ALERT_MAX = 35;

  // pH. Matches PondsService.phStatus.
  private static readonly PH_ALERT_MIN = 6;
  private static readonly PH_ALERT_MAX = 9;

  // Dissolved oxygen floor (mg/L). Matches PondsService.oxygenStatus.
  private static readonly DO_ALERT_MIN = 3;

  // TDS window (ppm). 0 = disconnected probe → never alerted on.
  private static readonly TDS_ALERT_MIN = 100;
  private static readonly TDS_ALERT_MAX = 500;

  // Re-remind about continuously-low stock at most this often.
  private static readonly LOW_STOCK_REMINDER_HOURS = 6;

  // Re-remind about continuous sensor alerts at most this often.
  private static readonly ALERT_REMINDER_HOURS = 2;

  private readonly logger = new Logger('SensorsService');

  /**
   * Resolve the pond owner that should receive notifications for a device.
   * Returns null when the device is unregistered, has no pond, or the pond
   * has no owner — logged so the gap is visible in production.
   */
  private async resolveOwnerUserId(deviceCode: string): Promise<string | null> {
    if (!deviceCode) return null;

    const device = await this.deviceRepository.findOne({
      where: { deviceCode },
      relations: { pond: { owner: true } },
    });

    if (!device) {
      this.logger.warn(`[ALERTS] No device row with deviceCode="${deviceCode}"`);
      return null;
    }
    if (!device.pondId) {
      this.logger.warn(`[ALERTS] Device "${deviceCode}" has no pondId`);
      return null;
    }
    const ownerId = device.pond?.owner?.id;
    if (typeof ownerId !== 'string' || ownerId.length === 0) {
      this.logger.warn(`[ALERTS] Pond ${device.pondId} has no owner`);
      return null;
    }
    return ownerId;
  }

  /**
   * Create DB notifications for the events the app should surface:
   *   - feed dispensed by the feeder (`feeding === true`)
   *   - feed stock crossing into "low" (transition + reminder)
   *   - water temperature leaving the safe window
   *   - pH leaving the safe window
   *   - dissolved oxygen dropping below the safe floor
   *   - TDS leaving the safe window (0 ppm = disconnected, skipped)
   *
   * Every created notification is broadcast on the `notification` socket
   * event so the Flutter app can raise a local push immediately.
   */
  private async maybeCreateNotifications(
    dto: CreateSensorDataDto,
    previousReading: SensorDataEntity | null,
    savedReading: SensorDataEntity,
  ): Promise<void> {
    // ── Gate 1: NotificationsService must be wired up ──
    if (!this.notificationsService) {
      this.logger.error(
        '[ALERTS] NotificationsService is undefined — add NotificationsModule ' +
          'to SensorsModule imports/providers. No alerts can be created.',
      );
      return;
    }

    const deviceCode = dto.deviceId?.trim();
    if (!deviceCode) return;

    // Debug trace — remove once alerts are confirmed working.
    this.logger.debug(
      `[ALERTS] evaluate device=${deviceCode} ` +
        `ph=${dto.ph ?? 'null'} tds=${dto.tds ?? 'null'} ` +
        `temp=${dto.temperature ?? 'null'} do=${dto.dissolvedOxygen ?? 'null'} ` +
        `lowStock=${dto.lowStock ?? 'null'} feeding=${dto.feeding ?? 'null'}`,
    );

    const lowStock = dto.lowStock === true || (dto.lowStock as unknown) === 'true';
    const feeding = dto.feeding === true;

    const temperature =
      savedReading.temperature != null ? Number(savedReading.temperature) : null;
    const temperatureAlert =
      temperature != null &&
      (temperature < SensorsService.TEMP_ALERT_MIN ||
        temperature > SensorsService.TEMP_ALERT_MAX);

    // Postgres decimal columns come back as strings — coerce explicitly.
    const ph = savedReading.ph != null ? Number(savedReading.ph) : null;
    const dissolvedOxygen =
      savedReading.dissolvedOxygen != null ? Number(savedReading.dissolvedOxygen) : null;

    // TDS: a disconnected probe reads 0. Never alert on that.
    const tdsRaw = savedReading.tds != null ? Number(savedReading.tds) : null;
    const tds = tdsRaw != null && tdsRaw > 0 ? tdsRaw : null;

    const phAlert =
      ph != null &&
      (ph < SensorsService.PH_ALERT_MIN || ph > SensorsService.PH_ALERT_MAX);
    const oxygenAlert =
      dissolvedOxygen != null && dissolvedOxygen < SensorsService.DO_ALERT_MIN;
    const tdsAlert =
      tds != null &&
      (tds < SensorsService.TDS_ALERT_MIN || tds > SensorsService.TDS_ALERT_MAX);

    if (
      !lowStock &&
      !feeding &&
      !temperatureAlert &&
      !phAlert &&
      !oxygenAlert &&
      !tdsAlert
    ) {
      return; // Nothing to alert on.
    }

    // ── Gate 4: resolve the recipient ──
    const userId = await this.resolveOwnerUserId(deviceCode);
    if (!userId) {
      this.logger.warn(
        `[ALERTS] No notification created for ${deviceCode}: ` +
          'device not registered, has no pond, or pond has no owner.',
      );
      return;
    }

    const notes: Array<{ title: string; message: string }> = [];

    // ── Feed dispensed ──
    if (feeding) {
      const kg = (Number(dto.feedGramsDispensed ?? 0) / 1000).toFixed(3);
      notes.push({
        title: 'Feed dispensed',
        message: `${deviceCode} finished feeding and dispensed ${kg} kg.`,
      });
    }

    // ── Low stock (transition + reminder) ──
    if (lowStock) {
      const prevLow = previousReading?.lowStock === true;
      let shouldNotify = !prevLow;
      if (!shouldNotify) {
        const last = await this.notificationsService
          .findLatestByTitle(userId, 'Low feed stock')
          .catch(() => null);
        shouldNotify =
          !last ||
          Date.now() - new Date(last.createdAt).getTime() >=
            SensorsService.LOW_STOCK_REMINDER_HOURS * 3_600_000;
      }
      if (shouldNotify) {
        const remainingKg = Number(dto.remainingStockGrams ?? 0) / 1000;
        notes.push({
          title: 'Low feed stock',
          message: `${deviceCode} remaining feed is ${remainingKg.toFixed(
            3,
          )} kg. Refill the hopper soon.`,
        });
      }
    }

    // ── Temperature ──
    if (temperatureAlert && temperature != null) {
      const prevTemp =
        previousReading?.temperature != null
          ? Number(previousReading.temperature)
          : null;
      const prevAlert =
        prevTemp != null &&
        (prevTemp < SensorsService.TEMP_ALERT_MIN ||
          prevTemp > SensorsService.TEMP_ALERT_MAX);
      const shouldNotify = await this.passesThrottle(
        userId,
        'Water temperature alert',
        !prevAlert,
      );
      if (shouldNotify) {
        const kind =
          temperature < SensorsService.TEMP_ALERT_MIN ? 'too low' : 'too high';
        notes.push({
          title: 'Water temperature alert',
          message:
            `${deviceCode} water temperature is ${kind} ` +
            `(${temperature.toFixed(1)} °C). Safe range: ` +
            `${SensorsService.TEMP_ALERT_MIN}-${SensorsService.TEMP_ALERT_MAX} °C.`,
        });
      }
    }

    // ── pH ──
    if (phAlert && ph != null) {
      const prevPh =
        previousReading?.ph != null ? Number(previousReading.ph) : null;
      const prevAlert =
        prevPh != null &&
        (prevPh < SensorsService.PH_ALERT_MIN ||
          prevPh > SensorsService.PH_ALERT_MAX);
      const shouldNotify = await this.passesThrottle(
        userId,
        'Water pH alert',
        !prevAlert,
      );
      if (shouldNotify) {
        const kind = ph < SensorsService.PH_ALERT_MIN ? 'too low' : 'too high';
        notes.push({
          title: 'Water pH alert',
          message:
            `${deviceCode} water pH is ${kind} (${ph.toFixed(2)}). ` +
            `Safe range: ${SensorsService.PH_ALERT_MIN}-${SensorsService.PH_ALERT_MAX}.`,
        });
      }
    }

    // ── TDS ──
    if (tdsAlert && tds != null) {
      const prevTds =
        previousReading?.tds != null ? Number(previousReading.tds) : null;
      const prevAlert =
        prevTds != null &&
        prevTds > 0 &&
        (prevTds < SensorsService.TDS_ALERT_MIN ||
          prevTds > SensorsService.TDS_ALERT_MAX);
      const shouldNotify = await this.passesThrottle(
        userId,
        'Water TDS alert',
        !prevAlert,
      );
      if (shouldNotify) {
        const kind = tds < SensorsService.TDS_ALERT_MIN ? 'too low' : 'too high';
        notes.push({
          title: 'Water TDS alert',
          message:
            `${deviceCode} water TDS is ${kind} (${tds.toFixed(1)} ppm). ` +
            `Safe range: ${SensorsService.TDS_ALERT_MIN}-${SensorsService.TDS_ALERT_MAX} ppm.`,
        });
      }
    }

    // ── Dissolved oxygen ──
    if (oxygenAlert && dissolvedOxygen != null) {
      const prevDo =
        previousReading?.dissolvedOxygen != null
          ? Number(previousReading.dissolvedOxygen)
          : null;
      const prevAlert = prevDo != null && prevDo < SensorsService.DO_ALERT_MIN;
      if (!prevAlert) {
        notes.push({
          title: 'Dissolved oxygen alert',
          message:
            `${deviceCode} dissolved oxygen is low ` +
            `(${dissolvedOxygen.toFixed(1)} mg/L). Safe minimum: ` +
            `${SensorsService.DO_ALERT_MIN} mg/L — check aeration.`,
        });
      }
    }

    // ── Persist + push each pending note ──
    for (const note of notes) {
      try {
        const created = await this.notificationsService.create({
          // `user: { id }` matches what NotificationsService.findAll() queries.
          // Passing a bare `userId` only works if the entity exposes a raw
          // userId column — which it may not.
          user: { id: userId } as any,
          title: note.title,
          message: note.message,
          isRead: false,
        } as any);

        this.logger.log(
          `[ALERTS] Created "${note.title}" for user ${userId} (device ${deviceCode})`,
        );

        // Best-effort socket broadcast so the app raises a local push.
        this.deviceGateway?.broadcastNotification({
          id: created?.id,
          userId,
          deviceId: deviceCode,
          title: note.title,
          message: note.message,
          createdAt: created?.createdAt ?? new Date().toISOString(),
        });
      } catch (err) {
        // One failing notification must not block the others.
        this.logger.error(
          `[ALERTS] Failed to create "${note.title}" for user ${userId}: ${(err as Error).message}`,
        );
      }
    }
  }

  /**
   * True when a notification should be created: either this is a fresh
   * transition into the alert state, or the previous reminder is older than
   * ALERT_REMINDER_HOURS.
   */
  private async passesThrottle(
    userId: string,
    title: string,
    isTransition: boolean,
  ): Promise<boolean> {
    if (isTransition) return true;
    const last = await this.notificationsService!
      .findLatestByTitle(userId, title)
      .catch(() => null);
    return (
      !last ||
      Date.now() - new Date(last.createdAt).getTime() >=
        SensorsService.ALERT_REMINDER_HOURS * 3_600_000
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────

  async createSensorData(
    createSensorDataDto: CreateSensorDataDto,
  ): Promise<SensorDataEntity> {
    const deviceId = createSensorDataDto.deviceId?.trim();
    if (!deviceId) {
      throw new BadRequestException('deviceId is required');
    }

    // Sanitize impossible readings. A DS18B20 probe reports -127 when it
    // is disconnected; storing it as-is made the app show "-127.0 Abnormal".
    // Keep only values inside the sensor's physical range (-55..125 °C),
    // otherwise leave the column unset (NULL) so the app shows "Unknown".
    const t = createSensorDataDto.temperature;
    const temperature =
      typeof t === 'number' && Number.isFinite(t) && t >= -55 && t <= 125
        ? t
        : undefined;

    const previousReading = await this.sensorDataRepository.findOne({
      where: { deviceId },
      order: { createdAt: 'DESC' },
    });

    // Look up the device's current pond assignment so this reading is
    // permanently linked to the correct pond. When the hardware is later
    // reassigned, historical readings stay with the pond they were taken for.
    const device = await this.deviceRepository.findOne({
      where: { deviceCode: deviceId },
    });
    const currentPondId = device?.pondId ?? null;

    const sensorData = this.sensorDataRepository.create({
      deviceId,
      pondId: currentPondId,
      temperature,
      ph: createSensorDataDto.ph,
      dissolvedOxygen: createSensorDataDto.dissolvedOxygen,
      tds: createSensorDataDto.tds,
      weightGrams: createSensorDataDto.weightGrams,
      feeding: createSensorDataDto.feeding,
      feedGramsDispensed: createSensorDataDto.feedGramsDispensed,
      remainingStockGrams: createSensorDataDto.remainingStockGrams,
      lowStock: createSensorDataDto.lowStock,
      ...(createSensorDataDto.timestamp == null
        ? {}
        : { createdAt: new Date(createSensorDataDto.timestamp) }),
    });
    const saved = await this.sensorDataRepository.save(sensorData);

    try {
      await this.maybeCreateNotifications(
        createSensorDataDto,
        previousReading,
        saved,
      );
    } catch (err) {
      // Notification failures must never break sensor ingestion.
      this.logger.error(
        `[ALERTS] maybeCreateNotifications threw: ${(err as Error).message}`,
      );
    }

    try {
      this.deviceGateway?.broadcastSensorData(saved);
    } catch (err) {
      // Best-effort broadcast — ignore errors.
    }

    return saved;
  }

  async findAllSensorData(): Promise<SensorDataEntity[]> {
    return this.sensorDataRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findLatestSensorData(): Promise<SensorDataEntity[]> {
    return this.sensorDataRepository.find({
      order: { createdAt: 'DESC' },
      take: 20,
    });
  }

  async findSensorData(id: string): Promise<SensorDataEntity> {
    const sensorData = await this.sensorDataRepository.findOne({
      where: { id },
    });
    if (!sensorData) {
      throw new NotFoundException('Sensor data not found');
    }
    return sensorData;
  }
}