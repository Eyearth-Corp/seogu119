# API 문서

서구 골목 프로젝트의 REST API 사용 내역 정리 문서입니다.

## 기본 정보

### Base URL
- **Production**: `https://seogu119-api.eyearth.net/api`
- **Development**: `https://seogu119-api.eyearth.net/api` (debug mode)

### API 응답 형식
모든 API는 다음과 같은 공통 응답 형식을 사용합니다:

```json
{
  "success": true,
  "data": {
    // 실제 응답 데이터
  }
}
```

### 인증
관리자 API는 JWT 토큰 기반 인증을 사용합니다.
- Header: `Authorization: Bearer {token}`
- 토큰은 로그인 시 발급되며 SharedPreferences에 저장됩니다
- JWT 만료 시 자동으로 로그아웃 처리됩니다

## 공개 API (Public APIs)

### 1. 메인 대시보드

#### GET /api/main-dashboard
메인 대시보드의 전체 데이터를 조회합니다.

**Request**
```
GET /api/main-dashboard
Content-Type: application/json
```

**Response**
```json
{
  "success": true,
  "data": {
    "topMetrics": [
      {
        "icon": "🏪",
        "title": "전체 가맹점",
        "value": "11,426",
        "unit": "개",
        "color": "#6366F1"
      }
    ],
    "newMerchants": "47",
    "resolvedComplaints": "23",
    "supportBudget": "2.3",
    "complaintKeywords": [...],
    "complaintCases": [...],
    "processedComplaints": "187",
    "processingRate": "94.2",
    "otherOrganizationTrends": [...]
  }
}
```

**사용 위치**: `lib/core/api_service.dart:13`

---

### 2. 지역구(동) 관리

#### GET /api/districts
전체 동 목록을 조회합니다.

**Request**
```
GET /api/districts
Content-Type: application/json
```

**Response**
```json
{
  "success": true,
  "data": {
    "districts": [
      {
        "id": 1,
        "dong_name": "동천동",
        "merchant_count": 15,
        "total_stores": 500,
        "total_member_stores": 450,
        "avg_membership_rate": 90.0,
        "created_at": "2024-01-01T00:00:00",
        "updated_at": "2024-01-01T00:00:00"
      }
    ]
  }
}
```

**사용 위치**:
- `lib/core/api_service.dart:40`
- `lib/page/data/admin_service.dart:264`

---

#### GET /api/districts/{dongName}/merchants
특정 동의 상인회 목록을 조회합니다.

**Parameters**
- `dongName` (path): 동 이름 (예: "동천동")

**Request**
```
GET /api/districts/동천동/merchants
Content-Type: application/json
```

**Response**
```json
{
  "success": true,
  "data": {
    "district": {
      "id": 1,
      "dong_name": "동천동",
      "merchant_count": 15,
      "total_stores": 500,
      "total_member_stores": 450,
      "overall_membership_rate": 90.0
    },
    "merchants": [
      {
        "id": 1,
        "merchant_name": "동천상가번영회",
        "president": "홍길동",
        "store_count": 50,
        "member_store_count": 45,
        "membership_rate": 90.0,
        "created_at": "2024-01-01T00:00:00",
        "updated_at": "2024-01-01T00:00:00"
      }
    ]
  }
}
```

**사용 위치**:
- `lib/core/api_service.dart:61`
- `lib/page/data/admin_service.dart:284`

---

### 3. 상인회 관리

#### GET /api/merchants/{merchantId}
특정 상인회의 상세 정보를 조회합니다.

**Parameters**
- `merchantId` (path): 상인회 ID

**Request**
```
GET /api/merchants/1
Content-Type: application/json
```

**Response**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "district": {
      "id": 1,
      "dong_name": "동천동",
      "merchant_count": 15
    },
    "merchant_name": "동천상가번영회",
    "president": "홍길동",
    "store_count": 50,
    "member_store_count": 45,
    "membership_rate": 90.0,
    "membership_percentage": 90.0,
    "created_at": "2024-01-01T00:00:00",
    "updated_at": "2024-01-01T00:00:00"
  }
}
```

**사용 위치**:
- `lib/core/api_service.dart:81`
- `lib/page/data/admin_service.dart:304`

---

### 4. 통계 정보

#### GET /api/statistics/summary
전체 통계 요약 정보를 조회합니다.

**Request**
```
GET /api/statistics/summary
Content-Type: application/json
```

**Response**
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_districts": 18,
      "total_merchants": 119,
      "total_stores": 11426,
      "total_member_stores": 9800,
      "overall_membership_rate": 85.7
    },
    "top_districts": [
      {
        "dong_name": "동천동",
        "merchant_count": 15
      }
    ]
  }
}
```

**사용 위치**:
- `lib/core/api_service.dart:101`
- `lib/page/data/admin_service.dart:364`

---

### 5. 대시보드 위젯 데이터

#### GET /api/DashBoardType1?id={id}
타입1 대시보드 위젯 데이터를 조회합니다.

**Parameters**
- `id` (query): 위젯 ID

**Request**
```
GET /api/DashBoardType1?id=1
Content-Type: application/json
```

**사용 위치**: `lib/core/api_service.dart:122`

---

#### GET /api/DashBoardType2?id={id}
타입2 대시보드 위젯 데이터를 조회합니다.

**사용 위치**: `lib/core/api_service.dart:143`

---

#### GET /api/DashBoardType3?id={id}
타입3 대시보드 위젯 데이터를 조회합니다.

**사용 위치**: `lib/core/api_service.dart:163`

---

#### GET /api/DashBoardType4?id={id}
타입4 대시보드 위젯 데이터를 조회합니다.

**사용 위치**: `lib/core/api_service.dart:183`

---

#### GET /api/DashBoardType5?id={id}
타입5 대시보드 위젯 데이터를 조회합니다.

**사용 위치**: `lib/core/api_service.dart:203`

---

#### GET /api/DashBoardBbs1?id={id}
게시판 타입1 위젯 데이터를 조회합니다.

**사용 위치**: `lib/core/api_service.dart:223`

---

#### GET /api/DashBoardBbs2?id={id}
게시판 타입2 위젯 데이터를 조회합니다.

**사용 위치**: `lib/core/api_service.dart:243`

---

#### GET /api/DashBoardChart?id={id}
차트 위젯 데이터를 조회합니다.

**사용 위치**: `lib/core/api_service.dart:263`

---

#### GET /api/DashBoardPercent?id={id}
퍼센트 위젯 데이터를 조회합니다.

**사용 위치**: `lib/core/api_service.dart:283`

---

### 6. 대시보드 타이틀

#### GET /api/dashboard-title
대시보드 타이틀을 조회합니다.

**Request**
```
GET /api/dashboard-title
Content-Type: application/json
```

**Response**
```json
{
  "success": true,
  "data": {
    "title": "서구 골목상권 현황"
  }
}
```

**사용 위치**:
- `lib/core/api_service.dart:303`
- `lib/page/data/admin_service.dart:791`

---

## 관리자 API (Admin APIs)

### 1. 인증

#### POST /api/admin/login
관리자 로그인을 수행합니다.

**Request**
```json
POST /api/admin/login
Content-Type: application/json

{
  "username": "admin",
  "password": "password123"
}
```

**Response**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer"
  }
}
```

**사용 위치**: `lib/page/data/admin_service.dart:73`

---

#### POST /api/admin/logout
관리자 로그아웃을 수행합니다.

**Request**
```
POST /api/admin/logout
Authorization: Bearer {token}
```

**사용 위치**: `lib/page/data/admin_service.dart:133`

---

#### GET /api/admin/me
현재 로그인한 관리자 정보를 조회합니다.

**Request**
```
GET /api/admin/me
Authorization: Bearer {token}
```

**Response**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com"
  }
}
```

**사용 위치**: `lib/page/data/admin_service.dart:149`

---

#### POST /api/admin/change-password
관리자 비밀번호를 변경합니다.

**Request**
```json
POST /api/admin/change-password
Authorization: Bearer {token}
Content-Type: application/json

{
  "current_password": "oldpassword",
  "new_password": "newpassword"
}
```

**사용 위치**: `lib/page/data/admin_service.dart:466`

---

### 2. 상인회 관리

#### PUT /api/merchants/{merchantId}
상인회 정보를 수정합니다.

**Parameters**
- `merchantId` (path): 상인회 ID
- Query Parameters:
  - `merchant_name` (optional): 상인회 이름
  - `president` (optional): 회장 이름
  - `store_count` (optional): 전체 점포 수
  - `member_store_count` (optional): 가맹 점포 수
  - `membership_rate` (optional): 가맹률

**Request**
```
PUT /api/merchants/1?merchant_name=동천상가번영회&president=홍길동&store_count=50
Authorization: Bearer {token}
```

**Response**
```json
{
  "success": true,
  "data": {
    // 수정된 상인회 정보
  }
}
```

**사용 위치**: `lib/page/data/admin_service.dart:324`

---

### 3. 공지사항 관리

#### GET /api/districts/{dongName}/notices
특정 동의 공지사항 목록을 조회합니다.

**Request**
```
GET /api/districts/동천동/notices
Authorization: Bearer {token}
```

**사용 위치**: `lib/page/data/admin_service.dart:384`

---

#### POST /api/districts/{dongName}/notices
특정 동에 공지사항을 생성합니다.

**Parameters**
- `dongName` (path): 동 이름
- Query Parameters:
  - `title`: 공지사항 제목
  - `content`: 공지사항 내용

**Request**
```
POST /api/districts/동천동/notices?title=공지사항&content=내용
Authorization: Bearer {token}
```

**사용 위치**: `lib/page/data/admin_service.dart:404`

---

#### PUT /api/notices/{noticeId}
공지사항을 수정합니다.

**Parameters**
- `noticeId` (path): 공지사항 ID
- Query Parameters:
  - `title` (optional): 공지사항 제목
  - `content` (optional): 공지사항 내용

**Request**
```
PUT /api/notices/1?title=수정된제목&content=수정된내용
Authorization: Bearer {token}
```

**사용 위치**: `lib/page/data/admin_service.dart:423`

---

#### DELETE /api/notices/{noticeId}
공지사항을 삭제합니다.

**Parameters**
- `noticeId` (path): 공지사항 ID

**Request**
```
DELETE /api/notices/1
Authorization: Bearer {token}
```

**사용 위치**: `lib/page/data/admin_service.dart:446`

---

### 4. 메인 대시보드 관리

#### POST /api/main-dashboard
메인 대시보드 데이터를 생성/업데이트합니다.

**Request**
```json
POST /api/main-dashboard
Authorization: Bearer {token}
Content-Type: application/json

{
  "data_json": {
    "topMetrics": [...],
    "trendChart": {...},
    "dongMembership": {...},
    "complaintKeywords": {...},
    "complaintCases": {...},
    "complaintPerformance": {...},
    "organizationTrends": {...},
    "weeklyAchievements": [...]
  }
}
```

**사용 위치**: `lib/page/data/admin_service.dart:538`

---

### 5. 대시보드 마스터 관리

#### POST /api/dashboard-master
대시보드 마스터를 생성합니다.

**Request**
```json
POST /api/dashboard-master
Authorization: Bearer {token}
Content-Type: application/json

{
  "id": 1,
  "widget_type": "type1",
  "dashboard_name": "위젯 이름",
  "dashboard_description": "위젯 설명"
}
```

**사용 위치**: `lib/page/data/admin_service.dart:698`

---

#### PUT /api/dashboard-master/{id}/{widgetType}
대시보드 마스터를 수정합니다.

**Parameters**
- `id` (path): 대시보드 ID
- `widgetType` (path): 위젯 타입

**Request**
```json
PUT /api/dashboard-master/1/type1
Authorization: Bearer {token}
Content-Type: application/json

{
  "dashboard_name": "수정된 이름",
  "dashboard_description": "수정된 설명",
  "title_color": "#000000",
  "background_color": "#FFFFFF"
}
```

**사용 위치**: `lib/page/data/admin_service.dart:721`

---

#### DELETE /api/dashboard-master/{id}/{widgetType}
대시보드 마스터를 삭제합니다.

**Parameters**
- `id` (path): 대시보드 ID
- `widgetType` (path): 위젯 타입

**Request**
```
DELETE /api/dashboard-master/1/type1
Authorization: Bearer {token}
```

**사용 위치**: `lib/page/data/admin_service.dart:747`

---

#### GET /api/widget-types
사용 가능한 위젯 타입 목록을 조회합니다.

**Request**
```
GET /api/widget-types
Authorization: Bearer {token}
```

**사용 위치**: `lib/page/data/admin_service.dart:762`

---

#### PUT /api/dashboard-title
대시보드 타이틀을 수정합니다.

**Request**
```json
PUT /api/dashboard-title
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "새로운 타이틀"
}
```

**사용 위치**: `lib/page/data/admin_service.dart:774`

---

## 범용 메서드 (Generic Methods)

AdminService는 다음과 같은 범용 HTTP 메서드를 제공합니다:

### fetchFromURL(url)
임의의 URL에서 데이터를 GET 요청으로 가져옵니다.

**사용 위치**: `lib/page/data/admin_service.dart:169`

---

### postToURL(url, data)
임의의 URL로 POST 요청을 보냅니다.

**사용 위치**: `lib/page/data/admin_service.dart:193`

---

### putToURL(url, data)
임의의 URL로 PUT 요청을 보냅니다.

**사용 위치**: `lib/page/data/admin_service.dart:217`

---

### deleteFromURL(url)
임의의 URL로 DELETE 요청을 보냅니다.

**사용 위치**: `lib/page/data/admin_service.dart:241`

---

## 에러 처리

모든 API 호출은 다음과 같은 에러 처리 패턴을 따릅니다:

1. HTTP 상태 코드 확인 (200, 201 등)
2. 응답 본문의 `success` 필드 확인
3. 에러 발생 시 예외 throw 또는 null/false 반환
4. JWT 토큰 만료 시 자동 로그아웃 처리

## 데이터 모델

주요 데이터 모델은 다음 파일에 정의되어 있습니다:

- **MainDashboardData**: `lib/core/api_service.dart:338`
- **District**: `lib/core/api_service.dart:552`
- **Merchant**: `lib/core/api_service.dart:670`
- **StatisticsSummary**: `lib/core/api_service.dart:711`

각 모델은 `fromJson` 팩토리 메서드를 통해 API 응답을 파싱합니다.
