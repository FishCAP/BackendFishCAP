import {
  IsDateString,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateSensorDataDto {
  @IsString()
  @IsNotEmpty({ message: 'deviceId is required' })
  deviceId!: string;

  @IsOptional()
  @IsNumber()
  temperature?: number;

  @IsOptional()
  @IsNumber()
  ph?: number;

  @IsOptional()
  @IsNumber()
  dissolvedOxygen?: number;

  @IsOptional()
  @IsDateString()
  timestamp?: string;
}
