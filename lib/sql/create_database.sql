-- 서구 골목경제 119 대시보드 데이터베이스 생성 스크립트
-- 데이터베이스 생성 및 초기 설정

-- 데이터베이스 생성 (존재하지 않을 경우)
CREATE DATABASE IF NOT EXISTS seogu119_dashboard
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci
    COMMENT '서구 골목경제 119 대시보드 데이터베이스';

-- 데이터베이스 사용
USE seogu119_dashboard;

-- 테이블 목록 확인용 뷰 생성
CREATE OR REPLACE VIEW table_info AS
SELECT 
    TABLE_NAME as '테이블명',
    TABLE_COMMENT as '설명',
    CREATE_TIME as '생성일',
    UPDATE_TIME as '수정일'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'seogu119_dashboard';

-- 사용자 생성 및 권한 부여 (필요시 사용)
-- CREATE USER 'seogu119_user'@'localhost' IDENTIFIED BY 'your_secure_password';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON seogu119_dashboard.* TO 'seogu119_user'@'localhost';
-- FLUSH PRIVILEGES;

-- 데이터베이스 정보 조회
SELECT 
    SCHEMA_NAME as '데이터베이스명',
    DEFAULT_CHARACTER_SET_NAME as '문자셋',
    DEFAULT_COLLATION_NAME as '콜레이션'
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME = 'seogu119_dashboard';