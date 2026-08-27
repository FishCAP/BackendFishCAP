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

  // --- FishCAP feeder telemetry (nullable so older rows remain valid) ---
  @Column({ name: 'weight_grams', type: 'decimal', precision: 10, scale: 2, nullable: true })
  weightGrams?: number;

  @Column({ name: 'feeding', type: 'boolean', nullable: true })
  feeding?: boolean;

  @Column({ name: 'feed_grams_dispensed', type: 'decimal', precision: 10, scale: 2, nullable: true })
  feedGramsDispensed?: number;

  @Column({ name: 'remaining_stock_grams', type: 'decimal', precision: 10, scale: 2, nullable: true })
  remainingStockGrams?: number;

  @Column({ name: 'low_stock', type: 'boolean', nullable: true })
  lowStock?: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp' })
  createdAt!: Date;
}
