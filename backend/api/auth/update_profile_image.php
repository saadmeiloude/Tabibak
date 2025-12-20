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

if (!isset($_FILES['image'])) {
    http_response_code(400);
    echo json_encode(['error' => 'No image uploaded']);
    exit;
}

$image = $_FILES['image'];
$allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
$extension = strtolower(pathinfo($image['name'], PATHINFO_EXTENSION));
$allowedExtensions = ['jpg', 'jpeg', 'png'];

if (!in_array($image['type'], $allowedTypes) && !in_array($extension, $allowedExtensions)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid file type. Only JPG, JPEG, and PNG are allowed.']);
    exit;
}

$uploadDir = '../../uploads/profiles/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

$extension = pathinfo($image['name'], PATHINFO_EXTENSION);
$fileName = 'profile_' . $user['id'] . '_' . time() . '.' . $extension;
$uploadFile = $uploadDir . $fileName;

if (move_uploaded_file($image['tmp_name'], $uploadFile)) {
    try {
        $db = Database::getInstance();
        $conn = $db->getConnection();
        
        // Use relative path for storage
        $imagePath = 'uploads/profiles/' . $fileName;
        
        $updateQuery = "UPDATE users SET profile_image = :profile_image WHERE id = :id";
        $stmt = $conn->prepare($updateQuery);
        $stmt->bindParam(':profile_image', $imagePath);
        $stmt->bindParam(':id', $user['id']);
        
        if ($stmt->execute()) {
            file_put_contents('upload_log.txt', "Success: Updated user " . $user['id'] . " with " . $imagePath . "\n", FILE_APPEND);
            echo json_encode([
                'success' => true,
                'message' => 'Profile image updated successfully',
                'data' => [
                    'profile_image' => $imagePath
                ]
            ]);
        } else {
            error_log("DB Update failed for user " . $user['id']);
            throw new Exception("Failed to update user record");
        }
    } catch (Exception $e) {
        file_put_contents('upload_log.txt', "DB Error: " . $e->getMessage() . "\n", FILE_APPEND);
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
} else {
    file_put_contents('upload_log.txt', "Move failed: " . $image['tmp_name'] . " to " . $uploadFile . "\n", FILE_APPEND);
    http_response_code(500);
    echo json_encode(['error' => 'Failed to move uploaded file']);
}
?>
