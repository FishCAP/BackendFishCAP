import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { ReportsService } from './reports.service';
import { PondEntity } from '../ponds/entities/pond.entity/pond.entity';
import { FeedingLogEntity } from '../feeding/entities/feeding-log.entity';
import { SensorDataEntity } from '../sensors/entities/sensor-data.entity';
import { NotificationEntity } from '../notifications/entities/notification.entity/notification.entity';
import { UserEntity } from '../users/entities/user.entity';

// Mock repositories
const mockPondRepository = {
  count: jest.fn(),
  find: jest.fn(),
};

const mockFeedingLogRepository = {
  count: jest.fn(),
};

const mockSensorDataRepository = {
  find: jest.fn(),
};

const mockNotificationRepository = {
  count: jest.fn(),
  find: jest.fn(),
  update: jest.fn(),
};

const mockUserRepository = {
  findOne: jest.fn(),
};

describe('ReportsService', () => {
  let service: ReportsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReportsService,
        {
          provide: getRepositoryToken(PondEntity),
          useValue: mockPondRepository,
        },
        {
          provide: getRepositoryToken(FeedingLogEntity),
          useValue: mockFeedingLogRepository,
        },
        {
          provide: getRepositoryToken(SensorDataEntity),
          useValue: mockSensorDataRepository,
        },
        {
          provide: getRepositoryToken(NotificationEntity),
          useValue: mockNotificationRepository,
        },
        {
          provide: getRepositoryToken(UserEntity),
          useValue: mockUserRepository,
        },
      ],
    }).compile();

    service = module.get<ReportsService>(ReportsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getSummary', () => {
    it('should return summary with active alerts count for a user', async () => {
      const userId = 'user-123';

      // Setup mocks to return specific values for each call
      mockPondRepository.count
        .mockResolvedValueOnce(5) // First call: pondCount
        .mockResolvedValueOnce(2); // Second call: pondsWithAlerts (with where clause)
      
      mockFeedingLogRepository.count.mockResolvedValue(42);
      mockSensorDataRepository.find.mockResolvedValue([]);
      mockNotificationRepository.count.mockResolvedValue(3);

      const result = await service.getSummary(userId);

      expect(result).toEqual({
        pondCount: 5,
        feedLogCount: 42,
        latestSensor: null,
        activeAlertsCount: 3,
        pondsWithAlerts: 2,
        alerts: 3,
      });

      expect(mockNotificationRepository.count).toHaveBeenCalledWith({
        where: { user: { id: userId }, isRead: false },
      });
    });

    it('should return zero alerts when userId is not provided', async () => {
      mockPondRepository.count.mockResolvedValue(5);
      mockFeedingLogRepository.count.mockResolvedValue(42);
      mockSensorDataRepository.find.mockResolvedValue([]);

      const result = await service.getSummary();

      expect(result.activeAlertsCount).toBe(0);
      expect(result.pondsWithAlerts).toBe(5); // Still returns pond count since no userId filter
      expect(result.alerts).toBe(0);
      expect(result.pondCount).toBe(5);
    });
  });

  describe('getActiveAlerts', () => {
    it('should return unread notifications for a user', async () => {
      const userId = 'user-123';
      const mockAlerts = [
        {
          id: 'alert-1',
          title: 'Water temperature alert',
          message: 'Temperature too high',
          isRead: false,
          createdAt: new Date(),
          userId,
          user: { id: userId } as UserEntity,
        },
        {
          id: 'alert-2',
          title: 'Low feed stock',
          message: 'Stock is low',
          isRead: false,
          createdAt: new Date(),
          userId,
          user: { id: userId } as UserEntity,
        },
      ];

      mockNotificationRepository.find.mockResolvedValue(mockAlerts);

      const result = await service.getActiveAlerts(userId);

      expect(result).toHaveLength(2);
      expect(result[0].title).toBe('Water temperature alert');
      expect(result[1].title).toBe('Low feed stock');
      expect(mockNotificationRepository.find).toHaveBeenCalledWith({
        where: { user: { id: userId }, isRead: false },
        relations: { user: true },
        order: { createdAt: 'DESC' },
      });
    });
  });

  describe('getAlertCountsByType', () => {
    it('should categorize alerts by type', async () => {
      const userId = 'user-123';
      const mockAlerts = [
        { id: '1', title: 'Water temperature alert', isRead: false, createdAt: new Date() },
        { id: '2', title: 'Water temperature alert', isRead: false, createdAt: new Date() },
        { id: '3', title: 'Water pH alert', isRead: false, createdAt: new Date() },
        { id: '4', title: 'Low feed stock', isRead: false, createdAt: new Date() },
        { id: '5', title: 'Low feed stock', isRead: false, createdAt: new Date() },
        { id: '6', title: 'Feed dispensed', isRead: false, createdAt: new Date() },
      ];

      mockNotificationRepository.find.mockResolvedValue(mockAlerts);

      const result = await service.getAlertCountsByType(userId);

      expect(result).toEqual({
        total: 6,
        waterTemperature: 2,
        waterPH: 1,
        dissolvedOxygen: 0,
        waterTDS: 0,
        lowStock: 2,
        feedDispensed: 1,
        other: 0,
      });
    });
  });
});