<?php
header('Content-Type: application/json');
require_once '../../config/database.php';
require_once '../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$user = authenticate();

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Check if filtering by specific user (only admin or doctor can do this usually, but for now we simplify)
    // If request asks for specific user and current user is authorized, use that.
    // Default: get appointments for current user where they are either patient or doctor
    
    $whereClause = "(patient_id = :patient_id OR doctor_id = :doctor_id)";
    
    // Correct Join: appointments.doctor_id refers to doctors.id
    // doctors.user_id refers to users.id
    $query = "SELECT a.*, 
                     p.full_name as patient_name,
                     u.full_name as doctor_name,
                     doc.specialization,
                     COALESCE(a.fee_paid, doc.consultation_fee) as amount
              FROM appointments a 
              JOIN users p ON a.patient_id = p.id
              JOIN doctors doc ON a.doctor_id = doc.id
              JOIN users u ON doc.user_id = u.id
              WHERE $whereClause
              ORDER BY a.appointment_date DESC, a.appointment_time DESC";
              
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':patient_id', $user['id']);
    
    // For doctor check, we need to find doctor record id for current user
    // But since $whereClause uses :doctor_id parameter which matches appointments.doctor_id
    // We need to pass the doctor.id corresponding to current user.id
    
    // First, let's find if current user is a doctor and get their doctor ID
    $doctorQuery = "SELECT id FROM doctors WHERE user_id = :uid";
    $dStmt = $conn->prepare($doctorQuery);
    $dStmt->bindParam(':uid', $user['id']);
    $dStmt->execute();
    $doctorId = $dStmt->fetchColumn();
    
    // If user is not keywords doctor, this param might not matching anything, which is fine for patient view
    // But to be safe, if $doctorId is false (not found), we pass 0 or NULL
    $bindDoctorId = $doctorId ? $doctorId : 0;
    
    $stmt->bindParam(':doctor_id', $bindDoctorId);
    $stmt->execute();
    
    $appointments = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => ['appointments' => $appointments]
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
