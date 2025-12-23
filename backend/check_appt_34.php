<?php
require_once 'config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    echo "Checking Appointment 34...\n";
    $stmt = $conn->query("SELECT * FROM appointments WHERE id = 34");
    $appt = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($appt) {
        print_r($appt);
        
        echo "\nChecking relationships for Doctor ID " . $appt['doctor_id'] . ":\n";
        $d = $conn->query("SELECT * FROM doctors WHERE id = " . $appt['doctor_id'])->fetch(PDO::FETCH_ASSOC);
        print_r($d);
        
        echo "\nChecking relationships for Patient ID " . $appt['patient_id'] . ":\n";
        $p = $conn->query("SELECT * FROM users WHERE id = " . $appt['patient_id'])->fetch(PDO::FETCH_ASSOC);
        print_r($p);
        
    } else {
        echo "Appointment 34 NOT FOUND.\n";
    }

} catch (Exception $e) { 
    echo $e->getMessage(); 
}
?>
