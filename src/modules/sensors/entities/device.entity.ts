import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { PondEntity } from '../../ponds/entities/pond.entity/pond.entity';

@Entity('devices')
export class DeviceEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'device_code', type: 'varchar', length: 50, unique: true, nullable: false })
  deviceCode: string;

  @Column({ name: 'status', type: 'varchar', length: 20, default: 'ONLINE' })
  status: string;

  @Column({ name: 'pond_id', type: 'uuid', nullable: false })
  pondId: string;

  @ManyToOne(() => PondEntity, (pond) => pond.devices, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'pond_id' })
  pond: PondEntity;
}
