-- Medical Research / Articles table
CREATE TABLE IF NOT EXISTS medical_research (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    summary TEXT,
    content LONGTEXT,
    attachment_url VARCHAR(255),
    category VARCHAR(100),
    tags VARCHAR(255),
    is_published BOOLEAN DEFAULT TRUE,
    views INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (doctor_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_doctor (doctor_id),
    INDEX idx_category (category),
    INDEX idx_created_at (created_at)
);
