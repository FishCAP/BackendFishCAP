import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { AppService } from './app.service';

describe('AppController', () => {
  let appController: AppController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [AppService],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('root', () => {
    it('should return a healthy API response', () => {
      const response = appController.getHello();
      expect(response.success).toBe(true);
      expect(response.message).toContain('FishCap API');
    });
  });

  describe('auth', () => {
    it('should return a success payload for login requests', () => {
      const response = appController.login({ username: 'demo', password: 'password123' });
      expect(response.success).toBe(true);
      expect(response.data.token).toBeDefined();
    });
  });
});
