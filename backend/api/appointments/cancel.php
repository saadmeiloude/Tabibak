<?php
header('Content-Type: application/json');
require_once '../../config/database.php';
require_once '../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$user = authenticate();
$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['id'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Appointment ID is required']);
    exit;
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Check if appointment belongs to user
    $checkQuery = "SELECT * FROM appointments 
                   WHERE id = :id AND (patient_id = :user_id OR doctor_id = :user_id)";
    $checkStmt = $conn->prepare($checkQuery);
    $checkStmt->bindParam(':id', $input['id']);
    $checkStmt->bindParam(':user_id', $user['id']);
    $checkStmt->execute();
    
    if (!$checkStmt->fetch()) {
        http_response_code(403);
        echo json_encode(['error' => 'Not authorized to cancel this appointment']);
        exit;
    }
    
    $query = "UPDATE appointments SET status = 'cancelled' WHERE id = :id";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':id', $input['id']);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Appointment cancelled successfully'
        ]);
    } else {
        throw new Exception("Failed to update status");
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
