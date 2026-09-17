import { Injectable, Logger } from '@nestjs/common';
import { WebSocketGateway, WebSocketServer, OnGatewayConnection, OnGatewayDisconnect } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({ path: '/ws', cors: { origin: '*' } })
@Injectable()
export class DeviceGateway implements OnGatewayConnection, OnGatewayDisconnect {
  private readonly logger = new Logger('DeviceGateway');
  @WebSocketServer()
  server: Server;

  // Map deviceCode -> socket id
  private deviceSockets = new Map<string, string>();

  handleConnection(client: Socket) {
    const deviceId = client.handshake.query?.deviceId as string | undefined;
    if (deviceId) {
      this.deviceSockets.set(deviceId, client.id);
      this.logger.log(`[WS] Device connected: ${deviceId} (socket=${client.id})`);
      this.server.to(client.id).emit('device_status', { deviceId, status: 'online' });
    } else {
      this.logger.log(`[WS] Client connected: ${client.id}`);
    }
  }

  handleDisconnect(client: Socket) {
    // Remove any map entries that reference this socket id.
    for (const [deviceId, socketId] of this.deviceSockets.entries()) {
      if (socketId === client.id) {
        this.deviceSockets.delete(deviceId);
        this.logger.log(`[WS] Device disconnected: ${deviceId} (socket=${client.id})`);
        break;
      }
    }
  }

  /** Send a schedule update to a specific device by deviceCode. */
  async sendScheduleToDevice(deviceCode: string, payload: unknown): Promise<boolean> {
    const socketId = this.deviceSockets.get(deviceCode);
    this.logger.log(`[SCHEDULE] Sending update to ${deviceCode} (socket=${socketId ?? 'none'})`);
    if (!socketId) return false;
    try {
      this.server.to(socketId).emit('schedule_update', payload);
      return true;
    } catch (err) {
      this.logger.error('[SCHEDULE] Error sending schedule', err as any);
      return false;
    }
  }

  /**
   * Send a configuration update to a device when it is reassigned to a new pond.
   * The ESP32 should acknowledge this to confirm it received the new config.
   */
  async sendDeviceConfig(
    deviceCode: string,
    config: { hardware_id: string; pond_id: string; status: string },
  ): Promise<boolean> {
    const socketId = this.deviceSockets.get(deviceCode);
    this.logger.log(`[CONFIG] Sending config to ${deviceCode} (socket=${socketId ?? 'none'})`);
    if (!socketId) return false;
    try {
      this.server.to(socketId).emit('device_config', config);
      return true;
    } catch (err) {
      this.logger.error('[CONFIG] Error sending device config', err as any);
      return false;
    }
  }

  broadcastSensorData(payload: unknown) {
    this.server.emit('sensor_update', payload);
  }

  /** Push a backend-created alert to every connected dashboard client. */
  broadcastNotification(payload: unknown) {
    this.server.emit('notification', payload);
  }
}
