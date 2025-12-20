<?php
header('Content-Type: application/json');
require_once '../../config/database.php';
require_once '../auth/middleware.php';

$user = authenticate('patient');
$userId = $user['id'];

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['card_number']) || !isset($input['holder_name']) || !isset($input['expiry_date']) || !isset($input['card_type'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing required fields']);
    exit;
}

// Mask card number for storage
$last4 = substr($input['card_number'], -4);
$masked = "**** **** **** " . $last4;

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    // If first card, make it default
    $checkQuery = "SELECT COUNT(*) FROM payment_cards WHERE user_id = :user_id";
    $checkStmt = $conn->prepare($checkQuery);
    $checkStmt->bindParam(':user_id', $userId);
    $checkStmt->execute();
    $isDefault = ($checkStmt->fetchColumn() == 0) ? 1 : 0;

    $query = "INSERT INTO payment_cards (user_id, card_type, card_number_masked, holder_name, expiry_date, is_default) 
              VALUES (:user_id, :card_type, :card_number_masked, :holder_name, :expiry_date, :is_default)";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':user_id', $userId);
    $stmt->bindParam(':card_type', $input['card_type']);
    $stmt->bindParam(':card_number_masked', $masked);
    $stmt->bindParam(':holder_name', $input['holder_name']);
    $stmt->bindParam(':expiry_date', $input['expiry_date']);
    $stmt->bindParam(':is_default', $isDefault);
    
    if ($stmt->execute()) {
        $cardId = $conn->lastInsertId();
        $newCard = [
            'id' => $cardId,
            'card_type' => $input['card_type'],
            'card_number_masked' => $masked,
            'holder_name' => $input['holder_name'],
            'expiry_date' => $input['expiry_date'],
            'is_default' => $isDefault
        ];
        echo json_encode(['success' => true, 'message' => 'Card added successfully', 'data' => $newCard]);
    } else {
        throw new Exception("Failed to insert card");
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>
