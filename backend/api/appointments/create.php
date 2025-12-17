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

$requiredFields = ['doctor_id', 'appointment_date', 'appointment_time'];
foreach ($requiredFields as $field) {
    if (!isset($input[$field]) || empty(trim($input[$field]))) {
        http_response_code(400);
        echo json_encode(['error' => ucfirst(str_replace('_', ' ', $field)) . ' is required']);
        exit;
    }
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Check if slot is available
    $query = "SELECT count(*) FROM appointments 
              WHERE doctor_id = :doctor_id 
              AND appointment_date = :date 
              AND appointment_time = :time 
              AND status != 'cancelled'";
              
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':doctor_id', $input['doctor_id']);
    $stmt->bindParam(':date', $input['appointment_date']);
    $stmt->bindParam(':time', $input['appointment_time']);
    $stmt->execute();
    
    if ($stmt->fetchColumn() > 0) {
        http_response_code(409);
        echo json_encode(['error' => 'This time slot is already booked']);
        exit;
    }
    
    // Create appointment
    $insertQuery = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, symptoms, consultation_type, duration_minutes) 
                    VALUES (:patient_id, :doctor_id, :date, :time, :symptoms, :type, :duration)";
                    
    $stmt = $conn->prepare($insertQuery);
    $stmt->bindParam(':patient_id', $user['id']);
    $stmt->bindParam(':doctor_id', $input['doctor_id']);
    $stmt->bindParam(':date', $input['appointment_date']);
    $stmt->bindParam(':time', $input['appointment_time']);
    $stmt->bindValue(':symptoms', $input['symptoms'] ?? null);
    $stmt->bindValue(':type', $input['consultation_type'] ?? 'online');
    $stmt->bindValue(':duration', $input['duration_minutes'] ?? 30);
    
    if ($stmt->execute()) {
        $appointmentId = $conn->lastInsertId();
        
        // Fetch complete appointment data with doctor and patient names
        $fetchQuery = "SELECT a.*, 
                              p.full_name as patient_name,
                              d.full_name as doctor_name
                       FROM appointments a
                       JOIN users p ON a.patient_id = p.id
                       JOIN users d ON a.doctor_id = d.id
                       WHERE a.id = :id";
        $fetchStmt = $conn->prepare($fetchQuery);
        $fetchStmt->bindParam(':id', $appointmentId);
        $fetchStmt->execute();
        $appointment = $fetchStmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'Appointment booked successfully',
            'data' => ['appointment' => $appointment]
        ]);
    } else {
        throw new Exception("Failed to insert appointment");
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
