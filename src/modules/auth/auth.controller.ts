import {
  Body,
  Controller,
  Post,
  HttpCode,
  HttpStatus,
  BadRequestException,
  UnauthorizedException,
  NotFoundException,
  Res,
  Req,
  Logger,
} from '@nestjs/common';
import { ServiceUnavailableException } from '@nestjs/common';
import { MailService } from '../mail/mail.service';
import { AuthService } from './auth.service';
import { OtpService } from './otp.service';
import { UsersService } from '../users/users.service';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { ForgotPasswordDto } from './dto/forget-password.dto';

@Controller('auth')
export class AuthController {
  private readonly logger = new Logger(AuthController.name);

  constructor(
    private readonly authService: AuthService,
    private readonly otpService: OtpService,
    private readonly usersService: UsersService,
    private readonly mailService: MailService,
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

    const email = body.email.trim();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      throw new BadRequestException('Please provide a valid email address');
    }
    const otp = await this.otpService.createOtp(email);
    try {
      await this.mailService.sendVerificationCode(email, otp.code);
    } catch (error) {
      // Log the real cause (missing SMTP_HOST vs. auth failure vs. timeout)
      // so the Render Logs tab pinpoints the misconfiguration; the client
      // only sees the generic 503.
      this.logger.error(
        `request-otp: could not send verification email to ${email}: ${
          error instanceof Error ? error.message : String(error)
        }`,
      );
      throw new ServiceUnavailableException('Could not send verification email. Please try again later.');
    }
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

  /// Password reset for a forgotten password ("Forgot Password?" on login).
  ///
  /// Ownership is proven with the 6-digit code from `request-otp` instead of
  /// the current password. Verifying the code consumes it, so a wrong or
  /// expired code never changes anything. No session is issued: the caller
  /// signs in normally with the new password afterwards.
  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  async resetPassword(
    @Body() body: { email: string; code: string; password: string },
  ) {
    if (!body.email?.trim()) {
      throw new BadRequestException('Email is required');
    }

    if (!body.code?.trim()) {
      throw new BadRequestException('Verification code is required');
    }

    // Same rule as register(): a reset must not weaken the password policy.
    if (!body.password || body.password.length < 8) {
      throw new BadRequestException('Password must be at least 8 characters long');
    }

    const ok = await this.otpService.verifyOtp(body.email, body.code);
    if (!ok) {
      throw new BadRequestException('Invalid or expired OTP');
    }

    const userEntity = await this.usersService.findByEmail(body.email);
    if (!userEntity) {
      throw new NotFoundException('User not found');
    }

    // UsersService hashes the new password before persisting it.
    await this.usersService.update(userEntity.id, { password: body.password });

    return {
      success: true,
      data: { message: 'Password reset successfully' },
    };
  }

  /// Token-based password reset (standard "Forgot Password" flow).
  /// Step 1: call forgotPassword to receive a reset link via email.
  /// Step 2: click the link and call resetPassword with the token.
  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  async forgotPassword(@Body() body: ForgotPasswordDto) {
    if (!body.email?.trim()) {
      throw new BadRequestException('Email is required');
    }
    const result = await this.authService.forgotPassword(body.email.trim());
    return result;
  }

  @Post('reset-password-token')
  @HttpCode(HttpStatus.OK)
  async resetPasswordToken(@Body() body: ResetPasswordDto) {
    if (!body.token?.trim()) {
      throw new BadRequestException('Reset token is required');
    }
    if (!body.newPassword || body.newPassword.length < 8) {
      throw new BadRequestException('Password must be at least 8 characters long');
    }
    const result = await this.authService.resetPassword(body.token.trim(), body.newPassword);
    return result;
  }

  /// Logout endpoint (clears JWT - frontend expects this at /api/auth/logout).
  /// Note: JWT is stateless, so "logout" here is primarily for frontend consistency.
  /// The actual token invalidation happens on the client side by clearing the token.
  @Post('logout')
  @HttpCode(HttpStatus.OK)
  async logout() {
    // JWT is stateless - no server-side invalidation needed.
    // The frontend clears the token locally after this call.
    return { success: true, data: { message: 'Logged out successfully' } };
  }
}
