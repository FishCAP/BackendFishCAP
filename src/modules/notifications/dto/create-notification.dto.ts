import { IsOptional, IsString, IsNotEmpty } from 'class-validator';

/**
 * Body for POST /api/notifications as sent from realtime_service.dart.
 * Front-end sends: { title, message, isRead? } — map to backend field names.
 */
export class CreateNotificationDto {
  @IsString()
  @IsNotEmpty({ message: 'title is required' })
  title!: string;

  /** Front-end sends `message`; backend stores it as `body`. */
  @IsString()
  @IsOptional()
  message?: string;

  /** Back-end column name is `body`. */
  @IsString()
  @IsOptional()
  body?: string;

  @IsOptional()
  @IsString()
  type?: string;

  @IsOptional()
  @IsString()
  event?: string;

  @IsOptional()
  isRead?: boolean;

  @IsOptional()
  @IsString()
  userId?: string;
}

