// pond.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { UserEntity } from '../../../users/entities/user.entity';
import { DeviceEntity } from '../../../sensors/entities/device.entity';
import { FeedScheduleEntity } from '../../../feeding/entities/feed-schedule.entity';

@Entity('ponds')
export class PondEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column()
  name!: string;

  @Column({ nullable: true })
  location?: string;

  @Column({ nullable: true })
  species?: string;

  @Column({ type: 'int', nullable: true })
  estimatedCount?: number;

  @Column({ type: 'date', nullable: true })
  startDate?: string;

  @Column({ type: 'date', nullable: true })
  endDate?: string;

  @Column({ type: 'simple-array', nullable: true })
  feedingTimes?: string[];

  @Column({ type: 'float', nullable: true })
  amount?: number;

  @Column({ nullable: true })
  hardwareId?: string;

  @Column({ default: 'active', nullable: true })
  status?: string;

  @Column({ nullable: true })
  statusColor?: string;

  @Column({ type: 'boolean', default: false, nullable: true })
  hasAlert?: boolean;

  @Column({ nullable: true })
  temperature?: string; // or number if you prefer

  @ManyToOne(() => UserEntity, (user) => user.ponds, {
    onDelete: 'CASCADE',
    nullable: false,
  })
  owner!: UserEntity;

  @OneToMany(() => DeviceEntity, (device) => device.pond)
  devices!: DeviceEntity[];

  @OneToMany(() => FeedScheduleEntity, (schedule) => schedule.pond)
  feedSchedules!: FeedScheduleEntity[];

  @CreateDateColumn()
  created_at!: Date;

  @UpdateDateColumn()
  updated_at!: Date;
}