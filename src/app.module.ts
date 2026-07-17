import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './modules/users/users.module';
import { PondsModule } from './modules/ponds/ponds.module';
import { CommonModule } from './common/common.module';
import { ConfigModule } from './config/config.module';
import { ModulesModule } from './modules/modules.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: 'localhost',
      port: 5432,
      username: 'fishcap_user',
      password: 'fishcap123',
      database: 'fishcap_db',
      schema: 'public',
      autoLoadEntities: true,
      synchronize: false,
    }),
    UsersModule,
    PondsModule,
    CommonModule,
    ConfigModule,
    ModulesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
