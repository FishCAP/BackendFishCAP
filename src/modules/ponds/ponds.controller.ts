import {
  Body,
  Controller,
  Delete,
  Get,
  NotFoundException,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { PondsService } from './ponds.service';
import { CreatePondDto } from './dto/create-pond.dto';
import { UpdatePondDto } from './dto/update-pond.dto';
import { AddFeedScheduleDto } from './dto/add-feed-schedule.dto';

@Controller('ponds')
@UseGuards(JwtAuthGuard)
export class PondsController {
  constructor(private readonly pondsService: PondsService) {}

  @Post()
  async create(@Req() req, @Body() createPondDto: CreatePondDto) {
    // JwtStrategy.validate() returns { id, email } — use req.user.id consistently.
    const userId = req.user.id;
    const pond = await this.pondsService.create(createPondDto, userId);
    return { success: true, data: pond };
  }

  @Get()
  async findAll(@Req() req) {
    const userId = req.user.id;
    const ponds = await this.pondsService.findAll(userId);
    return { success: true, data: ponds };
  }

  @Get(':id')
  async findOne(@Req() req, @Param('id') id: string) {
    const userId = req.user.id;
    const pond = await this.pondsService.findOne(id, userId);
    return { success: true, data: pond };
  }

  // "Add New Time" button on the pond detail page.
  @Post(':id/feed-schedules')
  async addFeedSchedule(
    @Req() req,
    @Param('id') id: string,
    @Body() dto: AddFeedScheduleDto,
  ) {
    const userId = req.user.id;
    const schedule = await this.pondsService.addFeedSchedule(id, userId, dto);
    return { success: true, data: schedule };
  }

  @Patch(':id')
  async update(
    @Req() req,
    @Param('id') id: string,
    @Body() updatePondDto: UpdatePondDto,
  ) {
    const userId = req.user.id;
    const pond = await this.pondsService.update(id, updatePondDto, userId);
    return { success: true, data: pond };
  }

  @Delete(':id')
  async remove(@Req() req, @Param('id') id: string) {
    const userId = req.user.id;
    await this.pondsService.remove(id, userId);
    return { success: true, message: 'Pond deleted' };
  }
}