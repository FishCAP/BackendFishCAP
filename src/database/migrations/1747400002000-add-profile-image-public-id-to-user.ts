import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Migration: Add profile_image_public_id column to users table
 *
 * Profile images are now uploaded to Cloudinary (`fishcap/profile-images`)
 * and the returned secure URL is persisted in users.profile_image. The
 * Cloudinary public_id is stored alongside so a user's previous image can be
 * deleted from Cloudinary when they upload a replacement.
 */
export class AddProfileImagePublicIdToUser1747400002000 implements MigrationInterface {
  name = 'AddProfileImagePublicIdToUser1747400002000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_image_public_id VARCHAR(255) NULL`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE users DROP COLUMN IF EXISTS profile_image_public_id`,
    );
  }
}
