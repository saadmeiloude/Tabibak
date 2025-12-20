<?php
require_once __DIR__ . '/../config/database.php';
try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    $tables = ['users', 'doctors', 'user_sessions', 'specialties'];
    
    foreach ($tables as $table) {
        echo "--- Table: $table ---\n";
        $stmt = $conn->query("DESCRIBE $table");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($columns as $col) {
            echo "Field: {$col['Field']}, Type: {$col['Type']}, Null: {$col['Null']}, Key: {$col['Key']}, Default: {$col['Default']}\n";
        }
        echo "\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
