<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: application/json');

require_once '../../config/database.php';
$conn = Database::getInstance()->getConnection();

try {
    $stmt = $conn->query("DESCRIBE doctors");
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo json_encode(['table' => 'doctors', 'columns' => $columns]);
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>
