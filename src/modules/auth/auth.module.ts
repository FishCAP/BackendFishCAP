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
      signOptions: { expiresIn: '24h' },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, OtpService],
  exports: [AuthService],
})
export class AuthModule {}
