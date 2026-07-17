import { Column, Entity, JoinColumn, ManyToOne, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { UserEntity } from '../../../users/entities/user.entity/user.entity';
import { DeviceEntity } from '../../../sensors/entities/device.entity';
import { FeedScheduleEntity } from '../../../feeding/entities/feed-schedule.entity';

@Entity('ponds')
export class PondEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'pond_name' })
  pondName: string;

  @Column({ name: 'fish_type', nullable: true })
  fishType: string;

  @Column({ name: 'fish_count', type: 'integer', nullable: true })
  fishCount: number;

  @Column({ name: 'created_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @Column({ name: 'user_id' })
  userId: string;

  @ManyToOne(() => UserEntity, (user) => user.ponds, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: UserEntity;

  @OneToMany(() => DeviceEntity, (device) => device.pond)
  devices: DeviceEntity[];

  @OneToMany(() => FeedScheduleEntity, (schedule) => schedule.pond)
  feedSchedules: FeedScheduleEntity[];
}
