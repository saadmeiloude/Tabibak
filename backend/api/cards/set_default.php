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

    $conn->beginTransaction();

    // Set all cards for this user to NOT default
    $query1 = "UPDATE payment_cards SET is_default = 0 WHERE user_id = :user_id";
    $stmt1 = $conn->prepare($query1);
    $stmt1->bindParam(':user_id', $userId);
    $stmt1->execute();

    // Set target card to default
    $query2 = "UPDATE payment_cards SET is_default = 1 WHERE id = :id AND user_id = :user_id";
    $stmt2 = $conn->prepare($query2);
    $stmt2->bindParam(':id', $input['id']);
    $stmt2->bindParam(':user_id', $userId);
    $stmt2->execute();

    $conn->commit();
    echo json_encode(['success' => true, 'message' => 'Default card updated successfully']);

} catch (Exception $e) {
    if (isset($conn) && $conn->inTransaction()) {
        $conn->rollBack();
    }
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
