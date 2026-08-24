import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { OtpEntity } from './entities/otp.entity';

interface FallbackOtp {
  id: string;
  email: string;
  code: string;
  expiresAt: Date;
  used: boolean;
  createdAt: Date;
}

@Injectable()
export class OtpService {
  constructor(
    @InjectRepository(OtpEntity)
    private readonly otpRepository: Repository<OtpEntity>,
  ) {}

  private _fallbackStore: Record<string, FallbackOtp[]> = {};

  private generateCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  async createOtp(email: string, ttlMinutes = 5): Promise<OtpEntity> {
    const code = this.generateCode();
    const expires = new Date(Date.now() + ttlMinutes * 60 * 1000);

    try {
      // Wrap delete + insert in the same transaction
      return await this.otpRepository.manager.transaction(async (manager) => {
        await manager.delete(OtpEntity, { email });

        const entry = manager.create(OtpEntity, {
          email,
          code,
          expiresAt: expires,
          used: false,
        });

        return await manager.save(entry);
      });
    } catch (err) {
      console.error('DB error in createOtp, using fallback:', err);

      const obj: FallbackOtp = {
        id: `fallback-${Date.now()}`,
        email,
        code,
        expiresAt: expires,
        used: false,
        createdAt: new Date(),
      };

      this._fallbackStore[email] = this._fallbackStore[email] ?? [];
      this._fallbackStore[email].push(obj);

      return obj as unknown as OtpEntity;
    }
  }

  async verifyOtp(email: string, code: string): Promise<boolean> {
    try {
      // Atomic verification:
      // mark as used only if it is still unused and not expired.
      const result = await this.otpRepository
        .createQueryBuilder()
        .update(OtpEntity)
        .set({ used: true })
        .where(
          'email = :email AND code = :code AND used = false AND expires_at > :now',
          { email, code, now: new Date() },
        )
        .execute();

      return result.affected === 1;
    } catch (err) {
      console.error('DB error in verifyOtp, using fallback:', err);

      const list = this._fallbackStore[email] ?? [];

      // Check most recent fallback OTPs first
      for (const entry of list.slice().reverse()) {
        if (entry.code === code && !entry.used) {
          if (entry.expiresAt.getTime() < Date.now()) {
            return false;
          }

          entry.used = true;
          return true;
        }
      }

      return false;
    }
  }
}