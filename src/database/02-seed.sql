-- Seed initial demo data

-- Enable pgcrypto for hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create a demo user with password 'demo' (SHA256)
INSERT INTO users (full_name, email, password_hash, phone)
VALUES ('Demo User', 'demo@fishcap.local', encode(digest('demo','sha256'), 'hex'), '1234567890')
ON CONFLICT (email) DO NOTHING;

-- Create a demo pond for the demo user
DO $$
DECLARE
  uid UUID;
BEGIN
  SELECT id INTO uid FROM users WHERE email = 'demo@fishcap.local';
  IF uid IS NOT NULL THEN
    INSERT INTO ponds (user_id, pond_name, fish_type, fish_count)
    SELECT uid, 'Demo Pond', 'Tilapia', 50
    WHERE NOT EXISTS (
      SELECT 1 FROM ponds WHERE user_id = uid AND pond_name = 'Demo Pond'
    );
  END IF;
END$$;

-- Create a device for the pond
DO $$
DECLARE
  pid UUID;
BEGIN
  SELECT id INTO pid FROM ponds WHERE pond_name = 'Demo Pond' LIMIT 1;
  IF pid IS NOT NULL THEN
    INSERT INTO devices (pond_id, device_code, status)
    SELECT pid, 'DEMO-DEVICE-001', 'ONLINE'
    WHERE NOT EXISTS (
      SELECT 1 FROM devices WHERE device_code = 'DEMO-DEVICE-001'
    );
  END IF;
END$$;

-- Example feed schedule
DO $$
DECLARE
  pid UUID;
BEGIN
  SELECT id INTO pid FROM ponds WHERE pond_name = 'Demo Pond' LIMIT 1;
  IF pid IS NOT NULL THEN
    INSERT INTO feed_schedules (pond_id, feed_time, feed_amount)
    SELECT pid, '08:00:00', 100.00
    WHERE NOT EXISTS (
      SELECT 1 FROM feed_schedules WHERE pond_id = pid AND feed_time = '08:00:00'
    );
  END IF;
END$$;
