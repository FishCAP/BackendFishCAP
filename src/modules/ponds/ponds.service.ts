// ponds.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PondEntity } from './entities/pond.entity/pond.entity';
import { CreatePondDto } from './dto/create-pond.dto';
import { UpdatePondDto } from './dto/update-pond.dto';

@Injectable()
export class PondsService {
  constructor(
    @InjectRepository(PondEntity)
    private pondsRepository: Repository<PondEntity>,
  ) {}

  async create(createPondDto: CreatePondDto, userId: string): Promise<PondEntity> {
    const pond = this.pondsRepository.create({
      ...createPondDto,
      owner: { id: userId },
    });
    return this.pondsRepository.save(pond);
  }

  async findAll(userId: string): Promise<PondEntity[]> {
    return this.pondsRepository.find({
      where: { owner: { id: userId } },
      relations: { owner: true },
      order: { created_at: 'DESC' },
    });
  }

  async findOne(id: string, userId: string): Promise<PondEntity> {
    const pond = await this.pondsRepository.findOne({
      where: { id, owner: { id: userId } },
      relations: { owner: true },
    });
    if (!pond) throw new NotFoundException('Pond not found or not owned by user');
    return pond;
  }

  async update(id: string, updatePondDto: UpdatePondDto, userId: string): Promise<PondEntity> {
    const pond = await this.findOne(id, userId);
    Object.assign(pond, updatePondDto);
    return this.pondsRepository.save(pond);
  }

  async remove(id: string, userId: string): Promise<void> {
    const pond = await this.findOne(id, userId);
    await this.pondsRepository.delete(id);
  }
}