<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: application/json');

echo json_encode(['status' => 'start']);

try {
    require_once '../../config/database.php';
    echo json_encode(['status' => 'included_db']);
    
    $db = Database::getInstance();
    $conn = $db->getConnection();
    echo json_encode(['status' => 'connected', 'success' => true]);
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
