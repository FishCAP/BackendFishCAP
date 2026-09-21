import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { FeedScheduleEntity } from './feed-schedule.entity';
import { PondEntity } from '../../ponds/entities/pond.entity/pond.entity';

@Entity('feeding_logs')
export class FeedingLogEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'pond_id', type: 'uuid', nullable: false })
  pondId: string;

  @ManyToOne(() => PondEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'pond_id' })
  pond: PondEntity;

  @Column({ name: 'schedule_id', type: 'uuid', nullable: true })
  scheduleId: string;

  @ManyToOne(() => FeedScheduleEntity, (schedule) => schedule.logs, {
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'schedule_id' })
  schedule: FeedScheduleEntity;

  @Column({ name: 'feed_amount', type: 'decimal', precision: 10, scale: 2, nullable: true })
  feedAmount: number;

  @Column({ name: 'status', type: 'varchar', length: 20, nullable: true })
  status: string;

  @Column({ name: 'fed_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  fedAt: Date;
}
