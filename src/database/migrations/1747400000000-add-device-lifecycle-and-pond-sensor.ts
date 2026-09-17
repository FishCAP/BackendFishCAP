import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Migration: Add device lifecycle fields and pond_id to sensor_data
 *
 * Changes:
 * 1. Make devices.pond_id nullable (was NOT NULL) to support released devices
 * 2. Add device_name, assigned_at, released_at columns to devices
 * 3. Add pond_id column to sensor_data for pond-based history
 * 4. Update default status from 'ONLINE' to 'AVAILABLE'
 */
export class AddDeviceLifecycleAndPondSensor1747400000000 implements MigrationInterface {
  name = 'AddDeviceLifecycleAndPondSensor1747400000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Make pond_id nullable
    await queryRunner.query(`ALTER TABLE devices ALTER COLUMN pond_id DROP NOT NULL`);

    // Add new columns to devices table
    await queryRunner.query(`ALTER TABLE devices ADD COLUMN IF NOT EXISTS device_name varchar(100) NULL`);
    await queryRunner.query(`ALTER TABLE devices ADD COLUMN IF NOT EXISTS assigned_at timestamptz NULL`);
    await queryRunner.query(`ALTER TABLE devices ADD COLUMN IF NOT EXISTS released_at timestamptz NULL`);

    // Add pond_id to sensor_data
    await queryRunner.query(`ALTER TABLE sensor_data ADD COLUMN IF NOT EXISTS pond_id uuid NULL`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS idx_sensor_data_pond_id ON sensor_data(pond_id)`);

    // Add foreign key constraint (nullable, so SET NULL on delete)
    await queryRunner.query(`
      ALTER TABLE sensor_data
      ADD CONSTRAINT fk_sensor_data_pond_id
      FOREIGN KEY (pond_id) REFERENCES ponds(id) ON DELETE SET NULL
    `);

    // Backfill sensor_data.pond_id from the device's current pond assignment
    await queryRunner.query(`
      UPDATE sensor_data sd
      SET pond_id = d.pond_id
      FROM devices d
      WHERE sd.device_id = d.device_code
      AND sd.pond_id IS NULL
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Remove foreign key
    await queryRunner.query(`ALTER TABLE sensor_data DROP CONSTRAINT IF EXISTS fk_sensor_data_pond_id`);
    // Remove index
    await queryRunner.query(`DROP INDEX IF EXISTS idx_sensor_data_pond_id`);
    // Remove pond_id column
    await queryRunner.query(`ALTER TABLE sensor_data DROP COLUMN IF EXISTS pond_id`);
    // Remove device lifecycle columns
    await queryRunner.query(`ALTER TABLE devices DROP COLUMN IF EXISTS released_at`);
    await queryRunner.query(`ALTER TABLE devices DROP COLUMN IF EXISTS assigned_at`);
    await queryRunner.query(`ALTER TABLE devices DROP COLUMN IF EXISTS device_name`);
    // Restore pond_id NOT NULL (may fail if there are nulls)
    await queryRunner.query(`ALTER TABLE devices ALTER COLUMN pond_id SET NOT NULL`);
  }
}
