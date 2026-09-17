import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DeviceGateway } from './device.gateway';
import { DevicesController } from './devices.controller';
import { DevicesService } from './devices.service';
import { DeviceEntity } from '../sensors/entities/device.entity';
import { PondEntity } from '../ponds/entities/pond.entity/pond.entity';
import { FeedScheduleEntity } from '../feeding/entities/feed-schedule.entity';

@Module({
  imports: [TypeOrmModule.forFeature([DeviceEntity, PondEntity, FeedScheduleEntity])],
  providers: [DeviceGateway, DevicesService],
  controllers: [DevicesController],
  exports: [DeviceGateway, DevicesService],
})
export class DevicesModule {}
