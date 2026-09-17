import { Module } from '@nestjs/common';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './modules/users/users.module';
import { PondsModule } from './modules/ponds/ponds.module';
import { CommonModule } from './common/common.module';
import { ConfigModule } from './config/config.module';
import { ModulesModule } from './modules/modules.module';
import { DatabaseModule } from './database/database.module';
import { AuthModule } from './modules/auth/auth.module';
import { SensorsModule } from './modules/sensors/sensors.module';
import { DevicesModule } from './modules/devices/device.module';

@Module({
  imports: [
    ConfigModule,
    DatabaseModule,
    UsersModule,
    AuthModule,
    PondsModule,
    DevicesModule,
    CommonModule,
    ModulesModule,
    SensorsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
