import {
  IsArray,
  IsBoolean,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';

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