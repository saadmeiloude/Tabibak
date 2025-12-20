<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

require_once '../auth/middleware.php';

$user = authenticate('doctor');
$doctorId = $user['id'];

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // 1. Get Today's Appointments Count
    $todayQuery = "SELECT COUNT(*) as count FROM appointments 
                   WHERE doctor_id = :doctor_id 
                   AND appointment_date = CURRENT_DATE() 
                   AND status != 'cancelled'";
    $todayStmt = $conn->prepare($todayQuery);
    $todayStmt->bindParam(':doctor_id', $doctorId);
    $todayStmt->execute();
    $todayCount = $todayStmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // 2. Get New Patients Count (Patients registered in last 30 days OR first appointment in last 30 days)
    // Simplified: Patients who have an appointment with this doctor created in the last 7 days
    // A better metric might be "Unique patients seen in the last 30 days" or "Total unique patients"
    // Let's go with "Total unique patients" for now, or "New patients this month"
    
    // Let's counting distinct patients whose first appointment with this doctor was in the last 30 days
    $newPatientsQuery = "SELECT COUNT(DISTINCT patient_id) as count FROM appointments 
                         WHERE doctor_id = :doctor_id 
                         AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
    $newPatientsStmt = $conn->prepare($newPatientsQuery);
    $newPatientsStmt->bindParam(':doctor_id', $doctorId);
    $newPatientsStmt->execute();
    $newPatientsCount = $newPatientsStmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // 3. Get Upcoming Appointments (Limit 5)
    $upcomingQuery = "SELECT a.id, a.patient_id, a.appointment_date, a.appointment_time, a.consultation_type, a.status,
                             u.full_name as patient_name, u.profile_image as patient_image
                      FROM appointments a
                      JOIN users u ON a.patient_id = u.id
                      WHERE a.doctor_id = :doctor_id 
                      AND (a.appointment_date > CURRENT_DATE() OR (a.appointment_date = CURRENT_DATE() AND a.appointment_time >= CURRENT_TIME()))
                      AND a.status IN ('confirmed', 'pending')
                      ORDER BY a.appointment_date ASC, a.appointment_time ASC
                      LIMIT 5";
    $upcomingStmt = $conn->prepare($upcomingQuery);
    $upcomingStmt->bindParam(':doctor_id', $doctorId);
    $upcomingStmt->execute();
    $upcomingAppointments = $upcomingStmt->fetchAll(PDO::FETCH_ASSOC);
    
    
    // 4. Get Recent Patients (Limit 5)
    // Patients with most recent completed appointments
    $recentPatientsQuery = "SELECT DISTINCT u.id, u.full_name as name, u.profile_image, 
                                   MAX(a.appointment_date) as last_visit
                            FROM appointments a
                            JOIN users u ON a.patient_id = u.id
                            WHERE a.doctor_id = :doctor_id
                            AND a.status = 'completed'
                            GROUP BY u.id, u.full_name, u.profile_image
                            ORDER BY last_visit DESC
                            LIMIT 5";
                            
    // If no completed, show any recent interaction
    if ($upcomingAppointments) {
         // Fallback logic if needed, but the query above is standard
    }

    $recentPatientsStmt = $conn->prepare($recentPatientsQuery);
    $recentPatientsStmt->bindParam(':doctor_id', $doctorId);
    $recentPatientsStmt->execute();
    $recentPatients = $recentPatientsStmt->fetchAll(PDO::FETCH_ASSOC);

    // 5. Get Total Patients Count (All patients in system)
    $totalPatientsQuery = "SELECT COUNT(*) as count FROM users WHERE user_type = 'patient'";
    $totalPatientsStmt = $conn->prepare($totalPatientsQuery);
    $totalPatientsStmt->execute();
    $totalPatientsCount = $totalPatientsStmt->fetch(PDO::FETCH_ASSOC)['count'];

    // 6. Get Recently Added Patients (Last 7 days)
    $recentlyAddedQuery = "SELECT id, full_name as name, phone, profile_image, created_at
                           FROM users 
                           WHERE user_type = 'patient'
                           ORDER BY created_at DESC
                           LIMIT 5";
    $recentlyAddedStmt = $conn->prepare($recentlyAddedQuery);
    $recentlyAddedStmt->execute();
    $recentlyAddedPatients = $recentlyAddedStmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'data' => [
            'today_appointments' => $todayCount,
            'new_patients' => $newPatientsCount,
            'total_patients' => $totalPatientsCount,
            'upcoming_appointments' => $upcomingAppointments,
            'recent_patients' => $recentPatients,
            'recently_added_patients' => $recentlyAddedPatients
        ]
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error: ' . $e->getMessage()]);
}
?>
