-- Clean up existing database tables
-- Run this if you get "table already exists" errors

USE tabibak;

-- Drop all tables in reverse order (due to foreign key constraints)
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS medical_records;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS password_resets;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS users;

-- Verify database is clean
SHOW TABLES;