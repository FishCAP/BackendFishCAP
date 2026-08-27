import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PondsController } from './ponds.controller';
import { PondsService } from './ponds.service';
import { PondEntity } from './entities/pond.entity/pond.entity';
import { UserEntity } from '../users/entities/user.entity';
import { DeviceEntity } from '../sensors/entities/device.entity';
import { FeedScheduleEntity } from '../feeding/entities/feed-schedule.entity';
import { SensorDataEntity } from '../sensors/entities/sensor-data.entity';

@Module({
  imports: [TypeOrmModule.forFeature([PondEntity, UserEntity, DeviceEntity, FeedScheduleEntity, SensorDataEntity])],
  controllers: [PondsController],
  providers: [PondsService],
})
export class PondsModule {}
