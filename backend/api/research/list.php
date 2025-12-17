<?php
header('Content-Type: application/json');
require_once '../../config/database.php';
require_once '../auth/middleware.php';

// Allow public access to list, or require login? 
// Usually apps require login. Let's assume login required for consistency.
$user = authenticate();

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    $whereClauses = ["is_published = 1"];
    $params = [];
    
    if (isset($_GET['doctor_id'])) {
        $whereClauses[] = "doctor_id = :doctor_id";
        $params[':doctor_id'] = $_GET['doctor_id'];
    }
    
    if (isset($_GET['category'])) {
        $whereClauses[] = "category = :category";
        $params[':category'] = $_GET['category'];
    }

    // Search functionality
    if (isset($_GET['search'])) {
        $whereClauses[] = "(title LIKE :search OR summary LIKE :search OR tags LIKE :search)";
        $params[':search'] = '%' . $_GET['search'] . '%';
    }
    
    $whereSql = implode(' AND ', $whereClauses);
    
    $query = "SELECT r.*, u.full_name as doctor_name, u.profile_image as doctor_image
              FROM medical_research r
              JOIN users u ON r.doctor_id = u.id
              WHERE $whereSql
              ORDER BY created_at DESC";
              
    $stmt = $conn->prepare($query);
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->execute();
    
    $research = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => $research
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
