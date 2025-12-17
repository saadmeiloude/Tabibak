<?php
header('Content-Type: application/json');
require_once '../config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // The password seen in the screenshot is '1234567'
    $newPassword = '1234567';
    $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
    
    // Update the specific user shown in the screenshot
    $query = "UPDATE users SET password = :password WHERE email = 'nou7@gmail.com'";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':password', $hashedPassword);
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        echo json_encode([
            'success' => true,
            'message' => "Password for nou7@gmail.com has been hashed successfully. You can now login with password: $newPassword"
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => "User nou7@gmail.com not found or password already updated."
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
