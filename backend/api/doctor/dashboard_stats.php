<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

require_once '../auth/middleware.php';

$user = authenticate('doctor');
$doctorId = $user['id'];

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Check if we have a valid doctor profile ID
    // If the user array comes from 'users' table (fallback in middleware), it won't have 'user_id' column pointing to itself
    // unless strictly selected. The middleware selects *.
    // 'doctors' table has 'user_id'. 'users' table does id.
    // However, to be safe: if we fell back to users table, we probably don't have a doctor_id to query appointments with.
    
    if (!isset($user['user_id']) && !isset($user['license_number'])) {
        // This is likely a raw user without a doctor profile
        echo json_encode([
            'success' => true,
            'data' => [
                'today_appointments' => 0,
                'new_patients' => 0,
                'total_patients' => 0,
                'upcoming_appointments' => [],
                'recent_patients' => [],
                'recently_added_patients' => []
            ]
        ]);
        exit;
    }

    // 1. Get Appointments needing approval (Pending)
    $todayQuery = "SELECT COUNT(*) as count FROM appointments 
                   WHERE doctor_id = :doctor_id 
                   AND status = 'pending'";
    $todayStmt = $conn->prepare($todayQuery);
    $todayStmt->bindParam(':doctor_id', $doctorId);
    $todayStmt->execute();
    $todayCount = $todayStmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // 2. Get New Patients Count (Patients registered in last 30 days OR first appointment in last 30 days)
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
    $recentPatientsQuery = "SELECT DISTINCT u.id, u.full_name as name, u.profile_image, 
                                   MAX(a.appointment_date) as last_visit
                            FROM appointments a
                            JOIN users u ON a.patient_id = u.id
                            WHERE a.doctor_id = :doctor_id
                            GROUP BY u.id, u.full_name, u.profile_image
                            ORDER BY last_visit DESC
                            LIMIT 5";
                            
    $recentPatientsStmt = $conn->prepare($recentPatientsQuery);
    $recentPatientsStmt->bindParam(':doctor_id', $doctorId);
    $recentPatientsStmt->execute();
    $recentPatients = $recentPatientsStmt->fetchAll(PDO::FETCH_ASSOC);

    // 5. Get Total Patients Count (Patients linked to this doctor)
    $totalPatientsQuery = "SELECT COUNT(DISTINCT patient_id) as count FROM appointments WHERE doctor_id = :doctor_id";
    $totalPatientsStmt = $conn->prepare($totalPatientsQuery);
    $totalPatientsStmt->bindParam(':doctor_id', $doctorId);
    $totalPatientsStmt->execute();
    $totalPatientsCount = $totalPatientsStmt->fetch(PDO::FETCH_ASSOC)['count'];

    // 6. Get Recently Added Patients (Patients linked to this doctor, sorted by most recent first interaction)
    $recentlyAddedQuery = "SELECT DISTINCT u.id, u.full_name as name, u.phone, u.profile_image, u.created_at
                           FROM appointments a
                           JOIN users u ON a.patient_id = u.id
                           WHERE a.doctor_id = :doctor_id
                           ORDER BY a.created_at DESC
                           LIMIT 5";
    $recentlyAddedStmt = $conn->prepare($recentlyAddedQuery);
    $recentlyAddedStmt->bindParam(':doctor_id', $doctorId);
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
