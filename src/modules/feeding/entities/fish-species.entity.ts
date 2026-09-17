import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('fish_species')
export class FishSpeciesEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'name_en', type: 'varchar', length: 100, nullable: false })
  nameEn!: string;

  @Column({ name: 'name_km', type: 'varchar', length: 100, nullable: false })
  nameKm!: string;

  @Column({ name: 'aliases', type: 'jsonb', nullable: true })
  aliases?: string[];

  // JSON field containing growth stages: [{ name, minWeight, maxWeight, feedingRatePercent, adg }]
  @Column({ name: 'growth_stages', type: 'jsonb', nullable: true })
  growthStages?: any[];

  @Column({ name: 'default_initial_weight', type: 'int', nullable: true })
  defaultInitialWeight?: number; // grams

  @Column({ name: 'environment', type: 'jsonb', nullable: true })
  environment?: {
    temperature?: { min?: number; max?: number };
    ph?: { min?: number; max?: number };
    oxygen?: { min?: number };
  };
}
