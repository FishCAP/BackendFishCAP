-- Run once against an existing FishCap database before deploying this change.
-- New databases are created correctly from SensorDataEntity when synchronize is
-- enabled in development.
DO $$
DECLARE constraint_name text;
BEGIN
  FOR constraint_name IN
    SELECT conname
    FROM pg_constraint
    WHERE conrelid = 'sensor_data'::regclass AND contype = 'f'
  LOOP
    EXECUTE format('ALTER TABLE sensor_data DROP CONSTRAINT %I', constraint_name);
  END LOOP;
END $$;

ALTER TABLE sensor_data
  ALTER COLUMN device_id TYPE varchar(100) USING device_id::text;

