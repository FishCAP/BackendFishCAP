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

  async findAll(): Promise<NotificationEntity[]> {
    return this.notificationsRepository.find({ relations: { user: true } });
  }

  async findOne(id: string): Promise<NotificationEntity> {
    const notification = await this.notificationsRepository.findOne({ where: { id }, relations: { user: true } });
    if (!notification) {
      throw new NotFoundException('Notification not found');
    }
    return notification;
  }

  async update(id: string, updateNotificationDto: UpdateNotificationDto): Promise<NotificationEntity> {
    const notification = await this.findOne(id);
    const updated = { ...notification, ...updateNotificationDto };
    await this.notificationsRepository.save(updated);
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    const result = await this.notificationsRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Notification not found');
    }
  }
}
