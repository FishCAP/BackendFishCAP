import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('sensor_data')
export class SensorDataEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  /**
   * Hardware identifier (e.g. "FC-001"). An ESP32 can send its first reading
   * before an operator has registered a dashboard device record, so this is a
   * plain varchar, not a foreign key.
   */
  @Column({ name: 'device_id', type: 'varchar', length: 100 })
  deviceId!: string;

  /**
   * The pond this reading belongs to. Set at ingest time by looking up which
   * pond the device is currently assigned to. This preserves pond history even
   * when the hardware is later reassigned to a different pond — historical
   * readings stay linked to the pond they were taken for.
   */
  @Index()
  @Column({ name: 'pond_id', type: 'uuid', nullable: true })
  pondId!: string | null;

  @Column({ name: 'temperature', type: 'decimal', precision: 5, scale: 2, nullable: true })
  temperature?: number;

  @Column({ name: 'ph', type: 'decimal', precision: 4, scale: 2, nullable: true })
  ph?: number;

  @Column({ name: 'dissolved_oxygen', type: 'decimal', precision: 5, scale: 2, nullable: true })
  dissolvedOxygen?: number;

  @Column({ name: 'tds', type: 'decimal', precision: 8, scale: 2, nullable: true })
  tds?: number;

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
