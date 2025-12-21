-- تطبيق سريع لنظام المحفظة
-- قم بنسخ هذا الكود وتنفيذه في phpMyAdmin أو MySQL Workbench

USE tabibak;

-- 1. جدول المحافظ
CREATE TABLE IF NOT EXISTS wallets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    balance DECIMAL(12,2) DEFAULT 0.00 NOT NULL,
    currency VARCHAR(3) DEFAULT 'MRU' NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_transaction_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_wallet (user_id),
    CHECK (balance >= 0)
);

-- 2. جدول المعاملات
CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_ref VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    wallet_id INT NOT NULL,
    transaction_type ENUM('deposit', 'withdrawal', 'payment', 'refund', 'transfer', 'commission') NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'MRU' NOT NULL,
    balance_before DECIMAL(12,2) NOT NULL,
    balance_after DECIMAL(12,2) NOT NULL,
    status ENUM('pending', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
    payment_method ENUM('card', 'bank_transfer', 'mobile_money', 'cash', 'wallet') DEFAULT 'wallet',
    description TEXT,
    metadata JSON,
    related_user_id INT NULL,
    related_appointment_id INT NULL,
    payment_gateway VARCHAR(50),
    gateway_transaction_id VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    notes TEXT,
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE,
    FOREIGN KEY (related_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (related_appointment_id) REFERENCES appointments(id) ON DELETE SET NULL,
    INDEX idx_user_trans (user_id),
    INDEX idx_wallet_trans (wallet_id),
    INDEX idx_type (transaction_type),
    INDEX idx_status (status),
    CHECK (amount > 0)
);

-- 3. جدول طلبات السحب
CREATE TABLE IF NOT EXISTS withdrawal_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    wallet_id INT NOT NULL,
    transaction_id INT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'MRU' NOT NULL,
    withdrawal_method ENUM('bank_transfer', 'mobile_money', 'cash', 'check') NOT NULL,
    bank_name VARCHAR(100),
    account_number VARCHAR(50),
    account_holder_name VARCHAR(100),
    mobile_money_number VARCHAR(20),
    status ENUM('pending', 'approved', 'processing', 'completed', 'rejected', 'cancelled') DEFAULT 'pending',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    processed_by INT NULL,
    rejection_reason TEXT,
    admin_notes TEXT,
    receipt_url VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE SET NULL,
    FOREIGN KEY (processed_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_withdrawal (user_id),
    INDEX idx_status_withdrawal (status),
    CHECK (amount > 0)
);

-- 4. جدول إعدادات العمولات
CREATE TABLE IF NOT EXISTS commission_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_type VARCHAR(50) NOT NULL,
    commission_type ENUM('fixed', 'percentage') NOT NULL,
    commission_value DECIMAL(10,2) NOT NULL,
    min_amount DECIMAL(12,2) DEFAULT 0.00,
    max_amount DECIMAL(12,2) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type_commission (transaction_type),
    INDEX idx_active (is_active)
);

-- 5. جدول سجل نشاط المحفظة
CREATE TABLE IF NOT EXISTS wallet_activity_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    wallet_id INT NOT NULL,
    user_id INT NOT NULL,
    action VARCHAR(50) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_wallet_log (wallet_id),
    INDEX idx_user_log (user_id)
);

-- 6. جدول بطاقات الدفع (اختياري)
CREATE TABLE IF NOT EXISTS payment_cards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    card_holder_name VARCHAR(100) NOT NULL,
    card_number_last4 VARCHAR(4) NOT NULL,
    card_type ENUM('visa', 'mastercard', 'amex', 'other') NOT NULL,
    expiry_month INT NOT NULL,
    expiry_year INT NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    card_token VARCHAR(255),
    billing_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_cards (user_id),
    CHECK (expiry_month >= 1 AND expiry_month <= 12)
);

-- 7. إدراج إعدادات العمولات الافتراضية
INSERT INTO commission_settings (transaction_type, commission_type, commission_value, description) VALUES
('appointment_payment', 'percentage', 10.00, 'عمولة على دفع المواعيد - 10%'),
('withdrawal', 'fixed', 5.00, 'رسوم سحب ثابتة - 5 أوقية'),
('deposit_card', 'percentage', 2.00, 'رسوم الإيداع بالبطاقة - 2%');

-- 8. إنشاء محافظ للمستخدمين الحاليين
INSERT INTO wallets (user_id, balance, currency)
SELECT id, 0.00, 'MRU' FROM users 
WHERE id NOT IN (SELECT user_id FROM wallets);

SELECT 'تم إنشاء جداول نظام المحفظة بنجاح!' as message;
