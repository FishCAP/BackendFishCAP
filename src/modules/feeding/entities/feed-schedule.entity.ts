import { Column, Entity, JoinColumn, ManyToOne, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { PondEntity } from '../../ponds/entities/pond.entity/pond.entity';
import { FeedingLogEntity } from './feeding-log.entity';

@Entity('feed_schedules')
export class FeedScheduleEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'pond_id', type: 'uuid', nullable: false })
  pondId: string;

  @ManyToOne(() => PondEntity, (pond) => pond.feedSchedules, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'pond_id' })
  pond: PondEntity;

  @Column({ name: 'feed_time', type: 'time', nullable: false })
  feedTime: string;

  @Column({ name: 'feed_amount', type: 'decimal', precision: 10, scale: 2, nullable: false })
  feedAmount: number;

  // Optional label shown by the app's detail page (e.g. "Morning Feed").
  @Column({ type: 'varchar', length: 100, nullable: true })
  title?: string;

  @Column({ name: 'is_active', type: 'boolean', default: true, nullable: true })
  isActive: boolean;

  @OneToMany(() => FeedingLogEntity, (log) => log.schedule)
  logs: FeedingLogEntity[];

  // Sync metadata for device delivery
  @Column({ name: 'last_synced_at', type: 'timestamptz', nullable: true })
  lastSyncedAt?: Date;

  @Column({ name: 'last_sync_status', type: 'varchar', length: 50, nullable: true })
  lastSyncStatus?: string;

  @Column({ name: 'sync_attempts', type: 'int', default: 0 })
  syncAttempts?: number;
}