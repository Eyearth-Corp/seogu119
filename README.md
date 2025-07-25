# 서구 골목경제 119 상황판

84인치 터치 모니터를 위한 대한민국 서구 골목경제 현황 인터랙티브 맵 애플리케이션

## 🚀 프로젝트 개요

서구 골목경제 119 상황판은 광주광역시 서구의 18개 행정구역에 분포된 119개 골목형상점가와 11,426개 점포를 시각화하는 Flutter 웹 애플리케이션입니다. 84인치 터치 모니터 환경에 최적화되어 공공 디스플레이 및 키오스크 용도로 설계되었습니다.

## ✨ 주요 기능

### 🎯 84인치 터치 모니터 최적화
- **대형 터치 타겟**: 46px 크기의 터치하기 쉬운 상인 마커
- **멀티 터치 제스처**: 더블 탭 줌 리셋, 롱 프레스 선택 모드
- **햅틱 피드백**: 터치 시 진동 피드백 제공
- **자동 리셋**: 5분 비활성 시 자동으로 초기 상태 복원

### 🎨 아름다운 디자인
- **글래스모피즘**: GlassContainer를 활용한 세련된 반투명 UI
- **스태거드 애니메이션**: 상인 마커의 부드러운 페이드인/슬라이드 효과
- **펄스 애니메이션**: 선택된 마커의 실시간 펄스 효과
- **그라데이션**: 부드러운 색상 전환과 그림자 효과

### 🗺️ 인터랙티브 맵 기능
- **줌/팬**: 핀치 줌과 드래그로 자유로운 지도 탐색
- **18개 행정구역**: 동천동, 유촌동, 광천동 등 개별 선택 가능
- **119개 상인회**: 각 상인회별 상세 정보 및 위치 표시
- **애니메이션 줌**: 구역 선택 시 부드러운 애니메이션 전환

### 🎮 사용자 상호작용
- **단일 선택**: 상인 마커 터치로 상세 정보 모달 표시
- **다중 선택**: 롱 프레스로 선택 모드 활성화 후 여러 상인 동시 선택
- **좌표 복사**: 빈 공간 터치로 좌표 정보 클립보드 복사
- **위치 이동**: 상세 정보에서 해당 위치로 자동 이동

### 🔧 레이어 시스템
- **지형 레이어**: 산/강 지형 정보 토글
- **번호 레이어**: 상인 번호 표시/숨김
- **동이름 레이어**: 행정구역 이름 토글
- **구역 레이어**: 동 경계 영역 표시

## 🏗️ 기술 스택

### 프레임워크
- **Flutter 3.8.1+**: 크로스 플랫폼 UI 프레임워크
- **Dart**: 프로그래밍 언어

### 주요 패키지
- `glass_kit: ^3.0.0`: 글래스모피즘 UI 효과
- `flutter_staggered_animations: ^1.1.1`: 스태거드 애니메이션
- `animations: ^2.0.11`: 고급 애니메이션 효과
- `shimmer: ^3.0.0`: 로딩 애니메이션
- `fl_chart: ^1.0.0`: 차트 위젯
- `flutter_svg: ^2.0.10+1`: SVG 렌더링

## 📁 프로젝트 구조

```
lib/
├── app.dart                    # 메인 앱 설정
├── main.dart                   # 앱 엔트리 포인트
└── page/
    ├── home_page.dart          # 메인 화면 (대시보드 + 맵)
    ├── data/
    │   └── dong_list.dart      # 행정구역 및 상인 데이터
    └── widget/
        ├── chart_widget.dart           # 차트 위젯
        ├── dashboard_widget.dart       # 대시보드 패널
        ├── floating_action_buttons.dart # 플로팅 액션 버튼
        ├── map_widget.dart            # 인터랙티브 맵 (메인)
        └── merchant_list_dialog.dart   # 상인 목록 다이얼로그

assets/
├── images/         # 일반 이미지
├── map/           # 지도 관련 이미지 (base, terrain, dong areas)
├── svg/           # SVG 벡터 이미지
└── temp/          # 임시 파일
```

## 🚀 시작하기

### 필요 조건
- Flutter SDK 3.8.1 이상
- Chrome 브라우저 (웹 실행용)
- 84인치 터치 모니터 (권장)

### 설치 및 실행

1. **저장소 클론**
   ```bash
   git clone <repository-url>
   cd seogu119
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **웹에서 실행**
   ```bash
   flutter run -d chrome
   ```

4. **프로덕션 빌드**
   ```bash
   flutter build web
   ```

## 💡 사용 방법

### 기본 조작
1. **지도 탐색**: 마우스 드래그나 터치로 지도 이동
2. **줌 조작**: 마우스 휠이나 핀치 제스처로 확대/축소
3. **상인 선택**: 번호 마커를 클릭하여 상세 정보 확인
4. **구역 선택**: 우측 패널에서 행정구역 선택

### 고급 기능
- **더블 탭**: 줌 리셋
- **롱 프레스**: 다중 선택 모드 활성화
- **레이어 토글**: 하단 글래스 패널에서 표시 옵션 조정
- **자동 리셋**: 5분 후 자동으로 초기 상태로 복원

## 📊 데이터 정보

### 행정구역 (18개)
동천동, 유촌동, 광천동, 치평동, 상무1동, 화정1동, 농성1동, 양동, 마륵동, 상무2동, 금고1동, 화정4동, 화정3동, 화정2동, 농성2동, 금고2동, 풍암동, 매월동

### 상인회 데이터
- **총 119개 상인회**
- **11,426개 점포**
- **100% 골목형상점가 지정 완료**

## 🎯 84인치 터치 모니터 최적화 특징

### 터치 인터페이스
- 46px 최소 터치 타겟 크기
- 터치 반응 영역 확대
- 햅틱 피드백 지원
- 제스처 기반 내비게이션

### 키오스크 모드
- 5분 자동 리셋 타이머
- 세션 상태 관리
- 사용자 활동 추적
- 초기 상태 복원

### 성능 최적화
- 뷰포트 기반 렌더링
- 효율적인 메모리 관리
- 고해상도 이미지 지원
- 부드러운 애니메이션

## 🌐 API 서버 정보

### 서버 환경
- **개발 서버**: `http://localhost:8000`
- **프로덕션 서버**: `https://seogu119-api.eyearth.net`
- **인증 방식**: Bearer Token 기반 JWT 인증
- **HTTP 클라이언트**: Flutter http 패키지 사용

### API 엔드포인트

#### 🔐 관리자 인증
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/admin/login` | 관리자 로그인 |
| POST | `/admin/logout` | 관리자 로그아웃 |
| GET | `/admin/me` | 현재 관리자 정보 조회 |
| POST | `/admin/change-password` | 비밀번호 변경 |

#### 🏪 상인회 관리
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/merchant-details/{date}` | 상인회 목록 조회 (필터링 지원) |
| POST | `/api/merchant-details/{date}` | 새 상인회 생성 |
| PUT | `/api/merchant-details/{date}/{merchantId}` | 상인회 정보 수정 |
| DELETE | `/api/merchant-details/{date}/{merchantId}` | 상인회 삭제 |

#### 📊 통계 및 데이터
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/statistics/{date}` | 전체 통계 데이터 조회 |
| GET | `/api/dong-status/{date}/{dongName}` | 동별 상인회 현황 조회 |
| GET | `/api/dates` | 사용 가능한 데이터 수집일 목록 |

### API 요청 파라미터

#### 상인회 목록 조회 쿼리 파라미터
```
- dong_name: 행정구역 이름 필터
- category: 업종 카테고리 필터  
- status: 상태 필터
- page: 페이지 번호 (기본: 1)
- limit: 페이지당 개수 (기본: 50)
```

#### 인증 헤더
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### API 응답 형식

#### 성공 응답
```json
{
  "success": true,
  "data": { ... },
  "message": "요청이 성공적으로 처리되었습니다."
}
```

#### 로그인 응답
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

#### 오류 응답
```json
{
  "success": false,
  "error": "오류 메시지",
  "detail": "상세 오류 정보"
}
```

### 서비스 클래스 사용법

```dart
// 관리자 로그인
final success = await AdminService.login(username, password);

// 상인회 목록 조회
final merchants = await AdminService.getMerchants(
  date: '2024-01-01',
  dongName: '동천동',
  page: 1,
  limit: 20,
);

// 통계 데이터 조회
final stats = await AdminService.getStatistics('2024-01-01');
```

## 🛠️ 개발 정보

### 개발 명령어
```bash
# 의존성 설치
flutter pub get

# 개발 서버 실행
flutter run -d chrome

# 정적 분석
flutter analyze

# 테스트 실행
flutter test

# 웹 빌드
flutter build web
```



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
GET /api/dong-dashboard                    # 전체 동별 데이터 (최신)
GET /api/dong-dashboard/2025-07-25        # 특정 날짜 전체 동별 데이터
GET /api/dong-dashboard/dong/동천동        # 특정 동 데이터 (최신)
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
    "availableDongs": ["광천동", "동천동", "유덕동", "치평동", "상무1동"]
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
- `GET /api/dong-dashboard` - 동별 대시보드 데이터 조회
- `GET /api/dong-dashboard/{date}` - 특정 날짜 동별 데이터 조회
- `GET /api/dong-dashboard/dong/{dong_name}` - 특정 동 데이터 조회
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
- Primary Key: `data_date` (DATE 타입)
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
