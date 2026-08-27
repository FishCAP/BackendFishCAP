import {
  IsBoolean,
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

  // --- FishCAP feeder telemetry (sent by the ESP32 on every reading) ---
  @IsOptional()
  @IsNumber()
  weightGrams?: number;

  @IsOptional()
  @IsBoolean()
  feeding?: boolean;

  @IsOptional()
  @IsNumber()
  feedGramsDispensed?: number;

  @IsOptional()
  @IsNumber()
  remainingStockGrams?: number;

  @IsOptional()
  @IsBoolean()
  lowStock?: boolean;

  @IsOptional()
  @IsDateString()
  timestamp?: string;
}
