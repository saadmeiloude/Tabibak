<?php
require_once 'config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    echo "=== CHECKING BOOKED SLOTS ===\n\n";
    
    // Get recent appointments to see what's booked
    $query = "SELECT a.id, a.doctor_id, a.appointment_date, a.appointment_time, a.status,
                     d.full_name as doctor_name, d.user_id as doctor_user_id,
                     p.full_name as patient_name
              FROM appointments a
              LEFT JOIN doctors d ON a.doctor_id = d.id
              LEFT JOIN users p ON a.patient_id = p.id
              WHERE a.appointment_date >= CURDATE()
              AND a.status != 'cancelled'
              ORDER BY a.appointment_date, a.appointment_time";
    
    $appointments = $conn->query($query)->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Found " . count($appointments) . " active upcoming appointments\n\n";
    
    $byDoctor = [];
    foreach ($appointments as $appt) {
        $doctorId = $appt['doctor_id'];
        $doctorName = $appt['doctor_name'] ?? 'Unknown';
        $date = $appt['appointment_date'];
        $time = $appt['appointment_time'];
        $key = "$doctorId|$date|$time";
        
        if (!isset($byDoctor[$doctorId])) {
            $byDoctor[$doctorId] = [
                'name' => $doctorName,
                'user_id' => $appt['doctor_user_id'],
                'slots' => []
            ];
        }
        
        if (isset($byDoctor[$doctorId]['slots'][$key])) {
            echo "⚠️  DUPLICATE SLOT FOUND!\n";
            echo "   Doctor: $doctorName (ID: $doctorId)\n";
            echo "   Date: $date, Time: $time\n";
            echo "   Existing: Appointment {$byDoctor[$doctorId]['slots'][$key]['id']} - {$byDoctor[$doctorId]['slots'][$key]['patient']}\n";
            echo "   New: Appointment {$appt['id']} - {$appt['patient_name']}\n\n";
        }
        
        $byDoctor[$doctorId]['slots'][$key] = [
            'id' => $appt['id'],
            'patient' => $appt['patient_name'],
            'datetime' => "$date $time"
        ];
    }
    
    echo "\n=== SUMMARY BY DOCTOR ===\n";
    foreach ($byDoctor as $doctorId => $data) {
        echo "Doctor ID: $doctorId ({$data['name']}, User ID: {$data['user_id']})\n";
        echo "  Total booked slots: " . count($data['slots']) . "\n\n";
    }
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
