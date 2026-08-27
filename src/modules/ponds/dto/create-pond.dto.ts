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

/**
 * One feeding entry as sent by the Flutter app:
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

export class CreatePondDto {
  @IsString()
  @IsNotEmpty({ message: 'name is required' })
  name!: string;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsString()
  species?: string;

  @IsOptional()
  @IsNumber()
  estimatedCount?: number;

  @IsOptional()
  @IsString()
  startDate?: string;

  @IsOptional()
  @IsString()
  endDate?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  feedingTimes?: string[];

  // Structured per-time schedule sent by newer app versions.
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(20)
  @ValidateNested({ each: true })
  @Type(() => FeedingScheduleItemDto)
  feedingSchedules?: FeedingScheduleItemDto[];

  @IsOptional()
  @IsNumber()
  amount?: number;

  @IsOptional()
  @IsString()
  hardwareId?: string;

  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsString()
  statusColor?: string;

  @IsOptional()
  @IsBoolean()
  hasAlert?: boolean;

  @IsOptional()
  @IsString()
  temperature?: string;
}
