# Elastic Beanstalk용 애플리케이션 엔트리 포인트
from main import app

# EB는 기본적으로 'application' 변수를 찾습니다
application = app

if __name__ == "__main__":
    application.run()