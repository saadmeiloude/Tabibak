<?php
require_once __DIR__ . '/../../config/database.php';

function authenticate() {
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
        
        $query = "SELECT u.* FROM users u 
                  JOIN user_sessions s ON u.id = s.user_id 
                  WHERE s.token = :token AND s.expires_at > NOW()";
        
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':token', $token);
        $stmt->execute();
        
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            http_response_code(401);
            echo json_encode(['error' => 'Invalid or expired token']);
            exit;
        }
        
        return $user;
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error oh chit fuck you' => 'Authentication error']);
        exit;
    }
}
?>
