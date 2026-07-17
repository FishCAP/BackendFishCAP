import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SensorsController } from './sensors.controller';
import { SensorsService } from './sensors.service';
import { DeviceEntity } from './entities/device.entity';
import { SensorDataEntity } from './entities/sensor-data.entity';
import { PondEntity } from '../ponds/entities/pond.entity/pond.entity';

@Module({
  imports: [TypeOrmModule.forFeature([DeviceEntity, SensorDataEntity, PondEntity])],
  controllers: [SensorsController],
  providers: [SensorsService],
})
export class SensorsModule {}
