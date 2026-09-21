import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Migration: Add ON DELETE SET NULL to the feeding_logs → feed_schedules FK
 *
 * Problem: When a pond's feed schedules are synced (replace-all) via PATCH
 * /api/ponds/:id, the syncFeedSchedules() method deletes all feed_schedules
 * rows for the pond. If any feeding_logs rows still reference those schedule
 * IDs, PostgreSQL raises:
 *   "update or delete on table 'feed_schedules' violates foreign key
 *    constraint 'FK_...' on table 'feeding_logs'"
 *
 * The FK was originally created with NO ACTION (no ON DELETE clause). This
 * migration changes it to ON DELETE SET NULL so that historical feeding logs
 * are preserved (their schedule_id becomes NULL) rather than blocking the
 * deletion of schedules.
 *
 * New databases created via synchronize will pick up onDelete: 'SET NULL'
 * from the FeedingLogEntity decorator automatically.
 */
export class SetNullOnFeedingLogsScheduleFk1747400003000
  implements MigrationInterface
{
  name = 'SetNullOnFeedingLogsScheduleFk1747400003000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Drop the existing FK constraint (TypeORM-generated or custom-named).
    // Postgres constraint names are case-folded to lowercase, so we use
    // lowercase and handle both the TypeORM default name pattern and the
    // custom name from 01-schema.sql.
    await queryRunner.query(`
      ALTER TABLE feeding_logs
      DROP CONSTRAINT IF EXISTS "FK_443cabfc5bf40a820667e3548e9",
      DROP CONSTRAINT IF EXISTS fk_log_schedule
    `);

    // Recreate with ON DELETE SET NULL so deleting a feed_schedule that has
    // feeding_logs does not raise a foreign-key violation; the log's
    // schedule_id is simply set to NULL.
    await queryRunner.query(`
      ALTER TABLE feeding_logs
      ADD CONSTRAINT fk_log_schedule
      FOREIGN KEY (schedule_id)
      REFERENCES feed_schedules(id)
      ON DELETE SET NULL
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE feeding_logs
      DROP CONSTRAINT IF EXISTS fk_log_schedule
    `);

    await queryRunner.query(`
      ALTER TABLE feeding_logs
      ADD CONSTRAINT fk_log_schedule
      FOREIGN KEY (schedule_id)
      REFERENCES feed_schedules(id)
    `);
  }
}
