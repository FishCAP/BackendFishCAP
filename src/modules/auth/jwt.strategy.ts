// auth/jwt.strategy.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

// Must match the fallback in auth.module.ts to avoid signing/verifying
// mismatches when JWT_SECRET is not set (e.g. in Docker where the runtime
// image does not contain the .env file).
const JWT_SECRET =
  process.env.JWT_SECRET || 'your-secret-key-change-this-in-production';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: JWT_SECRET,
    });
  }

  async validate(payload: { sub?: string; email?: string }) {
    // `sub` is the user id we sign in AuthService.generateToken().
    // If it is missing (e.g. a token signed by an older version of the
    // backend, or a malformed token), reject the request with 401 instead
    // of letting `req.user.id` be undefined and blowing up with a 500.
    if (!payload?.sub) {
      throw new UnauthorizedException('Invalid token: missing user id');
    }
    return { id: payload.sub, email: payload.email }; // <-- must include id
  }
}
