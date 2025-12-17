<?php
header('Content-Type: application/json');
require_once '../config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Set all users to verified
    $query = "UPDATE users SET is_verified = 1 WHERE is_verified = 0";
    $stmt = $conn->prepare($query);
    $stmt->execute();
    
    $count = $stmt->rowCount();
    
    echo json_encode([
        'success' => true,
        'message' => "Updated $count users to verified status.",
        'affected_rows' => $count
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
