import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { SensorsService } from './sensors.service';
import { CreateDeviceDto } from './dto/create-device.dto';
import { CreateSensorDataDto } from './dto/create-sensor-data.dto';

@Controller('sensors')
export class SensorsController {
  constructor(private readonly sensorsService: SensorsService) {}

  @Post('devices')
  createDevice(@Body() createDeviceDto: CreateDeviceDto) {
    return this.sensorsService.createDevice(createDeviceDto);
  }

  @Get('devices')
  findAllDevices() {
    return this.sensorsService.findAllDevices();
  }

  @Get('devices/:id')
  findDevice(@Param('id') id: string) {
    return this.sensorsService.findDevice(id);
  }

  @Post('data')
  createSensorData(@Body() createSensorDataDto: CreateSensorDataDto) {
    return this.sensorsService.createSensorData(createSensorDataDto);
  }

  // ESP32-friendly endpoint: POST /api/sensor-data
  @Post('sensor-data')
  createSensorDataFromDevice(@Body() createSensorDataDto: CreateSensorDataDto) {
    return this.sensorsService.createSensorData(createSensorDataDto);
  }

  @Get('data')
  findAllSensorData() {
    return this.sensorsService.findAllSensorData();
  }

  // Latest readings for the Flutter SensorDashboard
  @Get('sensor-data/latest')
  getLatestSensorData() {
    return this.sensorsService.findLatestSensorData();
  }

  @Get('data/:id')
  findSensorData(@Param('id') id: string) {
    return this.sensorsService.findSensorData(id);
  }
}
