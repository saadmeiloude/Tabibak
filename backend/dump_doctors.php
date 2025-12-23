<?php
require_once 'config/database.php';
$db = Database::getInstance();
$conn = $db->getConnection();
$doctors = $conn->query("SELECT id, user_id, full_name, email FROM doctors")->fetchAll(PDO::FETCH_ASSOC);
echo print_r($doctors, true);
?>
