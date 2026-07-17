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
    private readonly pondsRepository: Repository<PondEntity>,
  ) {}

  async create(createPondDto: CreatePondDto): Promise<PondEntity> {
    const pond = this.pondsRepository.create(createPondDto);
    return this.pondsRepository.save(pond);
  }

  async findAll(): Promise<PondEntity[]> {
    return this.pondsRepository.find({ relations: { user: true, devices: true } });
  }

  async findOne(id: string): Promise<PondEntity> {
    const pond = await this.pondsRepository.findOne({ where: { id }, relations: { user: true, devices: true } });
    if (!pond) {
      throw new NotFoundException('Pond not found');
    }
    return pond;
  }

  async update(id: string, updatePondDto: UpdatePondDto): Promise<PondEntity> {
    const pond = await this.findOne(id);
    const updated = { ...pond, ...updatePondDto };
    await this.pondsRepository.save(updated);
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    const result = await this.pondsRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Pond not found');
    }
  }
}
