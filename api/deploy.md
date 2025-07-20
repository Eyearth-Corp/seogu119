# AWS Elastic Beanstalk 배포 가이드

## 🚀 배포 준비

### 1. EB CLI 설치
```bash
pip install awsebcli
```

### 2. AWS 자격 증명 설정
```bash
aws configure
# AWS Access Key ID: AKIA4YJ67FJATNCBVHVG
# AWS Secret Access Key: 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
# Default region: ap-northeast-2
```

## 📦 배포 과정

### 1. EB 애플리케이션 초기화
```bash
cd api
eb init
```

설정 옵션:
- Region: `ap-northeast-2` (Asia Pacific Seoul)
- Application Name: `seogu119-api`
- Platform: `Python 3.9`
- SSH 키페어: 선택사항

### 2. EB 환경 생성
```bash
eb create seogu119-api-prod
```

### 3. 배포
```bash
eb deploy
```

### 4. 애플리케이션 열기
```bash
eb open
```

## ⚙️ 배포된 파일들

### Procfile
- FastAPI 서버 실행 명령어 정의

### .ebextensions/
- **01_python.config**: Python/WSGI 설정
- **02_healthcheck.config**: 헬스체크 설정
- **03_environment.config**: 환경 변수 설정
- **04_timezone.config**: 시간대를 서울로 설정

### .platform/hooks/
- **prebuild/**: 빌드 전 실행될 스크립트
- **postdeploy/**: 배포 후 실행될 스크립트 (DB 테이블 생성)

## 🔧 환경 설정

### 자동 환경 감지
`config.py`에서 호스트명을 기반으로 자동으로 다음 중 선택:
- **로컬 환경**: MySQL (127.0.0.1:23307)
- **운영 환경**: AWS RDS

### AWS RDS 연결
- 호스트: `gbmf.cluster-ccpekrtljkcw.ap-northeast-2.rds.amazonaws.com`
- 포트: `3306`
- 사용자: `admin`
- 데이터베이스: `seogu119`

## 📊 모니터링

### EB 환경 상태 확인
```bash
eb status
eb health
```

### 로그 확인
```bash
eb logs
eb logs --all
```

### 환경 변수 확인
```bash
eb printenv
```

## 🔄 업데이트 배포

코드 변경 후:
```bash
eb deploy
```

## 🛠️ 문제 해결

### 1. 데이터베이스 연결 실패
- RDS 보안 그룹에서 EB 환경의 보안 그룹 허용 확인
- 데이터베이스 엔드포인트 및 자격 증명 확인

### 2. 애플리케이션 시작 실패
```bash
eb logs
```
로그를 확인하여 오류 원인 파악

### 3. 헬스체크 실패
- `/` 엔드포인트가 정상 응답하는지 확인
- 타임아웃 설정 조정

## 🔒 보안 설정

### 환경 변수 설정 (필요시)
```bash
eb setenv DATABASE_URL=mysql+pymysql://admin:password@host:port/database
eb setenv AWS_DEFAULT_REGION=ap-northeast-2
```

### HTTPS 설정
EB 환경에서 Load Balancer에 SSL 인증서 추가

## 💰 비용 최적화

### 개발환경용 인스턴스
- Instance Type: `t3.micro` (프리티어)
- Load Balancer: Single Instance

### 운영환경용 설정
- Instance Type: `t3.small` 이상
- Load Balancer: Application Load Balancer
- Auto Scaling 설정

## 📱 API 엔드포인트

배포 후 사용 가능한 주요 엔드포인트:
```
GET  /{eb-environment-url}/
GET  /{eb-environment-url}/docs
GET  /{eb-environment-url}/api/dates
GET  /{eb-environment-url}/api/dashboard/{date}
GET  /{eb-environment-url}/api/statistics/{date}
```

## 🔄 롤백

이전 버전으로 롤백:
```bash
eb deploy --version-number {version-number}
```

버전 목록 확인:
```bash
eb appversion
```