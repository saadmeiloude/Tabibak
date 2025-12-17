<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

$requiredFields = ['full_name', 'email', 'password', 'phone', 'license_number', 'specialization'];
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
$licenseNumber = trim($input['license_number']);
$specialization = trim($input['specialization']);
$verificationMethod = isset($input['verification_method']) ? $input['verification_method'] : 'sms';
$dateOfBirth = isset($input['date_of_birth']) ? $input['date_of_birth'] : null;
$gender = isset($input['gender']) ? $input['gender'] : 'male';
$address = isset($input['address']) ? $input['address'] : null;

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

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Start transaction
    $conn->beginTransaction();

    // Check if email/phone exists
    $checkQuery = "SELECT id FROM users WHERE email = :email OR phone = :phone";
    $checkStmt = $conn->prepare($checkQuery);
    $checkStmt->bindParam(':email', $email);
    $checkStmt->bindParam(':phone', $phone);
    $checkStmt->execute();
    
    if ($checkStmt->fetch()) {
        $conn->rollBack();
        http_response_code(409);
        echo json_encode(['error' => 'Email or phone number already registered']);
        exit;
    }
    
    // Check if license number exists
    $checkLicense = "SELECT id FROM doctors WHERE license_number = :license";
    $checkLicenseStmt = $conn->prepare($checkLicense);
    $checkLicenseStmt->bindParam(':license', $licenseNumber);
    $checkLicenseStmt->execute();

    if ($checkLicenseStmt->fetch()) {
        $conn->rollBack();
        http_response_code(409);
        echo json_encode(['error' => 'License number already registered']);
        exit;
    }

    // Insert user
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    $insertUser = "INSERT INTO users (full_name, email, phone, password, user_type, verification_method, date_of_birth, gender, address, is_verified) 
                   VALUES (:full_name, :email, :phone, :password, 'doctor', :verification_method, :date_of_birth, :gender, :address, 1)";
    
    $stmtUser = $conn->prepare($insertUser);
    $stmtUser->bindParam(':full_name', $fullName);
    $stmtUser->bindParam(':email', $email);
    $stmtUser->bindParam(':phone', $phone);
    $stmtUser->bindParam(':password', $hashedPassword);
    $stmtUser->bindParam(':verification_method', $verificationMethod);
    $stmtUser->bindParam(':date_of_birth', $dateOfBirth);
    $stmtUser->bindParam(':gender', $gender);
    $stmtUser->bindParam(':address', $address);
    
    if (!$stmtUser->execute()) {
        throw new Exception("Failed to create user account");
    }
    
    $userId = $conn->lastInsertId();

    // Insert doctor details
    $insertDoctor = "INSERT INTO doctors (user_id, license_number, specialization, is_available) 
                     VALUES (:user_id, :license_number, :specialization, 1)";
    
    $stmtDoctor = $conn->prepare($insertDoctor);
    $stmtDoctor->bindParam(':user_id', $userId);
    $stmtDoctor->bindParam(':license_number', $licenseNumber);
    $stmtDoctor->bindParam(':specialization', $specialization);

    if (!$stmtDoctor->execute()) {
        throw new Exception("Failed to create doctor profile");
    }

    $conn->commit();

    // Get created user
    $userQuery = "SELECT id, full_name, email, phone, user_type, verification_method, is_verified, created_at FROM users WHERE id = :id";
    $userStmt = $conn->prepare($userQuery);
    $userStmt->bindParam(':id', $userId);
    $userStmt->execute();
    $user = $userStmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'message' => 'Doctor account created successfully',
        'data' => [
            'user' => $user
        ]
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    error_log("Doctor Registration error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error: ' . $e->getMessage()]);
}
?>
