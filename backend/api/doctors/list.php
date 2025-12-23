<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    // DEBUG DOCTORS LIST
    $logMsg = "All Doctors in DB:\n";
    $allDocs = $conn->query("SELECT id, user_id, full_name FROM doctors")->fetchAll(PDO::FETCH_ASSOC);
    $logMsg .= print_r($allDocs, true);
    file_put_contents('debug_doctors_list.txt', $logMsg);
    
    $specialization = isset($_GET['specialization']) ? $_GET['specialization'] : null;
    
    $query = "SELECT *, full_name as name FROM doctors WHERE is_active = 1";
              
    if ($specialization) {
        $query .= " AND d.specialization LIKE :specialization";
    }
    
    $stmt = $conn->prepare($query);
    
    if ($specialization) {
        $specParam = "%$specialization%";
        $stmt->bindParam(':specialization', $specParam);
    }
    
    $stmt->execute();
    $doctors = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Add reviews count and rating if needed (schema has total_reviews and rating in doctors table? No, schema check needed)
    // Checking schema_minimal.sql previously I saw doctors table has experience_years, consultation_fee.
    // I don't recall seeing rating in doctors table but it might be computed from reviews table.
    // Let's check schema_minimal.sql again for doctors table structure to be precise on what to SELECT.
    
    echo json_encode([
        'success' => true,
        'data' => ['doctors' => $doctors]
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
