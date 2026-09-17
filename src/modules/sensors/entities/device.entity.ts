import { Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';
import { PondEntity } from '../../ponds/entities/pond.entity/pond.entity';

/**
 * Hardware lifecycle status values:
 * - AVAILABLE: device is not assigned to any pond, ready for assignment
 * - ASSIGNED: device has been assigned to a pond but not yet confirmed active
 * - ACTIVE: device is currently operating with a pond
 * - OFFLINE: device is not responding
 * - MAINTENANCE: device is under maintenance
 */
export type DeviceStatus = 'AVAILABLE' | 'ASSIGNED' | 'ACTIVE' | 'OFFLINE' | 'MAINTENANCE';

@Entity('devices')
export class DeviceEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /** Permanent unique hardware identifier (e.g. "FC-001") */
  @Column({ name: 'device_code', type: 'varchar', length: 50, unique: true, nullable: false })
  deviceCode: string;

  @Column({ name: 'device_name', type: 'varchar', length: 100, nullable: true })
  deviceName: string;

  @Column({ name: 'status', type: 'varchar', length: 20, default: 'AVAILABLE' })
  status: DeviceStatus;

  /**
   * Current pond assignment. Nullable so the device can exist without a pond
   * (when released/completed). A device can only be assigned to one active pond
   * at a time — enforced at the service layer.
   */
  @Column({ name: 'pond_id', type: 'uuid', nullable: true })
  pondId: string | null;

  @ManyToOne(() => PondEntity, (pond) => pond.devices, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'pond_id' })
  pond: PondEntity | null;

  /** Timestamp when the device was assigned to the current pond */
  @Column({ name: 'assigned_at', type: 'timestamptz', nullable: true })
  assignedAt: Date | null;

  /** Timestamp when the device was released from its previous pond */
  @Column({ name: 'released_at', type: 'timestamptz', nullable: true })
  releasedAt: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;
}
