import { Injectable } from '@nestjs/common';
import { v2 as cloudinary, UploadApiResponse } from 'cloudinary';

/**
 * Reusable Cloudinary configuration provider.
 *
 * Credentials come from environment variables (never hardcoded, never sent
 * to the Flutter client):
 *   CLOUDINARY_CLOUD_NAME
 *   CLOUDINARY_API_KEY
 *   CLOUDINARY_API_SECRET
 *
 * All profile images are stored in the `fishcap/profile-images` folder.
 */
export const CLOUDINARY_FOLDER = 'fishcap/profile-images';

/** Maximum accepted profile image size (5 MB). */
export const PROFILE_IMAGE_MAX_BYTES = 5 * 1024 * 1024;

/** Accepted profile image mime types. */
export const PROFILE_IMAGE_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/webp',
];

@Injectable()
export class CloudinaryService {
  constructor() {
    cloudinary.config({
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET,
    });
  }

  /** True when the required Cloudinary credentials are present. */
  isConfigured(): boolean {
    return Boolean(
      process.env.CLOUDINARY_CLOUD_NAME &&
        process.env.CLOUDINARY_API_KEY &&
        process.env.CLOUDINARY_API_SECRET,
    );
  }

  /**
   * Upload an image buffer to Cloudinary.
   *
   * The Node SDK accepts either a file path or a base64 data URI — not a raw
   * Buffer — so the bytes are wrapped in a data URI built from the multer
   * detected mimetype.
   */
  async uploadImage(
    buffer: Buffer,
    mimetype: string,
  ): Promise<{ secureUrl: string; publicId: string }> {
    const dataUri = `data:${mimetype || 'image/jpeg'};base64,${buffer.toString('base64')}`;

    const result: UploadApiResponse = await cloudinary.uploader.upload(
      dataUri,
      {
        folder: CLOUDINARY_FOLDER,
        resource_type: 'image',
      },
    );

    return { secureUrl: result.secure_url, publicId: result.public_id };
  }

  /**
   * Delete an image from Cloudinary by public_id. Used to replace a user's
   * previous profile image after a new one has been stored successfully.
   */
  async deleteImage(publicId: string): Promise<void> {
    await cloudinary.uploader.destroy(publicId, { resource_type: 'image' });
  }
}
