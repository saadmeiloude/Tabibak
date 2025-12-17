<?php
header('Content-Type: application/json');
require_once '../../config/database.php';
require_once '../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$user = authenticate();

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Get records where user is patient
    $query = "SELECT m.*, 
                     p.full_name as patient_name,
                     d.full_name as doctor_name
              FROM medical_records m
              JOIN users p ON m.patient_id = p.id
              JOIN users d ON m.doctor_id = d.id
              WHERE m.patient_id = :user_id OR m.doctor_id = :user_id
              ORDER BY m.record_date DESC";
              
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':user_id', $user['id']);
    $stmt->execute();
    
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => ['records' => $records]
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
