# 서구 골목경제 119 대시보드 API

FastAPI + MySQL을 사용한 서구 골목경제 119 대시보드 API 서버입니다. JWT 인증을 통한 보안 관리와 동별 가맹점 정보를 제공합니다.

## 🏗️ 프로젝트 구조

```
seogu119_api/
├── app/                    # 메인 애플리케이션 코드
│   ├── api/               # API 엔드포인트
│   │   ├── main.py        # 메인 API 라우터
│   │   └── admin_api.py   # 관리자 API (사용 안함)
│   ├── auth/              # 인증 관련
│   │   └── auth.py        # JWT 인증 로직
│   ├── core/              # 핵심 설정
│   │   └── config.py      # 데이터베이스 설정
│   ├── database/          # 데이터베이스 모델
│   │   └── database.py    # SQLAlchemy 모델
│   └── models/            # Pydantic 모델
│       └── models.py      # 요청/응답 모델
├── scripts/               # 유틸리티 스크립트
│   ├── run.py            # 서버 실행 스크립트
│   └── create_admin.py   # 관리자 계정 생성
├── docs/                  # 문서
│   └── CLAUDE.md         # 개발 가이드
├── data/                  # 샘플 데이터
│   ├── main_data.json    # 메인 대시보드 샘플 데이터
│   └── dong_data.json    # 동별 대시보드 샘플 데이터
├── sql/                   # SQL 스크립트
│   ├── create_database.sql    # 데이터베이스 생성
│   ├── main_data_table.sql    # 메인 데이터 테이블
│   └── dong_data_table.sql    # 동별 데이터 테이블
├── main.py               # 애플리케이션 진입점
└── requirements.txt      # Python 의존성
```

## 🚀 설치 및 실행

### 1. 의존성 설치
```bash
pip install -r requirements.txt
```

### 2. MySQL 데이터베이스 설정

이 프로젝트는 환경에 따라 자동으로 데이터베이스를 선택합니다:
- **로컬 환경**: 127.0.0.1:23307 (seogu119 DB)
- **운영 환경**: AWS RDS (seogu119 DB)

**로컬 MySQL 설정:**
```bash
# 데이터베이스 생성
mysql -u admin -p -h 127.0.0.1 -P 23307 < sql/create_database.sql

# 테이블 생성 및 샘플 데이터 삽입
mysql -u admin -p -h 127.0.0.1 -P 23307 seogu119 < sql/main_data_table.sql
mysql -u admin -p -h 127.0.0.1 -P 23307 seogu119 < sql/dong_data_table.sql
```

### 3. 관리자 계정 생성
```bash
python scripts/create_admin.py
```

### 4. 서버 실행
```bash
# 방법 1: 실행 스크립트 사용
python scripts/run.py

# 방법 2: 메인 파일 실행
python main.py

# 방법 3: uvicorn 직접 실행
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## 📡 API 엔드포인트

### 기본 정보
- **서버 주소**: http://localhost:8000
- **API 문서**: http://localhost:8000/docs
- **OpenAPI 스펙**: http://localhost:8000/openapi.json

### 인증
모든 API는 JWT 토큰 인증이 필요합니다 (로그인 API 제외).

#### 관리자 로그인
```http
POST /api/admin/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

**응답:**
```json
{
  "success": true,
  "message": "로그인에 성공했습니다.",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "admin": {
      "id": 1,
      "username": "admin",
      "is_active": true,
      "created_at": "2025-07-20T23:37:35",
      "last_login": "2025-07-25T12:23:35"
    }
  }
}
```

#### 비밀번호 변경
```http
PUT /api/admin/change-password
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "current_password": "admin123",
  "new_password": "newpassword123"
}
```

### 대시보드 API

#### 1. 메인 대시보드 데이터 조회 (인증 불필요)
```http
GET /api/main-dashboard                    # 최신 데이터
GET /api/main-dashboard/2025-07-25        # 특정 날짜 데이터
```

**응답 데이터 구조:**
```json
{
  "success": true,
  "message": "메인 대시보드 데이터를 성공적으로 조회했습니다.",
  "data": {
    "topMetrics": [
      {"title": "🏪 전체 가맹점", "value": "11,427", "unit": "개"},
      {"title": "✨ 이번주 신규", "value": "47", "unit": "개"},
      {"title": "📊 가맹률", "value": "85.2", "unit": "%"}
    ],
    "trendChart": {
      "title": "📈 온누리 가맹점 추이",
      "data": [{"x": 0, "y": 75}, {"x": 1, "y": 78}]
    },
    "dongMembership": {
      "title": "🗺️ 동별 가맹률 현황",
      "data": [
        {"name": "동천동", "percentage": 92.1},
        {"name": "유촌동", "percentage": 88.3}
      ]
    },
    "availableDates": ["2025-07-25"]
  }
}
```

#### 2. 메인 대시보드 데이터 생성 (인증 필요)
```http
POST /api/main-dashboard
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "data_date": "2025-07-26",
  "data_json": {
    "topMetrics": [
      {"title": "🏪 전체 가맹점", "value": "12,000", "unit": "개"},
      {"title": "✨ 이번주 신규", "value": "50", "unit": "개"},
      {"title": "📊 가맹률", "value": "86.5", "unit": "%"}
    ],
    "weeklyAchievements": [...],
    "trendChart": {...},
    "dongMembership": {...},
    "complaintKeywords": {...},
    "complaintCases": {...},
    "complaintPerformance": {...},
    "organizationTrends": {...}
  }
}
```

**응답 예시:**
```json
{
  "success": true,
  "message": "메인 대시보드 데이터가 성공적으로 생성되었습니다.",
  "data": {
    "data_date": "2025-07-26",
    "created_at": "2025-07-25T13:04:06",
    "created_by": "admin"
  }
}
```

#### 3. 메인 대시보드 데이터 수정 (인증 필요)
```http
PUT /api/main-dashboard/2025-07-26
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "data_json": {
    "topMetrics": [
      {"title": "🏪 전체 가맹점", "value": "12,500", "unit": "개"}
    ],
    // ... 기타 필드들
  }
}
```

#### 4. 동별 대시보드 데이터 조회 (인증 불필요)
```http
GET /api/dong-dashboard/dong/동천동/2025-07-25  # 특정 동의 특정 날짜 데이터
```

**동별 데이터 구조:**
```json
{
  "success": true,
  "message": "동천동 대시보드 데이터를 성공적으로 조회했습니다.",
  "data": {
    "dongMetrics": [
      {"title": "🏪 총 상인회", "value": "5", "unit": "개"},
      {"title": "✨ 가맹률", "value": "92.1", "unit": "%"}
    ],
    "complaints": [
      {"keyword": "주차 문제", "count": 8},
      {"keyword": "소음 방해", "count": 5}
    ],
    "businessTypes": [
      {"type": "음식점", "count": 2, "percentage": 40.0},
      {"type": "소매점", "count": 2, "percentage": 30.0}
    ],
    "availableDates": ["2025-07-25"],
    "availableDongs": ["양3동", "광천동", "동천동", "유덕동", "치평동", "풍암동", "금고1동", "금고2동", "농성1동", "농성2동", "상무1동", "상무2동", "화정1동", "화정2동", "화정3동", "화정4동", "서창(마륵)동", "서창(매월)동"]
  }
}
```

#### 5. 동별 대시보드 데이터 생성 (인증 필요)
```http
POST /api/dong-dashboard
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "data_date": "2025-07-26",
  "data_json": {
    "동천동": {
      "dongMetrics": [
        {"title": "🏪 총 상인회", "value": "6", "unit": "개"},
        {"title": "✨ 가맹률", "value": "94.5", "unit": "%"}
      ],
      "weeklyAchievements": [
        {"title": "신규 가맹", "value": "3개"},
        {"title": "매출 증가", "value": "12%"}
      ],
      "complaints": [
        {"keyword": "주차 문제", "count": 5},
        {"keyword": "소음 방해", "count": 3}
      ],
      "businessTypes": [
        {"type": "음식점", "count": 25, "percentage": 45.0},
        {"type": "소매점", "count": 20, "percentage": 35.0}
      ]
    },
    "유촌동": {
      "dongMetrics": [
        {"title": "🏪 총 상인회", "value": "4", "unit": "개"},
        {"title": "✨ 가맹률", "value": "88.7", "unit": "%"}
      ],
      "weeklyAchievements": [
        {"title": "신규 가맹", "value": "2개"},
        {"title": "매출 증가", "value": "8%"}
      ],
      "complaints": [
        {"keyword": "배달 문제", "count": 4},
        {"keyword": "접근성", "count": 2}
      ],
      "businessTypes": [
        {"type": "음식점", "count": 18, "percentage": 40.0},
        {"type": "서비스업", "count": 15, "percentage": 30.0}
      ]
    }
  }
}
```

**응답 예시:**
```json
{
  "success": true,
  "message": "동별 대시보드 데이터가 성공적으로 생성되었습니다.",
  "data": {
    "data_date": "2025-07-26",
    "created_at": "2025-07-25T17:20:25",
    "created_by": "admin",
    "dong_count": 2
  }
}
```

#### 6. 동별 대시보드 데이터 수정 (인증 필요)
```http
PUT /api/dong-dashboard/2025-07-26
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "data_json": {
    "동천동": {
      "dongMetrics": [
        {"title": "🏪 총 상인회", "value": "7", "unit": "개"},
        {"title": "✨ 가맹률", "value": "96.2", "unit": "%"}
      ],
      "weeklyAchievements": [
        {"title": "신규 가맹", "value": "5개"},
        {"title": "매출 증가", "value": "15%"}
      ],
      "complaints": [
        {"keyword": "주차 문제", "count": 3},
        {"keyword": "소음 방해", "count": 2}
      ],
      "businessTypes": [
        {"type": "음식점", "count": 28, "percentage": 50.0},
        {"type": "소매점", "count": 18, "percentage": 32.0}
      ]
    }
  }
}
```

**응답 예시:**
```json
{
  "success": true,
  "message": "동별 대시보드 데이터가 성공적으로 수정되었습니다.",
  "data": {
    "data_date": "2025-07-26",
    "updated_at": "2025-07-25T17:25:30",
    "updated_by": "admin",
    "dong_count": 1
  }
}
```

### 관리자 정보 API

#### 현재 로그인한 관리자 정보 조회
```http
GET /api/admin/me
Authorization: Bearer {access_token}
```

## 🔒 인증 및 보안

### JWT 토큰 인증
- **GET 엔드포인트**: 인증 불필요 (데이터 조회)
- **POST, PUT, DELETE 엔드포인트**: JWT 토큰 인증 필요 (데이터 생성/수정/삭제)
- **관리자 전용 엔드포인트**: JWT 토큰 인증 필요
- 토큰 유효 기간: 24시간
- Authorization 헤더에 `Bearer {token}` 형태로 전송

### 비밀번호 보안
- bcrypt를 사용한 비밀번호 해시화
- 최소 6자 이상 비밀번호 요구
- 현재 비밀번호 검증 후 변경

### 인증이 필요한 엔드포인트
- `POST /api/admin/login` - 로그인 (인증 불필요)
- `GET /api/admin/me` - 관리자 정보 조회
- `PUT /api/admin/change-password` - 비밀번호 변경
- `POST /api/main-dashboard` - 메인 데이터 생성
- `PUT /api/main-dashboard/{date}` - 메인 데이터 수정
- `PUT /api/dong-dashboard/dong/{dong_name}/{date}` - 특정 동 데이터 수정

### 인증이 불필요한 엔드포인트
- `GET /` - Health Check
- `GET /api/main-dashboard` - 메인 대시보드 데이터 조회
- `GET /api/main-dashboard/{date}` - 특정 날짜 메인 데이터 조회
- `GET /api/dong-dashboard/dong/{dong_name}/{date}` - 특정 동의 특정 날짜 데이터 조회

### 에러 응답
```json
{
  "detail": "권한이 없습니다."  // 401 Unauthorized
}
```

```json
{
  "detail": "2025-07-26 날짜의 메인 대시보드 데이터가 이미 존재합니다. 수정을 원하시면 PUT 메서드를 사용하세요."  // 400 Bad Request
}
```

## 📊 데이터베이스 스키마

### 주요 테이블
- **main_data**: 메인 대시보드 데이터 (JSON 형태)
- **dong_data**: 동별 대시보드 데이터 (JSON 형태)
- **admins**: 관리자 계정 정보

### 데이터 구조
- **main_data**: Primary Key: `data_date` (DATE 타입)
- **dong_data**: Primary Key: `(dong, data_date)` (복합키)
- JSON 컬럼을 사용한 유연한 데이터 저장
- 날짜별 데이터 버전 관리
- 동별 개별 레코드 관리

## 🔧 기술 스택

- **FastAPI**: 고성능 웹 프레임워크
- **SQLAlchemy**: Python SQL 툴킷 및 ORM
- **PyMySQL**: MySQL 데이터베이스 드라이버
- **Pydantic**: 데이터 검증 라이브러리
- **python-jose**: JWT 토큰 처리
- **passlib**: 비밀번호 해시화
- **bcrypt**: 암호화 라이브러리
- **Uvicorn**: ASGI 서버

## 🎯 주요 기능

1. **하이브리드 인증 시스템**:
   - GET 엔드포인트: 인증 불필요 (공개 데이터 조회)
   - POST/PUT/DELETE 엔드포인트: JWT 토큰 인증 필요
2. **날짜별 데이터 관리**: 각 수집일별로 독립적인 데이터 관리
3. **메인 대시보드**: 서구 전체 가맹점 현황 및 통계
4. **동별 대시보드**: 각 동별 상세 현황 및 분석
5. **완전한 CRUD API**: 데이터 생성, 조회, 수정 지원
6. **실시간 API**: RESTful API를 통한 데이터 제공
7. **관리자 관리**: 비밀번호 변경 및 계정 정보 관리

## 🚀 배포 가이드

### 환경 변수
운영 환경에서는 다음 환경 변수들을 설정하세요:
```bash
DATABASE_URL=mysql+pymysql://user:password@host:port/database
```

### 서버 설정
- 포트: 8000
- CORS: 모든 도메인 허용 (개발용)
- 로그 레벨: INFO

## 🤝 개발 가이드

### API 추가 방법
1. `app/models/models.py`에 Pydantic 모델 추가
2. `app/api/main.py`에 엔드포인트 추가
3. JWT 인증이 필요한 경우 `Depends(get_current_active_admin)` 추가

### 데이터베이스 모델 추가
1. `app/database/database.py`에 SQLAlchemy 모델 추가
2. 마이그레이션 스크립트 작성 (필요시)

### 테스트
```bash
# 서버 실행 후
curl -X POST "http://localhost:8000/api/admin/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```

├── app/                    # 메인 애플리케이션 코드
│   ├── api/               # API 엔드포인트
│   │   ├── main.py        # 메인 API 라우터
│   │   └── admin_api.py   # 관리자 API (사용 안함)
│   ├── auth/              # 인증 관련
│   │   └── auth.py        # JWT 인증 로직
│   ├── core/              # 핵심 설정
│   │   └── config.py      # 데이터베이스 설정
│   ├── database/          # 데이터베이스 모델
│   │   └── database.py    # SQLAlchemy 모델
│   └── models/            # Pydantic 모델
│       └── models.py      # 요청/응답 모델
├── scripts/               # 유틸리티 스크립트
│   ├── run.py            # 서버 실행 스크립트
│   └── create_admin.py   # 관리자 계정 생성
├── docs/                  # 문서
│   └── CLAUDE.md         # 개발 가이드
├── data/                  # 샘플 데이터
│   ├── main_data.json    # 메인 대시보드 샘플 데이터
│   └── dong_data.json    # 동별 대시보드 샘플 데이터
├── sql/                   # SQL 스크립트
│   ├── create_database.sql    # 데이터베이스 생성
│   ├── main_data_table.sql    # 메인 데이터 테이블
│   └── dong_data_table.sql    # 동별 데이터 테이블
├── main.py               # 애플리케이션 진입점
└── requirements.txt      # Python 의존성
```

## 🚀 설치 및 실행

### 1. 의존성 설치
```bash
pip install -r requirements.txt
```

### 2. MySQL 데이터베이스 설정

이 프로젝트는 환경에 따라 자동으로 데이터베이스를 선택합니다:
- **로컬 환경**: 127.0.0.1:23307 (seogu119 DB)
- **운영 환경**: AWS RDS (seogu119 DB)

**로컬 MySQL 설정:**
```bash
# 데이터베이스 생성
mysql -u admin -p -h 127.0.0.1 -P 23307 < sql/create_database.sql

# 테이블 생성 및 샘플 데이터 삽입
mysql -u admin -p -h 127.0.0.1 -P 23307 seogu119 < sql/main_data_table.sql
mysql -u admin -p -h 127.0.0.1 -P 23307 seogu119 < sql/dong_data_table.sql
```

### 3. 관리자 계정 생성
```bash
python scripts/create_admin.py
```

### 4. 서버 실행
```bash
# 방법 1: 실행 스크립트 사용
python scripts/run.py

# 방법 2: 메인 파일 실행
python main.py

# 방법 3: uvicorn 직접 실행
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## 📡 API 엔드포인트

### 기본 정보
- **서버 주소**: http://localhost:8000
- **API 문서**: http://localhost:8000/docs
- **OpenAPI 스펙**: http://localhost:8000/openapi.json

### 인증
모든 API는 JWT 토큰 인증이 필요합니다 (로그인 API 제외).

#### 관리자 로그인
```http
POST /api/admin/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

**응답:**
```json
{
  "success": true,
  "message": "로그인에 성공했습니다.",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "admin": {
      "id": 1,
      "username": "admin",
      "is_active": true,
      "created_at": "2025-07-20T23:37:35",
      "last_login": "2025-07-25T12:23:35"
    }
  }
}
```

#### 비밀번호 변경
```http
PUT /api/admin/change-password
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "current_password": "admin123",
  "new_password": "newpassword123"
}
```

### 대시보드 API

#### 1. 메인 대시보드 데이터 조회 (인증 불필요)
```http
GET /api/main-dashboard                    # 최신 데이터
GET /api/main-dashboard/2025-07-25        # 특정 날짜 데이터
```

**응답 데이터 구조:**
```json
{
  "success": true,
  "message": "메인 대시보드 데이터를 성공적으로 조회했습니다.",
  "data": {
    "topMetrics": [
      {"title": "🏪 전체 가맹점", "value": "11,427", "unit": "개"},
      {"title": "✨ 이번주 신규", "value": "47", "unit": "개"},
      {"title": "📊 가맹률", "value": "85.2", "unit": "%"}
    ],
    "trendChart": {
      "title": "📈 온누리 가맹점 추이",
      "data": [{"x": 0, "y": 75}, {"x": 1, "y": 78}]
    },
    "dongMembership": {
      "title": "🗺️ 동별 가맹률 현황",
      "data": [
        {"name": "동천동", "percentage": 92.1},
        {"name": "유촌동", "percentage": 88.3}
      ]
    },
    "availableDates": ["2025-07-25"]
  }
}
```

#### 2. 메인 대시보드 데이터 생성 (인증 필요)
```http
POST /api/main-dashboard
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "data_date": "2025-07-26",
  "data_json": {
    "topMetrics": [
      {"title": "🏪 전체 가맹점", "value": "12,000", "unit": "개"},
      {"title": "✨ 이번주 신규", "value": "50", "unit": "개"},
      {"title": "📊 가맹률", "value": "86.5", "unit": "%"}
    ],
    "weeklyAchievements": [...],
    "trendChart": {...},
    "dongMembership": {...},
    "complaintKeywords": {...},
    "complaintCases": {...},
    "complaintPerformance": {...},
    "organizationTrends": {...}
  }
}
```

**응답 예시:**
```json
{
  "success": true,
  "message": "메인 대시보드 데이터가 성공적으로 생성되었습니다.",
  "data": {
    "data_date": "2025-07-26",
    "created_at": "2025-07-25T13:04:06",
    "created_by": "admin"
  }
}
```

#### 3. 메인 대시보드 데이터 수정 (인증 필요)
```http
PUT /api/main-dashboard/2025-07-26
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "data_json": {
    "topMetrics": [
      {"title": "🏪 전체 가맹점", "value": "12,500", "unit": "개"}
    ],
    // ... 기타 필드들
  }
}
```

#### 4. 동별 대시보드 데이터 조회 (인증 불필요)
```http
GET /api/dong-dashboard/dong/동천동/2025-07-25  # 특정 동의 특정 날짜 데이터
```

**동별 데이터 구조:**
```json
{
  "success": true,
  "message": "동천동 대시보드 데이터를 성공적으로 조회했습니다.",
  "data": {
    "dongMetrics": [
      {"title": "🏪 총 상인회", "value": "5", "unit": "개"},
      {"title": "✨ 가맹률", "value": "92.1", "unit": "%"}
    ],
    "complaints": [
      {"keyword": "주차 문제", "count": 8},
      {"keyword": "소음 방해", "count": 5}
    ],
    "businessTypes": [
      {"type": "음식점", "count": 2, "percentage": 40.0},
      {"type": "소매점", "count": 2, "percentage": 30.0}
    ],
    "availableDates": ["2025-07-25"],
    "availableDongs": ["양3동", "광천동", "동천동", "유덕동", "치평동", "풍암동", "금고1동", "금고2동", "농성1동", "농성2동", "상무1동", "상무2동", "화정1동", "화정2동", "화정3동", "화정4동", "서창(마륵)동", "서창(매월)동"]
  }
}
```

#### 5. 동별 대시보드 데이터 생성 (인증 필요)
```http
POST /api/dong-dashboard
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "data_date": "2025-07-26",
  "data_json": {
    "동천동": {
      "dongMetrics": [
        {"title": "🏪 총 상인회", "value": "6", "unit": "개"},
        {"title": "✨ 가맹률", "value": "94.5", "unit": "%"}
      ],
      "weeklyAchievements": [
        {"title": "신규 가맹", "value": "3개"},
        {"title": "매출 증가", "value": "12%"}
      ],
      "complaints": [
        {"keyword": "주차 문제", "count": 5},
        {"keyword": "소음 방해", "count": 3}
      ],
      "businessTypes": [
        {"type": "음식점", "count": 25, "percentage": 45.0},
        {"type": "소매점", "count": 20, "percentage": 35.0}
      ]
    },
    "유촌동": {
      "dongMetrics": [
        {"title": "🏪 총 상인회", "value": "4", "unit": "개"},
        {"title": "✨ 가맹률", "value": "88.7", "unit": "%"}
      ],
      "weeklyAchievements": [
        {"title": "신규 가맹", "value": "2개"},
        {"title": "매출 증가", "value": "8%"}
      ],
      "complaints": [
        {"keyword": "배달 문제", "count": 4},
        {"keyword": "접근성", "count": 2}
      ],
      "businessTypes": [
        {"type": "음식점", "count": 18, "percentage": 40.0},
        {"type": "서비스업", "count": 15, "percentage": 30.0}
      ]
    }
  }
}
```

**응답 예시:**
```json
{
  "success": true,
  "message": "동별 대시보드 데이터가 성공적으로 생성되었습니다.",
  "data": {
    "data_date": "2025-07-26",
    "created_at": "2025-07-25T17:20:25",
    "created_by": "admin",
    "dong_count": 2
  }
}
```

#### 6. 동별 대시보드 데이터 수정 (인증 필요)
```http
PUT /api/dong-dashboard/2025-07-26
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "data_json": {
    "동천동": {
      "dongMetrics": [
        {"title": "🏪 총 상인회", "value": "7", "unit": "개"},
        {"title": "✨ 가맹률", "value": "96.2", "unit": "%"}
      ],
      "weeklyAchievements": [
        {"title": "신규 가맹", "value": "5개"},
        {"title": "매출 증가", "value": "15%"}
      ],
      "complaints": [
        {"keyword": "주차 문제", "count": 3},
        {"keyword": "소음 방해", "count": 2}
      ],
      "businessTypes": [
        {"type": "음식점", "count": 28, "percentage": 50.0},
        {"type": "소매점", "count": 18, "percentage": 32.0}
      ]
    }
  }
}
```

**응답 예시:**
```json
{
  "success": true,
  "message": "동별 대시보드 데이터가 성공적으로 수정되었습니다.",
  "data": {
    "data_date": "2025-07-26",
    "updated_at": "2025-07-25T17:25:30",
    "updated_by": "admin",
    "dong_count": 1
  }
}
```

### 관리자 정보 API

#### 현재 로그인한 관리자 정보 조회
```http
GET /api/admin/me
Authorization: Bearer {access_token}
```

## 🔒 인증 및 보안

### JWT 토큰 인증
- **GET 엔드포인트**: 인증 불필요 (데이터 조회)
- **POST, PUT, DELETE 엔드포인트**: JWT 토큰 인증 필요 (데이터 생성/수정/삭제)
- **관리자 전용 엔드포인트**: JWT 토큰 인증 필요
- 토큰 유효 기간: 24시간
- Authorization 헤더에 `Bearer {token}` 형태로 전송

### 비밀번호 보안
- bcrypt를 사용한 비밀번호 해시화
- 최소 6자 이상 비밀번호 요구
- 현재 비밀번호 검증 후 변경

### 인증이 필요한 엔드포인트
- `POST /api/admin/login` - 로그인 (인증 불필요)
- `GET /api/admin/me` - 관리자 정보 조회
- `PUT /api/admin/change-password` - 비밀번호 변경
- `POST /api/main-dashboard` - 메인 데이터 생성
- `PUT /api/main-dashboard/{date}` - 메인 데이터 수정
- `PUT /api/dong-dashboard/dong/{dong_name}/{date}` - 특정 동 데이터 수정

### 인증이 불필요한 엔드포인트
- `GET /` - Health Check
- `GET /api/main-dashboard` - 메인 대시보드 데이터 조회
- `GET /api/main-dashboard/{date}` - 특정 날짜 메인 데이터 조회
- `GET /api/dong-dashboard/dong/{dong_name}/{date}` - 특정 동의 특정 날짜 데이터 조회

### 에러 응답
```json
{
  "detail": "권한이 없습니다."  // 401 Unauthorized
}
```

```json
{
  "detail": "2025-07-26 날짜의 메인 대시보드 데이터가 이미 존재합니다. 수정을 원하시면 PUT 메서드를 사용하세요."  // 400 Bad Request
}
```

## 📊 데이터베이스 스키마

### 주요 테이블
- **main_data**: 메인 대시보드 데이터 (JSON 형태)
- **dong_data**: 동별 대시보드 데이터 (JSON 형태)
- **admins**: 관리자 계정 정보

### 데이터 구조
- **main_data**: Primary Key: `data_date` (DATE 타입)
- **dong_data**: Primary Key: `(dong, data_date)` (복합키)
- JSON 컬럼을 사용한 유연한 데이터 저장
- 날짜별 데이터 버전 관리
- 동별 개별 레코드 관리

## 🔧 기술 스택

- **FastAPI**: 고성능 웹 프레임워크
- **SQLAlchemy**: Python SQL 툴킷 및 ORM
- **PyMySQL**: MySQL 데이터베이스 드라이버
- **Pydantic**: 데이터 검증 라이브러리
- **python-jose**: JWT 토큰 처리
- **passlib**: 비밀번호 해시화
- **bcrypt**: 암호화 라이브러리
- **Uvicorn**: ASGI 서버

## 🎯 주요 기능

1. **하이브리드 인증 시스템**:
   - GET 엔드포인트: 인증 불필요 (공개 데이터 조회)
   - POST/PUT/DELETE 엔드포인트: JWT 토큰 인증 필요
2. **날짜별 데이터 관리**: 각 수집일별로 독립적인 데이터 관리
3. **메인 대시보드**: 서구 전체 가맹점 현황 및 통계
4. **동별 대시보드**: 각 동별 상세 현황 및 분석
5. **완전한 CRUD API**: 데이터 생성, 조회, 수정 지원
6. **실시간 API**: RESTful API를 통한 데이터 제공
7. **관리자 관리**: 비밀번호 변경 및 계정 정보 관리

## 🚀 배포 가이드

### 환경 변수
운영 환경에서는 다음 환경 변수들을 설정하세요:
```bash
DATABASE_URL=mysql+pymysql://user:password@host:port/database
```

### 서버 설정
- 포트: 8000
- CORS: 모든 도메인 허용 (개발용)
- 로그 레벨: INFO

## 🤝 개발 가이드

### API 추가 방법
1. `app/models/models.py`에 Pydantic 모델 추가
2. `app/api/main.py`에 엔드포인트 추가
3. JWT 인증이 필요한 경우 `Depends(get_current_active_admin)` 추가

### 데이터베이스 모델 추가
1. `app/database/database.py`에 SQLAlchemy 모델 추가
2. 마이그레이션 스크립트 작성 (필요시)

### 테스트
```bash
# 서버 실행 후
curl -X POST "http://localhost:8000/api/admin/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```
