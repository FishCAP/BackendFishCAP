import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { PondEntity } from '../../ponds/entities/pond.entity/pond.entity';

@Entity('devices')
export class DeviceEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'device_code', unique: true })
  deviceCode: string;

  @Column({ default: 'ONLINE' })
  status: string;

  @Column({ name: 'pond_id' })
  pondId: string;

  @ManyToOne(() => PondEntity, (pond) => pond.devices, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'pond_id' })
  pond: PondEntity;

}
