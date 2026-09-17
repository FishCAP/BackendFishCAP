CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    phone VARCHAR(20),
    profile_image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE otps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(200) NOT NULL,
    code VARCHAR(20) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ponds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    pond_name VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    fish_type VARCHAR(100),
    fish_count INTEGER,
    start_date VARCHAR(20),
    end_date VARCHAR(20),
    feeding_times JSONB,
    amount DECIMAL(10,2),
    hardware_id VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active',
    status_color VARCHAR(20),
    has_alert BOOLEAN DEFAULT FALSE,
    temperature VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT fk_pond_user
    FOREIGN KEY(user_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);

CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pond_id UUID NOT NULL,
    device_code VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'ONLINE' NOT NULL,

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
    device_id VARCHAR(100) NOT NULL,
    temperature DECIMAL(5,2),
    ph DECIMAL(4,2),
    dissolved_oxygen DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notification_user
    FOREIGN KEY(user_id)
    REFERENCES users(id)
);
