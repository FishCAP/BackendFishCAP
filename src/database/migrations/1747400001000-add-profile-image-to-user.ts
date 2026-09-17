import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Migration: Add profile_image column to users table
 *
 * The FishCAP mobile app lets users upload a profile picture (via the
 * EditProfileScreen). The image is stored on disk under uploads/ and its
 * URL is persisted in users.profile_image.
 */
export class AddProfileImageToUser1747400001000 implements MigrationInterface {
  name = 'AddProfileImageToUser1747400001000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_image VARCHAR(500) NULL`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE users DROP COLUMN IF EXISTS profile_image`);
  }
}