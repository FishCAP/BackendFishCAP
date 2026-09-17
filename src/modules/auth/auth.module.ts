import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { UsersModule } from '../users/users.module';
import { UserEntity } from '../users/entities/user.entity';
import { OtpEntity } from './entities/otp.entity';
import { OtpService } from './otp.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([UserEntity, OtpEntity]),
    UsersModule,
    JwtModule.register({
      // Must match the fallback in jwt.strategy.ts (and the value passed by
      // docker-compose.yml) so signing and verification never diverge.
      secret:
        process.env.JWT_SECRET || 'your-secret-key-change-this-in-production',
      // Session length. docker-compose.yml sets JWT_EXPIRES_IN=7d: a 24h
      // lifetime made every app session expire overnight, and the only
      // symptom was a raw 401 on the next day's pond fetch.
      signOptions: {
        expiresIn: (process.env.JWT_EXPIRES_IN || '7d') as any,
      },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, OtpService],
  exports: [AuthService],
})
export class AuthModule {}
