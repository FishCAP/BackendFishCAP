import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FeedScheduleEntity } from './entities/feed-schedule.entity';
import { FeedingLogEntity } from './entities/feeding-log.entity';
import { CreateFeedScheduleDto } from './dto/create-feed-schedule.dto';
import { UpdateFeedScheduleDto } from './dto/update-feed-schedule.dto';
import { CreateFeedingLogDto } from './dto/create-feeding-log.dto';
import { FishSpeciesEntity } from './entities/fish-species.entity';
import { BatchEntity } from './entities/batch.entity';
import { FeedCalculationEntity } from './entities/feed-calculation.entity';
import { normalizeFishSpecies, SpeciesId } from './utils/normalize-fish-species';

@Injectable()
export class FeedingService {
  constructor(
    @InjectRepository(FeedScheduleEntity)
    private readonly feedScheduleRepository: Repository<FeedScheduleEntity>,
    @InjectRepository(FeedingLogEntity)
    private readonly feedingLogRepository: Repository<FeedingLogEntity>,
    @InjectRepository(FishSpeciesEntity)
    private readonly fishSpeciesRepository: Repository<FishSpeciesEntity>,
    @InjectRepository(BatchEntity)
    private readonly batchRepository: Repository<BatchEntity>,
    @InjectRepository(FeedCalculationEntity)
    private readonly feedCalculationRepository: Repository<FeedCalculationEntity>,
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

  /** Return feeding logs grouped by date (dd-MM-yyyy). Optional pondId filters rows. */
  async getLogsGrouped(pondId?: string): Promise<Record<string, any>> {
    const where = pondId ? { pondId } : {};
    const rows = await this.feedingLogRepository.find({ where, order: { fedAt: 'DESC' } });
    const grouped: Record<string, any[]> = {};
    for (const r of rows) {
      const dt = r.fedAt instanceof Date ? r.fedAt : new Date(r.fedAt);
      const key = `${String(dt.getDate()).padStart(2, '0')}-${String(dt.getMonth() + 1).padStart(2, '0')}-${dt.getFullYear()}`;
      grouped[key] = grouped[key] || [];
      grouped[key].push({
        id: r.id,
        pondId: r.pondId,
        scheduleId: r.scheduleId,
        feedAmount: Number(r.feedAmount || 0),
        fedAt: r.fedAt,
      });
    }
    return grouped;
  }

  // Search species by Khmer or English query
  async searchSpecies(query: string): Promise<FishSpeciesEntity[]> {
    if (!query) return [];
    const normalized = query.trim();
    const all = await this.fishSpeciesRepository.find();
    const q = normalized.toLowerCase();
    return all.filter((s) => {
      const aliases = (s.aliases || []).map((a) => String(a).toLowerCase());
      return (
        s.nameEn.toLowerCase().includes(q) ||
        s.nameKm.toLowerCase().includes(q) ||
        aliases.some((a) => a.includes(q))
      );
    });
  }

  // Calculate daily feed for a batch on a target date
  async calculateDailyFeed(batchId: string, targetDate: string | Date, language: 'km' | 'en' = 'km') {
    const batch = await this.batchRepository.findOne({ where: { id: batchId }, relations: { species: true } });
    if (!batch) throw new NotFoundException('Batch not found');
    const species = batch.species;
    if (!species) throw new NotFoundException('Species not found for batch');

    const stockingDate = new Date(batch.stockingDate);
    const tDate = new Date(targetDate);
    const days = Math.max(0, Math.floor((tDate.getTime() - stockingDate.getTime()) / (1000 * 60 * 60 * 24)));

    const initialWeight = batch.initialWeight || species.defaultInitialWeight || 5; // grams
    // Simple growth: use ADG from nearest growth stage or fallback to 1 g/day
    let adg = 1;
    let feedingRatePercent = 3; // default percent of body weight
    if (species.growthStages && Array.isArray(species.growthStages) && species.growthStages.length) {
      // determine ADG as average of stages' adg or last stage
      adg = species.growthStages[species.growthStages.length - 1].adg || species.growthStages[0].adg || adg;
      // find stage by projected weight
      const projectedWeight = initialWeight + adg * days;
      const found = species.growthStages.find((st) => projectedWeight >= (st.minWeight || 0) && projectedWeight <= (st.maxWeight || Number.MAX_SAFE_INTEGER));
      if (found) {
        feedingRatePercent = found.feedingRatePercent || feedingRatePercent;
      } else {
        feedingRatePercent = species.growthStages[species.growthStages.length - 1].feedingRatePercent || feedingRatePercent;
      }
    }

    const avgWeight = initialWeight + adg * days; // grams
    const count = batch.currentCount ?? batch.initialCount ?? 0;
    const totalFeedGrams = (count * avgWeight * (feedingRatePercent / 100));

    const calc = this.feedCalculationRepository.create({
      batchId: batch.id,
      targetDate: tDate,
      totalFeedGrams,
      details: {
        avgWeight,
        days,
        feedingRatePercent,
        adg,
        count,
      },
      language,
    });
    await this.feedCalculationRepository.save(calc);

    const splits = 3;
    const perFeed = totalFeedGrams / splits;

    const localized = {
      totalFeedGrams,
      totalFeedKg: totalFeedGrams / 1000,
      perFeedGrams: perFeed,
      perFeedKg: perFeed / 1000,
      splits,
      splitsLabel: language === 'km' ? '៣ ដងក្នុងមួយថ្ងៃ' : '3x daily',
      species: language === 'km' ? species.nameKm : species.nameEn,
      details: calc.details,
    };

    return localized;
  }
}
