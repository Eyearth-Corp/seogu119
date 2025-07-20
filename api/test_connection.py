#!/usr/bin/env python3
"""
데이터베이스 연결 테스트 스크립트
"""

from config import get_mysql_config, get_database_url
from database import engine, SessionLocal
import socket

def test_connection():
    print("🔍 서구119 API 데이터베이스 연결 테스트")
    print("=" * 50)
    
    # 현재 환경 확인
    hostname = socket.gethostname()
    print(f"현재 호스트명: {hostname}")
    
    # 설정 확인
    config = get_mysql_config()
    print(f"사용 중인 설정: {'Local' if 'Local' in config.__name__ else 'Production'}")
    print(f"호스트: {config.HOST}:{config.PORT}")
    print(f"사용자: {config.USER}")
    print(f"데이터베이스: {config.DATABASE_PRODUCT}")
    
    # 데이터베이스 URL 확인
    db_url = get_database_url()
    print(f"연결 URL: {db_url.replace(config.PASSWORD, '****')}")
    print()
    
    try:
        # 연결 테스트
        print("⏳ 데이터베이스 연결 중...")
        db = SessionLocal()
        
        # 간단한 쿼리 실행
        result = db.execute("SELECT 1 as test").fetchone()
        
        if result and result[0] == 1:
            print("✅ 데이터베이스 연결 성공!")
            
            # 테이블 존재 확인
            tables_query = """
            SELECT TABLE_NAME 
            FROM INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_SCHEMA = %s
            """
            tables = db.execute(tables_query, (config.DATABASE_PRODUCT,)).fetchall()
            
            if tables:
                print(f"\n📋 기존 테이블 목록 ({len(tables)}개):")
                for table in tables:
                    print(f"  - {table[0]}")
            else:
                print("\n📋 테이블이 없습니다. 첫 실행시 자동으로 생성됩니다.")
        else:
            print("❌ 연결 테스트 실패")
            
        db.close()
        
    except Exception as e:
        print(f"❌ 연결 실패: {str(e)}")
        print("\n🔧 확인사항:")
        print("1. MySQL 서버가 실행 중인지 확인")
        print("2. 네트워크 연결 확인")
        print("3. 데이터베이스 사용자 권한 확인")
        print("4. 방화벽 설정 확인")

if __name__ == "__main__":
    test_connection()