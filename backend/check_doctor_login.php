<?php
require_once 'config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Check all active sessions
    echo "=== ACTIVE SESSIONS ===\n";
    $sessions = $conn->query("SELECT * FROM user_sessions WHERE expires_at > NOW() ORDER BY created_at DESC LIMIT 5")->fetchAll(PDO::FETCH_ASSOC);
    print_r($sessions);
    
    // For each session, check if user exists
    foreach ($sessions as $session) {
        $userId = $session['user_id'];
        $userType = $session['user_type'];
        
        echo "\n=== Checking Session for User ID: $userId, Type: $userType ===\n";
        
        if ($userType === 'doctor') {
            // Check if doctor record exists
            $doctor = $conn->query("SELECT * FROM doctors WHERE user_id = $userId")->fetch(PDO::FETCH_ASSOC);
            if ($doctor) {
                echo "✓ Doctor record found:\n";
                print_r($doctor);
            } else {
                echo "✗ NO doctor record found for user_id $userId\n";
                // Check if user exists in users table
                $user = $conn->query("SELECT * FROM users WHERE id = $userId")->fetch(PDO::FETCH_ASSOC);
                if ($user) {
                    echo "User exists in users table:\n";
                    print_r($user);
                }
            }
        } else {
            $user = $conn->query("SELECT * FROM users WHERE id = $userId")->fetch(PDO::FETCH_ASSOC);
            if ($user) {
                echo "✓ Patient/User record found:\n";
                print_r($user);
            } else {
                echo "✗ NO user record found\n";
            }
        }
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
