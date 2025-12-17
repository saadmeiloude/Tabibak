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

// Only doctors can typically create specific records, but patients might upload some.
// For now, allow creation if authenticated. Assuming input validation handles logic.

$requiredFields = ['title', 'record_type'];
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
    
    // Default to current user as patient AND doctor if not specified (self-uploaded record)
    // Or if doctor is creating, patient_id must be provided.
    // Let's assume for now the user is uploading their own record or a doctor uploading for a patient.
    
    $patientId = $input['patient_id'] ?? $user['id'];
    $doctorId = $input['doctor_id'] ?? $user['id']; // If self-upload, doctor_id might be self or null? DB says NOT NULL.
    // If patient uploads, maybe assign a system doctor ID or self? 
    // Let's use user['id'] for both if not provided, assuming self-record.
    
    $insertQuery = "INSERT INTO medical_records (patient_id, doctor_id, appointment_id, record_type, title, description, diagnosis, treatment, medications, attachments, record_date) 
                    VALUES (:patient_id, :doctor_id, :appointment_id, :record_type, :title, :description, :diagnosis, :treatment, :medications, :attachments, :record_date)";
                    
    $stmt = $conn->prepare($insertQuery);
    $stmt->bindParam(':patient_id', $patientId);
    $stmt->bindParam(':doctor_id', $doctorId);
    $stmt->bindValue(':appointment_id', $input['appointment_id'] ?? null);
    $stmt->bindParam(':record_type', $input['record_type']);
    $stmt->bindParam(':title', $input['title']);
    $stmt->bindValue(':description', $input['description'] ?? null);
    $stmt->bindValue(':diagnosis', $input['diagnosis'] ?? null);
    $stmt->bindValue(':treatment', $input['treatment'] ?? null);
    $stmt->bindValue(':medications', $input['medications'] ?? null);
    $stmt->bindValue(':attachments', $input['attachments'] ?? null);
    $stmt->bindValue(':record_date', $input['record_date'] ?? date('Y-m-d'));
    
    if ($stmt->execute()) {
        $recordId = $conn->lastInsertId();
        
        $fetchQuery = "SELECT * FROM medical_records WHERE id = :id";
        $fetchStmt = $conn->prepare($fetchQuery);
        $fetchStmt->bindParam(':id', $recordId);
        $fetchStmt->execute();
        $record = $fetchStmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'Medical record created successfully',
            'data' => ['record' => $record]
        ]);
    } else {
        throw new Exception("Failed to insert medical record");
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
