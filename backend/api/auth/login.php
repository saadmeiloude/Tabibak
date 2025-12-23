<?php
header('Content-Type: application/json');
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['email']) || !isset($input['password'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Email and password are required']);
    exit;
}

$identifier = trim($input['email']);
$password = $input['password'];

if (empty($identifier)) {
    http_response_code(400);
    echo json_encode(['error' => 'Email or phone required']);
    exit;
}

// We will validate in the query - if no user found, then credentials invalid.
// We relax strict email format validation here because user might enter a phone number.

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Check doctors table first
    $query = "SELECT *, 'doctor' as user_type FROM doctors WHERE (email = :email OR phone = :phone) AND is_active = 1";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':email', $identifier);
    $stmt->bindParam(':phone', $identifier);
    $stmt->execute();
    $doctorUser = $stmt->fetch(PDO::FETCH_ASSOC);

    $user = null;

    // If found in doctors and password matches, use doctor account
    if ($doctorUser && password_verify($password, $doctorUser['password'])) {
        $user = $doctorUser;
    } else {
        // If not a doctor specific login, check generic users table
        $query = "SELECT * FROM users WHERE (email = :email OR phone = :phone) AND is_active = 1";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':email', $identifier);
        $stmt->bindParam(':phone', $identifier);
        $stmt->execute();
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    if (!$user || !password_verify($password, $user['password'])) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid credentials']);
        exit;
    }
    
    if (!$user['is_verified']) {
        http_response_code(403);
        echo json_encode(['error' => 'Account not verified', 'needs_verification' => true]);
        exit;
    }
    
    // Generate session token
    $token = bin2hex(random_bytes(16)); // 32 character hex string to fit VARCHAR(100)
    $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));
    
    // Determine correct user_id for session
    // If user is doctor, we need the global user_id from users table, not the doctor table primary key
    $sessionUserId = $user['id'];
    if (isset($user['user_type']) && $user['user_type'] === 'doctor' && isset($user['user_id'])) {
        $sessionUserId = $user['user_id'];
    }

    // Store session in database
    $insertQuery = "INSERT INTO user_sessions (user_id, token, user_type, expires_at) VALUES (:user_id, :token, :user_type, :expires_at)";
    $insertStmt = $conn->prepare($insertQuery);
    $insertStmt->bindParam(':user_id', $sessionUserId);
    $insertStmt->bindParam(':token', $token);
    $insertStmt->bindParam(':user_type', $user['user_type']);
    $insertStmt->bindParam(':expires_at', $expiresAt);
    $insertStmt->execute();
    
    // Remove sensitive data from response
    unset($user['password']);
    
    // Add default verification_method for doctors if not present
    if ($user['user_type'] === 'doctor' && !isset($user['verification_method'])) {
        $user['verification_method'] = 'email';
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Login successful',
        'data' => [
            'user' => $user,
            'token' => $token,
            'expires_at' => $expiresAt
        ]
    ]);
    
} catch (Exception $e) {
    error_log("Login error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error']);
}
?>