<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['provider']) || !isset($input['email'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Provider and email are required']);
    exit;
}

$provider = $input['provider'];
$email = trim($input['email']);
$fullName = isset($input['full_name']) ? trim($input['full_name']) : 'User ' . substr(md5(time()), 0, 5);

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Check if user exists
    $query = "SELECT *, 'patient' as user_type FROM users WHERE email = :email";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':email', $email);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        // Create new patient user
        $insertQuery = "INSERT INTO users (full_name, email, password, is_verified, verification_method) 
                        VALUES (:full_name, :email, :password, 1, 'social')";
        $insertStmt = $conn->prepare($insertQuery);
        $insertStmt->bindParam(':full_name', $fullName);
        $insertStmt->bindParam(':email', $email);
        $mockPassword = password_hash(bin2hex(random_bytes(10)), PASSWORD_DEFAULT);
        $insertStmt->bindParam(':password', $mockPassword);
        $insertStmt->execute();
        
        $user_id = $conn->lastInsertId();
        
        // Fetch new user
        $query = "SELECT *, 'patient' as user_type FROM users WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':id', $user_id);
        $stmt->execute();
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    // Generate session token
    $token = bin2hex(random_bytes(16));
    $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));
    
    // Store session
    $insertQuery = "INSERT INTO user_sessions (user_id, token, user_type, expires_at) VALUES (:user_id, :token, :user_type, :expires_at)";
    $insertStmt = $conn->prepare($insertQuery);
    $insertStmt->bindParam(':user_id', $user['id']);
    $insertStmt->bindParam(':token', $token);
    $insertStmt->bindParam(':user_type', $user['user_type']);
    $insertStmt->bindParam(':expires_at', $expiresAt);
    $insertStmt->execute();
    
    unset($user['password']);
    
    echo json_encode([
        'success' => true,
        'message' => 'Login with ' . ucfirst($provider) . ' successful',
        'data' => [
            'user' => $user,
            'token' => $token,
            'expires_at' => $expiresAt
        ]
    ]);
    
} catch (Exception $e) {
    error_log("Social login error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error: ' . $e->getMessage()]);
}
?>
