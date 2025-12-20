<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

require_once '../../config/database.php';
require_once 'middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$user = authenticate();

$input = json_decode(file_get_contents('php://input'), true);

$name = $input['name'] ?? null;
$email = $input['email'] ?? null;
$phone = $input['phone'] ?? null;

if (!$name || !$email) {
    http_response_code(400);
    echo json_encode(['error' => 'Name and email are required']);
    exit;
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    $updateQuery = "UPDATE users SET full_name = :name, email = :email, phone = :phone WHERE id = :id";
    $stmt = $conn->prepare($updateQuery);
    $stmt->bindParam(':name', $name);
    $stmt->bindParam(':email', $email);
    $stmt->bindParam(':phone', $phone);
    $stmt->bindParam(':id', $user['id']);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => [
                'full_name' => $name,
                'email' => $email,
                'phone' => $phone
            ]
        ]);
    } else {
        throw new Exception("Failed to update user record");
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
