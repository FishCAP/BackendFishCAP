import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { BatchEntity } from './batch.entity';

@Entity('feed_calculations')
export class FeedCalculationEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'batch_id', type: 'uuid', nullable: false })
  batchId: string;

  @ManyToOne(() => BatchEntity)
  @JoinColumn({ name: 'batch_id' })
  batch: BatchEntity;

  @Column({ name: 'target_date', type: 'timestamp', nullable: false })
  targetDate: Date;

  @Column({ name: 'total_feed_grams', type: 'decimal', precision: 12, scale: 2, nullable: false })
  totalFeedGrams: number;

  @Column({ name: 'details', type: 'jsonb', nullable: true })
  details?: any;

  @Column({ name: 'language', type: 'varchar', length: 5, default: 'km' })
  language: string;
}
