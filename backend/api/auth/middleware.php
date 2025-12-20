<?php
require_once __DIR__ . '/../../config/database.php';

function authenticate($requiredType = null) {
    $headers = getallheaders();
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
    
    if (empty($authHeader) && isset($headers['authorization'])) {
        $authHeader = $headers['authorization'];
    }
    
    if (!preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
        http_response_code(401);
        echo json_encode(['error' => 'No token provided']);
        exit;
    }
    
    $token = $matches[1];
    
    try {
        $db = Database::getInstance();
        $conn = $db->getConnection();
        
        // First get session to know user_userId and user_type
        $sessionQuery = "SELECT user_id, user_type FROM user_sessions WHERE token = :token AND expires_at > NOW()";
        $sessionStmt = $conn->prepare($sessionQuery);
        $sessionStmt->bindParam(':token', $token);
        $sessionStmt->execute();
        $session = $sessionStmt->fetch(PDO::FETCH_ASSOC);

        if (!$session) {
            http_response_code(401);
            echo json_encode(['error' => 'Invalid or expired token']);
            exit;
        }

        $userId = $session['user_id'];
        $userType = $session['user_type'];

        // Enforce role check if requiredType is specified
        if ($requiredType !== null && $userType !== $requiredType) {
            http_response_code(403);
            echo json_encode(['error' => 'Unauthorized access for this account type']);
            exit;
        }

        // Now fetch user from appropriate table
        if ($userType === 'doctor') {
            $query = "SELECT *, 'doctor' as user_type FROM doctors WHERE id = :id";
        } else {
            $query = "SELECT *, 'patient' as user_type FROM users WHERE id = :id";
        }
        
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':id', $userId);
        $stmt->execute();
        
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            http_response_code(401);
            echo json_encode(['error' => 'User not found']);
            exit;
        }
        
        return $user;
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Authentication error']);
        exit;
    }
}
?>
