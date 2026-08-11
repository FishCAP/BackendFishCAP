import { Injectable, BadRequestException } from '@nestjs/common';
import { UsersService } from '../users/users.service';

@Injectable()
export class AuthService {
  constructor(private readonly usersService: UsersService) {}

  async validateUser(identifier: string, password: string) {
    if (!identifier) {
      throw new BadRequestException('Email is required to sign in');
    }

    if (!identifier.includes('@')) {
      throw new BadRequestException('Please sign in with your email address');
    }

    return this.usersService.validateCredentials(identifier, password);
  }
}
