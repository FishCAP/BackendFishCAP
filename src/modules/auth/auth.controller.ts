import {
  Body,
  Controller,
  Post,
  HttpCode,
  HttpStatus,
  BadRequestException,
  UnauthorizedException,
  Res,
  Req,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { OtpService } from './otp.service';
import { UsersService } from '../users/users.service';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly otpService: OtpService,
    private readonly usersService: UsersService,
  ) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() body: { email?: string; username?: string; password: string }) {
    const identifier = body.email?.trim() || body.username?.trim() || '';
    const user = await this.authService.validateUser(identifier, body.password);
    const signed = this.authService.signUser({ id: user.id, email: user.email });
    return { success: true, data: { ...signed, fullName: user.fullName } };
  }



  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(
    @Body() body: { fullName: string; email: string; password?: string; phone?: string },
  ) {
    const user = await this.authService.register(body);
    return {
      success: true,
      data: user,
    };
  }

  @Post('request-otp')
  @HttpCode(HttpStatus.OK)
  async requestOtp(@Body() body: { email: string }) {
    if (!body.email?.trim()) {
      throw new BadRequestException('Email is required');
    }

    // In production, send the OTP via email/SMS, not in the response
    await this.otpService.createOtp(body.email);
    return {
      success: true,
      data: { message: 'OTP sent successfully' },
    };
  }

  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  async verifyOtp(
    @Body()
    body: {
      email: string;
      code: string;
      fullName?: string;
      phone?: string;
      password?: string;
    },
  ) {
    const ok = await this.otpService.verifyOtp(body.email, body.code);
    if (!ok) {
      throw new BadRequestException('Invalid or expired OTP');
    }

    let userEntity = await this.usersService.findByEmail(body.email);

    if (!userEntity) {
      // Use authService.register to create the user with optional password
      const created = await this.authService.register({
        fullName: body.fullName ?? 'New User',
        email: body.email,
        password: body.password, // may be undefined for passwordless OTP
        phone: body.phone,
      });

      return {
        success: true,
        data: created,
      };
    }

    const signed = this.authService.signUser({
      id: userEntity.id,
      email: userEntity.email,
    });

    return {
      success: true,
      data: { ...signed, fullName: userEntity.fullName },
    };
  }
}
