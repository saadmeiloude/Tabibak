<?php
require_once 'config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    echo "=== CHECKING APPOINTMENTS AND DOCTORS RELATIONSHIP ===\n\n";
    
    // Get all appointments
    $appointments = $conn->query("SELECT id, patient_id, doctor_id, appointment_date, status FROM appointments ORDER BY id DESC LIMIT 10")->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Total appointments found: " . count($appointments) . "\n\n";
    
    foreach ($appointments as $appt) {
        echo "Appointment ID: {$appt['id']}\n";
        echo "  Patient ID: {$appt['patient_id']}\n";
        echo "  Doctor ID: {$appt['doctor_id']}\n";
        echo "  Date: {$appt['appointment_date']}\n";
        echo "  Status: {$appt['status']}\n";
        
        // Check if doctor exists
        $doctor = $conn->query("SELECT id, user_id, full_name FROM doctors WHERE id = {$appt['doctor_id']}")->fetch(PDO::FETCH_ASSOC);
        if ($doctor) {
            echo "  ✓ Doctor found: {$doctor['full_name']} (Doctor ID: {$doctor['id']}, User ID: {$doctor['user_id']})\n";
        } else {
            echo "  ✗ Doctor NOT found for doctor_id {$appt['doctor_id']}\n";
            // Check if this doctor_id might be a user_id
            $userAsDoctor = $conn->query("SELECT id, full_name FROM users WHERE id = {$appt['doctor_id']} AND user_type = 'doctor'")->fetch(PDO::FETCH_ASSOC);
            if ($userAsDoctor) {
                echo "    → BUT User ID {$appt['doctor_id']} exists as doctor: {$userAsDoctor['full_name']}\n";
                // Check if this user has a doctor profile
                $doctorProfile = $conn->query("SELECT id FROM doctors WHERE user_id = {$appt['doctor_id']}")->fetch(PDO::FETCH_ASSOC);
                if ($doctorProfile) {
                    echo "    → SOLUTION: Should use Doctor ID {$doctorProfile['id']} instead!\n";
                }
            }
        }
        echo "\n";
    }
    
    echo "\n=== DOCTORS TABLE ===\n";
    $doctors = $conn->query("SELECT id, user_id, full_name FROM doctors")->fetchAll(PDO::FETCH_ASSOC);
    foreach ($doctors as $doc) {
        echo "Doctor ID: {$doc['id']}, User ID: {$doc['user_id']}, Name: {$doc['full_name']}\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
