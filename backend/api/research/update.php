<?php
header('Content-Type: application/json');
require_once '../../config/database.php';
require_once '../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'PUT' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$user = authenticate();
$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['id'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Research ID is required']);
    exit;
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // check ownership
    $checkQuery = "SELECT doctor_id FROM medical_research WHERE id = :id";
    $stmt = $conn->prepare($checkQuery);
    $stmt->execute([':id' => $data['id']]);
    $research = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$research) {
        http_response_code(404);
        echo json_encode(['error' => 'Research not found']);
        exit;
    }
    
    if ($research['doctor_id'] != $user['id'] && $user['user_type'] !== 'admin') {
        http_response_code(403);
        echo json_encode(['error' => 'Unauthorized']);
        exit;
    }
    
    // Build update query dynamically
    $fields = [];
    $params = [':id' => $data['id']];
    
    $updatableFields = ['title', 'summary', 'content', 'attachment_url', 'category', 'tags', 'is_published'];
    
    foreach ($updatableFields as $field) {
        if (isset($data[$field])) {
            $fields[] = "$field = :$field";
            $params[":$field"] = $data[$field];
        }
    }
    
    if (empty($fields)) {
        echo json_encode(['success' => true, 'message' => 'No changes made']);
        exit;
    }
    
    $query = "UPDATE medical_research SET " . implode(', ', $fields) . " WHERE id = :id";
    $stmt = $conn->prepare($query);
    
    if ($stmt->execute($params)) {
        echo json_encode([
            'success' => true,
            'message' => 'Research updated successfully'
        ]);
    } else {
        throw new Exception("Failed to update research");
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
