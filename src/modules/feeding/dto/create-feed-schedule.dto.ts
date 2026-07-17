export class CreateFeedScheduleDto {
  pondId: string;
  feedTime: string;
  feedAmount: number;
  isActive?: boolean;
}
