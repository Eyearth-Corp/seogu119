-- 동별 대시보드 데이터를 저장하는 테이블
-- PK는 날짜로 설정하여 일별 데이터 관리

CREATE TABLE IF NOT EXISTS dong_data (
    data_date DATE PRIMARY KEY COMMENT '데이터 기준일 (2025-07-25)',
    data_json JSON NOT NULL COMMENT '동별 대시보드 데이터 (JSON 형태)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '데이터 생성시간',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '데이터 수정시간'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='동별 대시보드 데이터 테이블';

-- 샘플 데이터 삽입 (2025-07-25 기준)
INSERT INTO dong_data (data_date, data_json) VALUES (
    '2025-07-25',
    JSON_OBJECT(
        '동천동', JSON_OBJECT(
            'dongMetrics', JSON_ARRAY(
                JSON_OBJECT('title', '🏪 총 상인회2', 'value', '5', 'unit', '개'),
                JSON_OBJECT('title', '✨ 가맹률', 'value', '92.1', 'unit', '%'),
                JSON_OBJECT('title', '📊 이번주 방문', 'value', '24', 'unit', '회')
            ),
            'weeklyAchievements', JSON_ARRAY(
                JSON_OBJECT('title', '신규 가맹', 'value', '2개'),
                JSON_OBJECT('title', '민원 해결', 'value', '3건'),
                JSON_OBJECT('title', '지원 예산', 'value', '150만원')
            ),
            'complaints', JSON_ARRAY(
                JSON_OBJECT('keyword', '주차 문제', 'count', 8),
                JSON_OBJECT('keyword', '소음 방해', 'count', 5),
                JSON_OBJECT('keyword', '청소 문제', 'count', 2)
            ),
            'businessTypes', JSON_ARRAY(
                JSON_OBJECT('type', '음식점', 'count', 2, 'percentage', 40.0),
                JSON_OBJECT('type', '소매점', 'count', 2, 'percentage', 30.0),
                JSON_OBJECT('type', '서비스업', 'count', 1, 'percentage', 20.0),
                JSON_OBJECT('type', '기타', 'count', 1, 'percentage', 10.0)
            )
        ),
        '유덕동', JSON_OBJECT(
            'dongMetrics', JSON_ARRAY(
                JSON_OBJECT('title', '🏪 총 상인회', 'value', '3', 'unit', '개'),
                JSON_OBJECT('title', '✨ 가맹률', 'value', '88.3', 'unit', '%'),
                JSON_OBJECT('title', '📊 이번주 방문', 'value', '15', 'unit', '회')
            ),
            'weeklyAchievements', JSON_ARRAY(
                JSON_OBJECT('title', '신규 가맹', 'value', '1개'),
                JSON_OBJECT('title', '민원 해결', 'value', '2건'),
                JSON_OBJECT('title', '지원 예산', 'value', '80만원')
            ),
            'complaints', JSON_ARRAY(
                JSON_OBJECT('keyword', '소음 방해', 'count', 4),
                JSON_OBJECT('keyword', '주차 문제', 'count', 3),
                JSON_OBJECT('keyword', '청소 문제', 'count', 1)
            ),
            'businessTypes', JSON_ARRAY(
                JSON_OBJECT('type', '음식점', 'count', 1, 'percentage', 33.3),
                JSON_OBJECT('type', '소매점', 'count', 1, 'percentage', 33.3),
                JSON_OBJECT('type', '서비스업', 'count', 1, 'percentage', 33.3),
                JSON_OBJECT('type', '기타', 'count', 0, 'percentage', 0.0)
            )
        ),
        '광천동', JSON_OBJECT(
            'dongMetrics', JSON_ARRAY(
                JSON_OBJECT('title', '🏪 총 상인회', 'value', '1', 'unit', '개'),
                JSON_OBJECT('title', '✨ 가맹률', 'value', '75.0', 'unit', '%'),
                JSON_OBJECT('title', '📊 이번주 방문', 'value', '8', 'unit', '회')
            ),
            'weeklyAchievements', JSON_ARRAY(
                JSON_OBJECT('title', '신규 가맹', 'value', '0개'),
                JSON_OBJECT('title', '민원 해결', 'value', '1건'),
                JSON_OBJECT('title', '지원 예산', 'value', '50만원')
            ),
            'complaints', JSON_ARRAY(
                JSON_OBJECT('keyword', '청소 문제', 'count', 2),
                JSON_OBJECT('keyword', '주차 문제', 'count', 1),
                JSON_OBJECT('keyword', '소음 방해', 'count', 0)
            ),
            'businessTypes', JSON_ARRAY(
                JSON_OBJECT('type', '음식점', 'count', 1, 'percentage', 100.0),
                JSON_OBJECT('type', '소매점', 'count', 0, 'percentage', 0.0),
                JSON_OBJECT('type', '서비스업', 'count', 0, 'percentage', 0.0),
                JSON_OBJECT('type', '기타', 'count', 0, 'percentage', 0.0)
            )
        ),
        '치평동', JSON_OBJECT(
            'dongMetrics', JSON_ARRAY(
                JSON_OBJECT('title', '🏪 총 상인회', 'value', '18', 'unit', '개'),
                JSON_OBJECT('title', '✨ 가맹률', 'value', '85.7', 'unit', '%'),
                JSON_OBJECT('title', '📊 이번주 방문', 'value', '42', 'unit', '회')
            ),
            'weeklyAchievements', JSON_ARRAY(
                JSON_OBJECT('title', '신규 가맹', 'value', '3개'),
                JSON_OBJECT('title', '민원 해결', 'value', '5건'),
                JSON_OBJECT('title', '지원 예산', 'value', '320만원')
            ),
            'complaints', JSON_ARRAY(
                JSON_OBJECT('keyword', '주차 문제', 'count', 12),
                JSON_OBJECT('keyword', '소음 방해', 'count', 8),
                JSON_OBJECT('keyword', '청소 문제', 'count', 4)
            ),
            'businessTypes', JSON_ARRAY(
                JSON_OBJECT('type', '음식점', 'count', 7, 'percentage', 38.9),
                JSON_OBJECT('type', '소매점', 'count', 5, 'percentage', 27.8),
                JSON_OBJECT('type', '서비스업', 'count', 4, 'percentage', 22.2),
                JSON_OBJECT('type', '기타', 'count', 2, 'percentage', 11.1)
            )
        ),
        '상무1동', JSON_OBJECT(
            'dongMetrics', JSON_ARRAY(
                JSON_OBJECT('title', '🏪 총 상인회', 'value', '12', 'unit', '개'),
                JSON_OBJECT('title', '✨ 가맹률', 'value', '89.5', 'unit', '%'),
                JSON_OBJECT('title', '📊 이번주 방문', 'value', '28', 'unit', '회')
            ),
            'weeklyAchievements', JSON_ARRAY(
                JSON_OBJECT('title', '신규 가맹', 'value', '2개'),
                JSON_OBJECT('title', '민원 해결', 'value', '3건'),
                JSON_OBJECT('title', '지원 예산', 'value', '200만원')
            ),
            'complaints', JSON_ARRAY(
                JSON_OBJECT('keyword', '주차 문제', 'count', 7),
                JSON_OBJECT('keyword', '소음 방해', 'count', 4),
                JSON_OBJECT('keyword', '청소 문제', 'count', 2)
            ),
            'businessTypes', JSON_ARRAY(
                JSON_OBJECT('type', '음식점', 'count', 5, 'percentage', 41.7),
                JSON_OBJECT('type', '소매점', 'count', 4, 'percentage', 33.3),
                JSON_OBJECT('type', '서비스업', 'count', 2, 'percentage', 16.7),
                JSON_OBJECT('type', '기타', 'count', 1, 'percentage', 8.3)
            )
        )
    )
) ON DUPLICATE KEY UPDATE 
    data_json = VALUES(data_json),
    updated_at = CURRENT_TIMESTAMP;

-- 데이터 조회 예시 쿼리
-- SELECT data_date, JSON_PRETTY(data_json) FROM dong_data WHERE data_date = '2025-07-25';

-- 특정 동의 데이터만 조회하는 예시
-- SELECT data_date, JSON_EXTRACT(data_json, '$.동천동') as dongcheon_data FROM dong_data WHERE data_date = '2025-07-25';

-- 인덱스 추가 (성능 향상을 위해)
CREATE INDEX idx_dong_data_created_at ON dong_data(created_at);