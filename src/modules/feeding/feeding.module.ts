import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FeedingController } from './feeding.controller';
import { FeedingLogsIngestController } from './feeding.controller';
import { FeedingService } from './feeding.service';
import { FeedScheduleEntity } from './entities/feed-schedule.entity';
import { FeedingLogEntity } from './entities/feeding-log.entity';
import { PondEntity } from '../ponds/entities/pond.entity/pond.entity';
import { FishSpeciesEntity } from './entities/fish-species.entity';
import { BatchEntity } from './entities/batch.entity';
import { FeedCalculationEntity } from './entities/feed-calculation.entity';
import { DeviceEntity } from '../sensors/entities/device.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      FeedScheduleEntity,
      FeedingLogEntity,
      PondEntity,
      FishSpeciesEntity,
      BatchEntity,
      FeedCalculationEntity,
      DeviceEntity,
    ]),
  ],
  controllers: [FeedingController, FeedingLogsIngestController],
  providers: [FeedingService],
  exports: [FeedingService],
})
export class FeedingModule {}
