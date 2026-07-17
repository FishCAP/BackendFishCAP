import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FeedScheduleEntity } from './entities/feed-schedule.entity';
import { FeedingLogEntity } from './entities/feeding-log.entity';
import { CreateFeedScheduleDto } from './dto/create-feed-schedule.dto';
import { UpdateFeedScheduleDto } from './dto/update-feed-schedule.dto';
import { CreateFeedingLogDto } from './dto/create-feeding-log.dto';

@Injectable()
export class FeedingService {
  constructor(
    @InjectRepository(FeedScheduleEntity)
    private readonly feedScheduleRepository: Repository<FeedScheduleEntity>,
    @InjectRepository(FeedingLogEntity)
    private readonly feedingLogRepository: Repository<FeedingLogEntity>,
  ) {}

  async createSchedule(createFeedScheduleDto: CreateFeedScheduleDto): Promise<FeedScheduleEntity> {
    const schedule = this.feedScheduleRepository.create(createFeedScheduleDto);
    return this.feedScheduleRepository.save(schedule);
  }

  async findAllSchedules(): Promise<FeedScheduleEntity[]> {
    return this.feedScheduleRepository.find({ relations: { pond: true, logs: true } });
  }

  async findSchedule(id: string): Promise<FeedScheduleEntity> {
    const schedule = await this.feedScheduleRepository.findOne({ where: { id }, relations: { pond: true, logs: true } });
    if (!schedule) {
      throw new NotFoundException('Feed schedule not found');
    }
    return schedule;
  }

  async updateSchedule(id: string, updateFeedScheduleDto: UpdateFeedScheduleDto): Promise<FeedScheduleEntity> {
    const schedule = await this.findSchedule(id);
    const updated = { ...schedule, ...updateFeedScheduleDto };
    await this.feedScheduleRepository.save(updated);
    return this.findSchedule(id);
  }

  async removeSchedule(id: string): Promise<void> {
    const result = await this.feedScheduleRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Feed schedule not found');
    }
  }

  async createLog(createFeedingLogDto: CreateFeedingLogDto): Promise<FeedingLogEntity> {
    const log = this.feedingLogRepository.create(createFeedingLogDto);
    return this.feedingLogRepository.save(log);
  }

  async findAllLogs(): Promise<FeedingLogEntity[]> {
    return this.feedingLogRepository.find({ relations: { pond: true, schedule: true } });
  }

  async findLog(id: string): Promise<FeedingLogEntity> {
    const log = await this.feedingLogRepository.findOne({ where: { id }, relations: { pond: true, schedule: true } });
    if (!log) {
      throw new NotFoundException('Feeding log not found');
    }
    return log;
  }
}
