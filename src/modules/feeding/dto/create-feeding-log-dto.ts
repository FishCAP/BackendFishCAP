import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';

/** One feeding entry as sent by the Flutter app:
 * feedingSchedules: [{ time: "08:30", amount: 1.5 }, ...]
 */
export class FeedingScheduleItemDto {
  @IsString()
  @IsNotEmpty()
  time!: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @IsOptional()
  amount?: number;
}

/** Payload the ESP32 sends to POST /api/feeding-logs after a dispense attempt. */
export class CreateFeedingLogFromDeviceDto {
  @IsString()
  @IsNotEmpty({ message: 'scheduleId is required' })
  scheduleId!: string;

  @IsString()
  @IsNotEmpty({ message: 'deviceId is required' })
  deviceId!: string;

  @IsString()
  status!: string;

  @IsOptional()
  @IsNumber()
  targetFeedKg?: number;

  @IsOptional()
  @IsNumber()
  previousHopperWeightKg?: number;

  @IsOptional()
  @IsNumber()
  finalHopperWeightKg?: number;

  @IsOptional()
  @IsNumber()
  actualDispensedKg?: number;

  @IsOptional()
  @IsNumber()
  remainingFeedKg?: number;

  @IsOptional()
  @IsNumber()
  toleranceKg?: number;

  @IsOptional()
  @IsString()
  failureReason?: string;

  @IsOptional()
  @IsNumber()
  startedAt?: number;

  @IsOptional()
  @IsNumber()
  completedAt?: number;

  @IsOptional()
  @IsNumber()
  fedAt?: number;
}