<?php
require_once 'config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    echo "=== ALL USERS IN DATABASE ===\n\n";
    
    $users = $conn->query("SELECT id, full_name, email, phone, user_type, is_verified, created_at 
                           FROM users 
                           ORDER BY created_at DESC")->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Total users: " . count($users) . "\n\n";
    
    foreach ($users as $user) {
        $verified = $user['is_verified'] ? '✓' : '✗';
        echo "[$verified] ID: {$user['id']} | {$user['full_name']}\n";
        echo "    Email: {$user['email']}\n";
        echo "    Phone: {$user['phone']}\n";
        echo "    Type: {$user['user_type']}\n";
        echo "    Created: {$user['created_at']}\n\n";
    }
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
