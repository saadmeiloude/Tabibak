<?php
header('Content-Type: application/json');
require_once '../config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Get one row to see columns
    $stmt = $conn->query("SELECT * FROM doctors LIMIT 1");
    $doctor = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($doctor) {
        echo json_encode(['columns' => array_keys($doctor)]);
    } else {
        echo json_encode(['message' => 'No doctors found']);
    }
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>
