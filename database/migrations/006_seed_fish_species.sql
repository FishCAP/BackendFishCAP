-- Seed core fish species with Khmer and English names, aliases, and growth stages
INSERT INTO fish_species (name_en, name_km, aliases, growth_stages, default_initial_weight)
VALUES
('Tilapia', 'ត្រីតិឡាព្យ៉ា', 
  '["tilapia","trey tilapia","trey tilapiya","trey or te","ត្រីអរតេ"]',
  '[{"name":"fingerling","minWeight":1,"maxWeight":50,"feedingRatePercent":5,"adg":1},{"name":"grow-out","minWeight":51,"maxWeight":500,"feedingRatePercent":3,"adg":3},{"name":"pre-harvest","minWeight":501,"maxWeight":2000,"feedingRatePercent":2,"adg":5}]',
  5
),
('Walking Catfish', 'ត្រីអណ្ដែង', '["walking catfish","trey andeng","trey andeang","ត្រីអណ្ដែង"]',
  '[{"name":"fingerling","minWeight":1,"maxWeight":30,"feedingRatePercent":6,"adg":0.8},{"name":"grow-out","minWeight":31,"maxWeight":300,"feedingRatePercent":4,"adg":2.5},{"name":"pre-harvest","minWeight":301,"maxWeight":2000,"feedingRatePercent":2.5,"adg":4}]',
  4
),
('Pangas / Iridescent Shark', 'ត្រីប្រា', '["pangas","pangas catfish","iridescent shark","trey pra","ត្រីប្រា"]',
  '[{"name":"fingerling","minWeight":1,"maxWeight":50,"feedingRatePercent":5.5,"adg":1.2},{"name":"grow-out","minWeight":51,"maxWeight":800,"feedingRatePercent":3.2,"adg":3.5},{"name":"pre-harvest","minWeight":801,"maxWeight":2000,"feedingRatePercent":2.2,"adg":6}]',
  6
),
('Striped Snakehead', 'ត្រីរស់', '["striped snakehead","trey ros","trey chhdaor","ត្រីឆ្តោ","ត្រីរស់"]',
  '[{"name":"fingerling","minWeight":1,"maxWeight":40,"feedingRatePercent":6.5,"adg":1},{"name":"grow-out","minWeight":41,"maxWeight":600,"feedingRatePercent":4,"adg":3},{"name":"pre-harvest","minWeight":601,"maxWeight":2000,"feedingRatePercent":2.5,"adg":5}]',
  6
),
('Climbing Perch', 'ត្រីក្រាញ់', '["climbing perch","trey kranh","ត្រីក្រាញ់"]',
  '[{"name":"fingerling","minWeight":1,"maxWeight":20,"feedingRatePercent":7,"adg":0.6},{"name":"grow-out","minWeight":21,"maxWeight":200,"feedingRatePercent":4.5,"adg":1.5}]',
  3
),
('Silver Barb', 'ត្រីឆ្ពិន', '["silver barb","trey chhpin","ត្រីឆ្ពិន"]',
  '[{"name":"fingerling","minWeight":1,"maxWeight":30,"feedingRatePercent":6,"adg":0.8},{"name":"grow-out","minWeight":31,"maxWeight":300,"feedingRatePercent":3.5,"adg":2}]',
  4
),
('Small Mud Carp', 'ត្រីរៀល', '["small mud carp","trey riel","ត្រីរៀល"]',
  '[{"name":"fingerling","minWeight":1,"maxWeight":40,"feedingRatePercent":6.5,"adg":0.9},{"name":"grow-out","minWeight":41,"maxWeight":400,"feedingRatePercent":3.5,"adg":2.2}]',
  4
),
('Asian Swamp Eel', 'ត្រីអន្លង់', '["asian swamp eel","trey anlong","ត្រីអន្លង់"]',
  '[{"name":"fingerling","minWeight":1,"maxWeight":30,"feedingRatePercent":6.5,"adg":0.7},{"name":"grow-out","minWeight":31,"maxWeight":500,"feedingRatePercent":4,"adg":2}]',
  5
);

-- Add basic seed for freshwater prawns (macrobrachium). Adjust as needed for local species.
INSERT INTO fish_species (name_en, name_km, aliases, growth_stages, default_initial_weight)
VALUES
('Freshwater Prawn', 'Freshwater Prawn',
  '["prawn","prawns","shrimp","freshwater prawn","macrobrachium"]',
  '[{"name":"juvenile","minWeight":0.1,"maxWeight":5,"feedingRatePercent":8,"adg":0.2},{"name":"grow-out","minWeight":5,"maxWeight":50,"feedingRatePercent":5,"adg":1}]',
  1
);
