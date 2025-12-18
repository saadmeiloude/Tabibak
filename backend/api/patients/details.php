<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

if (!isset($_GET['id'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Patient ID is required']);
    exit;
}

$patientId = $_GET['id'];

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    // 1. Get Patient Profile
    $query = "SELECT id, full_name, phone, email, date_of_birth, gender, profile_image 
              FROM users 
              WHERE id = :id AND user_type = 'patient'";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':id', $patientId);
    $stmt->execute();
    $patient = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$patient) {
        http_response_code(404);
        echo json_encode(['error' => 'Patient not found']);
        exit;
    }

    // 2. Get Past Appointments (Visits)
    $queryVisits = "SELECT a.id, a.appointment_date, a.appointment_time, a.status, a.notes, a.consultation_type,
                           d.full_name as doctor_name
                    FROM appointments a
                    JOIN users d ON a.doctor_id = d.id
                    WHERE a.patient_id = :id
                    ORDER BY a.appointment_date DESC";
    $stmtVisits = $conn->prepare($queryVisits);
    $stmtVisits->bindParam(':id', $patientId);
    $stmtVisits->execute();
    $visits = $stmtVisits->fetchAll(PDO::FETCH_ASSOC);

    // 3. Get Medical Records (Reports & Prescriptions)
    $queryRecords = "SELECT mr.*, d.full_name as doctor_name
                     FROM medical_records mr
                     JOIN users d ON mr.doctor_id = d.id
                     WHERE mr.patient_id = :id
                     ORDER BY mr.record_date DESC";
    $stmtRecords = $conn->prepare($queryRecords);
    $stmtRecords->bindParam(':id', $patientId);
    $stmtRecords->execute();
    $allRecords = $stmtRecords->fetchAll(PDO::FETCH_ASSOC);

    // Filter records
    $reports = array_filter($allRecords, function($r) {
        return in_array($r['record_type'], ['test_result', 'diagnosis', 'consultation']);
    });
    
    $prescriptions = array_filter($allRecords, function($r) {
        return $r['record_type'] === 'prescription';
    });

    echo json_encode([
        'success' => true,
        'data' => [
            'patient' => $patient,
            'visits' => $visits,
            'reports' => array_values($reports),
            'prescriptions' => array_values($prescriptions)
        ]
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
