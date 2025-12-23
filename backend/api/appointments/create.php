<?php
header('Content-Type: application/json');
require_once '../../config/database.php';
require_once '../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$user = authenticate();
$input = json_decode(file_get_contents('php://input'), true);

// DEBUG LOGGING
file_put_contents('debug_create_appointment.txt', date('Y-m-d H:i:s') . " - Input: " . print_r($input, true) . "\n", FILE_APPEND);
file_put_contents('debug_create_appointment.txt', date('Y-m-d H:i:s') . " - User: " . print_r($user, true) . "\n", FILE_APPEND);

$requiredFields = ['doctor_id', 'appointment_date', 'appointment_time'];
foreach ($requiredFields as $field) {
    if (!isset($input[$field]) || empty(trim($input[$field]))) {
        http_response_code(400);
        echo json_encode(['error' => ucfirst(str_replace('_', ' ', $field)) . ' is required']);
        exit;
    }
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // INTELLIGENT DOCTOR ID RESOLUTION
    // The frontend might send user_id instead of doctor_id. We need to handle both.
    $providedId = $input['doctor_id'];
    $finalDoctorId = $providedId; // Default to assuming it's correct

    // 1. Check if this ID exists as a doctor's Primary Key
    $checkPk = $conn->prepare("SELECT id FROM doctors WHERE id = ?");
    $checkPk->execute([$providedId]);
    if (!$checkPk->fetchColumn()) {
        // 2. If not found, check if it is a doctor's User ID
        $checkUser = $conn->prepare("SELECT id FROM doctors WHERE user_id = ?");
        $checkUser->execute([$providedId]);
        $resolvedId = $checkUser->fetchColumn();
        
        if ($resolvedId) {
            $finalDoctorId = $resolvedId;
            file_put_contents('debug_create_appointment.txt', date('Y-m-d H:i:s') . " - RESOLVED Doctor ID from $providedId to $finalDoctorId\n", FILE_APPEND);
        } else {
             // If neither, we have an invalid doctor ID, but we let it proceed to fail at FK constraint or insert null
             // Or better, error out here? Let's error out to be safe.
             http_response_code(400);
             echo json_encode(['error' => 'Invalid Doctor ID']);
             exit;
        }
    }

    // Check if slot is available
    $query = "SELECT count(*) FROM appointments 
              WHERE doctor_id = :doctor_id 
              AND appointment_date = :date 
              AND appointment_time = :time 
              AND status != 'cancelled'";
              
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':doctor_id', $finalDoctorId);
    $stmt->bindParam(':date', $input['appointment_date']);
    $stmt->bindParam(':time', $input['appointment_time']);
    $stmt->execute();
    
    if ($stmt->fetchColumn() > 0) {
        http_response_code(409);
        echo json_encode(['error' => 'This time slot is already booked']);
        exit;
    }
    
    // Create appointment
    $insertQuery = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, symptoms, consultation_type, duration_minutes) 
                    VALUES (:patient_id, :doctor_id, :date, :time, :symptoms, :type, :duration)";
                    
    // Determine patient_id
    $patientId = $user['id'];
    if ($user['user_type'] === 'doctor') {
        if (!isset($input['patient_id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Patient ID is required for doctor bookings']);
            exit;
        }
        $patientId = $input['patient_id'];
    }

    $stmt = $conn->prepare($insertQuery);
    $stmt->bindParam(':patient_id', $patientId);
    $stmt->bindParam(':doctor_id', $finalDoctorId);
    $stmt->bindParam(':date', $input['appointment_date']);
    $stmt->bindParam(':time', $input['appointment_time']);
    $stmt->bindValue(':symptoms', $input['symptoms'] ?? null);
    $stmt->bindValue(':type', $input['consultation_type'] ?? 'online');
    $stmt->bindValue(':duration', $input['duration_minutes'] ?? 30);
    
    if ($stmt->execute()) {
        $appointmentId = $conn->lastInsertId();
        
        // Fetch complete appointment data with doctor and patient names
        $fetchQuery = "SELECT a.*, 
                              p.full_name as patient_name,
                              d.full_name as doctor_name
                       FROM appointments a
                       LEFT JOIN users p ON a.patient_id = p.id
                       LEFT JOIN doctors d ON a.doctor_id = d.id
                       WHERE a.id = :id";
        $fetchStmt = $conn->prepare($fetchQuery);
        $fetchStmt->bindParam(':id', $appointmentId);
        $fetchStmt->execute();
        $appointment = $fetchStmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$appointment) {
            // Fallback if join completely fails or id not found (unlikely)
            $stmt = $conn->query("SELECT * FROM appointments WHERE id = $appointmentId");
            $appointment = $stmt->fetch(PDO::FETCH_ASSOC);
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'Appointment booked successfully',
            'data' => ['appointment' => $appointment]
        ]);
        file_put_contents('debug_create_appointment.txt', date('Y-m-d H:i:s') . " - Success! ID: " . $appointmentId . "\n---\n", FILE_APPEND);
    } else {
        throw new Exception("Failed to insert appointment");
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
