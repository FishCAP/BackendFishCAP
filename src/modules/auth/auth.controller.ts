import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  async login(@Body() body: { email?: string; username?: string; password: string }) {
    const identifier = body.email?.trim() || body.username?.trim() || '';
    return this.authService.validateUser(identifier, body.password);
  }
}
