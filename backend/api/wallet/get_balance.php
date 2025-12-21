<?php
// Disable display_errors to prevent HTML output, but log them
ini_set('display_errors', 0);
error_reporting(E_ALL);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    require_once '../../config/database.php';

    // Get params
    $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;
    $user_type = isset($_GET['user_type']) ? $_GET['user_type'] : 'patient'; // Default 'patient' if not provided

    if (!$user_id) {
        throw new Exception('معرف المستخدم مطلوب');
    }

    /* $database = new Database(); -- Wrong, Singleton */
    $db = Database::getInstance()->getConnection();
    
    // Check if table exists (quick check)
    try {
        $check_table = "SELECT 1 FROM wallets LIMIT 1";
        $db->query($check_table);
    } catch (PDOException $e) {
         throw new Exception('جداول المحفظة غير موجودة. يرجى إعادة ضبط قاعدة البيانات.', 0, $e);
    }
    
    // Get Wallet
    $query = "SELECT * FROM wallets WHERE user_id = :user_id AND user_type = :user_type";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':user_id', $user_id);
    $stmt->bindParam(':user_type', $user_type);
    $stmt->execute();
    
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // If wallet doesn't exist, create it
    if (!$wallet) {
        $insert = "INSERT INTO wallets (user_id, user_type, balance, currency) VALUES (:user_id, :user_type, 0.00, 'MRU')";
        $istmt = $db->prepare($insert);
        $istmt->bindParam(':user_id', $user_id);
        $istmt->bindParam(':user_type', $user_type);
        $istmt->execute();
        
        // Fetch again
        $stmt->execute();
        $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    // Get User Info
    $full_name = 'مستخدم'; // Default name
    
    // Check columns first to avoid errors
    if ($user_type === 'doctor') {
         // Fallback if full_name doesn't exist, try getting it via join with users if possible
         // But let's verify if full_name exists first
         try {
            $u_query = "SELECT full_name FROM doctors WHERE id = :uid";
            $ustmt = $db->prepare($u_query);
            $ustmt->bindParam(':uid', $user_id);
            $ustmt->execute();
            if ($row = $ustmt->fetch(PDO::FETCH_ASSOC)) {
                $full_name = $row['full_name'];
            }
         } catch (PDOException $e) {
            // Probably full_name column missing, maybe query from users table using user_id foreign key?
            // doctor.user_id -> users.id
            $u_query = "SELECT u.full_name FROM users u JOIN doctors d ON u.id = d.user_id WHERE d.id = :uid";
            $ustmt = $db->prepare($u_query);
            $ustmt->bindParam(':uid', $user_id);
            $ustmt->execute();
             if ($row = $ustmt->fetch(PDO::FETCH_ASSOC)) {
                $full_name = $row['full_name'];
            }
         }
    } else {
        $u_query = "SELECT full_name FROM users WHERE id = :uid";
        $ustmt = $db->prepare($u_query);
        $ustmt->bindParam(':uid', $user_id);
        $ustmt->execute();
        if ($row = $ustmt->fetch(PDO::FETCH_ASSOC)) {
            $full_name = $row['full_name'];
        }
    }
    
    // Get Stats
    $wallet_id = $wallet['id'];
    $trans_query = "SELECT COUNT(*) as total_transactions,
                    SUM(CASE WHEN transaction_type = 'deposit' THEN amount ELSE 0 END) as total_deposits,
                    SUM(CASE WHEN transaction_type = 'withdrawal' THEN amount ELSE 0 END) as total_withdrawals,
                    SUM(CASE WHEN transaction_type = 'payment' THEN amount ELSE 0 END) as total_payments
                    FROM transactions 
                    WHERE wallet_id = :wallet_id AND status = 'completed'";
    
    $tstmt = $db->prepare($trans_query);
    $tstmt->bindParam(':wallet_id', $wallet_id);
    $tstmt->execute();
    $stats = $tstmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'wallet' => [
            'id' => intval($wallet['id']),
            'user_id' => intval($wallet['user_id']),
            'user_type' => $wallet['user_type'],
            'balance' => floatval($wallet['balance']),
            'currency' => $wallet['currency'],
            'currency_symbol' => 'أ.م',
            'is_active' => (bool)$wallet['is_active'],
            'last_transaction_at' => $wallet['last_transaction_at'],
            'created_at' => $wallet['created_at']
        ],
        'statistics' => [
            'total_transactions' => intval($stats['total_transactions']),
            'total_deposits' => floatval($stats['total_deposits'] ?? 0),
            'total_withdrawals' => floatval($stats['total_withdrawals'] ?? 0),
            'total_payments' => floatval($stats['total_payments'] ?? 0)
        ],
        'user' => [
            'full_name' => $full_name,
            'user_type' => $user_type
        ]
    ], JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => 'حدث خطأ في الخادم',
        'error' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
