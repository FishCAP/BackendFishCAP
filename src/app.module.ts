import { Module } from '@nestjs/common';

import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule as NestConfigModule, ConfigService } from '@nestjs/config';
// import { ConfigModule } from './config/config.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './modules/users/users.module';
import { PondsModule } from './modules/ponds/ponds.module';
import { CommonModule } from './common/common.module';
import { ConfigModule } from './config/config.module';
import { ModulesModule } from './modules/modules.module';
// import { ConfigService } from '@nestjs/config';

@Module({
  imports: [
    NestConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',

        host: config.get<string>('DATABASE_HOST'),
        port: config.get<number>('DATABASE_PORT'),

        username: config.get<string>('DATABASE_USERNAME'),
        password: config.get<string>('DATABASE_PASSWORD'),
        database: config.get<string>('DATABASE_NAME'),

        schema: 'public',

        autoLoadEntities: true,
        synchronize: false,
      }),
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
