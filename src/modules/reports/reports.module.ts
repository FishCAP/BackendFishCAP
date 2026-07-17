import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';
import { PondEntity } from '../ponds/entities/pond.entity/pond.entity';
import { FeedingLogEntity } from '../feeding/entities/feeding-log.entity';
import { SensorDataEntity } from '../sensors/entities/sensor-data.entity';

@Module({
  imports: [TypeOrmModule.forFeature([PondEntity, FeedingLogEntity, SensorDataEntity])],
  controllers: [ReportsController],
  providers: [ReportsService],
})
export class ReportsModule {}
