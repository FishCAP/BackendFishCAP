import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import {
  App,
  ServiceAccount,
  cert,
  getApp,
  getApps,
  initializeApp,
} from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';
import { Repository } from 'typeorm';
import { NotificationEntity } from './entities/notification.entity/notification.entity';
import { NotificationDeviceTokenEntity } from './entities/notification-device-token.entity';

@Injectable()
export class PushNotificationsService {
  private readonly logger = new Logger(PushNotificationsService.name);
  private firebaseApp: App | null = null;
  private configurationWarningLogged = false;

  constructor(
    @InjectRepository(NotificationDeviceTokenEntity)
    private readonly deviceTokensRepository: Repository<NotificationDeviceTokenEntity>,
  ) {}

  async registerToken(
    userId: string,
    token: string,
  ): Promise<{ success: true }> {
    await this.deviceTokensRepository.upsert({ userId, token }, ['token']);
    return { success: true };
  }

  async removeToken(userId: string, token: string): Promise<{ success: true }> {
    await this.deviceTokensRepository.delete({ userId, token });
    return { success: true };
  }

  async sendToUser(
    userId: string,
    notification: NotificationEntity,
  ): Promise<void> {
    const app = this.getFirebaseApp();
    if (!app) return;

    let tokens: NotificationDeviceTokenEntity[];
    try {
      tokens = await this.deviceTokensRepository.find({
        where: { userId },
        select: { token: true },
      });
    } catch (error) {
      this.logger.error(
        `Failed to load device tokens for user ${userId}: ${
          error instanceof Error ? error.message : String(error)
        }`,
      );
      return;
    }
    if (tokens.length === 0) return;

    const messaging = getMessaging(app);
    await Promise.all(
      tokens.map(async ({ token }) => {
        try {
          await messaging.send({
            token,
            notification: {
              title: notification.title,
              body: notification.message ?? '',
            },
            data: { notificationId: notification.id },
            android: {
              priority: 'high',
              notification: { channelId: 'fishcap_channel' },
            },
          });
        } catch (error) {
          const code =
            typeof error === 'object' && error !== null && 'code' in error
              ? String(error.code)
              : '';
          if (
            code === 'messaging/registration-token-not-registered' ||
            code === 'messaging/invalid-registration-token'
          ) {
            await this.deviceTokensRepository.delete({ token });
            this.logger.warn('Removed an expired notification device token');
            return;
          }

          this.logger.error(
            `Failed to send notification ${notification.id}: ${
              error instanceof Error ? error.message : String(error)
            }`,
          );
        }
      }),
    );
  }

  private getFirebaseApp(): App | null {
    if (this.firebaseApp) return this.firebaseApp;

    const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
    if (!serviceAccountJson) {
      if (!this.configurationWarningLogged) {
        this.logger.warn(
          'Push notifications are disabled; set FIREBASE_SERVICE_ACCOUNT_JSON in the hosting environment.',
        );
        this.configurationWarningLogged = true;
      }
      return null;
    }

    try {
      const serviceAccount = JSON.parse(serviceAccountJson) as ServiceAccount;
      this.firebaseApp = getApps().length
        ? getApp()
        : initializeApp({ credential: cert(serviceAccount) });
      return this.firebaseApp;
    } catch (error) {
      this.logger.error(
        `Firebase Admin initialization failed: ${
          error instanceof Error ? error.message : String(error)
        }`,
      );
      return null;
    }
  }
}
