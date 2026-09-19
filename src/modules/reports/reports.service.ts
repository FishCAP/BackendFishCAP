import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PondEntity } from '../ponds/entities/pond.entity/pond.entity';
import { FeedingLogEntity } from '../feeding/entities/feeding-log.entity';
import { SensorDataEntity } from '../sensors/entities/sensor-data.entity';
import { NotificationEntity } from '../notifications/entities/notification.entity/notification.entity';
import { UserEntity } from '../users/entities/user.entity';

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(PondEntity)
    private readonly pondRepository: Repository<PondEntity>,
    @InjectRepository(FeedingLogEntity)
    private readonly feedingLogRepository: Repository<FeedingLogEntity>,
    @InjectRepository(SensorDataEntity)
    private readonly sensorDataRepository: Repository<SensorDataEntity>,
    @InjectRepository(NotificationEntity)
    private readonly notificationRepository: Repository<NotificationEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
  ) {}

  async getSummary(userId?: string) {
    const pondCount = userId
      ? await this.pondRepository.count({ where: { owner: { id: userId } } })
      : await this.pondRepository.count();

    const feedLogCount = userId
      ? await this.feedingLogRepository.count({
          where: { pond: { owner: { id: userId } } },
        })
      : await this.feedingLogRepository.count();

    const latestSensor = await this.sensorDataRepository.find({
      order: { createdAt: 'DESC' },
      take: 1,
    });

    // Active alerts count (unread notifications for the user)
    const activeAlertsCount = userId
      ? await this.notificationRepository.count({
          where: { user: { id: userId }, isRead: false },
        })
      : 0;

    // Total unread notifications
    const totalUnreadNotifications = userId
      ? await this.notificationRepository.count({
          where: { user: { id: userId }, isRead: false },
        })
      : 0;

    // Ponds with active alerts (has_alert = true and status = 'active')
    const pondsWithAlerts = userId
      ? await this.pondRepository.count({
          where: {
            owner: { id: userId },
            hasAlert: true,
            status: 'active',
          },
        })
      : await this.pondRepository.count({
          where: { hasAlert: true, status: 'active' },
        });

    return {
      pondCount,
      feedLogCount,
      latestSensor: latestSensor[0] ?? null,
      activeAlertsCount: totalUnreadNotifications,
      pondsWithAlerts,
      // For backward compatibility
      alerts: totalUnreadNotifications,
    };
  }

  /**
   * Get active alerts for a user - unread notifications that represent
   * current alert conditions (water quality, low stock, etc.)
   */
  async getActiveAlerts(userId: string) {
    const alerts = await this.notificationRepository.find({
      where: { user: { id: userId }, isRead: false },
      relations: { user: true },
      order: { createdAt: 'DESC' },
    });

    return alerts.map((n) => {
      if (n.user && (n.user as any).passwordHash) {
        const { passwordHash, ...safeUser } = n.user as any;
        return { ...n, user: safeUser } as NotificationEntity;
      }
      return n;
    });
  }

  /**
   * Get alert counts by type for dashboard visualization
   */
  async getAlertCountsByType(userId: string) {
    const alerts = await this.notificationRepository.find({
      where: { user: { id: userId }, isRead: false },
      order: { createdAt: 'DESC' },
    });

    const counts = {
      total: alerts.length,
      waterTemperature: 0,
      waterPH: 0,
      dissolvedOxygen: 0,
      waterTDS: 0,
      lowStock: 0,
      feedDispensed: 0,
      other: 0,
    };

    for (const alert of alerts) {
      const title = alert.title?.toLowerCase() ?? '';
      if (title.includes('temperature')) {
        counts.waterTemperature++;
      } else if (title.includes('ph')) {
        counts.waterPH++;
      } else if (title.includes('oxygen')) {
        counts.dissolvedOxygen++;
      } else if (title.includes('tds')) {
        counts.waterTDS++;
      } else if (title.includes('stock')) {
        counts.lowStock++;
      } else if (title.includes('feed dispensed')) {
        counts.feedDispensed++;
      } else {
        counts.other++;
      }
    }

    return counts;
  }
}
