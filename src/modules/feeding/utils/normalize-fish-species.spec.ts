import { normalizeFishSpecies, SpeciesId } from './normalize-fish-species';

describe('normalizeFishSpecies', () => {
  it('normalizes Khmer script to species id', () => {
    expect(normalizeFishSpecies('ត្រីអណ្ដែង')).toBe(SpeciesId.WALKING_CATFISH);
    expect(normalizeFishSpecies('ត្រីប្រា')).toBe(SpeciesId.PANGAS_PRA);
  });

  it('normalizes phonetic Khmer/Latin and English', () => {
    expect(normalizeFishSpecies('Trey Pra')).toBe(SpeciesId.PANGAS_PRA);
    expect(normalizeFishSpecies('Tilapia')).toBe(SpeciesId.TILAPIA);
  });

  it('returns null for unknown', () => {
    expect(normalizeFishSpecies('unknown fish')).toBeNull();
  });
});
