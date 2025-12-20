<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

$requiredFields = ['full_name', 'email', 'password', 'phone', 'verification_method'];
foreach ($requiredFields as $field) {
    if (!isset($input[$field]) || empty(trim($input[$field]))) {
        http_response_code(400);
        echo json_encode(['error' => ucfirst(str_replace('_', ' ', $field)) . ' is required']);
        exit;
    }
}

$fullName = trim($input['full_name']);
$email = filter_var(trim($input['email']), FILTER_VALIDATE_EMAIL);
$password = $input['password'];
$phone = trim($input['phone']);
$verificationMethod = $input['verification_method'];
$dateOfBirth = isset($input['date_of_birth']) ? $input['date_of_birth'] : null;
$gender = isset($input['gender']) ? $input['gender'] : 'male';
$address = isset($input['address']) ? $input['address'] : null;
$emergencyContact = isset($input['emergency_contact']) ? $input['emergency_contact'] : null;

if (!$email) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid email format']);
    exit;
}

if (strlen($password) < 6) {
    http_response_code(400);
    echo json_encode(['error' => 'Password must be at least 6 characters']);
    exit;
}

if (!preg_match('/^[0-9]+$/', $phone)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid phone number format']);
    exit;
}

if (!in_array($verificationMethod, ['sms', 'email'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid verification method']);
    exit;
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Check if email or phone already exists in either table
    $checkQuery = "SELECT id FROM users WHERE email = :email OR phone = :phone 
                   UNION 
                   SELECT id FROM doctors WHERE email = :email OR phone = :phone";
    $checkStmt = $conn->prepare($checkQuery);
    $checkStmt->bindParam(':email', $email);
    $checkStmt->bindParam(':phone', $phone);
    $checkStmt->execute();
    
    if ($checkStmt->fetch()) {
        http_response_code(409);
        echo json_encode(['error' => 'Email or phone number already registered']);
        exit;
    }
    
    // Hash password
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    
    // Insert new user
    $insertQuery = "INSERT INTO users (full_name, email, phone, password, verification_method, date_of_birth, gender, address, emergency_contact, is_verified) 
                   VALUES (:full_name, :email, :phone, :password, :verification_method, :date_of_birth, :gender, :address, :emergency_contact, 1)";
    
    $insertStmt = $conn->prepare($insertQuery);
    $insertStmt->bindParam(':full_name', $fullName);
    $insertStmt->bindParam(':email', $email);
    $insertStmt->bindParam(':phone', $phone);
    $insertStmt->bindParam(':password', $hashedPassword);
    $insertStmt->bindParam(':verification_method', $verificationMethod);
    $insertStmt->bindParam(':date_of_birth', $dateOfBirth);
    $insertStmt->bindParam(':gender', $gender);
    $insertStmt->bindParam(':address', $address);
    $insertStmt->bindParam(':emergency_contact', $emergencyContact);
    
    if ($insertStmt->execute()) {
        $userId = $conn->lastInsertId();
        
        // Get the created user (without password)
        $userQuery = "SELECT id, full_name, email, phone, user_type, verification_method, is_verified, created_at FROM users WHERE id = :id";
        $userStmt = $conn->prepare($userQuery);
        $userStmt->bindParam(':id', $userId);
        $userStmt->execute();
        $user = $userStmt->fetch();
        
        echo json_encode([
            'success' => true,
            'message' => 'Account created successfully',
            'data' => [
                'user' => $user,
                'verification_required' => false,
                'verification_method' => $verificationMethod
            ]
        ]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to create account']);
    }
    
} catch (Exception $e) {
    error_log("Registration error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error']);
}
?>