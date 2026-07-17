CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ponds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    pond_name VARCHAR(100) NOT NULL,
    fish_type VARCHAR(100),
    fish_count INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pond_user
    FOREIGN KEY(user_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);

CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pond_id UUID NOT NULL,
    device_code VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'ONLINE',

    CONSTRAINT fk_device_pond
    FOREIGN KEY(pond_id)
    REFERENCES ponds(id)
    ON DELETE CASCADE
);

CREATE TABLE feed_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pond_id UUID NOT NULL,
    feed_time TIME NOT NULL,
    feed_amount DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_schedule_pond
    FOREIGN KEY(pond_id)
    REFERENCES ponds(id)
    ON DELETE CASCADE
);

CREATE TABLE feeding_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pond_id UUID NOT NULL,
    schedule_id UUID,
    feed_amount DECIMAL(10,2),
    status VARCHAR(20),
    fed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_log_pond
    FOREIGN KEY(pond_id)
    REFERENCES ponds(id),

    CONSTRAINT fk_log_schedule
    FOREIGN KEY(schedule_id)
    REFERENCES feed_schedules(id)
);

CREATE TABLE sensor_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL,
    temperature DECIMAL(5,2),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_sensor_device
    FOREIGN KEY(device_id)
    REFERENCES devices(id)
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    title VARCHAR(200),
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notification_user
    FOREIGN KEY(user_id)
    REFERENCES users(id)
);