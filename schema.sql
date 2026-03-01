-- 맑은프레임워크 웹사이트 데이터베이스 스키마

-- 회원 테이블
CREATE TABLE tb_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    passwd VARCHAR(64) NOT NULL,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    reg_date VARCHAR(14) NOT NULL,
    mod_date VARCHAR(14),
    status INT DEFAULT 1,
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 게시판 테이블
CREATE TABLE tb_board (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    hit INT DEFAULT 0,
    reg_date VARCHAR(14) NOT NULL,
    mod_date VARCHAR(14),
    status INT DEFAULT 1,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_reg_date (reg_date),
    FOREIGN KEY (user_id) REFERENCES tb_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 신청 테이블
CREATE TABLE tb_apply (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    company VARCHAR(100),
    position VARCHAR(50),
    content TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    reg_date VARCHAR(14) NOT NULL,
    mod_date VARCHAR(14),
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_reg_date (reg_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 테스트 데이터 삽입 (선택사항)
-- INSERT INTO tb_user (email, passwd, name, phone, reg_date, status)
-- VALUES ('admin@test.com', SHA2('admin1234', 256), '관리자', '010-1234-5678', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), 1);
