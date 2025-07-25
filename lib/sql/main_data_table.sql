-- 메인 대시보드 데이터를 저장하는 테이블
-- PK는 날짜로 설정하여 일별 데이터 관리

CREATE TABLE IF NOT EXISTS main_data (
    data_date DATE PRIMARY KEY COMMENT '데이터 기준일 (2025-07-25)',
    data_json JSON NOT NULL COMMENT '메인 대시보드 데이터 (JSON 형태)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '데이터 생성시간',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '데이터 수정시간'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='메인 대시보드 데이터 테이블';

-- 샘플 데이터 삽입 (2025-07-25 기준)
INSERT INTO main_data (data_date, data_json) VALUES (
    '2025-07-25',
    JSON_OBJECT(
        'topMetrics', JSON_ARRAY(
            JSON_OBJECT('title', '🏪 전체 가맹점', 'value', '11,427', 'unit', '개'),
            JSON_OBJECT('title', '✨ 이번주 신규', 'value', '47', 'unit', '개'),
            JSON_OBJECT('title', '📊 가맹률', 'value', '85.2', 'unit', '%')
        ),
        'weeklyAchievements', JSON_ARRAY(
            JSON_OBJECT('title', '신규 가맹점2', 'value', '47개'),
            JSON_OBJECT('title', '민원 해결', 'value', '23건'),
            JSON_OBJECT('title', '지원 예산', 'value', '2.3억')
        ),
        'trendChart', JSON_OBJECT(
            'title', '📈 온누리 가맹점 추이',
            'data', JSON_ARRAY(
                JSON_OBJECT('x', 0, 'y', 75),
                JSON_OBJECT('x', 1, 'y', 78),
                JSON_OBJECT('x', 2, 'y', 82),
                JSON_OBJECT('x', 3, 'y', 80),
                JSON_OBJECT('x', 4, 'y', 85),
                JSON_OBJECT('x', 5, 'y', 87)
            )
        ),
        'dongMembership', JSON_OBJECT(
            'title', '🗺️ 동별 가맹률 현황3',
            'data', JSON_ARRAY(
                JSON_OBJECT('name', '동천동', 'percentage', 92.1),
                JSON_OBJECT('name', '유촌동', 'percentage', 88.3),
                JSON_OBJECT('name', '치평동', 'percentage', 85.7),
                JSON_OBJECT('name', '화정2동', 'percentage', 82.4),
                JSON_OBJECT('name', '화정4동', 'percentage', 81.4)
            )
        ),
        'complaintKeywords', JSON_OBJECT(
            'title', '🔥 민원 TOP 3 키워드',
            'data', JSON_ARRAY(
                JSON_OBJECT('rank', '1', 'keyword', '주차 문제', 'count', 34),
                JSON_OBJECT('rank', '2', 'keyword', '소음 방해', 'count', 28),
                JSON_OBJECT('rank', '3', 'keyword', '청소 문제', 'count', 19)
            )
        ),
        'complaintCases', JSON_OBJECT(
            'title', '✅ 민원 해결 사례',
            'data', JSON_ARRAY(
                JSON_OBJECT(
                    'title', '동천동 주차장 확장',
                    'status', '해결',
                    'detail', '주차 공간 부족으로 인한 민원이 지속적으로 제기되어, 기존 주차장을 확장하고 새로운 주차구역을 확보했습니다.'
                ),
                JSON_OBJECT(
                    'title', '유촌동 소음방해 개선',
                    'status', '진행중',
                    'detail', '야간 시간대 상가 운영으로 인한 소음 문제를 해결하기 위해 방음시설 설치 및 운영시간 조정을 진행 중입니다.'
                ),
                JSON_OBJECT(
                    'title', '청아동 청소 개선',
                    'status', '해결',
                    'detail', '쓰레기 무단투기 및 청소 상태 불량 문제를 해결하기 위해 청소 주기를 단축하고 CCTV를 설치했습니다.'
                )
            )
        ),
        'complaintPerformance', JSON_OBJECT(
            'title', '📋 민원처리 실적',
            'processed', '187건',
            'rate', '94.2%'
        ),
        'organizationTrends', JSON_OBJECT(
            'title', '🌐 타 기관·지자체 주요 동향',
            'data', JSON_ARRAY(
                JSON_OBJECT(
                    'title', '부산 동구 골목상권 활성화 사업',
                    'detail', '부산 동구에서 추진 중인 골목상권 활성화 사업으로, 상인회 조직 강화와 디지털 마케팅 지원을 통해 매출 증대를 도모하고 있습니다. 총 50개 상인회가 참여하여 온라인 플랫폼 입점과 배달 서비스 확대를 진행 중입니다.'
                ),
                JSON_OBJECT(
                    'title', '대구 중구 전통시장 디지털화',
                    'detail', '대구 중구 전통시장의 디지털 전환 사업으로, QR코드 결제 시스템 도입과 온라인 쇼핑몰 구축을 통해 젊은 고객층 유입을 늘리고 있습니다. 현재 80% 이상의 점포가 디지털 결제 시스템을 도입하여 운영 중입니다.'
                )
            )
        )
    )
) ON DUPLICATE KEY UPDATE 
    data_json = VALUES(data_json),
    updated_at = CURRENT_TIMESTAMP;

-- 데이터 조회 예시 쿼리
-- SELECT data_date, JSON_PRETTY(data_json) FROM main_data WHERE data_date = '2025-07-25';

-- 특정 섹션 데이터만 조회하는 예시
-- SELECT data_date, JSON_EXTRACT(data_json, '$.topMetrics') as top_metrics FROM main_data WHERE data_date = '2025-07-25';

-- 차트 데이터만 조회하는 예시
-- SELECT data_date, JSON_EXTRACT(data_json, '$.trendChart.data') as chart_data FROM main_data WHERE data_date = '2025-07-25';

-- 민원 키워드 TOP 3 조회 예시
-- SELECT data_date, JSON_EXTRACT(data_json, '$.complaintKeywords.data') as complaint_keywords FROM main_data WHERE data_date = '2025-07-25';

-- 인덱스 추가 (성능 향상을 위해)
CREATE INDEX idx_main_data_created_at ON main_data(created_at);