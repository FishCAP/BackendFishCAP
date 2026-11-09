import { DevicesController } from './devices.controller';

describe('DevicesController.getPending', () => {
  let controller: DevicesController;
  const devicesService = { findByDeviceCode: jest.fn() };
  const feedScheduleRepo = { find: jest.fn(), findOne: jest.fn(), save: jest.fn() };

  beforeEach(() => {
    jest.clearAllMocks();
    controller = new DevicesController(devicesService as any, feedScheduleRepo as any);
  });

  const getPending = async (code: string) =>
    (await controller.getPending(code)) as { success: boolean; data?: any[]; message?: string };

  it('rejects unknown device codes', async () => {
    devicesService.findByDeviceCode.mockResolvedValue(null);
    const res = await getPending('nope');
    expect(res.success).toBe(false);
  });

  it('returns an empty list for devices not linked to a pond', async () => {
    devicesService.findByDeviceCode.mockResolvedValue({
      deviceCode: 'DEV-1',
      pondId: null,
    });
    const res = await getPending('DEV-1');
    expect(res.success).toBe(true);
    expect(res.data).toEqual([]);
  });

  it('returns active schedules with numeric feedAmount and filters inactive ones', async () => {
    devicesService.findByDeviceCode.mockResolvedValue({
      deviceCode: 'fishcap_001',
      pondId: 'pond-1',
    });
    feedScheduleRepo.find.mockResolvedValue([
      { id: 's-1', feedTime: '10:30:00', feedAmount: '1.50', isActive: true },
      { id: 's-2', feedTime: '15:00:00', feedAmount: '2.00', isActive: false },
    ]);

    const res = await getPending('fishcap_001');

    expect(res.success).toBe(true);
    expect(res.data).toEqual([{ id: 's-1', feedTime: '10:30:00', feedAmount: 1.5 }]);
    // Feed amount must be a number for the firmware (pg returns decimal as string)
    expect(typeof res.data![0].feedAmount).toBe('number');
  });
});
