<?php
require_once 'config/database.php';
header('Content-Type: text/plain');

echo "--- DEBUG DATABASE STATE ---\n";
try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    // 1. Check Tables
    echo "\n[TABLES]\n";
    $tables = $conn->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    print_r($tables);

    // 2. Check Appointments Structure
    echo "\n[APPOINTMENTS STRUCTURE]\n";
    $stmt = $conn->query("DESCRIBE appointments");
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
        echo "{$col['Field']} - {$col['Type']} - Key: {$col['Key']}\n";
    }

    // 3. Check Recent Appointments (Last 5)
    echo "\n[LAST 5 APPOINTMENTS]\n";
    $stmt = $conn->query("SELECT * FROM appointments ORDER BY id DESC LIMIT 5");
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));

    // 4. Check Doctors
    echo "\n[DOCTORS]\n";
    $stmt = $conn->query("SELECT id, user_id, full_name, email FROM doctors");
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));

    // 5. Check Users
    echo "\n[USERS (Last 5)]\n";
    $stmt = $conn->query("SELECT id, full_name, email, user_type FROM users ORDER BY id DESC LIMIT 5");
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage();
}
?>
