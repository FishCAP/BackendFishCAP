import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class RegisterNotificationDeviceDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(512)
  token!: string;
}
