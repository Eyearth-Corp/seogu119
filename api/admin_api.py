from datetime import datetime, timedelta
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session
from sqlalchemy import func

from database import get_db, Admin, MerchantDetail, Merchant, DataCollection, Dong, DongInfo
from models import (
    Token, AdminLoginRequest, AdminResponse, AdminCreate, AdminUpdate, PasswordChangeRequest,
    BaseResponse, MerchantDetailResponse, MerchantDetailCreate, MerchantDetailUpdate,
    DataCollectionResponse, DongResponse, StatisticsResponse
)
from auth import (
    authenticate_admin, create_access_token, get_current_active_admin,
    get_password_hash, ACCESS_TOKEN_EXPIRE_MINUTES
)

router = APIRouter(prefix="/admin", tags=["admin"])

# 로그인
@router.post("/login", response_model=Token)
async def admin_login(
    admin_request: AdminLoginRequest,
    db: Session = Depends(get_db)
):
    admin = authenticate_admin(db, admin_request.username, admin_request.password)
    if not admin:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="아이디 또는 비밀번호가 올바르지 않습니다",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # 마지막 로그인 시간 업데이트
    admin.last_login = datetime.now()
    db.commit()
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": admin.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

# 현재 관리자 정보
@router.get("/me", response_model=AdminResponse)
async def get_current_admin_info(
    current_admin: Admin = Depends(get_current_active_admin)
):
    return current_admin

# 대시보드 통계
@router.get("/dashboard/stats", response_model=StatisticsResponse)
async def get_dashboard_stats(
    date: str = None,
    current_admin: Admin = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    # 최신 데이터 날짜 가져오기 (date가 없으면)
    if not date:
        latest_date = db.query(func.max(DataCollection.date)).scalar()
        if not latest_date:
            raise HTTPException(status_code=404, detail="데이터가 없습니다")
        date = latest_date
    
    # 기본 통계
    total_merchants = db.query(MerchantDetail).filter(MerchantDetail.date == date).count()
    operating_merchants = db.query(MerchantDetail).filter(
        MerchantDetail.date == date,
        MerchantDetail.status == "영업중"
    ).count()
    closed_merchants = total_merchants - operating_merchants
    operating_rate = (operating_merchants / total_merchants * 100) if total_merchants > 0 else 0
    
    # 매출 통계
    revenue_result = db.query(func.sum(MerchantDetail.monthly_revenue)).filter(
        MerchantDetail.date == date
    ).scalar()
    total_revenue = revenue_result or 0
    average_revenue = (total_revenue / total_merchants) if total_merchants > 0 else 0
    
    # 온누리상품권 통계
    on_nuri_card_merchants = db.query(MerchantDetail).filter(
        MerchantDetail.date == date,
        MerchantDetail.has_on_nuri_card == True
    ).count()
    on_nuri_card_rate = (on_nuri_card_merchants / total_merchants * 100) if total_merchants > 0 else 0
    
    # 카테고리별 통계
    category_stats = {}
    category_results = db.query(
        MerchantDetail.category,
        func.count(MerchantDetail.id)
    ).filter(
        MerchantDetail.date == date
    ).group_by(MerchantDetail.category).all()
    
    for category, count in category_results:
        category_stats[category] = count
    
    # 규모별 통계
    scale_stats = {}
    scale_results = db.query(
        MerchantDetail.scale,
        func.count(MerchantDetail.id)
    ).filter(
        MerchantDetail.date == date
    ).group_by(MerchantDetail.scale).all()
    
    for scale, count in scale_results:
        scale_stats[scale.value] = count
    
    # 동별 통계
    dong_stats = {}
    dong_results = db.query(
        MerchantDetail.dong_name,
        func.count(MerchantDetail.id)
    ).filter(
        MerchantDetail.date == date
    ).group_by(MerchantDetail.dong_name).all()
    
    for dong, count in dong_results:
        dong_stats[dong] = count
    
    return StatisticsResponse(
        total_merchants=total_merchants,
        operating_merchants=operating_merchants,
        closed_merchants=closed_merchants,
        operating_rate=round(operating_rate, 2),
        total_revenue=total_revenue,
        average_revenue=round(average_revenue, 2),
        on_nuri_card_merchants=on_nuri_card_merchants,
        on_nuri_card_rate=round(on_nuri_card_rate, 2),
        category_stats=category_stats,
        scale_stats=scale_stats,
        dong_stats=dong_stats
    )

# 가맹점 목록 조회 (페이징, 필터링)
@router.get("/merchants", response_model=List[MerchantDetailResponse])
async def get_merchants(
    date: str = None,
    dong_name: str = None,
    category: str = None,
    status: str = None,
    skip: int = 0,
    limit: int = 100,
    current_admin: Admin = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    # 최신 데이터 날짜 가져오기
    if not date:
        latest_date = db.query(func.max(DataCollection.date)).scalar()
        if not latest_date:
            raise HTTPException(status_code=404, detail="데이터가 없습니다")
        date = latest_date
    
    query = db.query(MerchantDetail).filter(MerchantDetail.date == date)
    
    if dong_name:
        query = query.filter(MerchantDetail.dong_name == dong_name)
    if category:
        query = query.filter(MerchantDetail.category == category)
    if status:
        query = query.filter(MerchantDetail.status == status)
    
    merchants = query.offset(skip).limit(limit).all()
    return merchants

# 가맹점 상세 정보
@router.get("/merchants/{merchant_id}", response_model=MerchantDetailResponse)
async def get_merchant_detail(
    merchant_id: int,
    current_admin: Admin = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    merchant = db.query(MerchantDetail).filter(MerchantDetail.id == merchant_id).first()
    if not merchant:
        raise HTTPException(status_code=404, detail="가맹점을 찾을 수 없습니다")
    return merchant

# 가맹점 정보 수정
@router.put("/merchants/{merchant_id}", response_model=BaseResponse)
async def update_merchant(
    merchant_id: int,
    merchant_update: MerchantDetailUpdate,
    current_admin: Admin = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    merchant = db.query(MerchantDetail).filter(MerchantDetail.id == merchant_id).first()
    if not merchant:
        raise HTTPException(status_code=404, detail="가맹점을 찾을 수 없습니다")
    
    # 업데이트할 필드만 적용
    update_data = merchant_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(merchant, field, value)
    
    try:
        db.commit()
        return BaseResponse(success=True, message="가맹점 정보가 수정되었습니다")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail="수정 중 오류가 발생했습니다")

# 가맹점 삭제
@router.delete("/merchants/{merchant_id}", response_model=BaseResponse)
async def delete_merchant(
    merchant_id: int,
    current_admin: Admin = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    merchant = db.query(MerchantDetail).filter(MerchantDetail.id == merchant_id).first()
    if not merchant:
        raise HTTPException(status_code=404, detail="가맹점을 찾을 수 없습니다")
    
    try:
        db.delete(merchant)
        db.commit()
        return BaseResponse(success=True, message="가맹점이 삭제되었습니다")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail="삭제 중 오류가 발생했습니다")

# 데이터 컬렉션 목록
@router.get("/data-collections", response_model=List[DataCollectionResponse])
async def get_data_collections(
    current_admin: Admin = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    collections = db.query(DataCollection).order_by(DataCollection.date.desc()).all()
    return collections

# 동별 가맹점 현황
@router.get("/dong/{dong_name}/merchants", response_model=List[MerchantDetailResponse])
async def get_dong_merchants(
    dong_name: str,
    date: str = None,
    current_admin: Admin = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    if not date:
        latest_date = db.query(func.max(DataCollection.date)).scalar()
        if not latest_date:
            raise HTTPException(status_code=404, detail="데이터가 없습니다")
        date = latest_date
    
    merchants = db.query(MerchantDetail).filter(
        MerchantDetail.date == date,
        MerchantDetail.dong_name == dong_name
    ).all()
    
    return merchants

# 관리자 비밀번호 변경
@router.put("/change-password", response_model=BaseResponse)
async def change_password(
    password_data: PasswordChangeRequest,
    current_admin: Admin = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    from auth import verify_password
    
    if not verify_password(password_data.current_password, current_admin.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="현재 비밀번호가 올바르지 않습니다"
        )
    
    current_admin.hashed_password = get_password_hash(password_data.new_password)
    try:
        db.commit()
        return BaseResponse(success=True, message="비밀번호가 변경되었습니다")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail="비밀번호 변경 중 오류가 발생했습니다")

# 로그아웃 (클라이언트에서 토큰 삭제하도록 안내)
@router.post("/logout", response_model=BaseResponse)
async def admin_logout():
    return BaseResponse(
        success=True, 
        message="로그아웃되었습니다. 토큰을 삭제해주세요."
    )