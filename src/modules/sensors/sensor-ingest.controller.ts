import { Body, Controller, Get, Post } from '@nestjs/common';
import { CreateSensorDataDto } from './dto/create-sensor-data.dto';
import { SensorsService } from './sensors.service';

/** Public hardware API; authentication can be added here later without changing dashboard routes. */
@Controller()
export class SensorIngestController {
  constructor(private readonly sensorsService: SensorsService) {}

  @Post('sensor-data')
  async ingest(@Body() dto: CreateSensorDataDto) {
    return { success: true, data: await this.sensorsService.createSensorData(dto) };
  }

  @Get('sensor-data/latest')
  async latest() {
    return { success: true, data: await this.sensorsService.findLatestSensorData() };
  }
}
