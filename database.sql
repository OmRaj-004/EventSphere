-- EventSphere Database Schema
-- PostgreSQL Version

-- Create database
CREATE DATABASE eventsphere;

-- Connect to eventsphere database
\c eventsphere;

-- Drop old tables in correct order so a single database holds every required table
DROP TABLE IF EXISTS bills;
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS venues;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS login_tokens;
DROP TABLE IF EXISTS password_resets;
DROP TABLE IF EXISTS promocodes;
DROP TABLE IF EXISTS customer_users;
DROP TABLE IF EXISTS host_users;
DROP TABLE IF EXISTS admin_users;

-- Create dedicated admin table
CREATE TABLE admin_users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create dedicated customer table
CREATE TABLE customer_users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create dedicated host table (venue owners; separate from admins/customers)
CREATE TABLE host_users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create venues table
CREATE TABLE venues (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    location VARCHAR(255) NOT NULL,
    event_type VARCHAR(50) NOT NULL DEFAULT 'OTHER',
    max_capacity INTEGER NOT NULL CHECK (max_capacity > 0),
    hourly_rate DECIMAL(10, 2) NOT NULL CHECK (hourly_rate >= 0),
    amenities TEXT,
    image_url VARCHAR(255),
    available BOOLEAN NOT NULL DEFAULT TRUE,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE','MAINTENANCE','INACTIVE')),
    created_by INTEGER,
    host_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    FOREIGN KEY (host_id) REFERENCES host_users(id) ON DELETE SET NULL
);

-- Create events table
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    event_type VARCHAR(50) NOT NULL,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    expected_guests INTEGER,
    organizer_id INTEGER,
    venue_id INTEGER,
    status VARCHAR(20) DEFAULT 'DRAFT' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (venue_id) REFERENCES venues(id) ON DELETE SET NULL
);

-- Create bookings table
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    booking_number VARCHAR(50) UNIQUE NOT NULL,
    event_id INTEGER NOT NULL,
    venue_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    booking_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    advance_paid DECIMAL(10, 2) DEFAULT 0,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    promo_id INTEGER,
    status VARCHAR(20) DEFAULT 'PENDING' NOT NULL CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED')),
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (venue_id) REFERENCES venues(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customer_users(id) ON DELETE CASCADE
);

-- Create bills table (one invoice per booking, created with the booking)
CREATE TABLE bills (
    id SERIAL PRIMARY KEY,
    bill_number VARCHAR(50) UNIQUE NOT NULL,
    booking_id INTEGER UNIQUE NOT NULL,
    customer_id INTEGER NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    advance_paid DECIMAL(10, 2) NOT NULL DEFAULT 0,
    balance_due DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ISSUED' CHECK (status IN ('ISSUED', 'PAID', 'CANCELLED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customer_users(id) ON DELETE CASCADE
);

-- Create feedback table
CREATE TABLE feedback (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER,
    customer_id INTEGER NOT NULL,
    venue_id INTEGER NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    image_url VARCHAR(255),
    admin_reply TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
    FOREIGN KEY (customer_id) REFERENCES customer_users(id) ON DELETE CASCADE,
    FOREIGN KEY (venue_id) REFERENCES venues(id) ON DELETE CASCADE
);

-- Password reset tokens (SHA-256 hash of the raw token, single use, expiring)
CREATE TABLE password_resets (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'CUSTOMER', 'HOST')),
    token_hash VARCHAR(64) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- In-app notifications (bell + center per role; email hook documented in NotificationDAO)
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    user_role VARCHAR(20) NOT NULL CHECK (user_role IN ('ADMIN', 'CUSTOMER', 'HOST')),
    title VARCHAR(150) NOT NULL,
    body TEXT,
    link VARCHAR(255),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Persistent login tokens ("remember me", SHA-256 hash stored, raw token in cookie)
CREATE TABLE login_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    user_role VARCHAR(20) NOT NULL CHECK (user_role IN ('ADMIN', 'CUSTOMER', 'HOST')),
    token_hash VARCHAR(64) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Promo / discount codes applied at booking time
CREATE TABLE promocodes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) UNIQUE NOT NULL,
    percent_off INTEGER NOT NULL CHECK (percent_off >= 1 AND percent_off <= 90),
    max_uses INTEGER NOT NULL DEFAULT 100,
    used_count INTEGER NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Link bookings to the promo that discounted them (added after promocodes exists)
ALTER TABLE bookings ADD CONSTRAINT bookings_promo_fk FOREIGN KEY (promo_id) REFERENCES promocodes(id) ON DELETE SET NULL;

-- Admin/host action audit trail
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    actor_id INTEGER,
    actor_role VARCHAR(20) NOT NULL,
    action VARCHAR(50) NOT NULL,
    target_type VARCHAR(50),
    target_id INTEGER,
    detail TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for faster lookups
CREATE INDEX idx_admin_users_email ON admin_users(email);
CREATE INDEX idx_customer_users_email ON customer_users(email);
CREATE INDEX idx_venues_created_by ON venues(created_by);
CREATE INDEX idx_venues_event_type ON venues(event_type);
CREATE INDEX idx_venues_location ON venues(location);
CREATE INDEX idx_venues_status ON venues(status);
CREATE INDEX idx_events_organizer_id ON events(organizer_id);
CREATE INDEX idx_events_venue_id ON events(venue_id);
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_bookings_customer_id ON bookings(customer_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_venue_id ON bookings(venue_id);
CREATE INDEX idx_bookings_venue_date ON bookings(venue_id, booking_date);
CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);
CREATE INDEX idx_bills_booking_id ON bills(booking_id);
CREATE INDEX idx_bills_customer_id ON bills(customer_id);
CREATE INDEX idx_feedback_venue_id ON feedback(venue_id);
CREATE INDEX idx_notifications_user ON notifications(user_id, user_role, is_read);
CREATE INDEX idx_password_resets_token ON password_resets(token_hash);
CREATE INDEX idx_login_tokens_token ON login_tokens(token_hash);
CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_role, created_at);
CREATE UNIQUE INDEX idx_feedback_booking_customer ON feedback(booking_id, customer_id) WHERE booking_id IS NOT NULL;

-- Insert sample users into the separate tables
-- password_hash values are BCrypt (cost 12) hashes, verified working with LoginServlet:
--   admin@eventsphere.com / Admin@141#233
--   john@example.com / password, jane@example.com / password
INSERT INTO admin_users (full_name, email, password_hash) VALUES
('Admin User', 'admin@eventsphere.com', '$2a$12$xJj5u3FGkgbR.BsYlIMMe.Oi0b5endMWwSmSuhhnoAUAc/yDkwcnG');

INSERT INTO customer_users (full_name, email, password_hash) VALUES
('John Doe', 'john@example.com', '$2a$12$N3bxNz16mSwK/BMlH56L/.3Oc72cTKw0qXu7EN0bnWVTRa4EJWHD6'),
('Jane Smith', 'jane@example.com', '$2a$12$N3bxNz16mSwK/BMlH56L/.3Oc72cTKw0qXu7EN0bnWVTRa4EJWHD6');

-- Sample host account (login with role HOST, password Host@1234)
INSERT INTO host_users (full_name, email, password_hash) VALUES
('Harbor Host', 'host@eventsphere.com', '$2a$12$2NRTPZYiXpMWV35QaJK.mu4rMNfNrdLN/Ye.pYSNaXRr5xgM7gTHy');

-- Sample promo codes
INSERT INTO promocodes (code, percent_off, max_uses) VALUES
('WELCOME10', 10, 100),
('FESTIVE20', 20, 50);

-- Insert venues (all AVAILABLE so they are bookable right after setup)
INSERT INTO venues (name, description, location, event_type, max_capacity, hourly_rate, amenities, image_url, available, status, created_by) VALUES
('Grand Ballroom', 'Elegant ballroom perfect for weddings and corporate events', '123 Main Street, Downtown', 'WEDDING', 500, 2500.00, 'AC, Parking, Catering, Stage', '/images/grand-ballroom.jpg', TRUE, 'AVAILABLE', 1),
('Riverside Garden', 'Beautiful outdoor garden venue with scenic views', '456 Park Avenue, Riverside', 'PARTY', 300, 1500.00, 'Garden, Parking, Lighting, Bar', '/images/riverside-garden.jpg', TRUE, 'AVAILABLE', 1),
('Modern Conference Hall', 'State-of-the-art conference facility', '789 Tech Plaza, Business District', 'CONFERENCE', 200, 1200.00, 'Projectors, Microphones, WiFi, Breakout Rooms', '/images/conference-hall.jpg', TRUE, 'AVAILABLE', 1),
('Crystal Palace Banquet', 'Luxury air-conditioned banquet hall with elegant interiors, perfect for weddings and grand receptions', '12 MG Road, Camp, Pune', 'WEDDING', 800, 5000.00, 'AC, Parking, Catering, Stage, Bridal Suite', '/images/crystal-banquet.jpg', TRUE, 'AVAILABLE', 1),
('Sunset Rooftop Terrace', 'Open-air rooftop venue with city skyline views, ideal for evening parties and celebrations', '45 Skyline Road, Koregaon Park, Pune', 'PARTY', 150, 2000.00, 'Rooftop, Lighting, Bar, Music System', '/images/sunset-terrace.jpg', TRUE, 'AVAILABLE', 1),
('Emerald Convention Center', 'Large modern convention facility with breakout rooms for conferences and corporate summits', '78 IT Park, Hinjewadi, Pune', 'CORPORATE', 1000, 3500.00, 'Projectors, WiFi, Breakout Rooms, Cafeteria', '/images/emerald-arena.jpg', TRUE, 'AVAILABLE', 1);

-- Insert sample events (times/guests for ids 3-4 inferred from booking totals)
INSERT INTO events (name, description, event_type, event_date, start_time, end_time, expected_guests, organizer_id, venue_id, status) VALUES
('Tech Conference 2026', 'Annual technology conference', 'CONFERENCE', '2026-10-15', '09:00:00', '17:00:00', 150, NULL, 3, 'CONFIRMED'),
('Wedding Reception', 'Beautiful wedding celebration', 'WEDDING', '2026-11-20', '18:00:00', '23:00:00', 200, NULL, 1, 'CONFIRMED'),
('Company Meeting', 'Quarterly company meeting', 'CORPORATE', '2026-10-20', '10:00:00', '12:00:00', 100, 1, 1, 'CONFIRMED'),
('Corporate Conference', 'Corporate leadership conference', 'CORPORATE', '2026-10-24', '09:00:00', '15:00:00', 150, 1, 3, 'CONFIRMED');

-- Insert sample bookings (mirrors the live dashboard: 000003 approved, 000004 rejected)
INSERT INTO bookings (booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, status, payment_method) VALUES
('ES-2026-000001', 1, 3, 1, '2026-10-15', 9600.00, 0, 'APPROVED', 'CARD'),
('ES-2026-000002', 2, 1, 2, '2026-11-20', 12500.00, 0, 'PENDING', 'TRANSFER'),
('ES-2026-000003', 3, 1, 1, '2026-10-20', 5000.00, 0, 'APPROVED', 'CARD'),
('ES-2026-000004', 4, 3, 1, '2026-10-24', 7200.00, 0, 'REJECTED', 'TRANSFER');

-- Insert sample bills (one per sample booking; booking ids 1-4 exist above)
INSERT INTO bills (bill_number, booking_id, customer_id, subtotal, advance_paid, balance_due, status) VALUES
('INV-2026-000001', 1, 1, 9600.00, 0, 9600.00, 'ISSUED'),
('INV-2026-000002', 2, 2, 12500.00, 0, 12500.00, 'ISSUED'),
('INV-2026-000003', 3, 1, 5000.00, 0, 5000.00, 'ISSUED'),
('INV-2026-000004', 4, 1, 7200.00, 0, 7200.00, 'ISSUED');

-- Optional sample feedback
INSERT INTO feedback (booking_id, customer_id, venue_id, rating, comment) VALUES
(1, 1, 3, 5, 'Great venue and smooth experience.');

-- Create sequences for IDs (already handled by SERIAL, but explicit for clarity)
-- SELECT SETVAL('admin_users_id_seq', (SELECT MAX(id) FROM admin_users) + 1);
-- SELECT SETVAL('customer_users_id_seq', (SELECT MAX(id) FROM customer_users) + 1);
-- SELECT SETVAL('venues_id_seq', (SELECT MAX(id) FROM venues) + 1);
-- SELECT SETVAL('events_id_seq', (SELECT MAX(id) FROM events) + 1);
-- SELECT SETVAL('bookings_id_seq', (SELECT MAX(id) FROM bookings) + 1);
-- SELECT SETVAL('feedback_id_seq', (SELECT MAX(id) FROM feedback) + 1);

-- Grant permissions (if using a specific user)
-- GRANT ALL PRIVILEGES ON DATABASE eventsphere TO eventsphere_user;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO eventsphere_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO eventsphere_user;
