# 서구 골목경제 119 대시보드 SQL 스크립트

이 폴더에는 서구 골목경제 119 대시보드의 데이터를 MySQL 데이터베이스에 저장하기 위한 SQL 스크립트들이 포함되어 있습니다.

## 파일 구성

### 1. `create_database.sql`
- 데이터베이스 생성 및 초기 설정
- 문자셋: utf8mb4, 콜레이션: utf8mb4_unicode_ci
- 사용자 생성 및 권한 부여 예시 포함

### 2. `main_data_table.sql`
- 메인 대시보드 데이터 테이블 생성
- 전체 가맹점 현황, 차트 데이터, 민원 현황 등 포함
- PK: `data_date` (DATE 타입)

### 3. `dong_data_table.sql`
- 동별 대시보드 데이터 테이블 생성
- 각 동의 상인회 현황, 민원 정보, 업종별 현황 등 포함
- PK: `data_date` (DATE 타입)

## 테이블 구조

### main_data 테이블
```sql
CREATE TABLE IF NOT EXISTS main_data (
    data_date DATE PRIMARY KEY,
    data_json JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### dong_data 테이블
```sql
CREATE TABLE IF NOT EXISTS dong_data (
    data_date DATE PRIMARY KEY,
    data_json JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## 데이터 구조

### main_data JSON 구조
- `topMetrics`: 상단 메트릭 (전체 가맹점, 신규 가맹점, 가맹률)
- `weeklyAchievements`: 주간 성과
- `trendChart`: 온누리 가맹점 추이 차트 데이터
- `dongMembership`: 동별 가맹률 현황
- `complaintKeywords`: 민원 TOP 3 키워드
- `complaintCases`: 민원 해결 사례
- `complaintPerformance`: 민원 처리 실적
- `organizationTrends`: 타 기관 동향

### dong_data JSON 구조
각 동별로 다음 정보 포함:
- `dongMetrics`: 동별 메트릭 (총 상인회, 가맹률, 방문 수)
- `weeklyAchievements`: 동별 주간 성과
- `complaints`: 동별 민원 현황
- `businessTypes`: 업종별 분포

## 설치 및 실행 순서

1. **데이터베이스 생성**
   ```bash
   mysql -u root -p < create_database.sql
   ```

2. **메인 대시보드 테이블 생성**
   ```bash
   mysql -u root -p seogu119_dashboard < main_data_table.sql
   ```

3. **동별 대시보드 테이블 생성**
   ```bash
   mysql -u root -p seogu119_dashboard < dong_data_table.sql
   ```

## 데이터 조회 예시

### 전체 메인 데이터 조회
```sql
SELECT data_date, JSON_PRETTY(data_json) 
FROM main_data 
WHERE data_date = '2025-07-25';
```

### 특정 동 데이터만 조회
```sql
SELECT data_date, JSON_EXTRACT(data_json, '$.동천동') as dongcheon_data 
FROM dong_data 
WHERE data_date = '2025-07-25';
```

### 차트 데이터만 조회
```sql
SELECT data_date, JSON_EXTRACT(data_json, '$.trendChart.data') as chart_data 
FROM main_data 
WHERE data_date = '2025-07-25';
```

## 주의사항

1. **MySQL 5.7.8 이상** 또는 **MariaDB 10.2.3 이상**에서 JSON 타입을 지원합니다.
2. 날짜별로 데이터를 관리하므로 동일한 날짜에 데이터를 삽입하면 기존 데이터가 업데이트됩니다.
3. JSON 데이터의 크기가 클 수 있으므로 `max_allowed_packet` 설정을 확인하세요.
4. 성능 향상을 위해 생성 시간 기준 인덱스가 추가되어 있습니다.

## 데이터 백업 및 복원

### 백업
```bash
mysqldump -u root -p seogu119_dashboard > seogu119_backup.sql
```

### 복원
```bash
mysql -u root -p seogu119_dashboard < seogu119_backup.sql
```