// pond.entity.ts
import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { UserEntity } from '../../../users/entities/user.entity';
import { DeviceEntity } from '../../../sensors/entities/device.entity';
import { FeedScheduleEntity } from '../../../feeding/entities/feed-schedule.entity';

@Entity('ponds')
export class PondEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'pond_name', type: 'varchar', length: 100, nullable: false })
  name!: string;

  @Column({ name: 'location', type: 'varchar', length: 255, nullable: true })
  location?: string;

  @Column({ name: 'fish_type', type: 'varchar', length: 100, nullable: true })
  species?: string;

  @Column({ name: 'fish_count', type: 'int', nullable: true })
  estimatedCount?: number;

  @Column({ name: 'start_date', type: 'varchar', length: 20, nullable: true })
  startDate?: string;

  @Column({ name: 'end_date', type: 'varchar', length: 20, nullable: true })
  endDate?: string;

  @Column({ name: 'feeding_times', type: 'jsonb', nullable: true })
  feedingTimes?: string[];

  @Column({ name: 'amount', type: 'decimal', precision: 10, scale: 2, nullable: true })
  amount?: number;

  @Column({ name: 'hardware_id', type: 'varchar', length: 100, nullable: true })
  hardwareId?: string;

  @Column({ name: 'status', type: 'varchar', length: 20, default: 'active', nullable: true })
  status?: string;

  @Column({ name: 'status_color', type: 'varchar', length: 20, nullable: true })
  statusColor?: string;

  @Column({ name: 'has_alert', type: 'boolean', default: false, nullable: true })
  hasAlert?: boolean;

  @Column({ name: 'temperature', type: 'varchar', length: 20, nullable: true })
  temperature?: string;

  @ManyToOne(() => UserEntity, (user) => user.ponds, {
    onDelete: 'CASCADE',
    nullable: false,
  })
  @JoinColumn({ name: 'user_id' })
  owner!: UserEntity;

  @OneToMany(() => DeviceEntity, (device) => device.pond)
  devices!: DeviceEntity[];

  @OneToMany(() => FeedScheduleEntity, (schedule) => schedule.pond)
  feedSchedules!: FeedScheduleEntity[];

  @CreateDateColumn({ name: 'created_at', type: 'timestamp' })
  created_at!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp' })
  updated_at!: Date;
}
