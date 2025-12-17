<?php
header('Content-Type: application/json');
require_once '../../config/database.php';
require_once '../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$user = authenticate();

// Check if user is a doctor
if ($user['user_type'] !== 'doctor' && $user['user_type'] !== 'admin') {
    http_response_code(403);
    echo json_encode(['error' => 'Only doctors can publish research']);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['title'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Title is required']);
    exit;
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    $query = "INSERT INTO medical_research (doctor_id, title, summary, content, attachment_url, category, tags, is_published)
              VALUES (:doctor_id, :title, :summary, :content, :attachment_url, :category, :tags, :is_published)";
              
    $stmt = $conn->prepare($query);
    
    $stmt->bindValue(':doctor_id', $user['id']);
    $stmt->bindValue(':title', $data['title']);
    $stmt->bindValue(':summary', $data['summary'] ?? '');
    $stmt->bindValue(':content', $data['content'] ?? '');
    $stmt->bindValue(':attachment_url', $data['attachment_url'] ?? null);
    $stmt->bindValue(':category', $data['category'] ?? 'General');
    $stmt->bindValue(':tags', $data['tags'] ?? '');
    $stmt->bindValue(':is_published', isset($data['is_published']) ? $data['is_published'] : 1);
    
    if ($stmt->execute()) {
        $id = $conn->lastInsertId();
        echo json_encode([
            'success' => true,
            'message' => 'Research article published successfully',
            'data' => ['id' => $id]
        ]);
    } else {
        throw new Exception("Failed to insert research");
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
