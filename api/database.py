import os
from sqlalchemy import create_engine, Column, String, Integer, Float, DateTime, Boolean, Enum, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import enum
from config import get_database_url

load_dotenv()

# 환경에 따른 데이터베이스 URL 자동 선택
DATABASE_URL = os.getenv("DATABASE_URL", get_database_url())

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 가맹점 상태 enum
class MerchantStatus(enum.Enum):
    operating = "영업중"
    closed = "휴업"
    relocated = "이전"
    new_open = "신규개점"

# 가맹점 규모 enum
class MerchantScale(enum.Enum):
    small = "소형"
    medium = "중형" 
    large = "대형"

# 데이터 수집일 테이블 (Primary Key)
class DataCollection(Base):
    __tablename__ = "data_collections"
    
    date = Column(String(10), primary_key=True)  # 2025-06-20 형식
    phase = Column(String(10), nullable=False)   # 6차
    title = Column(String(200), nullable=False)  # 제목
    total_areas = Column(Integer, nullable=False)
    total_stores = Column(Integer, nullable=False)
    on_nuri_card_rate = Column(Float, nullable=False)
    created_at = Column(DateTime, nullable=False)

# 동(행정구역) 테이블
class Dong(Base):
    __tablename__ = "dongs"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(String(10), nullable=False)  # 외래키로 data_collections.date 참조
    name = Column(String(50), nullable=False)
    color = Column(String(7), nullable=False)  # 색상코드 #FFFFFF
    area_left = Column(Float, nullable=False)
    area_top = Column(Float, nullable=False)
    area_width = Column(Float, nullable=False)
    area_height = Column(Float, nullable=False)
    area_asset = Column(String(200), nullable=False)
    dong_tag_left = Column(Float, nullable=False)
    dong_tag_top = Column(Float, nullable=False)
    dong_tag_width = Column(Float, nullable=False)
    dong_tag_height = Column(Float, nullable=False)
    dong_tag_asset = Column(String(200), nullable=False)

# 가맹점 정보 테이블
class Merchant(Base):
    __tablename__ = "merchants"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(String(10), nullable=False)  # 외래키
    dong_id = Column(Integer, nullable=False)  # dong 테이블의 id 참조
    merchant_id = Column(Integer, nullable=False)  # 원본 데이터의 id
    name = Column(String(100), nullable=False)
    x = Column(Float, nullable=False)
    y = Column(Float, nullable=False)

# 상세 가맹점 정보 테이블 (dong_merchant_data.dart 기반)
class MerchantDetail(Base):
    __tablename__ = "merchant_details"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(String(10), nullable=False)  # 외래키
    dong_name = Column(String(50), nullable=False)
    merchant_id = Column(String(50), nullable=False)  # 동천동_001 형식
    name = Column(String(100), nullable=False)
    category = Column(String(50), nullable=False)
    status = Column(Enum(MerchantStatus), nullable=False)
    scale = Column(Enum(MerchantScale), nullable=False)
    employee_count = Column(Integer, nullable=False)
    monthly_revenue = Column(Float, nullable=False)  # 월 매출 (만원)
    has_on_nuri_card = Column(Boolean, nullable=False)
    registered_date = Column(DateTime, nullable=False)
    address = Column(String(200), nullable=False)
    owner_name = Column(String(50), nullable=False)
    phone_number = Column(String(20), nullable=False)

# 대시보드 요약 정보 테이블
class DashboardSummary(Base):
    __tablename__ = "dashboard_summaries"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(String(10), nullable=False)  # 외래키
    areas = Column(Integer, nullable=False)
    stores = Column(Integer, nullable=False)
    completion_rate = Column(Float, nullable=False)

# 카테고리별 가맹점 수 테이블
class CategoryDistribution(Base):
    __tablename__ = "category_distributions"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(String(10), nullable=False)  # 외래키
    category = Column(String(50), nullable=False)
    count = Column(Integer, nullable=False)

# 지역 상세 정보 테이블
class AreaDetail(Base):
    __tablename__ = "area_details"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(String(10), nullable=False)  # 외래키
    name = Column(String(100), nullable=False)
    stores = Column(Integer, nullable=False)
    category = Column(String(50), nullable=False)

# 동별 정보 테이블
class DongInfo(Base):
    __tablename__ = "dong_infos"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(String(10), nullable=False)  # 외래키
    dong_name = Column(String(50), nullable=False)
    areas = Column(Integer, nullable=False)
    stores = Column(Integer, nullable=False)

# 관리자 테이블
class Admin(Base):
    __tablename__ = "admins"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, nullable=False)
    last_login = Column(DateTime, nullable=True)

def create_tables():
    Base.metadata.create_all(bind=engine)