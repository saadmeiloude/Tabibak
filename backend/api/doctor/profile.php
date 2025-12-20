<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

require_once '../auth/middleware.php';

$input = json_decode(file_get_contents('php://input'), true);
$method = $_SERVER['REQUEST_METHOD'];

$user = authenticate('doctor');
$doctorId = $user['id'];

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    if ($method === 'GET') {
        echo json_encode(['success' => true, 'data' => $user]);

    } elseif ($method === 'POST') {
        // Update profile
        $updateDoc = "UPDATE doctors SET 
                        full_name = :full_name,
                        phone = :phone,
                        address = :address,
                        specialization = :specialization,
                        experience_years = :experience,
                        consultation_fee = :fee,
                        education = :education,
                        certifications = :certifications
                      WHERE id = :id";
        
        $stmtDoc = $conn->prepare($updateDoc);
        $stmtDoc->bindValue(':full_name', $input['full_name']);
        $stmtDoc->bindValue(':phone', $input['phone']);
        $stmtDoc->bindValue(':address', $input['address'] ?? '');
        $stmtDoc->bindValue(':specialization', $input['specialization']);
        $stmtDoc->bindValue(':experience', $input['experience_years'] ?? 0);
        $stmtDoc->bindValue(':fee', $input['consultation_fee'] ?? 0);
        $stmtDoc->bindValue(':education', $input['education'] ?? '');
        $stmtDoc->bindValue(':certifications', $input['certifications'] ?? '');
        $stmtDoc->bindValue(':id', $doctorId);
        $stmtDoc->execute();

        // Get updated user
        $query = "SELECT *, 'doctor' as user_type FROM doctors WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':id', $doctorId);
        $stmt->execute();
        $updatedUser = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode(['success' => true, 'message' => 'Profile updated successfully', 'user' => $updatedUser]);
    }

} catch (Exception $e) {
    if (isset($conn) && $conn->inTransaction()) {
        $conn->rollBack();
    }
    http_response_code(500);
    echo json_encode(['error' => 'Server error: ' . $e->getMessage()]);
}
?>
