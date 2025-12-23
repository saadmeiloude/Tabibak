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

    // Check if email/phone exists in either table to prevent duplicates
    $checkQuery = "SELECT id FROM users WHERE email = :email OR phone = :phone 
                   UNION 
                   SELECT id FROM doctors WHERE email = :email OR phone = :phone";
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

    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    $consultationFee = isset($input['consultation_fee']) ? floatval($input['consultation_fee']) : 0.0;
    $experienceYears = isset($input['experience_years']) ? intval($input['experience_years']) : 0;

    // Insert into users first to generate user_id
    $insertUser = "INSERT INTO users (full_name, email, phone, password, user_type, is_verified, verification_method) 
                   VALUES (:full_name, :email, :phone, :password, 'doctor', 1, 'email')";
    
    $stmtUser = $conn->prepare($insertUser);
    $stmtUser->bindParam(':full_name', $fullName);
    $stmtUser->bindParam(':email', $email);
    $stmtUser->bindParam(':phone', $phone);
    $stmtUser->bindParam(':password', $hashedPassword);
    
    if (!$stmtUser->execute()) {
        throw new Exception("Failed to create user account for doctor");
    }
    
    $userId = $conn->lastInsertId();

    // Insert into doctors table with user_id
    $insertDoctor = "INSERT INTO doctors (user_id, full_name, email, phone, password, license_number, specialization, experience_years, consultation_fee, is_verified, is_available) 
                     VALUES (:user_id, :full_name, :email, :phone, :password, :license_number, :specialization, :experience_years, :consultation_fee, 1, 1)";
    
    $stmtDoctor = $conn->prepare($insertDoctor);
    $stmtDoctor->bindParam(':user_id', $userId);
    $stmtDoctor->bindParam(':full_name', $fullName);
    $stmtDoctor->bindParam(':email', $email);
    $stmtDoctor->bindParam(':phone', $phone);
    $stmtDoctor->bindParam(':password', $hashedPassword);
    $stmtDoctor->bindParam(':license_number', $licenseNumber);
    $stmtDoctor->bindParam(':specialization', $specialization);
    $stmtDoctor->bindParam(':experience_years', $experienceYears);
    $stmtDoctor->bindParam(':consultation_fee', $consultationFee);

    if (!$stmtDoctor->execute()) {
        // If doctor creation fails, delete the user
        $conn->exec("DELETE FROM users WHERE id = $userId");
        throw new Exception("Failed to create doctor profile");
    }
    
    $doctorId = $conn->lastInsertId();

    $conn->commit();

    // Get created doctor with user info
    $userQuery = "SELECT id, user_id, full_name, email, phone, license_number, specialization, is_verified, created_at FROM doctors WHERE id = :id";
    $userStmt = $conn->prepare($userQuery);
    $userStmt->bindParam(':id', $doctorId);
    $userStmt->execute();
    $user = $userStmt->fetch(PDO::FETCH_ASSOC);
    $user['user_type'] = 'doctor'; // Essential for frontend logic
    $user['verification_method'] = 'email'; // Default verification method for doctors

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
