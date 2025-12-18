<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

$input = json_decode(file_get_contents('php://input'), true);

// Basic validation
if (!isset($input['full_name']) || !isset($input['phone'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Full name and phone are required']);
    exit;
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    // Check if phone or email already exists
    $checkQuery = "SELECT id FROM users WHERE phone = :phone";
    if (isset($input['email']) && !empty($input['email'])) {
        $checkQuery .= " OR email = :email";
    }
    $stmtCheck = $conn->prepare($checkQuery);
    $stmtCheck->bindParam(':phone', $input['phone']);
    if (isset($input['email']) && !empty($input['email'])) {
        $stmtCheck->bindParam(':email', $input['email']);
    }
    $stmtCheck->execute();
    
    if ($stmtCheck->rowCount() > 0) {
        http_response_code(409);
        echo json_encode(['error' => 'User with this phone or email already exists']);
        exit;
    }

    // Hash password (default password for new patients created by doctor)
    // In a real app, might send an invite or set a temp password.
    // Setting default to '123456' for simplicity or generated.
    $defaultPassword = password_hash('123456', PASSWORD_DEFAULT);
    
    // Insert new patient
    $query = "INSERT INTO users (full_name, phone, email, password, user_type, is_verified) 
              VALUES (:full_name, :phone, :email, :password, 'patient', TRUE)";
              
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':full_name', $input['full_name']);
    $stmt->bindParam(':phone', $input['phone']);
    $email = isset($input['email']) && !empty($input['email']) ? $input['email'] : 'patient_' . $input['phone'] . '@tabibek.local';
    $stmt->bindParam(':email', $email);
    $stmt->bindParam(':password', $defaultPassword);
    
    if ($stmt->execute()) {
        $patientId = $conn->lastInsertId();
        echo json_encode([
            'success' => true, 
            'message' => 'Patient created successfully',
            'data' => ['id' => $patientId, 'full_name' => $input['full_name']]
        ]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to create patient']);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
