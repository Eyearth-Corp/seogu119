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

### 인증이 불필요한 엔드포인트
- `GET /` - Health Check
- `GET /api/main-dashboard` - 메인 대시보드 데이터 조회
- `GET /api/main-dashboard/{date}` - 특정 날짜 메인 데이터 조회

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
- **admins**: 관리자 계정 정보

### 데이터 구조
- **main_data**: Primary Key: `data_date` (DATE 타입)
- JSON 컬럼을 사용한 유연한 데이터 저장
- 날짜별 데이터 버전 관리

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
4. **완전한 CRUD API**: 데이터 생성, 조회, 수정 지원
5. **실시간 API**: RESTful API를 통한 데이터 제공
6. **관리자 관리**: 비밀번호 변경 및 계정 정보 관리

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

### 인증이 불필요한 엔드포인트
- `GET /` - Health Check
- `GET /api/main-dashboard` - 메인 대시보드 데이터 조회
- `GET /api/main-dashboard/{date}` - 특정 날짜 메인 데이터 조회

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
- **admins**: 관리자 계정 정보

### 데이터 구조
- **main_data**: Primary Key: `data_date` (DATE 타입)
- JSON 컬럼을 사용한 유연한 데이터 저장
- 날짜별 데이터 버전 관리

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
4. **완전한 CRUD API**: 데이터 생성, 조회, 수정 지원
5. **실시간 API**: RESTful API를 통한 데이터 제공
6. **관리자 관리**: 비밀번호 변경 및 계정 정보 관리

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
