import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { FeedingScheduleItemDto } from './create-pond.dto';

export class UpdatePondDto {
  @IsOptional()
  @IsString()
  name?: string;

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
