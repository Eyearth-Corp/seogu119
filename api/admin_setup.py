from datetime import datetime
from sqlalchemy.orm import Session
from database import SessionLocal, Admin
from auth import get_password_hash

def create_initial_admin():
    """초기 관리자 계정 생성"""
    db = SessionLocal()
    try:
        # 기존 관리자 확인
        existing_admin = db.query(Admin).filter(Admin.username == "admin").first()
        if existing_admin:
            print("Admin user already exists")
            return
        
        # 초기 관리자 생성
        hashed_password = get_password_hash("seogu119!#")
        admin = Admin(
            username="admin",
            hashed_password=hashed_password,
            is_active=True,
            created_at=datetime.now()
        )
        
        db.add(admin)
        db.commit()
        db.refresh(admin)
        
        print(f"Initial admin created successfully - ID: {admin.id}")
        
    except Exception as e:
        db.rollback()
        print(f"Error creating admin: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    create_initial_admin()