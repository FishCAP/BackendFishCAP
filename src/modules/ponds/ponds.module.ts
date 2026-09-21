import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PondsController } from './ponds.controller';
import { PondsService } from './ponds.service';
import { PondEntity } from './entities/pond.entity/pond.entity';
import { UserEntity } from '../users/entities/user.entity';
import { DeviceEntity } from '../sensors/entities/device.entity';
import { FeedScheduleEntity } from '../feeding/entities/feed-schedule.entity';
import { FeedingLogEntity } from '../feeding/entities/feeding-log.entity';
import { FishSpeciesEntity } from '../feeding/entities/fish-species.entity';
import { SensorDataEntity } from '../sensors/entities/sensor-data.entity';
import { DevicesModule } from '../devices/device.module';
import { DevicesService } from '../devices/devices.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      PondEntity,
      UserEntity,
      DeviceEntity,
      FeedScheduleEntity,
      FeedingLogEntity,
      FishSpeciesEntity,
      SensorDataEntity,
    ]),
    DevicesModule,
  ],
  controllers: [PondsController],
  providers: [PondsService, DevicesService],
  exports: [PondsService, DevicesService],
})
export class PondsModule {}
