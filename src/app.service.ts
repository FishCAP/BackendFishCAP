import { Injectable } from '@nestjs/common';

interface UserProfile {
  id: string;
  fullName: string;
  email: string;
  username: string;
  phoneNumber?: string;
  createdAt: string;
}

@Injectable()
export class AppService {
  private readonly users = new Map<string, UserProfile>();
  private readonly sessions = new Map<string, { token: string; user: UserProfile }>();

  getHello() {
    return {
      success: true,
      message: 'FishCap API is running',
      data: {
        service: 'fishcap-backend',
        status: 'healthy',
      },
    };
  }

  getHealth() {
    return {
      success: true,
      data: {
        status: 'healthy',
      },
    };
  }

  login(payload: { username?: string; email?: string; password: string }) {
    const identifier = (payload.email ?? payload.username ?? '').trim().toLowerCase();
    const password = payload.password ?? '';

    const demoUser: UserProfile = {
      id: 'demo-user',
      fullName: 'Demo User',
      email: 'demo@fishcap.com',
      username: 'demo',
      phoneNumber: '+1234567890',
      createdAt: new Date().toISOString(),
    };

    if ((identifier === 'demo' || identifier === 'demo@fishcap.com') && password === 'password123') {
      const token = `demo-token-${Date.now()}`;
      this.sessions.set(token, { token, user: demoUser });
      return {
        success: true,
        data: {
          token,
          user: demoUser,
        },
      };
    }

    const storedUser = this.users.get(identifier);
    if (!storedUser || password.length < 6) {
      return {
        success: false,
        message: 'Invalid credentials',
      };
    }

    const token = `token-${storedUser.id}-${Date.now()}`;
    this.sessions.set(token, { token, user: storedUser });

    return {
      success: true,
      data: {
        token,
        user: storedUser,
      },
    };
  }

  register(payload: { fullName?: string; email?: string; username?: string; phoneNumber?: string; password?: string }) {
    const email = (payload.email ?? '').trim().toLowerCase();
    const username = (payload.username ?? email.split('@')[0] ?? '').trim().toLowerCase();
    const password = payload.password ?? '';

    if (!email || !username || password.length < 6) {
      return {
        success: false,
        message: 'Please provide a valid email, username, and password',
      };
    }

    if (this.users.has(email) || this.users.has(username)) {
      return {
        success: false,
        message: 'User already exists',
      };
    }

    const user: UserProfile = {
      id: `user-${Date.now()}`,
      fullName: payload.fullName ?? username,
      email,
      username,
      phoneNumber: payload.phoneNumber,
      createdAt: new Date().toISOString(),
    };

    this.users.set(email, user);
    this.users.set(username, user);

    const token = `token-${user.id}-${Date.now()}`;
    this.sessions.set(token, { token, user });

    return {
      success: true,
      data: {
        token,
        user,
      },
    };
  }

  getCurrentUser(authorization?: string) {
    const token = authorization?.replace('Bearer ', '').trim();
    const session = token ? this.sessions.get(token) : undefined;

    if (!session) {
      return {
        success: false,
        message: 'Authentication required',
      };
    }

    return {
      success: true,
      data: session.user,
    };
  }

  getWaterQuality() {
    return {
      success: true,
      data: {
        temperature: 24.8,
        ph: 7.2,
        ammonia: 0.12,
        dissolvedOxygen: 6.8,
        status: 'Healthy',
      },
    };
  }

  getSchedules() {
    return {
      success: true,
      data: [
        { id: '1', title: 'Feed fish', time: '08:00', status: 'Scheduled' },
        { id: '2', title: 'Check pH', time: '12:00', status: 'Pending' },
      ],
    };
  }

  getHistory() {
    return {
      success: true,
      data: [
        { id: '1', event: 'Water quality check', date: '2026-08-04' },
        { id: '2', event: 'Feeding completed', date: '2026-08-03' },
      ],
    };
  }

  getNotifications() {
    return {
      success: true,
      data: [
        { id: '1', message: 'Water quality is stable', read: false },
        { id: '2', message: 'Feeding reminder scheduled for 8:00 AM', read: true },
      ],
    };
  }
}
