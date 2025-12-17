<?php
$_SERVER['REQUEST_METHOD'] = 'GET';
require_once '../config/database.php';
try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    $tables = ['users', 'user_sessions', 'doctors', 'appointments', 'medical_records', 'medical_research', 'reviews', 'notifications', 'messages'];
    $missing = [];
    
    foreach ($tables as $table) {
        try {
            $result = $conn->query("SELECT 1 FROM $table LIMIT 1");
        } catch (Exception $e) {
            $missing[] = $table;
        }
    }
    
    if (empty($missing)) {
        echo "All tables exist.";
    } else {
        echo "Missing tables: " . implode(', ', $missing);
    }
} catch (Exception $e) {
    echo "Connection failed: " . $e->getMessage();
}
?>
