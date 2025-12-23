<?php
require_once 'config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    echo "=== TESTING USER REGISTRATION ===\n\n";
    
    // Generate unique test data
    $timestamp = time();
    $testUser = [
        'full_name' => "Test User $timestamp",
        'email' => "test$timestamp@example.com",
        'phone' => "555" . substr($timestamp, -7),
        'password' => password_hash('testpass123', PASSWORD_DEFAULT),
        'verification_method' => 'email',
        'date_of_birth' => '1990-01-01',
        'gender' => 'male',
        'address' => 'Test Address',
        'emergency_contact' => '55500000',
        'is_verified' => 1
    ];
    
    echo "Creating test user:\n";
    echo "  Email: {$testUser['email']}\n";
    echo "  Phone: {$testUser['phone']}\n\n";
    
    // Try to insert
    $insertQuery = "INSERT INTO users (full_name, email, phone, password, verification_method, date_of_birth, gender, address, emergency_contact, is_verified) 
                   VALUES (:full_name, :email, :phone, :password, :verification_method, :date_of_birth, :gender, :address, :emergency_contact, :is_verified)";
    
    $stmt = $conn->prepare($insertQuery);
    $stmt->bindParam(':full_name', $testUser['full_name']);
    $stmt->bindParam(':email', $testUser['email']);
    $stmt->bindParam(':phone', $testUser['phone']);
    $stmt->bindParam(':password', $testUser['password']);
    $stmt->bindParam(':verification_method', $testUser['verification_method']);
    $stmt->bindParam(':date_of_birth', $testUser['date_of_birth']);
    $stmt->bindParam(':gender', $testUser['gender']);
    $stmt->bindParam(':address', $testUser['address']);
    $stmt->bindParam(':emergency_contact', $testUser['emergency_contact']);
    $stmt->bindParam(':is_verified', $testUser['is_verified']);
    
    if ($stmt->execute()) {
        $userId = $conn->lastInsertId();
        echo "✓ SUCCESS: User created with ID: $userId\n\n";
        
        // Verify it's in the database
        $checkStmt = $conn->prepare("SELECT * FROM users WHERE id = ?");
        $checkStmt->execute([$userId]);
        $user = $checkStmt->fetch(PDO::FETCH_ASSOC);
        
        if ($user) {
            echo "✓ VERIFIED: User found in database\n";
            echo "  ID: {$user['id']}\n";
            echo "  Name: {$user['full_name']}\n";
            echo "  Email: {$user['email']}\n";
            echo "  Phone: {$user['phone']}\n";
            echo "  User Type: {$user['user_type']}\n";
            echo "  Created: {$user['created_at']}\n";
        } else {
            echo "✗ ERROR: User not found after insert!\n";
        }
        
        // Clean up test user
        $deleteStmt = $conn->prepare("DELETE FROM users WHERE id = ?");
        $deleteStmt->execute([$userId]);
        echo "\n✓ Test user deleted\n";
        
    } else {
        echo "✗ FAILED: Could not insert user\n";
        print_r($stmt->errorInfo());
    }
    
    echo "\n=== CHECKING RECENT USERS ===\n";
    $recent = $conn->query("SELECT id, full_name, email, phone, created_at FROM users ORDER BY id DESC LIMIT 5")->fetchAll(PDO::FETCH_ASSOC);
    foreach ($recent as $user) {
        echo "ID: {$user['id']} - {$user['full_name']} ({$user['email']}) - Created: {$user['created_at']}\n";
    }
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?>
