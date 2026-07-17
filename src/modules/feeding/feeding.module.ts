import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FeedingController } from './feeding.controller';
import { FeedingService } from './feeding.service';
import { FeedScheduleEntity } from './entities/feed-schedule.entity';
import { FeedingLogEntity } from './entities/feeding-log.entity';
import { PondEntity } from '../ponds/entities/pond.entity/pond.entity';

@Module({
  imports: [TypeOrmModule.forFeature([FeedScheduleEntity, FeedingLogEntity, PondEntity])],
  controllers: [FeedingController],
  providers: [FeedingService],
})
export class FeedingModule {}
