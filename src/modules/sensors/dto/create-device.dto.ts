import { IsIn, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';
import type { DeviceStatus } from '../entities/device.entity';

/**
 * Body for POST /api/sensors/devices (device registration).
 *
 * Every field MUST carry a class-validator decorator: the global
 * ValidationPipe runs with `forbidNonWhitelisted: true`, so any property
 * without one is rejected with "property X should not exist" — which is
 * exactly what silently broke device registration before.
 */
export class CreateDeviceDto {
  /** Permanent unique hardware identifier (e.g. "fishcap_002"). */
  @IsString({ message: 'deviceCode must be a string' })
  @MaxLength(50, { message: 'deviceCode must be at most 50 characters' })
  deviceCode!: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  deviceName?: string;

  /** Optional pond to bind at registration time (usually left empty). */
  @IsOptional()
  @IsUUID('all', { message: 'pondId must be a UUID' })
  pondId?: string;

  @IsOptional()
  @IsIn(['AVAILABLE', 'ASSIGNED', 'ACTIVE', 'OFFLINE', 'MAINTENANCE'], {
    message:
      'status must be one of AVAILABLE, ASSIGNED, ACTIVE, OFFLINE, MAINTENANCE',
  })
  status?: DeviceStatus;
}
