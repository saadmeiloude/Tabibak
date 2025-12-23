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
    
    // Check authorization based on role
    $userCondition = "patient_id = :user_id";
    if (isset($user['user_type']) && $user['user_type'] === 'doctor') {
         $userCondition = "doctor_id = :user_id";
    }

    $checkQuery = "SELECT * FROM appointments 
                   WHERE id = :id AND ($userCondition)";
    $checkStmt = $conn->prepare($checkQuery);
    $checkStmt->bindParam(':id', $input['id']);
    $checkStmt->bindParam(':user_id', $user['id']);
    $checkStmt->execute();
    
    if (!$checkStmt->fetch()) {
        http_response_code(403);
        echo json_encode(['error' => 'Not authorized to update this appointment']);
        exit;
    }
    
    // Build update query dynamically
    $fields = [];
    $params = [':id' => $input['id']];
    
    if (isset($input['status'])) {
        $fields[] = "status = :status";
        $params[':status'] = $input['status'];
    }
    if (isset($input['appointment_date'])) {
        $fields[] = "appointment_date = :appointment_date";
        $params[':appointment_date'] = $input['appointment_date'];
    }
    if (isset($input['appointment_time'])) {
        $fields[] = "appointment_time = :appointment_time";
        $params[':appointment_time'] = $input['appointment_time'];
    }
    if (isset($input['notes'])) {
        $fields[] = "notes = :notes";
        $params[':notes'] = $input['notes'];
    }
     if (isset($input['symptoms'])) {
        $fields[] = "symptoms = :symptoms";
        $params[':symptoms'] = $input['symptoms'];
    }
    
    if (empty($fields)) {
        echo json_encode(['success' => true, 'message' => 'No changes made']);
        exit;
    }
    
    $query = "UPDATE appointments SET " . implode(', ', $fields) . " WHERE id = :id";
    $stmt = $conn->prepare($query);
    
    // Debug logging
    error_log("Query: " . $query);
    error_log("Params: " . json_encode($params));

    if ($stmt->execute($params)) {
        echo json_encode([
            'success' => true,
            'message' => 'Appointment updated successfully'
        ]);
    } else {
        throw new Exception("Failed to update appointment");
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
