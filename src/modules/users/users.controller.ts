import * as fs from 'fs';
import * as path from 'path';
import { Body, Controller, Delete, Get, Param, Patch, Post, Query, HttpCode, HttpStatus, NotFoundException, UseGuards, Req } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  async findAll(@Query('email') email?: string) {
    if (email) {
      const user = await this.usersService.findByEmail(email);
      // ✅ FIX: If user doesn't exist, throw a 404 error
      if (!user) {
        throw new NotFoundException('User not found');
      }
      return user;
    }
    return this.usersService.findAll();
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async getCurrentUser(@CurrentUser() user: { id: string; email: string }) {
    const fullUser = await this.usersService.findOne(user.id);
    return {
      success: true,
      data: fullUser,
    };
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Post('login')
  login(@Body() body: { email: string; password: string }) {
    return this.usersService.validateCredentials(body.email, body.password);
  }

    @Patch('me')
  @UseGuards(JwtAuthGuard)
  async updateProfile(@Req() req, @Body() updateProfileDto: Record<string, any>) {
    // Deliberately untyped so arbitrary profile fields can pass through.
    const userId = req.user.id; // from JWT strategy: { id, email }

    let profileImage: string | undefined;

    // Handle profile image upload via base64 (frontend sends
    // profileImageBase64 + filename). The image is decoded, saved to disk
    // under uploads/profile-images/, and the public URL is stored.
    if (updateProfileDto.profileImageBase64) {
      try {
        profileImage = await this._saveProfileImage(
          userId,
          updateProfileDto.profileImageBase64 as string,
          updateProfileDto.filename as string | undefined,
        );
      } catch (error) {
        console.error('Failed to save profile image:', error);
      }
    }

    const updatedUser = await this.usersService.update(userId, {
      // Accept both camelCase (current frontend) and snake_case (legacy) keys.
      fullName: updateProfileDto.fullName ?? updateProfileDto.full_name,
      phone: updateProfileDto.phone,
      profileImage: profileImage ?? updateProfileDto.profileImage,
    });
    return { success: true, data: updatedUser };
  }

  /// Decode a base64 image, persist it to disk, and return its public URL.
  private async _saveProfileImage(
    userId: string,
    base64Data: string,
    filename?: string,
  ): Promise<string> {
    // Strip optional data-URI prefix (e.g. "data:image/png;base64,...")
    const cleaned = base64Data.replace(/^data:image\/\w+;base64,/, '');

    // Determine extension from the original filename or default to jpg
    const ext = filename
      ? path.extname(filename).replace('.', '') || 'jpg'
      : 'jpg';
    const safeExt = ext.replace(/[^a-zA-Z0-9]/g, '') || 'jpg';

    // Build a unique filename: profile-{userId}-{timestamp}.ext
    const uniqueName = `profile-${userId}-${Date.now()}.${safeExt}`;
    const uploadDir = path.join(process.cwd(), 'uploads', 'profile-images');
    await fs.promises.mkdir(uploadDir, { recursive: true });
    const filepath = path.join(uploadDir, uniqueName);
    const buffer = Buffer.from(cleaned, 'base64');
    await fs.promises.writeFile(filepath, buffer);

    return `/uploads/profile-images/${uniqueName}`;
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(id, updateUserDto);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  async logout() {
    // JWT is stateless — there is no server-side session to destroy.
    // The client simply discards its stored token. Returning 200 here
    // avoids the previous 500 caused by `req.session` being undefined
    // (no express-session middleware is configured).
    return { success: true, message: 'Logged out successfully' };
  }
}
