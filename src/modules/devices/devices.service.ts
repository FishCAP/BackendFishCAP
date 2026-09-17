import { BadRequestException, ConflictException, Injectable, Logger, NotFoundException, Optional } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, IsNull, Repository } from 'typeorm';
import { DeviceEntity, DeviceStatus } from '../sensors/entities/device.entity';
import { PondEntity } from '../ponds/entities/pond.entity/pond.entity';
import { DeviceGateway } from './device.gateway';

@Injectable()
export class DevicesService {
  private readonly logger = new Logger('DevicesService');

  constructor(
    @InjectRepository(DeviceEntity)
    private readonly deviceRepo: Repository<DeviceEntity>,
    @InjectRepository(PondEntity)
    private readonly pondRepo: Repository<PondEntity>,
    @Optional() private readonly deviceGateway?: DeviceGateway,
  ) {}

  /**
   * List all devices with their current pond assignment.
   */
  async findAll(): Promise<DeviceEntity[]> {
    return this.deviceRepo.find({
      relations: { pond: true },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * List only devices that are available for assignment to a new pond.
   */
  async findAvailable(): Promise<DeviceEntity[]> {
    return this.deviceRepo.find({
      where: { status: 'AVAILABLE', pondId: IsNull() },
      order: { deviceCode: 'ASC' },
    });
  }

  /**
   * Get a single device by its ID.
   */
  async findById(id: string): Promise<DeviceEntity> {
    const device = await this.deviceRepo.findOne({
      where: { id },
      relations: { pond: true },
    });
    if (!device) {
      throw new NotFoundException(`Device ${id} not found`);
    }
    return device;
  }

  /**
   * Get a device by its hardware code (e.g. "FC-001").
   */
  async findByDeviceCode(deviceCode: string): Promise<DeviceEntity | null> {
    return this.deviceRepo.findOne({
      where: { deviceCode },
      relations: { pond: true },
    });
  }

  /**
   * Assign a device to a pond (bind the device's schedule source).
   *
   * devices.pond_id is the ONLY input the ESP32 schedule poll
   * (GET /devices/:code/pending) uses, so this endpoint:
   * 1. Clears the device's current pond_id if any (device may be moved
   *    directly from one pond to another — no manual SQL needed),
   * 2. Sets the new pond_id in the same transaction,
   * 3. Rejects the request when the TARGET pond already has a different
   *    device bound (one device per pond).
   *
   * A device therefore always has at most one pond (single nullable column),
   * and a pond at most one device (checked here).
   */
  async assignDeviceToPond(
    deviceId: string,
    pondId: string,
  ): Promise<DeviceEntity> {
    // Validate device exists
    const device = await this.deviceRepo.findOne({
      where: { id: deviceId },
      relations: { pond: true },
    });
    if (!device) {
      throw new NotFoundException(`Device ${deviceId} not found`);
    }

    // Validate pond exists and is not completed
    const pond = await this.pondRepo.findOne({ where: { id: pondId } });
    if (!pond) {
      throw new NotFoundException(`Pond ${pondId} not found`);
    }
    const pondStatus = (pond.status || 'active').toLowerCase();
    if (pondStatus === 'done' || pondStatus === 'completed' || pondStatus === 'finished') {
      throw new BadRequestException(
        `Cannot assign device to a completed pond. Please create a new pond or reactivate this one.`,
      );
    }

    // One device per pond: reject when the target pond already has a
    // DIFFERENT device bound to it.
    const existingDevice = await this.deviceRepo.findOne({
      where: { pondId },
      relations: { pond: true },
    });
    if (existingDevice && existingDevice.id !== device.id) {
      throw new ConflictException(
        `Pond ${pond.name} already has device ${existingDevice.deviceCode} assigned. Complete that pond or release the device before assigning a new one.`,
      );
    }

    // Remember what (if anything) the device was bound to so we can log the
    // move. The old binding is cleared atomically with the new one below.
    const previousPondId = device.pondId;

    // Atomically clear the old assignment and bind the new pond.
    //
    // NOTE: a plain `save(device)` is NOT enough here. The entity was loaded
    // with the `pond` relation, and TypeORM's change-diff then trusts the
    // loaded relation object over a mutated `pondId` column — the UPDATE
    // would silently skip pond_id and the device would keep polling the old
    // pond's schedules. A targeted update() writes exactly what we mean.
    const saved = await this.deviceRepo.manager.transaction(async (em) => {
      const repo = em.getRepository(DeviceEntity);
      await repo.update(deviceId, {
        pondId,
        status: 'ASSIGNED',
        assignedAt: new Date(),
        releasedAt: null,
      });
      return repo.findOne({ where: { id: deviceId }, relations: { pond: true } });
    });
    if (!saved) {
      // The device existed at validation time; a null here would be a
      // concurrent delete — surface it instead of writing blind data.
      throw new NotFoundException(`Device ${deviceId} not found`);
    }

    if (previousPondId && previousPondId !== pondId) {
      this.logger.log(
        `Device ${saved.deviceCode} moved from pond ${previousPondId} to pond ${pond.name} (${pondId})`,
      );
    } else {
      this.logger.log(
        `Device ${saved.deviceCode} assigned to pond ${pond.name} (status: ASSIGNED)`,
      );
    }

    // Push new configuration to the ESP32 so it knows which pond it now
    // belongs to and starts polling that pond's schedules.
    if (this.deviceGateway) {
      this.deviceGateway.sendDeviceConfig(saved.deviceCode, {
        hardware_id: saved.deviceCode,
        pond_id: pondId,
        status: 'ACTIVE',
      });
    }

    return saved;
  }

  /**
   * Release a device from its current pond (when pond is completed).
   * Sets device status to AVAILABLE and clears pond assignment.
   *
   * Uses a targeted update() — like assignDeviceToPond, a plain save() on a
   * relation-loaded entity lets TypeORM's diff ignore the pondId change.
   */
  async releaseDeviceFromPond(deviceId: string): Promise<DeviceEntity> {
    const device = await this.findById(deviceId);

    if (device.pondId === null) {
      // Already released — idempotent
      return device;
    }

    const previousPondId = device.pondId;

    await this.deviceRepo.update(deviceId, {
      pondId: null,
      status: 'AVAILABLE',
      releasedAt: new Date(),
    });

    this.logger.log(
      `Device ${device.deviceCode} released from pond ${previousPondId} (now AVAILABLE)`,
    );
    return this.findById(deviceId);
  }

  /**
   * Find the device currently assigned to a pond.
   */
  async findDeviceByPondId(pondId: string): Promise<DeviceEntity | null> {
    return this.deviceRepo.findOne({
      where: { pondId, status: In(['ASSIGNED', 'ACTIVE'] as DeviceStatus[]) },
    });
  }

  /**
   * Mark a device as ACTIVE (confirmed operating with its pond).
   * Called when the ESP32 acknowledges the new configuration.
   */
  async activateDevice(deviceId: string): Promise<DeviceEntity> {
    const device = await this.findById(deviceId);
    if (device.status !== 'ASSIGNED') {
      throw new BadRequestException(
        `Device must be in ASSIGNED state to activate. Current state: ${device.status}`,
      );
    }
    device.status = 'ACTIVE';
    const saved = await this.deviceRepo.save(device);
    this.logger.log(`Device ${saved.deviceCode} is now ACTIVE`);
    return saved;
  }

  /**
   * Update device status (for offline/maintenance transitions).
   */
  async updateStatus(deviceId: string, status: DeviceStatus): Promise<DeviceEntity> {
    const device = await this.findById(deviceId);
    device.status = status;
    return this.deviceRepo.save(device);
  }
}
