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
    $withdrawal_method = $data->withdrawal_method ?? 'bank_transfer';
    $bank_name = $data->bank_name ?? null;
    $account_number = $data->account_number ?? null;
    $account_holder_name = $data->account_holder_name ?? null;
    $mobile_money_number = $data->mobile_money_number ?? null;

    if ($amount <= 0) {
        throw new Exception('المبلغ يجب أن يكون أكبر من صفر');
    }

    // Minimum withdrawal amount
    if ($amount < 100) {
        throw new Exception('الحد الأدنى للسحب هو 100 أوقية');
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
        throw new Exception('المحفظة غير موجودة');
    }
    
    $balance_before = floatval($wallet['balance']);
    
    // Calculate withdrawal fee
    $withdrawal_fee = 0;
    try {
        $check_comm = "SELECT 1 FROM commission_settings LIMIT 1";
        $db->query($check_comm);

        $fee_query = "SELECT * FROM commission_settings 
                    WHERE transaction_type = 'withdrawal' 
                    AND is_active = TRUE 
                    AND :amount >= min_amount 
                    AND (:amount <= max_amount OR max_amount IS NULL)
                    LIMIT 1";
        $fee_stmt = $db->prepare($fee_query);
        $fee_stmt->bindParam(':amount', $amount);
        $fee_stmt->execute();
        $fee_setting = $fee_stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($fee_setting) {
            if ($fee_setting['commission_type'] === 'percentage') {
                $withdrawal_fee = ($amount * $fee_setting['commission_value']) / 100;
            } else {
                $withdrawal_fee = $fee_setting['commission_value'];
            }
        }
    } catch (Exception $e) {
        // Ignore setting error
    }
    
    $total_deduction = $amount + $withdrawal_fee;
    
    // Check if sufficient balance
    if ($balance_before < $total_deduction) {
        throw new Exception('الرصيد غير كافٍ. الرصيد المتاح: ' . $balance_before . ' أوقية');
    }
    
    // Create withdrawal request
    // Removed user_id as per schema
    $request_query = "INSERT INTO withdrawal_requests 
                      (wallet_id, amount, currency, withdrawal_method, 
                       bank_name, account_number, account_holder_name, mobile_money_number, status)
                      VALUES 
                      (:wallet_id, :amount, 'MRU', :method,
                       :bank_name, :account_number, :account_holder, :mobile_number, 'pending')";
    
    $request_stmt = $db->prepare($request_query);
    $request_stmt->bindParam(':wallet_id', $wallet['id']);
    $request_stmt->bindParam(':amount', $amount);
    $request_stmt->bindParam(':method', $withdrawal_method);
    $request_stmt->bindParam(':bank_name', $bank_name);
    $request_stmt->bindParam(':account_number', $account_number);
    $request_stmt->bindParam(':account_holder', $account_holder_name);
    $request_stmt->bindParam(':mobile_number', $mobile_money_number);
    $request_stmt->execute();
    
    $request_id = $db->lastInsertId();
    
    // Update wallet balance (deduct amount + fee)
    $balance_after = $balance_before - $total_deduction;
    $update_wallet = "UPDATE wallets SET balance = :balance WHERE id = :wallet_id";
    $update_stmt = $db->prepare($update_wallet);
    $update_stmt->bindParam(':balance', $balance_after);
    $update_stmt->bindParam(':wallet_id', $wallet['id']);
    $update_stmt->execute();
    
    // Generate unique transaction reference
    $transaction_ref = 'WTH-' . strtoupper(uniqid());
    
    // Create transaction record
    // Removed user_id
    $trans_query = "INSERT INTO transactions 
                    (transaction_ref, wallet_id, transaction_type, amount, currency, 
                     balance_before, balance_after, status, payment_method, description, 
                     metadata, created_at)
                    VALUES 
                    (:ref, :wallet_id, 'withdrawal', :amount, 'MRU', 
                     :balance_before, :balance_after, 'pending', :method, :description,
                     :metadata, NOW())";
    
    $description = 'طلب سحب رصيد';
    $metadata = json_encode([
        'withdrawal_request_id' => $request_id,
        'withdrawal_fee' => $withdrawal_fee,
        'net_amount' => $amount,
        'total_deduction' => $total_deduction,
        'withdrawal_method' => $withdrawal_method
    ]);
    
    // $ip_address = $_SERVER['REMOTE_ADDR'] ?? null;
    
    $trans_stmt = $db->prepare($trans_query);
    $trans_stmt->bindParam(':ref', $transaction_ref);
    $trans_stmt->bindParam(':wallet_id', $wallet['id']);
    $trans_stmt->bindParam(':amount', $total_deduction);
    $trans_stmt->bindParam(':balance_before', $balance_before);
    $trans_stmt->bindParam(':balance_after', $balance_after);
    $trans_stmt->bindParam(':method', $withdrawal_method);
    $trans_stmt->bindParam(':description', $description);
    $trans_stmt->bindParam(':metadata', $metadata);
    // $trans_stmt->bindParam(':ip', $ip_address);
    $trans_stmt->execute();
    
    $transaction_id = $db->lastInsertId();
    
    // Update withdrawal request with transaction_id
    $update_request = "UPDATE withdrawal_requests SET transaction_id = :trans_id WHERE id = :request_id";
    $update_req_stmt = $db->prepare($update_request);
    $update_req_stmt->bindParam(':trans_id', $transaction_id);
    $update_req_stmt->bindParam(':request_id', $request_id);
    $update_req_stmt->execute();
    
    // Log activity
    // Removed user_id
    /*
    try {
        $log_query = "INSERT INTO wallet_activity_log (wallet_id, action, description, ip_address)
                      VALUES (:wallet_id, 'withdrawal_request', :description, :ip)";
        $log_stmt = $db->prepare($log_query);
        $log_stmt->bindParam(':wallet_id', $wallet['id']);
        $log_stmt->bindParam(':description', $description);
        $log_stmt->bindParam(':ip', $ip_address);
        $log_stmt->execute();
    } catch (Exception $e) {
        // Ignore
    }
    */
    
    // Commit transaction
    $db->commit();
    
    echo json_encode([
        'success' => true,
        'message' => 'تم إنشاء طلب السحب بنجاح.',
        'withdrawal_request' => [
            'id' => $request_id,
            'transaction_id' => $transaction_id,
            'reference' => $transaction_ref,
            'amount' => $amount,
            'withdrawal_fee' => $withdrawal_fee,
            'total_deduction' => $total_deduction,
            'balance_after' => $balance_after,
            'status' => 'pending',
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
        'message' => 'فشل إنشاء طلب السحب',
        'error' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
