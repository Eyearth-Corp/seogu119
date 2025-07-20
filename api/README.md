# 서구 골목 API 서버

FastAPI + MySQL을 사용한 서구 골목 가맹점 정보 관리 API 서버입니다.

## 🏗️ 프로젝트 구조

```
api/
├── main.py              # FastAPI 애플리케이션 메인 파일
├── database.py          # SQLAlchemy 데이터베이스 설정 및 모델
├── models.py            # Pydantic 모델 (요청/응답)
├── data_loader.py       # Flutter 앱 데이터를 DB에 로드하는 스크립트
├── run.py              # 서버 실행 스크립트
├── requirements.txt     # Python 패키지 의존성
├── .env.example        # 환경 변수 예시 파일
└── README.md           # 이 파일
```

## 🚀 설치 및 실행

### 1. 의존성 설치
```bash
cd api
pip install -r requirements.txt
```

### 2. 환경 변수 설정
```bash
cp .env .env
# .env 파일을 편집하여 데이터베이스 연결 정보 설정
```

### 3. MySQL 데이터베이스 설정

이 프로젝트는 환경에 따라 자동으로 데이터베이스를 선택합니다:
- **로컬 환경**: 127.0.0.1:23307 (seogu119 DB)
- **운영 환경**: AWS RDS (seogu119 DB)

**로컬 MySQL 설정 (개발용):**
```sql
CREATE DATABASE seogu119 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

**AWS RDS는 이미 설정되어 있습니다.**

### 4. 데이터 로드 (선택사항)
```bash
python data_loader.py
```

### 5. 서버 실행
```bash
python run.py
# 또는
python main.py
# 또는
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## 📡 API 엔드포인트

### 기본 정보
- **서버 주소**: http://localhost:8000
- **API 문서**: http://localhost:8000/docs
- **OpenAPI 스펙**: http://localhost:8000/openapi.json

### 주요 엔드포인트

#### 1. Health Check
```
GET /
```

#### 2. 데이터 수집일 목록 조회
```
GET /api/dates
```

#### 3. 대시보드 데이터 조회
```
GET /api/dashboard/{date}
```

#### 4. 동 목록 조회
```
GET /api/dongs/{date}
```

#### 5. 가맹점 목록 조회
```
GET /api/merchants/{date}/{dong_id}
```

#### 6. 가맹점 상세 정보 조회 (페이지네이션)
```
GET /api/merchant-details/{date}
?dong_name=동천동&category=일반음식점&status=영업중&page=1&limit=50
```

#### 7. 동별 가맹점 현황
```
GET /api/dong-status/{date}/{dong_name}
```

#### 8. 가맹점 정보 CRUD
```
POST   /api/merchant-details/{date}           # 생성
PUT    /api/merchant-details/{date}/{id}      # 수정
DELETE /api/merchant-details/{date}/{id}      # 삭제
```

#### 9. 전체 통계 조회
```
GET /api/statistics/{date}
```

## 📊 데이터베이스 스키마

### Primary Key: 날짜 (2025-06-20)

### 주요 테이블
- **data_collections**: 데이터 수집일 정보
- **dongs**: 행정동 정보
- **merchants**: 기본 가맹점 정보
- **merchant_details**: 상세 가맹점 정보
- **dashboard_summaries**: 대시보드 요약 정보
- **category_distributions**: 카테고리별 분포
- **area_details**: 지역 상세 정보
- **dong_infos**: 동별 정보

## 🔧 기술 스택

- **FastAPI**: 웹 프레임워크
- **SQLAlchemy**: ORM
- **PyMySQL**: MySQL 드라이버
- **Pydantic**: 데이터 검증
- **Uvicorn**: ASGI 서버

## 🎯 주요 기능

1. **날짜별 데이터 관리**: 각 수집일별로 독립적인 데이터 관리
2. **동별 가맹점 현황**: 행정동별 가맹점 통계 및 현황
3. **실시간 CRUD**: 가맹점 정보 생성/조회/수정/삭제
4. **통계 및 분석**: 다양한 관점에서의 통계 정보 제공
5. **페이지네이션**: 대량 데이터 효율적 조회
6. **CORS 지원**: Flutter 웹 앱과의 연동

## 🌐 Flutter 앱과의 연동

이 API 서버는 Flutter 웹 앱 `lib/page/data` 디렉토리의 데이터 구조를 기반으로 설계되었습니다:

- **dong_list.dart**: 행정동 및 가맹점 기본 정보
- **dong_merchant_data.dart**: 가맹점 상세 정보 및 통계
- **dashboard_data.dart**: 대시보드 데이터 모델

## 🔒 보안 고려사항

- 환경 변수를 통한 데이터베이스 연결 정보 관리
- SQL Injection 방지를 위한 SQLAlchemy ORM 사용
- CORS 설정을 통한 도메인 제한 (현재는 개발용으로 모든 도메인 허용)

## 🚀 배포 가이드

### Docker를 사용한 배포 (예시)
```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "run.py"]
```

### 환경 변수 설정
운영 환경에서는 다음 환경 변수들을 설정해야 합니다:
- `DATABASE_URL`
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `MYSQL_PASSWORD`

## 📝 개발 참고사항

- 새로운 엔드포인트 추가 시 `main.py`에 라우터 추가
- 새로운 데이터 모델 추가 시 `database.py`와 `models.py` 모두 수정
- 데이터베이스 스키마 변경 시 마이그레이션 스크립트 작성 권장
- API 문서는 FastAPI의 자동 생성 기능 활용 (`/docs` 경로)