import { Injectable, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';

@Injectable()
export class AuthService {
  [x: string]: any;
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
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
}
