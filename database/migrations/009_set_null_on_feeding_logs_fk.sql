/* 009_set_null_on_feeding_logs_fk.sql
 *
 * Change the foreign key constraint on feeding_logs.schedule_id to
 * ON DELETE SET NULL so that syncing (replace-all) a pond's feed_schedules
 * via PATCH /api/ponds/:id no longer fails with a foreign-key violation
 * when existing feeding_logs rows still reference the old schedule IDs.
 *
 * After this change, deleting a feed_schedule simply sets schedule_id to NULL
 * on dependent feeding_logs — historical feeding records are preserved.
 */

-- Drop the existing constraint (handle both TypeORM-generated and custom names)
ALTER TABLE feeding_logs
    DROP CONSTRAINT IF EXISTS "FK_443cabfc5bf40a820667e3548e9",
    DROP CONSTRAINT IF EXISTS fk_log_schedule;

-- Recreate with ON DELETE SET NULL
ALTER TABLE feeding_logs
    ADD CONSTRAINT fk_log_schedule
    FOREIGN KEY (schedule_id)
    REFERENCES feed_schedules(id)
    ON DELETE SET NULL;
