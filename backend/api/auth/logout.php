<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['token'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Token is required']);
    exit;
}

$token = $input['token'];

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Delete the session
    $deleteQuery = "DELETE FROM user_sessions WHERE token = :token";
    $deleteStmt = $conn->prepare($deleteQuery);
    $deleteStmt->bindParam(':token', $token);
    $deleteStmt->execute();
    
    echo json_encode([
        'success' => true,
        'message' => 'Logout successful'
    ]);
    
} catch (Exception $e) {
    error_log("Logout error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error']);
}
?>