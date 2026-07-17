import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { SensorsModule } from './sensors/sensors.module';
import { FeedingModule } from './feeding/feeding.module';
import { NotificationsModule } from './notifications/notifications.module';
import { ReportsModule } from './reports/reports.module';

@Module({
  imports: [AuthModule, SensorsModule, FeedingModule, NotificationsModule, ReportsModule]
})
export class ModulesModule {}
