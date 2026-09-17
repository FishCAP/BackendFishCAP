-- 007_add_feed_schedule_sync_columns.sql
-- Add sync metadata to feed_schedules so devices/fallback can ack deliveries.

ALTER TABLE feed_schedules
  ADD COLUMN IF NOT EXISTS last_synced_at timestamptz NULL,
  ADD COLUMN IF NOT EXISTS last_sync_status varchar(50) NULL,
  ADD COLUMN IF NOT EXISTS sync_attempts int DEFAULT 0 NOT NULL;
