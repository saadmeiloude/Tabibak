<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

$method = $_SERVER['REQUEST_METHOD'];

// Get token (Auth check usually here)

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Simple report: Appointments count per status today
    $query = "SELECT status, COUNT(*) as count 
              FROM appointments 
              WHERE appointment_date = CURRENT_DATE() 
              GROUP BY status";
              
    $stmt = $conn->prepare($query);
    $stmt->execute();
    $todayStats = $stmt->fetchAll(PDO::FETCH_KEY_PAIR); // ['confirmed' => 5, 'pending' => 2]
    
    // Total patients
    $query2 = "SELECT COUNT(*) FROM users WHERE user_type = 'patient'";
    $stmt2 = $conn->prepare($query2);
    $stmt2->execute();
    $totalPatients = $stmt2->fetchColumn();
    
    // Revenue today (sum of fee_paid)
    $query3 = "SELECT SUM(fee_paid) FROM appointments WHERE appointment_date = CURRENT_DATE()";
    $stmt3 = $conn->prepare($query3);
    $stmt3->execute();
    $revenueToday = $stmt3->fetchColumn() ?: 0;

    echo json_encode([
        'success' => true,
        'data' => [
            'today_stats' => (object)$todayStats,
            'total_patients' => $totalPatients,
            'revenue_today' => $revenueToday
        ]
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
