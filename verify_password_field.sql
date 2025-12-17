-- Verify password field exists in users table
-- Run this in phpMyAdmin SQL tab

-- Show table structure
DESCRIBE users;

-- Show specific password column
SHOW COLUMNS FROM users LIKE 'password';

-- Show all users with password (hashed)
SELECT id, email, full_name, user_type, LEFT(password, 20) as 'password_hash_preview' FROM users;

-- Show if password field is NULL or NOT NULL
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_KEY,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'tabibak' 
AND TABLE_NAME = 'users' 
AND COLUMN_NAME = 'password';