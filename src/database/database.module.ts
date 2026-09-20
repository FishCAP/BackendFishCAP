import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const databaseUrl = configService.get<string>('DATABASE_URL');

        // Schema auto-sync is opt-in (DB_SYNCHRONIZE=true) for a one-shot
        // bootstrap of a FRESH database from the TypeORM entities. It must
        // stay unset/false in production (Render, docker-compose) so the
        // schema only ever changes deliberately.
        const synchronize =
          configService.get<string>('DB_SYNCHRONIZE') === 'true';

        // If you set DATABASE_URL on Render
        if (databaseUrl) {
          return {
            type: 'postgres',
            url: databaseUrl,
            autoLoadEntities: true,
            synchronize,
            ssl: { rejectUnauthorized: false },
          };
        }

        const host = configService.get<string>('DATABASE_HOST');

        // Fail fast with an actionable message instead of silently falling
        // back to localhost, which shows up on Render as
        // "AggregateError [ECONNREFUSED]" (nothing is listening on 127.0.0.1).
        if (!host) {
          throw new Error(
            'Database is not configured. Set DATABASE_URL in your Render ' +
              'environment variables (recommended), or set all of ' +
              'DATABASE_HOST / DATABASE_USER / DATABASE_PASSWORD / DATABASE_NAME. ' +
              'Note: the .env file is NOT deployed (it is in .dockerignore and ' +
              '.gitignore), so variables must be defined in the Render dashboard.',
          );
        }

        // If you set individual environment variables on Render
        return {
          type: 'postgres',
          host,
          port: configService.get<number>('DATABASE_PORT', 5432),
          username: configService.get<string>('DATABASE_USER'),
          password: configService.get<string>('DATABASE_PASSWORD'),
          database: configService.get<string>('DATABASE_NAME'),
          autoLoadEntities: true,
          synchronize,
          ssl: { rejectUnauthorized: false },
        };
      },
    }),
  ],
  exports: [TypeOrmModule],
})
export class DatabaseModule {}