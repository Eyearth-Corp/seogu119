#!/usr/bin/env python3
"""
관리자 계정 생성 스크립트
"""

from datetime import datetime
from sqlalchemy.orm import Session
from database import SessionLocal, Admin, create_tables
from auth import get_password_hash

def create_admin_user():
    """기본 관리자 계정 생성"""
    
    # 테이블 생성
    create_tables()
    
    db = SessionLocal()
    try:
        # 기존 관리자 계정 확인
        existing_admin = db.query(Admin).filter(Admin.username == "admin").first()
        
        if existing_admin:
            print("⚠️  기존 admin 계정이 있습니다.")
            response = input("비밀번호를 재설정하시겠습니까? (y/N): ")
            
            if response.lower() == 'y':
                new_password = input("새 비밀번호를 입력하세요: ")
                existing_admin.hashed_password = get_password_hash(new_password)
                db.commit()
                print("✅ admin 계정 비밀번호가 재설정되었습니다.")
            else:
                print("❌ 작업이 취소되었습니다.")
            return
        
        # 새 관리자 계정 생성
        print("🔐 새 관리자 계정을 생성합니다.")
        username = input("사용자명 (기본값: admin): ").strip() or "admin"
        password = input("비밀번호 (기본값: admin123): ").strip() or "admin123"
        
        admin = Admin(
            username=username,
            hashed_password=get_password_hash(password),
            is_active=True,
            created_at=datetime.now()
        )
        
        db.add(admin)
        db.commit()
        db.refresh(admin)
        
        print(f"✅ 관리자 계정이 생성되었습니다!")
        print(f"   - 사용자명: {username}")
        print(f"   - 비밀번호: {password}")
        print(f"   - 생성일시: {admin.created_at}")
        print("\n🔗 로그인 URL: http://localhost:3000/admin")
        
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        db.rollback()
    finally:
        db.close()

def list_admin_users():
    """관리자 계정 목록 출력"""
    db = SessionLocal()
    try:
        admins = db.query(Admin).all()
        
        if not admins:
            print("📝 등록된 관리자 계정이 없습니다.")
            return
        
        print("📋 관리자 계정 목록:")
        print("-" * 50)
        for admin in admins:
            status = "✅ 활성" if admin.is_active else "❌ 비활성"
            last_login = admin.last_login.strftime("%Y-%m-%d %H:%M:%S") if admin.last_login else "없음"
            print(f"사용자명: {admin.username}")
            print(f"상태: {status}")
            print(f"생성일: {admin.created_at.strftime('%Y-%m-%d %H:%M:%S')}")
            print(f"마지막 로그인: {last_login}")
            print("-" * 50)
            
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
    finally:
        db.close()

def main():
    print("🏢 서구 골목 관리자 계정 관리")
    print("=" * 40)
    
    while True:
        print("\n선택하세요:")
        print("1. 관리자 계정 생성/수정")
        print("2. 관리자 계정 목록 보기")
        print("3. 종료")
        
        choice = input("\n입력 (1-3): ").strip()
        
        if choice == "1":
            create_admin_user()
        elif choice == "2":
            list_admin_users()
        elif choice == "3":
            print("👋 종료합니다.")
            break
        else:
            print("❌ 올바른 번호를 입력하세요.")

if __name__ == "__main__":
    main()