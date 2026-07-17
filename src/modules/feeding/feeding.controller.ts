import { Body, Controller, Delete, Get, Param, Patch, Post } from '@nestjs/common';
import { FeedingService } from './feeding.service';
import { CreateFeedScheduleDto } from './dto/create-feed-schedule.dto';
import { UpdateFeedScheduleDto } from './dto/update-feed-schedule.dto';
import { CreateFeedingLogDto } from './dto/create-feeding-log.dto';

@Controller('feeding')
export class FeedingController {
  constructor(private readonly feedingService: FeedingService) {}

  @Post('schedules')
  createSchedule(@Body() createFeedScheduleDto: CreateFeedScheduleDto) {
    return this.feedingService.createSchedule(createFeedScheduleDto);
  }

  @Get('schedules')
  findAllSchedules() {
    return this.feedingService.findAllSchedules();
  }

  @Get('schedules/:id')
  findSchedule(@Param('id') id: string) {
    return this.feedingService.findSchedule(id);
  }

  @Patch('schedules/:id')
  updateSchedule(@Param('id') id: string, @Body() updateFeedScheduleDto: UpdateFeedScheduleDto) {
    return this.feedingService.updateSchedule(id, updateFeedScheduleDto);
  }

  @Delete('schedules/:id')
  removeSchedule(@Param('id') id: string) {
    return this.feedingService.removeSchedule(id);
  }

  @Post('logs')
  createLog(@Body() createFeedingLogDto: CreateFeedingLogDto) {
    return this.feedingService.createLog(createFeedingLogDto);
  }

  @Get('logs')
  findAllLogs() {
    return this.feedingService.findAllLogs();
  }

  @Get('logs/:id')
  findLog(@Param('id') id: string) {
    return this.feedingService.findLog(id);
  }
}
