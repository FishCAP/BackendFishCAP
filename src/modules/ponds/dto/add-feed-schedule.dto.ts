import { Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

/** Body for POST /api/ponds/:id/feed-schedules ("Add New Time" button). */
export class AddFeedScheduleDto {
  @IsString()
  @IsNotEmpty({ message: 'time is required' })
  time!: string;

  @IsOptional()
  @IsString()
  title?: string;
}