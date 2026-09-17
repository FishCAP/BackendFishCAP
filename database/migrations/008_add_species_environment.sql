-- Add environment jsonb column to fish_species and set defaults for prawns
ALTER TABLE fish_species ADD COLUMN IF NOT EXISTS environment jsonb;

-- Set a reasonable environment for freshwater prawns (example values)
UPDATE fish_species
SET environment = '{"temperature": {"min": 22, "max": 30}, "ph": {"min": 6.5, "max": 8.5}, "oxygen": {"min": 4}}'
WHERE name_en ILIKE 'Freshwater Prawn' OR name_en ILIKE 'prawn';
