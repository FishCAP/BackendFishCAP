import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('sensor_data')
export class SensorDataEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  // A hardware identifier, not a foreign key. An ESP32 can send its first
  // reading before an operator has registered a dashboard device record.
  @Column({ name: 'device_id', type: 'varchar', length: 100 })
  deviceId!: string;

  @Column({ name: 'temperature', type: 'decimal', precision: 5, scale: 2, nullable: true })
  temperature?: number;

  @Column({ name: 'ph', type: 'decimal', precision: 4, scale: 2, nullable: true })
  ph?: number;

  @Column({ name: 'dissolved_oxygen', type: 'decimal', precision: 5, scale: 2, nullable: true })
  dissolvedOxygen?: number;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp' })
  createdAt!: Date;
}
