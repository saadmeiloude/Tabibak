<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../../config/database.php';

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 50;
$offset = isset($_GET['offset']) ? intval($_GET['offset']) : 0;
$type = isset($_GET['type']) ? $_GET['type'] : null;
$status = isset($_GET['status']) ? $_GET['status'] : null;

if (!$user_id) {
    echo json_encode([
        'success' => false,
        'message' => 'معرف المستخدم مطلوب'
    ]);
    exit();
}

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Build query
    $where_conditions = ["user_id = :user_id"];
    $params = [':user_id' => $user_id];
    
    if ($type) {
        $where_conditions[] = "transaction_type = :type";
        $params[':type'] = $type;
    }
    
    if ($status) {
        $where_conditions[] = "status = :status";
        $params[':status'] = $status;
    }
    
    $where_clause = implode(' AND ', $where_conditions);
    
    // Get total count
    $count_query = "SELECT COUNT(*) as total FROM transactions WHERE $where_clause";
    $count_stmt = $db->prepare($count_query);
    foreach ($params as $key => $value) {
        $count_stmt->bindValue($key, $value);
    }
    $count_stmt->execute();
    $total = $count_stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // Get transactions
    $query = "SELECT t.*, 
              CASE 
                  WHEN t.related_user_id IS NOT NULL THEN u.full_name
                  ELSE NULL
              END as related_user_name
              FROM transactions t
              LEFT JOIN users u ON t.related_user_id = u.id
              WHERE $where_clause
              ORDER BY t.created_at DESC
              LIMIT :limit OFFSET :offset";
    
    $stmt = $db->prepare($query);
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();
    
    $transactions = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $metadata = json_decode($row['metadata'], true);
        
        $transactions[] = [
            'id' => $row['id'],
            'reference' => $row['transaction_ref'],
            'type' => $row['transaction_type'],
            'amount' => floatval($row['amount']),
            'currency' => $row['currency'],
            'balance_before' => floatval($row['balance_before']),
            'balance_after' => floatval($row['balance_after']),
            'status' => $row['status'],
            'payment_method' => $row['payment_method'],
            'description' => $row['description'],
            'metadata' => $metadata,
            'related_user_name' => $row['related_user_name'],
            'related_appointment_id' => $row['related_appointment_id'],
            'created_at' => $row['created_at'],
            'processed_at' => $row['processed_at']
        ];
    }
    
    echo json_encode([
        'success' => true,
        'transactions' => $transactions,
        'pagination' => [
            'total' => intval($total),
            'limit' => $limit,
            'offset' => $offset,
            'has_more' => ($offset + $limit) < $total
        ]
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'حدث خطأ أثناء جلب المعاملات',
        'error' => $e->getMessage()
    ]);
}
