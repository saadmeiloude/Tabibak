<?php
require_once 'config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    echo "=== FIXING OLD APPOINTMENTS ===\n\n";
    
    // Get all appointments with incorrect doctor_id
    $query = "SELECT a.id, a.doctor_id FROM appointments a 
              WHERE NOT EXISTS (SELECT 1 FROM doctors d WHERE d.id = a.doctor_id)";
    $appointments = $conn->query($query)->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Found " . count($appointments) . " appointments with incorrect doctor_id\n\n";
    
    $fixed = 0;
    $failed = 0;
    
    foreach ($appointments as $appt) {
        $appointmentId = $appt['id'];
        $incorrectDoctorId = $appt['doctor_id'];
        
        // Check if this incorrectDoctorId is actually a user_id in doctors table
        $stmt = $conn->prepare("SELECT id FROM doctors WHERE user_id = ?");
        $stmt->execute([$incorrectDoctorId]);
        $correctDoctorId = $stmt->fetchColumn();
        
        if ($correctDoctorId) {
            // Fix the appointment
            $updateStmt = $conn->prepare("UPDATE appointments SET doctor_id = ? WHERE id = ?");
            $updateStmt->execute([$correctDoctorId, $appointmentId]);
            
            echo "✓ Fixed Appointment $appointmentId: $incorrectDoctorId → $correctDoctorId\n";
            $fixed++;
        } else {
            echo "✗ Cannot fix Appointment $appointmentId: No doctor found for user_id $incorrectDoctorId\n";
            $failed++;
        }
    }
    
    echo "\n=== RESULTS ===\n";
    echo "Fixed: $fixed\n";
    echo "Failed: $failed\n";
    
    // Verify the fix
    echo "\n=== VERIFICATION ===\n";
    $remaining = $conn->query("SELECT COUNT(*) FROM appointments a 
                                WHERE NOT EXISTS (SELECT 1 FROM doctors d WHERE d.id = a.doctor_id)")->fetchColumn();
    echo "Remaining appointments with incorrect doctor_id: $remaining\n";

} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
