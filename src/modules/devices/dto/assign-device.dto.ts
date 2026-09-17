import { IsOptional, IsUUID } from 'class-validator';

/**
 * Body for POST /api/devices/:id/assign.
 *
 * `pondId` is the canonical field; `pond_id` is the legacy snake_case alias
 * still sent by the Flutter app (api_service.dart assignDevice()). At least
 * one must be a valid UUID — the controller enforces that with a clear 400.
 */
export class AssignDeviceDto {
  @IsOptional()
  @IsUUID('all', { message: 'pondId must be a UUID' })
  pondId?: string;

  @IsOptional()
  @IsUUID('all', { message: 'pond_id must be a UUID' })
  pond_id?: string;

  /** Resolve either field name to the target pond id. */
  resolvePondId(): string | undefined {
    return this.pondId ?? this.pond_id;
  }
}
