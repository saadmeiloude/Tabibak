<?php
header('Content-Type: application/json');
require_once '../../config/database.php';
require_once '../auth/middleware.php';

$user = authenticate('patient');
$userId = $user['id'];

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['id'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing card ID']);
    exit;
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    $query = "DELETE FROM payment_cards WHERE id = :id AND user_id = :user_id";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':id', $input['id']);
    $stmt->bindParam(':user_id', $userId);
    
    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Card deleted successfully']);
    } else {
        throw new Exception("Failed to delete card");
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
