<?php
header('Content-Type: application/json');
require_once '../config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // DROP tables to reset schema (Safe for dev environment setup/fix)
    $conn->exec("SET FOREIGN_KEY_CHECKS = 0");
    $conn->exec("DROP TABLE IF EXISTS wallet_activity_log");
    $conn->exec("DROP TABLE IF EXISTS withdrawal_requests");
    $conn->exec("DROP TABLE IF EXISTS transactions");
    $conn->exec("DROP TABLE IF EXISTS wallets");
    $conn->exec("SET FOREIGN_KEY_CHECKS = 1");

    // 1. Create Wallets Table with user_type support
    // We remove the strict Foreign Key to 'users' table because user_id might refer to 'doctors' table
    $sql_wallets = "
    CREATE TABLE IF NOT EXISTS wallets (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        user_type ENUM('patient', 'doctor', 'admin') DEFAULT 'patient',
        balance DECIMAL(12,2) DEFAULT 0.00 NOT NULL,
        currency VARCHAR(3) DEFAULT 'MRU' NOT NULL,
        is_active BOOLEAN DEFAULT TRUE,
        last_transaction_at TIMESTAMP NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY unique_user_wallet (user_id, user_type),
        CHECK (balance >= 0)
    )";
    $conn->exec($sql_wallets);

    // 2. Create Transactions Table
    $sql_transactions = "
    CREATE TABLE IF NOT EXISTS transactions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        transaction_ref VARCHAR(50) UNIQUE NOT NULL,
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
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE
    )";
    $conn->exec($sql_transactions);

    // 3. Populate wallets for existing Patients (from users table)
    $conn->exec("INSERT IGNORE INTO wallets (user_id, user_type, balance, currency) 
                 SELECT id, 'patient', 0.00, 'MRU' FROM users");

    // 4. Populate wallets for existing Doctors (from doctors table)
    $conn->exec("INSERT IGNORE INTO wallets (user_id, user_type, balance, currency) 
                 SELECT id, 'doctor', 0.00, 'MRU' FROM doctors");

    echo json_encode(['success' => true, 'message' => 'Wallet system initialized for both Patients and Doctors.']);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
