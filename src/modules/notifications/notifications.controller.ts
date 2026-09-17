import { Body, Controller, Delete, Get, Param, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { NotificationsService } from './notifications.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  findAll(@Req() req) {
    const userId = req.user?.id;
    return this.notificationsService.findAll(userId);
  }

  @UseGuards(JwtAuthGuard)
  @Patch('mark-all-read')
  markAllRead(@Req() req) {
    const userId = req.user?.id;
    return this.notificationsService.markAllRead(userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id')
  findOne(@Req() req, @Param('id') id: string) {
    const userId = req.user?.id;
    return this.notificationsService.findOne(id, userId);
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  update(@Req() req, @Param('id') id: string, @Body() updateNotificationDto: UpdateNotificationDto) {
    const userId = req.user?.id;
    return this.notificationsService.update(id, updateNotificationDto, userId);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  remove(@Req() req, @Param('id') id: string) {
    const userId = req.user?.id;
    return this.notificationsService.remove(id, userId);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@Req() req, @Body() createNotificationDto: CreateNotificationDto) {
    // Ensure the notification is created for the authenticated user only
    const userId = req.user?.id;
    const payload = { ...createNotificationDto, userId };
    return this.notificationsService.create(payload as CreateNotificationDto);
  }
}
