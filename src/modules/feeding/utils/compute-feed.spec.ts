import { computeDailyFeed } from './compute-feed';

describe('computeDailyFeed', () => {
  it('computes zero when count is zero', () => {
    expect(computeDailyFeed({ count: 0, avgWeightGrams: 10, feedingRatePercent: 5 }).totalFeedGrams).toBe(0);
  });

  it('computes expected feed for given inputs', () => {
    const res = computeDailyFeed({ count: 1000, avgWeightGrams: 50, feedingRatePercent: 3 });
    // 1000 * 50g * 3% = 1500 g
    expect(Math.round(res.totalFeedGrams)).toBe(1500);
    expect(res.totalFeedKg).toBeCloseTo(1.5);
  });
});
