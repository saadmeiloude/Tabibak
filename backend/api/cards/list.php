<?php
header('Content-Type: application/json');
require_once '../../config/database.php';
require_once '../auth/middleware.php';

$user = authenticate('patient');
$userId = $user['id'];

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    $query = "SELECT * FROM payment_cards WHERE user_id = :user_id ORDER BY is_default DESC, created_at DESC";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':user_id', $userId);
    $stmt->execute();
    $cards = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(['success' => true, 'data' => $cards]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
