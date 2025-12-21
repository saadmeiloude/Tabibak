<?php
// Disable display_errors to prevent HTML output, but log them
ini_set('display_errors', 0);
error_reporting(E_ALL);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    require_once '../../config/database.php';

    $data = json_decode(file_get_contents("php://input"));

    if (!isset($data->user_id) || !isset($data->amount)) {
        throw new Exception('معرف المستخدم والمبلغ مطلوبان');
    }

    $user_id = intval($data->user_id);
    $user_type = isset($data->user_type) ? $data->user_type : 'patient';
    $amount = floatval($data->amount);
    $payment_method = $data->payment_method ?? 'card';
    $description = $data->description ?? 'إيداع رصيد';

    if ($amount <= 0) {
        throw new Exception('المبلغ يجب أن يكون أكبر من صفر');
    }

    $db = Database::getInstance()->getConnection();
    
    // Start transaction
    $db->beginTransaction();
    
    // Get wallet
    $wallet_query = "SELECT * FROM wallets WHERE user_id = :user_id AND user_type = :user_type FOR UPDATE";
    $wallet_stmt = $db->prepare($wallet_query);
    $wallet_stmt->bindParam(':user_id', $user_id);
    $wallet_stmt->bindParam(':user_type', $user_type);
    $wallet_stmt->execute();
    $wallet = $wallet_stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$wallet) {
        // Create wallet if doesn't exist
        $create_wallet = "INSERT INTO wallets (user_id, user_type, balance, currency) VALUES (:user_id, :user_type, 0.00, 'MRU')";
        $create_stmt = $db->prepare($create_wallet);
        $create_stmt->bindParam(':user_id', $user_id);
        $create_stmt->bindParam(':user_type', $user_type);
        $create_stmt->execute();
        
        $wallet_stmt->execute();
        $wallet = $wallet_stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    $balance_before = floatval($wallet['balance']);
    
    // Calculate commission if applicable
    $commission = 0;
    // Check if commission_settings table exists
    try {
        $check_comm = "SELECT 1 FROM commission_settings LIMIT 1";
        $db->query($check_comm);
        
        $commission_query = "SELECT * FROM commission_settings 
                            WHERE transaction_type = 'deposit_card' 
                            AND is_active = TRUE 
                            AND :amount >= min_amount 
                            AND (:amount <= max_amount OR max_amount IS NULL)
                            LIMIT 1";
        $comm_stmt = $db->prepare($commission_query);
        $comm_stmt->bindParam(':amount', $amount);
        $comm_stmt->execute();
        $commission_setting = $comm_stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($commission_setting && $payment_method === 'card') {
            if ($commission_setting['commission_type'] === 'percentage') {
                $commission = ($amount * $commission_setting['commission_value']) / 100;
            } else {
                $commission = $commission_setting['commission_value'];
            }
        }
    } catch (Exception $e) {
        // Commission table might not exist, ignore
    }
    
    $net_amount = $amount - $commission;
    $balance_after = $balance_before + $net_amount;
    
    // Update wallet balance
    $update_wallet = "UPDATE wallets SET balance = :balance WHERE id = :wallet_id";
    $update_stmt = $db->prepare($update_wallet);
    $update_stmt->bindParam(':balance', $balance_after);
    $update_stmt->bindParam(':wallet_id', $wallet['id']);
    $update_stmt->execute();
    
    // Generate unique transaction reference
    $transaction_ref = 'DEP-' . strtoupper(uniqid());
    
    // Create transaction record
    // Removed user_id as it is not in the schema, using only wallet_id
    $trans_query = "INSERT INTO transactions 
                    (transaction_ref, wallet_id, transaction_type, amount, currency, 
                     balance_before, balance_after, status, payment_method, description, 
                     metadata, created_at)
                    VALUES 
                    (:ref, :wallet_id, 'deposit', :amount, 'MRU', 
                     :balance_before, :balance_after, 'completed', :payment_method, :description,
                     :metadata, NOW())";
    
    $metadata_array = [
        'gross_amount' => $amount,
        'commission' => $commission,
        'net_amount' => $net_amount,
        'payment_method' => $payment_method
    ];
    
    // Add phone number if provided
    if (isset($data->phone_number)) {
        $metadata_array['phone_number'] = $data->phone_number;
    }
    
    $metadata = json_encode($metadata_array);
    
    // $ip_address = $_SERVER['REMOTE_ADDR'] ?? null;
    
    $trans_stmt = $db->prepare($trans_query);
    $trans_stmt->bindParam(':ref', $transaction_ref);
    $trans_stmt->bindParam(':wallet_id', $wallet['id']);
    $trans_stmt->bindParam(':amount', $net_amount);
    $trans_stmt->bindParam(':balance_before', $balance_before);
    $trans_stmt->bindParam(':balance_after', $balance_after);
    $trans_stmt->bindParam(':payment_method', $payment_method);
    $trans_stmt->bindParam(':description', $description);
    $trans_stmt->bindParam(':metadata', $metadata);
    // $trans_stmt->bindParam(':ip', $ip_address);
    $trans_stmt->execute();
    
    $transaction_id = $db->lastInsertId();
    
    // Log activity if table exists
    /*
    try {
        $log_query = "INSERT INTO wallet_activity_log (wallet_id, user_id, action, description, ip_address)
                      VALUES (:wallet_id, :user_id, 'deposit', :description, :ip)";
        $log_stmt = $db->prepare($log_query);
        $log_stmt->bindParam(':wallet_id', $wallet['id']);
        $log_stmt->bindParam(':user_id', $user_id);
        $log_stmt->bindParam(':description', $description);
        $log_stmt->bindParam(':ip', $ip_address);
        $log_stmt->execute();
    } catch (Exception $e) {
        // Ignore logging errors
    }
    */
    
    // Commit transaction
    $db->commit();
    
    echo json_encode([
        'success' => true,
        'message' => 'تم إيداع المبلغ بنجاح',
        'transaction' => [
            'id' => $transaction_id,
            'reference' => $transaction_ref,
            'amount' => $net_amount,
            'commission' => $commission,
            'gross_amount' => $amount,
            'balance_before' => $balance_before,
            'balance_after' => $balance_after,
            'currency' => 'MRU'
        ]
    ]);

} catch (Throwable $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'فشل إيداع المبلغ',
        'error' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
