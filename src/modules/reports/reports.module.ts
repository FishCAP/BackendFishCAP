import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';
import { PondEntity } from '../ponds/entities/pond.entity/pond.entity';
import { FeedingLogEntity } from '../feeding/entities/feeding-log.entity';
import { SensorDataEntity } from '../sensors/entities/sensor-data.entity';
import { NotificationEntity } from '../notifications/entities/notification.entity/notification.entity';
import { UserEntity } from '../users/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      PondEntity,
      FeedingLogEntity,
      SensorDataEntity,
      NotificationEntity,
      UserEntity,
    ]),
  ],
  controllers: [ReportsController],
  providers: [ReportsService],
})
export class ReportsModule {}
