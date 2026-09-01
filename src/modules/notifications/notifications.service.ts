import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotificationEntity } from './entities/notification.entity/notification.entity';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(NotificationEntity)
    private readonly notificationsRepository: Repository<NotificationEntity>,
  ) {}

  async create(createNotificationDto: CreateNotificationDto): Promise<NotificationEntity> {
    const notification = this.notificationsRepository.create(createNotificationDto);
    return this.notificationsRepository.save(notification);
  }

    async findAll(userId?: string): Promise<NotificationEntity[]> {
    const where = userId ? { user: { id: userId } } : {};
    const notes = await this.notificationsRepository.find({
      where,
      relations: { user: true },
      order: { createdAt: 'DESC' },
    });
    return notes.map((n) => {
      if (n.user && (n.user as any).passwordHash) {
        const { passwordHash, ...safeUser } = n.user as any;
        return { ...n, user: safeUser } as NotificationEntity;
      }
      return n;
    });
  }

  async findOne(id: string, userId?: string): Promise<NotificationEntity> {
    const where: any = { id };
    if (userId) where.user = { id: userId };
    const notification = await this.notificationsRepository.findOne({
      where,
      relations: { user: true },
    });
    if (!notification) {
      throw new NotFoundException('Notification not found');
    }
    if (notification.user && (notification.user as any).passwordHash) {
      const { passwordHash, ...safeUser } = notification.user as any;
      return { ...notification, user: safeUser } as NotificationEntity;
    }
    return notification;
  }

  /// Mark all of a user's unread notifications as read.
  async markAllRead(userId: string): Promise<{ updated: number }> {
    const result = await this.notificationsRepository.update(
      { user: { id: userId }, isRead: false },
      { isRead: true },
    );
    return { updated: result.affected ?? 0 };
  }

    async update(id: string, updateNotificationDto: UpdateNotificationDto, userId?: string): Promise<NotificationEntity> {
    const notification = await this.findOne(id, userId);
    const updated = { ...notification, ...updateNotificationDto };
    await this.notificationsRepository.save(updated);
    return this.findOne(id, userId);
  }

  async remove(id: string, userId?: string): Promise<void> {
    const where: any = { id };
    if (userId) where.user = { id: userId };
    const result = await this.notificationsRepository.delete(where);
    if (result.affected === 0) {
      throw new NotFoundException('Notification not found');
    }
  }
}
