import { Injectable, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { MoreThan } from 'typeorm';
import { MailService } from '../mail/mail.service';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
  [x: string]: any;
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly mailService: MailService,
      @InjectRepository(UserEntity)
    private readonly usersRepo: Repository<UserEntity>,
  ) {}

    async validateUser(identifier: string, password: string) {
      if (!identifier) {
        throw new BadRequestException('Email is required to sign in');
      }

      if (!this.isValidEmail(identifier)) {
        throw new BadRequestException('Please sign in with a valid email address');
      }

      const user = await this.usersService.validateCredentials(identifier, password);

      if (!user) {
        throw new UnauthorizedException('Invalid credentials');
      }
          // return user without token
    return user;
    }

  async register(userData: {
    fullName: string;
    email: string;
    password?: string; // optional again
    phone?: string;
  }) {
    if (!userData?.fullName?.trim()) {
      throw new BadRequestException('Full name is required');
    }

    if (!userData?.email?.trim() || !this.isValidEmail(userData.email)) {
      throw new BadRequestException('Please provide a valid email address');
    }

    // Only validate password strength if a password is provided
    if (userData.password && userData.password.length < 8) {
      throw new BadRequestException('Password must be at least 8 characters long');
    }

    const user = await this.usersService.create(userData);
    const token = this.generateToken(user.id, user.email);

    // Remove password hash from response
    const { password, ...safeUser } = user as any;
    return { ...safeUser, token };
  }

  signUser(user: { id: string; email: string }) {
    const token = this.generateToken(user.id, user.email);
    return { ...user, token };
  }

  private generateToken(userId: string, email: string): string {
    return this.jwtService.sign(
      { sub: userId, email },
      { expiresIn: '24h' },
    );
  }

  private isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

    async forgotPassword(email: string) {
    const user = await this.usersRepo.findOne({ where: { email } });

    // Always return success to avoid email enumeration
    if (!user) return { success: true };

    const rawToken = crypto.randomBytes(32).toString('hex');
    const tokenHash = crypto
      .createHash('sha256')
      .update(rawToken)
      .digest('hex');

    user.resetTokenHash = tokenHash;
    user.resetTokenExpiresAt = new Date(Date.now() + 30 * 60 * 1000);
    await this.usersRepo.save(user);

    const resetLink = `${process.env.APP_RESET_URL}?token=${rawToken}`;
    await this.mailService.sendPasswordReset(user.email, resetLink);

    return { success: true };
  }

  async resetPassword(token: string, newPassword: string) {
    const tokenHash = crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    const user = await this.usersRepo.findOne({
      where: {
        resetTokenHash: tokenHash,
        resetTokenExpiresAt: MoreThan(new Date()),
      },
    });

    if (!user) {
      throw new BadRequestException('Invalid or expired reset token');
    }

    user.password = await bcrypt.hash(newPassword, 10);
    user.resetTokenHash = null;
    user.resetTokenExpiresAt = null;
    await this.usersRepo.save(user);

    return { success: true };
  }
}
