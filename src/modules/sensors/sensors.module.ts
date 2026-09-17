import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SensorsController } from './sensors.controller';
import { SensorIngestController } from './sensor-ingest.controller';
import { SensorsService } from './sensors.service';
import { DeviceEntity } from './entities/device.entity';
import { SensorDataEntity } from './entities/sensor-data.entity';
import { PondEntity } from '../ponds/entities/pond.entity/pond.entity';
import { DevicesModule } from '../devices/device.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([DeviceEntity, SensorDataEntity, PondEntity]),
    DevicesModule,
    NotificationsModule,
  ],
  controllers: [SensorsController, SensorIngestController],
  providers: [SensorsService],
})
export class SensorsModule {}
