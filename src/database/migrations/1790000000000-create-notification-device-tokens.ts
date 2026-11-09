import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateNotificationDeviceTokens1790000000000 implements MigrationInterface {
  name = 'CreateNotificationDeviceTokens1790000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS notification_device_tokens (
        token VARCHAR(512) PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    `);
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS idx_notification_device_tokens_user_id
      ON notification_device_tokens(user_id)
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE IF EXISTS notification_device_tokens');
  }
}
