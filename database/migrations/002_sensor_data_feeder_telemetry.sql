-- Run once against an existing FishCap database before deploying this change.
-- New databases are created correctly from SensorDataEntity when synchronize is
-- enabled in development.
ALTER TABLE sensor_data
  ADD COLUMN IF NOT EXISTS weight_grams          decimal(10,2),
  ADD COLUMN IF NOT EXISTS feeding               boolean,
  ADD COLUMN IF NOT EXISTS feed_grams_dispensed  decimal(10,2),
  ADD COLUMN IF NOT EXISTS remaining_stock_grams decimal(10,2),
  ADD COLUMN IF NOT EXISTS low_stock             boolean;
