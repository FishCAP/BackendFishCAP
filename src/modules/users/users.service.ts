import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { createHash } from 'crypto';
import { UserEntity } from './entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

export type UserResponse = Omit<UserEntity, 'passwordHash'>;

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly usersRepository: Repository<UserEntity>,
  ) {}

  private hashPassword(password: string): string {
    return createHash('sha256').update(password).digest('hex');
  }

  private sanitizeUser(user: UserEntity): UserResponse {
    const { passwordHash, ...safe } = user;
    return safe;
  }

  async create(createUserDto: CreateUserDto): Promise<UserResponse> {
    const existing = await this.usersRepository.findOneBy({ email: createUserDto.email });
    if (existing) {
      throw new ConflictException('Email already registered');
    }

    let passwordHash: string | undefined;
    if (createUserDto.password) {
      passwordHash = this.hashPassword(createUserDto.password);
    }

    const user = this.usersRepository.create({
      fullName: createUserDto.fullName,
      email: createUserDto.email,
      passwordHash,
      phone: createUserDto.phone ?? undefined,
    });

    const saved = await this.usersRepository.save(user);
    return this.sanitizeUser(saved);
  }

  async findAll(): Promise<UserResponse[]> {
    const users = await this.usersRepository.find();
    return users.map((user) => this.sanitizeUser(user));
  }

  async findOne(id: string): Promise<UserResponse> {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return this.sanitizeUser(user);
  }

  async findByEmail(email: string): Promise<UserEntity | null> {
    return this.usersRepository.findOneBy({ email });
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<UserResponse> {
    if (updateUserDto.email) {
      const existing = await this.usersRepository.findOneBy({ email: updateUserDto.email });
      if (existing && existing.id !== id) {
        throw new ConflictException('Email already in use');
      }
    }

    // Build a partial update. Never spread the loaded entity back into a
    // `save()` call: `passwordHash` is marked `select: false`, so it is
    // `undefined` on the loaded user and persisting it breaks the SQL
    // parameter binding → 500 Internal Server Error. Use `update()` instead
    // so only the fields we actually want to change are sent to PostgreSQL.
    const partial: Partial<UserEntity> = {};
    if (updateUserDto.fullName !== undefined) partial.fullName = updateUserDto.fullName;
    if (updateUserDto.email !== undefined) partial.email = updateUserDto.email;
    if (updateUserDto.phone !== undefined) partial.phone = updateUserDto.phone;
    if (updateUserDto.password) partial.passwordHash = this.hashPassword(updateUserDto.password);

    const result = await this.usersRepository.update(id, partial);
    if (result.affected === 0) {
      throw new NotFoundException('User not found');
    }

    const updated = await this.usersRepository.findOne({ where: { id } });
    if (!updated) {
      throw new NotFoundException('User not found');
    }
    return this.sanitizeUser(updated);
  }

  async remove(id: string): Promise<void> {
    const result = await this.usersRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('User not found');
    }
  }

  async validateCredentials(email: string, password: string): Promise<UserResponse | null> {
    // `passwordHash` is marked `select: false` on the entity, so it is NOT
    // loaded by `findByEmail()`. We must explicitly addSelect it here or the
    // password check below will always fail (login always fails with
    // "Invalid credentials" even with the correct password).
    const user = await this.usersRepository
      .createQueryBuilder('user')
      .addSelect('user.passwordHash')
      .where('user.email = :email', { email })
      .getOne();

    if (!user) {
      return null;                          // <- return null instead of throw
    }

    if (!user.passwordHash) {
      // Optional: if you want to distinguish OTP-only accounts, return null.
      // The frontend will just see "Invalid credentials" unless you customize.
      return null;
    }

    const passwordHash = this.hashPassword(password);
    if (user.passwordHash !== passwordHash) {
      return null;                          // <- return null instead of throw
    }

    return this.sanitizeUser(user);
  }
}
