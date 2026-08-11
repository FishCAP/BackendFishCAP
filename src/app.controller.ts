import { Body, Controller, Get, Headers, Post } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello() {
    return this.appService.getHello();
  }

  @Get('health')
  getHealth() {
    return this.appService.getHealth();
  }

  @Post('auth/login')
  login(@Body() body: { username?: string; email?: string; password: string }): any {
    return this.appService.login(body);
  }

  @Post('auth/register')
  register(@Body() body: { fullName?: string; email?: string; username?: string; phoneNumber?: string; password?: string }): any {
    return this.appService.register(body);
  }

  @Get('users/me')
  getCurrentUser(@Headers('authorization') authorization?: string): any {
    return this.appService.getCurrentUser(authorization);
  }

  @Get('water-quality')
  getWaterQuality(): any {
    return this.appService.getWaterQuality();
  }

  @Get('schedules')
  getSchedules(): any {
    return this.appService.getSchedules();
  }

  @Get('history')
  getHistory(): any {
    return this.appService.getHistory();
  }

  @Get('notifications')
  getNotifications(): any {
    return this.appService.getNotifications();
  }
}
