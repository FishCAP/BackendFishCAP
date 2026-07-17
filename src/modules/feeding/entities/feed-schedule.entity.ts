import { Column, Entity, JoinColumn, ManyToOne, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { PondEntity } from '../../ponds/entities/pond.entity/pond.entity';
import { FeedingLogEntity } from './feeding-log.entity';

@Entity('feed_schedules')
export class FeedScheduleEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'pond_id' })
  pondId: string;

  @ManyToOne(() => PondEntity, (pond) => pond.feedSchedules, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'pond_id' })
  pond: PondEntity;

  @Column({ name: 'feed_time', type: 'time' })
  feedTime: string;

  @Column({ name: 'feed_amount', type: 'decimal', precision: 10, scale: 2 })
  feedAmount: number;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @OneToMany(() => FeedingLogEntity, (log) => log.schedule)
  logs: FeedingLogEntity[];
}
