-- Required for databases that already contain ponds created before `name`
-- became mandatory.  It preserves the most useful existing label.
UPDATE ponds
SET name = COALESCE(NULLIF(trim(location), ''), 'Unnamed pond')
WHERE name IS NULL OR trim(name) = '';

ALTER TABLE ponds
  ALTER COLUMN name SET NOT NULL;
