<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

$method = $_SERVER['REQUEST_METHOD'];
$input = $_GET;

// Optional: Validate token
// For simplicity in this demo, strict token validation might be skipped or simplified
// But usually we want only doctors/admin to list patients.

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    $query = "SELECT id, full_name, phone, email, profile_image, date_of_birth, gender 
              FROM users 
              WHERE user_type = 'patient'";
    
    // Search filter
    if (isset($input['search']) && !empty($input['search'])) {
        $search = $input['search'];
        $query .= " AND (full_name LIKE :search OR phone LIKE :search_phone)";
    }
    
    $query .= " ORDER BY full_name ASC LIMIT 50";

    $stmt = $conn->prepare($query);
    
    if (isset($input['search']) && !empty($input['search'])) {
        $searchTerm = "%$search%";
        $stmt->bindParam(':search', $searchTerm);
        $stmt->bindParam(':search_phone', $searchTerm);
    }
    
    $stmt->execute();
    $patients = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(['success' => true, 'data' => ['patients' => $patients]]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
