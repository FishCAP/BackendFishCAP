import { DevicesController } from './devices.controller';

describe('DevicesController.getPending', () => {
  let controller: DevicesController;
  const deviceRepo = { findOne: jest.fn() };
  const feedScheduleRepo = { find: jest.fn(), findOne: jest.fn(), save: jest.fn() };

  beforeEach(() => {
    jest.clearAllMocks();
    controller = new DevicesController(deviceRepo as any, feedScheduleRepo as any);
  });

  const getPending = async (code: string) =>
    (await controller.getPending(code)) as { success: boolean; data?: any[]; message?: string };

  it('rejects unknown device codes', async () => {
    deviceRepo.findOne.mockResolvedValue(null);
    const res = await getPending('nope');
    expect(res.success).toBe(false);
  });

  it('returns an empty list for devices not linked to a pond', async () => {
    deviceRepo.findOne.mockResolvedValue({ deviceCode: 'DEV-1', pond: null });
    const res = await getPending('DEV-1');
    expect(res.success).toBe(true);
    expect(res.data).toEqual([]);
  });

  it('returns active schedules with numeric feedAmount and filters inactive ones', async () => {
    deviceRepo.findOne.mockResolvedValue({
      deviceCode: 'fishcap_001',
      pond: { id: 'pond-1' },
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
