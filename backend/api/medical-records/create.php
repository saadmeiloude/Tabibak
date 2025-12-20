<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

require_once '../../config/database.php';
require_once '../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$user = authenticate();

// Handle file upload if present
$attachmentsPath = null;
if (isset($_FILES['file'])) {
    $file = $_FILES['file'];
    $uploadDir = '../../uploads/medical_records/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }
    
    $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $fileName = 'record_' . $user['id'] . '_' . time() . '.' . $extension;
    $uploadFile = $uploadDir . $fileName;
    
    if (move_uploaded_file($file['tmp_name'], $uploadFile)) {
        $attachmentsPath = 'uploads/medical_records/' . $fileName;
    }
}

// Check if it's a JSON request or Multipart
if (empty($_POST) && !isset($_FILES['file'])) {
    $input = json_decode(file_get_contents('php://input'), true);
} else {
    $input = $_POST;
}

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
    
    $patientId = $input['patient_id'] ?? $user['id'];
    $doctorId = $input['doctor_id'] ?? $user['id'];
    
    $attachments = $attachmentsPath ?? $input['attachments'] ?? null;

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
    $stmt->bindValue(':attachments', $attachments);
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
