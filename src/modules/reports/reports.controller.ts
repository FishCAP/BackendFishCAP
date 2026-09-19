import { Controller, Get, Req, Query } from '@nestjs/common';
import { ReportsService } from './reports.service';

@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get('summary')
  getSummary(@Req() req: any, @Query('userId') userId?: string) {
    // Use userId from query param or from authenticated user
    const userIdentifier = userId || req.user?.id;
    return this.reportsService.getSummary(userIdentifier);
  }

  @Get('active-alerts')
  getActiveAlerts(@Req() req: any) {
    const userId = req.user?.id;
    if (!userId) {
      return { success: false, message: 'Authentication required' };
    }
    return { success: true, data: this.reportsService.getActiveAlerts(userId) };
  }

  @Get('alert-counts')
  getAlertCounts(@Req() req: any) {
    const userId = req.user?.id;
    if (!userId) {
      return { success: false, message: 'Authentication required' };
    }
    return { success: true, data: this.reportsService.getAlertCountsByType(userId) };
  }
}
