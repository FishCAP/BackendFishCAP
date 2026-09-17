export interface ComputeFeedInput {
  count: number;
  avgWeightGrams: number;
  feedingRatePercent: number; // % of body weight
}

export function computeDailyFeed({ count, avgWeightGrams, feedingRatePercent }: ComputeFeedInput) {
  if (!count || count <= 0) return { totalFeedGrams: 0, totalFeedKg: 0 };
  const totalFeedGrams = count * avgWeightGrams * (feedingRatePercent / 100);
  return { totalFeedGrams, totalFeedKg: totalFeedGrams / 1000 };
}
