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

$requiredFields = ['doctor_id', 'rating'];
foreach ($requiredFields as $field) {
    if (!isset($input[$field])) {
        http_response_code(400);
        echo json_encode(['error' => ucfirst(str_replace('_', ' ', $field)) . ' is required']);
        exit;
    }
}

$doctorId = $input['doctor_id'];
$rating = $input['rating'];
$reviewText = $input['review_text'] ?? '';
$appointmentId = $input['appointment_id'] ?? null;

if ($rating < 1 || $rating > 5) {
    http_response_code(400);
    echo json_encode(['error' => 'Rating must be between 1 and 5']);
    exit;
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Insert review
    $insertQuery = "INSERT INTO reviews (patient_id, doctor_id, appointment_id, rating, review_text) 
                    VALUES (:patient_id, :doctor_id, :appointment_id, :rating, :review_text)";
    
    $stmt = $conn->prepare($insertQuery);
    $stmt->bindParam(':patient_id', $user['id']);
    $stmt->bindParam(':doctor_id', $doctorId);
    $stmt->bindValue(':appointment_id', $appointmentId);
    $stmt->bindParam(':rating', $rating);
    $stmt->bindParam(':review_text', $reviewText);
    
    if ($stmt->execute()) {
        // Update doctor's average rating
        $updateQuery = "UPDATE doctors d 
                        SET rating = (SELECT AVG(rating) FROM reviews WHERE doctor_id = :doc_id1),
                            total_reviews = (SELECT COUNT(*) FROM reviews WHERE doctor_id = :doc_id2)
                        WHERE user_id = :doc_id3"; // Assuming doctor_id in reviews is users.id
        
        // Wait, in schema.sql:
        // doctors table has id and user_id.
        // reviews table has doctor_id which is users(id) or doctors(id)?
        // FOREIGN KEY (doctor_id) REFERENCES users(id) in reviews table.
        
        $updateStmt = $conn->prepare($updateQuery);
        $updateStmt->bindParam(':doc_id1', $doctorId);
        $updateStmt->bindParam(':doc_id2', $doctorId);
        $updateStmt->bindParam(':doc_id3', $doctorId);
        $updateStmt->execute();
        
        echo json_encode([
            'success' => true,
            'message' => 'Rating submitted successfully'
        ]);
    } else {
        throw new Exception("Failed to insert review");
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
