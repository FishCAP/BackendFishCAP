import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity('notification_device_tokens')
export class NotificationDeviceTokenEntity {
  @PrimaryColumn({ type: 'varchar', length: 512 })
  token!: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId!: string;

  @Column({
    name: 'created_at',
    type: 'timestamptz',
    default: () => 'CURRENT_TIMESTAMP',
  })
  createdAt!: Date;
}
