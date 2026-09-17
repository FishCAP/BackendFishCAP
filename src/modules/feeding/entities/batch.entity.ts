import { Column, Entity, ManyToOne, PrimaryGeneratedColumn, JoinColumn } from 'typeorm';
import { FishSpeciesEntity } from './fish-species.entity';

@Entity('batches')
export class BatchEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'pond_id', type: 'uuid', nullable: true })
  pondId?: string;

  @Column({ name: 'species_id', type: 'uuid', nullable: false })
  speciesId: string;

  @ManyToOne(() => FishSpeciesEntity)
  @JoinColumn({ name: 'species_id' })
  species: FishSpeciesEntity;

  @Column({ name: 'stocking_date', type: 'timestamp', nullable: false })
  stockingDate: Date;

  @Column({ name: 'initial_count', type: 'int', nullable: false })
  initialCount: number;

  @Column({ name: 'current_count', type: 'int', nullable: true })
  currentCount?: number;

  @Column({ name: 'initial_weight', type: 'int', nullable: true })
  initialWeight?: number; // grams

  @Column({ name: 'mortality_rate', type: 'decimal', precision: 5, scale: 2, nullable: true })
  mortalityRate?: number; // percentage
}
