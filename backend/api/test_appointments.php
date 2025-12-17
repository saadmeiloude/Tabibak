<?php
// Quick test script to verify appointments API
header('Content-Type: application/json');
require_once '../config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Test 1: Check if appointments table exists
    $result = $conn->query("SELECT COUNT(*) FROM appointments");
    $count = $result->fetchColumn();
    
    echo json_encode([
        'success' => true,
        'message' => 'Database connection successful',
        'appointments_count' => $count,
        'test' => 'passed'
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
