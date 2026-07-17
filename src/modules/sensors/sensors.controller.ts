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

  @Get('data')
  findAllSensorData() {
    return this.sensorsService.findAllSensorData();
  }

  @Get('data/:id')
  findSensorData(@Param('id') id: string) {
    return this.sensorsService.findSensorData(id);
  }
}
