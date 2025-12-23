<?php
require_once __DIR__ . '/../../config/database.php';

echo "--- USERS ---\n";
$conn = Database::getInstance()->getConnection();
$stmt = $conn->query("SELECT id, full_name, user_type, email FROM users");
print_r($stmt->fetchAll(PDO::FETCH_ASSOC));

echo "\n--- DOCTORS ---\n";
$stmt = $conn->query("SELECT id, user_id, full_name FROM doctors");
print_r($stmt->fetchAll(PDO::FETCH_ASSOC));

echo "\n--- APPOINTMENTS ---\n";
$stmt = $conn->query("SELECT id, patient_id, doctor_id, status, appointment_date FROM appointments");
print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
?>
