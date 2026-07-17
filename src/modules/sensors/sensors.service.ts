import { Injectable, NotFoundException } from '@nestjs/common';
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
    return this.deviceRepository.find({ relations: { pond: true, sensorData: true } });
  }

  async findDevice(id: string): Promise<DeviceEntity> {
    const device = await this.deviceRepository.findOne({ where: { id }, relations: { pond: true, sensorData: true } });
    if (!device) {
      throw new NotFoundException('Device not found');
    }
    return device;
  }

  async createSensorData(createSensorDataDto: CreateSensorDataDto): Promise<SensorDataEntity> {
    const sensorData = this.sensorDataRepository.create(createSensorDataDto);
    return this.sensorDataRepository.save(sensorData);
  }

  async findAllSensorData(): Promise<SensorDataEntity[]> {
    return this.sensorDataRepository.find({ relations: { device: true } });
  }

  async findSensorData(id: string): Promise<SensorDataEntity> {
    const sensorData = await this.sensorDataRepository.findOne({ where: { id }, relations: { device: true } });
    if (!sensorData) {
      throw new NotFoundException('Sensor data not found');
    }
    return sensorData;
  }
}
