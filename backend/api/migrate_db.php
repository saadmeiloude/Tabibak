<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // 1. Create specialties table (MySQL version)
    $specialtiesSql = "CREATE TABLE IF NOT EXISTS specialties (
      id CHAR(36) PRIMARY KEY,
      specialty VARCHAR(100) UNIQUE NOT NULL,
      specialty_name VARCHAR(100) NOT NULL,
      specialty_doctor_count VARCHAR(10) DEFAULT '0',
      specialty_image_path VARCHAR(500),
      description TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $conn->exec($specialtiesSql);
    echo "Table 'specialties' created/verified.\n";

    // 2. Modify doctors table to be standalone (not dependent on users table for identity)
    // First check columns
    $stmt = $conn->query("DESCRIBE doctors");
    $cols = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    $newCols = [
        'full_name' => "ALTER TABLE doctors ADD COLUMN full_name VARCHAR(255) AFTER id",
        'email' => "ALTER TABLE doctors ADD COLUMN email VARCHAR(100) UNIQUE AFTER full_name",
        'phone' => "ALTER TABLE doctors ADD COLUMN phone VARCHAR(20) UNIQUE AFTER email",
        'password' => "ALTER TABLE doctors ADD COLUMN password VARCHAR(255) AFTER phone",
        'profile_image' => "ALTER TABLE doctors ADD COLUMN profile_image VARCHAR(500) AFTER password",
        'is_verified' => "ALTER TABLE doctors ADD COLUMN is_verified TINYINT(1) DEFAULT 0 AFTER profile_image",
        'is_active' => "ALTER TABLE doctors ADD COLUMN is_active TINYINT(1) DEFAULT 1 AFTER is_verified"
    ];

    foreach ($newCols as $col => $sql) {
        if (!in_array($col, $cols)) {
            $conn->exec($sql);
            echo "Added column '$col' to 'doctors'.\n";
        }
    }

    // Optional: Migrate existing doctors if any? 
    // Usually a good idea to move data from users+doctors to just doctors.
    $migrateSql = "UPDATE doctors d 
                   JOIN users u ON d.user_id = u.id 
                   SET d.full_name = u.full_name, 
                       d.email = u.email, 
                       d.phone = u.phone, 
                       d.password = u.password,
                       d.profile_image = u.profile_image,
                       d.is_verified = u.is_verified";
    $conn->exec($migrateSql);
    // 3. Update user_sessions to handle both tables
    $stmt = $conn->query("DESCRIBE user_sessions");
    $sessionCols = $stmt->fetchAll(PDO::FETCH_COLUMN);
    if (!in_array('user_type', $sessionCols)) {
        $conn->exec("ALTER TABLE user_sessions ADD COLUMN user_type VARCHAR(20) DEFAULT 'patient' AFTER user_id");
        echo "Added column 'user_type' to 'user_sessions'.\n";
    }

    // Set existing sessions to patient (or doctor based on previous state if possible, but let's assume patient for now)
    $conn->exec("UPDATE user_sessions s JOIN users u ON s.user_id = u.id SET s.user_type = u.user_type");

    // 4. Seed specialties if empty
    $checkSpecs = $conn->query("SELECT COUNT(*) FROM specialties");
    if ($checkSpecs->fetchColumn() == 0) {
        $specs = [
            ['id1', 'cardiologist', 'Cardiologie', '12', 'assets/images/cardiologist.png', 'Spécialistes du cœur'],
            ['id2', 'dentist', 'Dentisterie', '8', 'assets/images/dentist.png', 'Soins dentaires'],
            ['id3', 'dermatologist', 'Dermatologie', '5', 'assets/images/dermatologist.png', 'Soins de la peau']
        ];
        $stmt = $conn->prepare("INSERT INTO specialties (id, specialty, specialty_name, specialty_doctor_count, specialty_image_path, description) VALUES (?, ?, ?, ?, ?, ?)");
        foreach ($specs as $s) {
            $stmt->execute($s);
        }
        echo "Seed data for 'specialties' added.\n";
    }

    echo "Database refactoring completed successfully.";

} catch (Exception $e) {
    http_response_code(500);
    echo "Error: " . $e->getMessage();
}
?>
