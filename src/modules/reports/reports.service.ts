import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PondEntity } from '../ponds/entities/pond.entity/pond.entity';
import { FeedingLogEntity } from '../feeding/entities/feeding-log.entity';
import { SensorDataEntity } from '../sensors/entities/sensor-data.entity';

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(PondEntity)
    private readonly pondRepository: Repository<PondEntity>,
    @InjectRepository(FeedingLogEntity)
    private readonly feedingLogRepository: Repository<FeedingLogEntity>,
    @InjectRepository(SensorDataEntity)
    private readonly sensorDataRepository: Repository<SensorDataEntity>,
  ) {}

  async getSummary() {
    const pondCount = await this.pondRepository.count();
    const feedLogCount = await this.feedingLogRepository.count();
    const latestSensor = await this.sensorDataRepository.find({
      order: { recordedAt: 'DESC' },
      take: 1,
    });

    return {
      pondCount,
      feedLogCount,
      latestSensor: latestSensor[0] ?? null,
    };
  }
}
