import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DeviceEntity } from './entities/device.entity';
import { SensorDataEntity } from './entities/sensor-data.entity';
import { CreateDeviceDto } from './dto/create-device.dto';
import { CreateSensorDataDto } from './dto/create-sensor-data.dto';

@Injectable()
export class SensorsService {
  constructor(
    @InjectRepository(DeviceEntity)
    private readonly deviceRepository: Repository<DeviceEntity>,
    @InjectRepository(SensorDataEntity)
    private readonly sensorDataRepository: Repository<SensorDataEntity>,
  ) {}

  async createDevice(createDeviceDto: CreateDeviceDto): Promise<DeviceEntity> {
    const device = this.deviceRepository.create(createDeviceDto);
    return this.deviceRepository.save(device);
  }

  async findAllDevices(): Promise<DeviceEntity[]> {
    return this.deviceRepository.find({ relations: { pond: true } });
  }

  async findDevice(id: string): Promise<DeviceEntity> {
    const device = await this.deviceRepository.findOne({ where: { id }, relations: { pond: true } });
    if (!device) {
      throw new NotFoundException('Device not found');
    }
    return device;
  }

  async createSensorData(createSensorDataDto: CreateSensorDataDto): Promise<SensorDataEntity> {
    if (!createSensorDataDto.deviceId.trim()) {
      throw new BadRequestException('deviceId is required');
    }
    const sensorData = this.sensorDataRepository.create({
      deviceId: createSensorDataDto.deviceId,
      temperature: createSensorDataDto.temperature,
      ph: createSensorDataDto.ph,
      dissolvedOxygen: createSensorDataDto.dissolvedOxygen,
      weightGrams: createSensorDataDto.weightGrams,
      feeding: createSensorDataDto.feeding,
      feedGramsDispensed: createSensorDataDto.feedGramsDispensed,
      remainingStockGrams: createSensorDataDto.remainingStockGrams,
      lowStock: createSensorDataDto.lowStock,
      ...(createSensorDataDto.timestamp == null
          ? {}
          : { createdAt: new Date(createSensorDataDto.timestamp) }),
    });
    return this.sensorDataRepository.save(sensorData);
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
    const sensorData = await this.sensorDataRepository.findOne({ where: { id } });
    if (!sensorData) {
      throw new NotFoundException('Sensor data not found');
    }
    return sensorData;
  }
}
