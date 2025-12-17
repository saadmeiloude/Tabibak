<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

$input = json_decode(file_get_contents('php://input'), true);
$method = $_SERVER['REQUEST_METHOD'];

// Get token
$headers = getallheaders();
$token = null;
if (isset($headers['Authorization'])) {
    if (preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $matches)) {
        $token = $matches[1];
    }
}
if (!$token && isset($input['token'])) $token = $input['token'];

if (!$token) {
    http_response_code(401);
    echo json_encode(['error' => 'No token provided']);
    exit;
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    // Authenticate
    $authQuery = "SELECT u.id, u.full_name, u.email, u.phone, u.profile_image, u.date_of_birth, u.gender, u.address
                  FROM users u 
                  JOIN user_sessions s ON u.id = s.user_id 
                  WHERE s.token = :token AND s.expires_at > NOW() AND u.user_type = 'doctor'";
    $stmtAuth = $conn->prepare($authQuery);
    $stmtAuth->bindParam(':token', $token);
    $stmtAuth->execute();
    $user = $stmtAuth->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid token or not a doctor']);
        exit;
    }

    $userId = $user['id'];

    if ($method === 'GET') {
        // Fetch doctor specific details
        $docQuery = "SELECT license_number, specialization, experience_years, education, certifications, 
                            consultation_fee, availability_schedule, is_available
                     FROM doctors WHERE user_id = :user_id";
        $stmtDoc = $conn->prepare($docQuery);
        $stmtDoc->bindParam(':user_id', $userId);
        $stmtDoc->execute();
        $doctorInfo = $stmtDoc->fetch(PDO::FETCH_ASSOC);

        if ($doctorInfo) {
            $response = array_merge($user, $doctorInfo);
        } else {
            $response = $user;
        }

        echo json_encode(['success' => true, 'data' => $response]);

    } elseif ($method === 'POST') {
        // Update profile
        $conn->beginTransaction();

        // Update User Table
        $updateUser = "UPDATE users SET full_name = :full_name, phone = :phone, address = :address WHERE id = :id";
        $stmtUser = $conn->prepare($updateUser);
        $stmtUser->bindValue(':full_name', $input['full_name']);
        $stmtUser->bindValue(':phone', $input['phone']);
        $stmtUser->bindValue(':address', $input['address'] ?? '');
        $stmtUser->bindValue(':id', $userId);
        $stmtUser->execute();

        // Update Doctor Table
        // Note: We are using 'education' field to store 'About/Bio' info if needed, or strictly education.
        $updateDoc = "UPDATE doctors SET 
                        specialization = :specialization,
                        experience_years = :experience,
                        consultation_fee = :fee,
                        education = :education,
                        certifications = :certifications
                      WHERE user_id = :user_id";
        $stmtDoc = $conn->prepare($updateDoc);
        $stmtDoc->bindValue(':specialization', $input['specialization']);
        $stmtDoc->bindValue(':experience', $input['experience_years'] ?? 0);
        $stmtDoc->bindValue(':fee', $input['consultation_fee'] ?? 0);
        $stmtDoc->bindValue(':education', $input['education'] ?? '');
        $stmtDoc->bindValue(':certifications', $input['certifications'] ?? '');
        $stmtDoc->bindValue(':user_id', $userId);
        $stmtDoc->execute();

        $conn->commit();
        
        // Fetch updated data to return
        $docQuery2 = "SELECT license_number, specialization, experience_years, education, certifications, 
                             consultation_fee, availability_schedule, is_available
                      FROM doctors WHERE user_id = :user_id";
        $stmtDoc2 = $conn->prepare($docQuery2);
        $stmtDoc2->bindParam(':user_id', $userId);
        $stmtDoc2->execute();
        $updatedDocInfo = $stmtDoc2->fetch(PDO::FETCH_ASSOC);

        $response = array_merge([
            'id' => $userId,
            'full_name' => $input['full_name'],
            'email' => $user['email'],
            'phone' => $input['phone'],
            'address' => $input['address'] ?? ''
        ], $updatedDocInfo ? $updatedDocInfo : []);

        echo json_encode(['success' => true, 'message' => 'Profile updated successfully', 'user' => $response]);
    }

} catch (Exception $e) {
    if (isset($conn) && $conn->inTransaction()) {
        $conn->rollBack();
    }
    http_response_code(500);
    echo json_encode(['error' => 'Server error: ' . $e->getMessage()]);
}
?>
