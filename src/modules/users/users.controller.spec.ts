import * as fs from 'fs';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { CloudinaryService } from './cloudinary.provider';

describe('UsersController.uploadProfileImage', () => {
  const usersService = {
    update: jest.fn(),
    setProfileImage: jest.fn(),
  };
  const cloudinaryService = {
    isConfigured: jest.fn(),
  };
  let controller: UsersController;

  beforeEach(() => {
    jest.clearAllMocks();
    controller = new UsersController(
      usersService as unknown as UsersService,
      cloudinaryService as unknown as CloudinaryService,
    );
  });

  it('stores the uploaded file locally when Cloudinary is not configured', async () => {
    cloudinaryService.isConfigured.mockReturnValue(false);
    usersService.update.mockImplementation(async (id, fields) => ({
      id,
      ...fields,
    }));
    const mkdir = jest
      .spyOn(fs.promises, 'mkdir')
      .mockResolvedValue(undefined);
    const writeFile = jest
      .spyOn(fs.promises, 'writeFile')
      .mockResolvedValue(undefined);
    const file = {
      buffer: Buffer.from('image bytes'),
      mimetype: 'image/png',
    } as Express.Multer.File;

    try {
      const result = await controller.uploadProfileImage(
        { user: { id: 'user-123' } },
        'me',
        file,
      );

      expect(usersService.update).toHaveBeenCalledWith(
        'user-123',
        expect.objectContaining({
          profileImage: expect.stringMatching(
            /^\/uploads\/profile-images\/profile-[\da-f-]+\.png$/,
          ),
        }),
      );
      expect(writeFile).toHaveBeenCalledWith(
        expect.stringMatching(/profile-[\da-f-]+\.png$/),
        file.buffer,
      );
      expect(result.profile_image).toMatch(
        /^\/uploads\/profile-images\/profile-[\da-f-]+\.png$/,
      );
      expect(mkdir).toHaveBeenCalledWith(
        expect.stringMatching(/uploads\/profile-images$/),
        { recursive: true },
      );
      expect(usersService.setProfileImage).not.toHaveBeenCalled();
    } finally {
      mkdir.mockRestore();
      writeFile.mockRestore();
    }
  });
});
