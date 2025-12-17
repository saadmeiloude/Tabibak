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
    
    // Check if filtering by specific user (only admin or doctor can do this usually, but for now we simplify)
    // If request asks for specific user and current user is authorized, use that.
    // Default: get appointments for current user where they are either patient or doctor
    
    $whereClause = "(patient_id = :patient_id OR doctor_id = :doctor_id)";
    
    $query = "SELECT a.*, 
                     p.full_name as patient_name,
                     d.full_name as doctor_name
              FROM appointments a 
              JOIN users p ON a.patient_id = p.id
              JOIN users d ON a.doctor_id = d.id
              WHERE $whereClause
              ORDER BY appointment_date DESC, appointment_time DESC";
              
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':patient_id', $user['id']);
    $stmt->bindParam(':doctor_id', $user['id']);
    $stmt->execute();
    
    $appointments = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => ['appointments' => $appointments]
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
