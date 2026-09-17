export enum SpeciesId {
  TILAPIA = 'TILAPIA',
  WALKING_CATFISH = 'WALKING_CATFISH',
  PANGAS_PRA = 'PANGAS_PRA',
  STRIPED_SNAKEHEAD = 'STRIPED_SNAKEHEAD',
  CLIMBING_PERCH = 'CLIMBING_PERCH',
  SILVER_BARB = 'SILVER_BARB',
  SMALL_MUD_CARP = 'SMALL_MUD_CARP',
  ASIAN_SWAMP_EEL = 'ASIAN_SWAMP_EEL',
  PRAWN = 'PRAWN',
}

const MAPPINGS: { keys: string[]; id: SpeciesId }[] = [
  { keys: ['tilapia', 'trey tilapia', 'trey tilapiya', 'ត្រីតិឡាព្យ៉ា', 'ត្រីអរតេ', 'trey or te', 'trey or te'], id: SpeciesId.TILAPIA },
  { keys: ['walking catfish', 'trey andeng', 'ត្រីអណ្ដែង', 'trey andeang'], id: SpeciesId.WALKING_CATFISH },
  { keys: ['pangas', 'pangas catfish', 'iridescent shark', 'trey pra', 'ត្រីប្រា'], id: SpeciesId.PANGAS_PRA },
  { keys: ['striped snakehead', 'trey ros', 'trey chhdaor', 'ត្រីរស់', 'ត្រីឆ្តោ'], id: SpeciesId.STRIPED_SNAKEHEAD },
  { keys: ['climbing perch', 'trey kranh', 'ត្រីក្រាញ់'], id: SpeciesId.CLIMBING_PERCH },
  { keys: ['silver barb', 'trey chhpin', 'ត្រីឆ្ពិន'], id: SpeciesId.SILVER_BARB },
  { keys: ['small mud carp', 'trey riel', 'ត្រីរៀល'], id: SpeciesId.SMALL_MUD_CARP },
  { keys: ['asian swamp eel', 'trey anlong', 'ត្រីអន្លង់'], id: SpeciesId.ASIAN_SWAMP_EEL },
    { keys: ['prawn', 'prawns', 'shrimp', 'freshwater prawn', 'macrobrachium', 'ចិញ្ចឹមទារស់'], id: SpeciesId.PRAWN },
];

export function normalizeFishSpecies(input: string): SpeciesId | null {
  if (!input) return null;
  const normalized = input.trim().toLowerCase().replace(/\s+/g, ' ');
  for (const m of MAPPINGS) {
    for (const k of m.keys) {
      if (normalized === k || normalized.includes(k)) {
        return m.id;
      }
    }
  }
  return null;
}
