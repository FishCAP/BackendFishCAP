-- Run once against an existing FishCap database before deploying this change.
-- New databases are created correctly from FeedScheduleEntity when synchronize
-- is enabled in development.
ALTER TABLE feed_schedules
  ADD COLUMN IF NOT EXISTS title varchar(100);
