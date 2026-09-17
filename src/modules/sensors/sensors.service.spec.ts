import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { SensorsService } from './sensors.service';
import { DeviceEntity } from './entities/device.entity';
import { SensorDataEntity } from './entities/sensor-data.entity';
import { DeviceGateway } from '../devices/device.gateway';
import { NotificationsService } from '../notifications/notifications.service';

describe('SensorsService', () => {
  let service: SensorsService;
  const sensorDataRepository = {
    create: jest.fn(),
    save: jest.fn(),
    findOne: jest.fn(),
  };
  const deviceRepository = {
    findOne: jest.fn(),
  };
  const notificationsService = {
    create: jest.fn(),
    findLatestByTitle: jest.fn(),
  };
  const deviceGateway = {
    broadcastSensorData: jest.fn(),
    broadcastNotification: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SensorsService,
        {
          provide: getRepositoryToken(SensorDataEntity),
          useValue: sensorDataRepository,
        },
        {
          provide: getRepositoryToken(DeviceEntity),
          useValue: deviceRepository,
        },
        {
          provide: NotificationsService,
          useValue: notificationsService,
        },
        {
          provide: DeviceGateway,
          useValue: deviceGateway,
        },
      ],
    }).compile();

    service = module.get<SensorsService>(SensorsService);
    jest.clearAllMocks();
  });

  /** Wire the repository mocks for a reading from a registered device. */
  const setupOwnerDevice = (deviceId: string) => {
    sensorDataRepository.create.mockImplementation((dto) => dto);
    sensorDataRepository.save.mockImplementation(async (dto) => ({
      id: 'sensor-1',
      createdAt: new Date(),
      ...dto,
    }));
    deviceRepository.findOne.mockResolvedValue({
      deviceCode: deviceId,
      pond: { owner: { id: 'user-123' } },
    });
    notificationsService.create.mockResolvedValue({
      id: 'note-1',
      createdAt: new Date(),
    });
  };

  it('should create a low-stock notification when a device crosses into low stock', async () => {
    const incoming = {
      deviceId: 'DEVICE-001',
      remainingStockGrams: 75,
      lowStock: true,
    };

    const saved = {
      id: 'sensor-1',
      ...incoming,
      createdAt: new Date(),
    };

    sensorDataRepository.create.mockImplementation((dto) => dto);
    sensorDataRepository.save.mockResolvedValue(saved);
    sensorDataRepository.findOne.mockResolvedValue(null);
    deviceRepository.findOne.mockResolvedValue({
      deviceCode: 'DEVICE-001',
      pond: { owner: { id: 'user-123' } },
    });
    notificationsService.create.mockResolvedValue({ id: 'note-1' });

    await service.createSensorData(incoming as any);

    expect(notificationsService.create).toHaveBeenCalledWith(
      expect.objectContaining({
        userId: 'user-123',
        title: 'Low feed stock',
        message: expect.stringContaining('DEVICE-001'),
      }),
    );
  });

  it('should create a pH alert when pH crosses below the safe window', async () => {
    setupOwnerDevice('DEVICE-001');
    sensorDataRepository.findOne.mockResolvedValue(null); // no previous reading

    await service.createSensorData({ deviceId: 'DEVICE-001', ph: 5.2 } as any);

    expect(notificationsService.create).toHaveBeenCalledWith(
      expect.objectContaining({
        userId: 'user-123',
        title: 'Water pH alert',
        message: expect.stringContaining('5.20'),
      }),
    );
    expect(deviceGateway.broadcastNotification).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Water pH alert', deviceId: 'DEVICE-001' }),
    );
  });

  it('should not repeat the pH alert while pH stays out of range', async () => {
    setupOwnerDevice('DEVICE-001');
    sensorDataRepository.findOne.mockResolvedValue({
      id: 'sensor-0',
      deviceId: 'DEVICE-001',
      ph: 5.4, // previous reading already out of range
      createdAt: new Date(),
    });

    await service.createSensorData({ deviceId: 'DEVICE-001', ph: 5.1 } as any);

    expect(notificationsService.create).not.toHaveBeenCalled();
    expect(deviceGateway.broadcastNotification).not.toHaveBeenCalled();
  });

  it('should create a dissolved-oxygen alert when DO drops below the floor', async () => {
    setupOwnerDevice('DEVICE-001');
    sensorDataRepository.findOne.mockResolvedValue(null);

    await service.createSensorData({
      deviceId: 'DEVICE-001',
      dissolvedOxygen: 2.1,
    } as any);

    expect(notificationsService.create).toHaveBeenCalledWith(
      expect.objectContaining({
        userId: 'user-123',
        title: 'Dissolved oxygen alert',
        message: expect.stringContaining('2.1'),
      }),
    );
    expect(deviceGateway.broadcastNotification).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Dissolved oxygen alert' }),
    );
  });

  it('should not alert when pH and DO are inside the safe window', async () => {
    setupOwnerDevice('DEVICE-001');
    sensorDataRepository.findOne.mockResolvedValue(null);

    await service.createSensorData({
      deviceId: 'DEVICE-001',
      ph: 7.4,
      dissolvedOxygen: 6.0,
    } as any);

    expect(notificationsService.create).not.toHaveBeenCalled();
    expect(deviceGateway.broadcastNotification).not.toHaveBeenCalled();
  });
});
