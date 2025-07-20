from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any
from datetime import datetime

from database import get_db, create_tables, DataCollection, Dong, Merchant, MerchantDetail, DashboardSummary, CategoryDistribution, AreaDetail, DongInfo
from models import (
    BaseResponse, 
    DataCollectionResponse,
    DongResponse,
    MerchantResponse,
    MerchantDetailResponse,
    MerchantDetailCreate,
    MerchantDetailUpdate,
    DashboardSummaryResponse,
    CategoryDistributionResponse,
    AreaDetailResponse,
    DongInfoResponse,
    CompleteDashboardResponse,
    DongMerchantStatusResponse,
    StatisticsResponse
)
from admin_api import router as admin_router

app = FastAPI(
    title="서구 골목 API",
    description="서구 골목 가맹점 정보 관리 API",
    version="1.0.0"
)

# 관리자 API 라우터 등록
app.include_router(admin_router)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Flutter 웹 앱에서 접근 허용
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 앱 시작시 테이블 생성
@app.on_event("startup")
async def startup_event():
    create_tables()

# Health Check
@app.get("/", response_model=BaseResponse)
async def root():
    return BaseResponse(
        success=True,
        message="서구 골목 API 서버가 정상 동작중입니다.",
        data={"version": "1.0.0"}
    )

# 1. 데이터 수집일 목록 조회
@app.get("/api/dates", response_model=BaseResponse)
async def get_available_dates(db: Session = Depends(get_db)):
    try:
        collections = db.query(DataCollection).order_by(DataCollection.date.desc()).all()
        return BaseResponse(
            success=True,
            message="데이터 수집일 목록 조회 성공",
            data=[DataCollectionResponse.from_orm(collection) for collection in collections]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 2. 특정 날짜의 전체 대시보드 데이터 조회
@app.get("/api/dashboard/{date}", response_model=BaseResponse)
async def get_dashboard_data(date: str, db: Session = Depends(get_db)):
    try:
        # 데이터 수집 정보 조회
        collection = db.query(DataCollection).filter(DataCollection.date == date).first()
        if not collection:
            raise HTTPException(status_code=404, detail="해당 날짜의 데이터가 존재하지 않습니다.")
        
        # 요약 정보 조회
        summary = db.query(DashboardSummary).filter(DashboardSummary.date == date).first()
        
        # 카테고리별 분포 조회
        categories = db.query(CategoryDistribution).filter(CategoryDistribution.date == date).all()
        stores_by_category = {cat.category: cat.count for cat in categories}
        
        # 지역 상세 정보 조회
        areas = db.query(AreaDetail).filter(AreaDetail.date == date).all()
        
        # 동별 정보 조회
        dong_infos = db.query(DongInfo).filter(DongInfo.date == date).all()
        areas_by_dong = {info.dong_name: DongInfoResponse.from_orm(info) for info in dong_infos}
        
        dashboard_data = CompleteDashboardResponse(
            collection_date=collection.date,
            phase=collection.phase,
            title=collection.title,
            total_areas=collection.total_areas,
            total_stores=collection.total_stores,
            summary=DashboardSummaryResponse.from_orm(summary) if summary else DashboardSummaryResponse(areas=0, stores=0, completion_rate=0.0),
            stores_by_category=stores_by_category,
            on_nuri_card_rate=collection.on_nuri_card_rate,
            area_details=[AreaDetailResponse.from_orm(area) for area in areas],
            areas_by_dong=areas_by_dong
        )
        
        return BaseResponse(
            success=True,
            message="대시보드 데이터 조회 성공",
            data=dashboard_data
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 3. 특정 날짜의 동 목록 조회
@app.get("/api/dongs/{date}", response_model=BaseResponse)
async def get_dongs_by_date(date: str, db: Session = Depends(get_db)):
    try:
        dongs = db.query(Dong).filter(Dong.date == date).all()
        return BaseResponse(
            success=True,
            message="동 목록 조회 성공",
            data=[DongResponse.from_orm(dong) for dong in dongs]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 4. 특정 날짜의 특정 동의 가맹점 목록 조회
@app.get("/api/merchants/{date}/{dong_id}", response_model=BaseResponse)
async def get_merchants_by_dong(date: str, dong_id: int, db: Session = Depends(get_db)):
    try:
        merchants = db.query(Merchant).filter(
            Merchant.date == date, 
            Merchant.dong_id == dong_id
        ).all()
        return BaseResponse(
            success=True,
            message="가맹점 목록 조회 성공",
            data=[MerchantResponse.from_orm(merchant) for merchant in merchants]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 5. 특정 날짜의 가맹점 상세 정보 조회 (페이지네이션)
@app.get("/api/merchant-details/{date}", response_model=BaseResponse)
async def get_merchant_details(
    date: str,
    dong_name: Optional[str] = Query(None, description="동 이름으로 필터링"),
    category: Optional[str] = Query(None, description="카테고리로 필터링"),
    status: Optional[str] = Query(None, description="상태로 필터링"),
    page: int = Query(1, ge=1, description="페이지 번호"),
    limit: int = Query(50, ge=1, le=500, description="페이지당 항목 수"),
    db: Session = Depends(get_db)
):
    try:
        query = db.query(MerchantDetail).filter(MerchantDetail.date == date)
        
        if dong_name:
            query = query.filter(MerchantDetail.dong_name == dong_name)
        if category:
            query = query.filter(MerchantDetail.category == category)
        if status:
            query = query.filter(MerchantDetail.status == status)
        
        total = query.count()
        merchants = query.offset((page - 1) * limit).limit(limit).all()
        
        return BaseResponse(
            success=True,
            message="가맹점 상세 정보 조회 성공",
            data={
                "merchants": [MerchantDetailResponse.from_orm(merchant) for merchant in merchants],
                "pagination": {
                    "current_page": page,
                    "per_page": limit,
                    "total_items": total,
                    "total_pages": (total + limit - 1) // limit
                }
            }
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 6. 특정 날짜의 동별 가맹점 현황 조회
@app.get("/api/dong-status/{date}/{dong_name}", response_model=BaseResponse)
async def get_dong_merchant_status(date: str, dong_name: str, db: Session = Depends(get_db)):
    try:
        merchants = db.query(MerchantDetail).filter(
            MerchantDetail.date == date,
            MerchantDetail.dong_name == dong_name
        ).all()
        
        if not merchants:
            return BaseResponse(
                success=True,
                message="해당 동의 가맹점 데이터가 없습니다.",
                data=None
            )
        
        total_merchants = len(merchants)
        operating_merchants = len([m for m in merchants if m.status.value == "영업중"])
        on_nuri_card_merchants = len([m for m in merchants if m.has_on_nuri_card])
        total_revenue = sum(m.monthly_revenue for m in merchants)
        average_revenue = total_revenue / total_merchants if total_merchants > 0 else 0
        
        # 카테고리별 분포
        category_dist = {}
        for merchant in merchants:
            category_dist[merchant.category] = category_dist.get(merchant.category, 0) + 1
        
        # 상태별 분포
        status_dist = {}
        for merchant in merchants:
            status_val = merchant.status.value
            status_dist[status_val] = status_dist.get(status_val, 0) + 1
        
        # 규모별 분포
        scale_dist = {}
        for merchant in merchants:
            scale_val = merchant.scale.value
            scale_dist[scale_val] = scale_dist.get(scale_val, 0) + 1
        
        status_data = DongMerchantStatusResponse(
            dong_name=dong_name,
            total_merchants=total_merchants,
            operating_merchants=operating_merchants,
            on_nuri_card_merchants=on_nuri_card_merchants,
            average_revenue=average_revenue,
            operating_rate=operating_merchants / total_merchants * 100 if total_merchants > 0 else 0,
            on_nuri_card_rate=on_nuri_card_merchants / total_merchants * 100 if total_merchants > 0 else 0,
            category_distribution=category_dist,
            status_distribution=status_dist,
            scale_distribution=scale_dist,
            merchants=[MerchantDetailResponse.from_orm(merchant) for merchant in merchants]
        )
        
        return BaseResponse(
            success=True,
            message="동별 가맹점 현황 조회 성공",
            data=status_data
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 7. 가맹점 상세 정보 생성
@app.post("/api/merchant-details/{date}", response_model=BaseResponse)
async def create_merchant_detail(
    date: str,
    merchant_data: MerchantDetailCreate,
    db: Session = Depends(get_db)
):
    try:
        # 날짜가 존재하는지 확인
        collection = db.query(DataCollection).filter(DataCollection.date == date).first()
        if not collection:
            raise HTTPException(status_code=404, detail="해당 날짜의 데이터 수집 정보가 없습니다.")
        
        new_merchant = MerchantDetail(
            date=date,
            **merchant_data.dict()
        )
        
        db.add(new_merchant)
        db.commit()
        db.refresh(new_merchant)
        
        return BaseResponse(
            success=True,
            message="가맹점 정보 생성 성공",
            data=MerchantDetailResponse.from_orm(new_merchant)
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

# 8. 가맹점 상세 정보 수정
@app.put("/api/merchant-details/{date}/{merchant_id}", response_model=BaseResponse)
async def update_merchant_detail(
    date: str,
    merchant_id: int,
    merchant_data: MerchantDetailUpdate,
    db: Session = Depends(get_db)
):
    try:
        merchant = db.query(MerchantDetail).filter(
            MerchantDetail.date == date,
            MerchantDetail.id == merchant_id
        ).first()
        
        if not merchant:
            raise HTTPException(status_code=404, detail="해당 가맹점을 찾을 수 없습니다.")
        
        # 수정할 필드만 업데이트
        update_data = merchant_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(merchant, field, value)
        
        db.commit()
        db.refresh(merchant)
        
        return BaseResponse(
            success=True,
            message="가맹점 정보 수정 성공",
            data=MerchantDetailResponse.from_orm(merchant)
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

# 9. 가맹점 상세 정보 삭제
@app.delete("/api/merchant-details/{date}/{merchant_id}", response_model=BaseResponse)
async def delete_merchant_detail(date: str, merchant_id: int, db: Session = Depends(get_db)):
    try:
        merchant = db.query(MerchantDetail).filter(
            MerchantDetail.date == date,
            MerchantDetail.id == merchant_id
        ).first()
        
        if not merchant:
            raise HTTPException(status_code=404, detail="해당 가맹점을 찾을 수 없습니다.")
        
        db.delete(merchant)
        db.commit()
        
        return BaseResponse(
            success=True,
            message="가맹점 정보 삭제 성공",
            data=None
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

# 10. 전체 통계 조회
@app.get("/api/statistics/{date}", response_model=BaseResponse)
async def get_statistics(date: str, db: Session = Depends(get_db)):
    try:
        merchants = db.query(MerchantDetail).filter(MerchantDetail.date == date).all()
        
        if not merchants:
            raise HTTPException(status_code=404, detail="해당 날짜의 데이터가 없습니다.")
        
        total_merchants = len(merchants)
        operating_merchants = len([m for m in merchants if m.status.value == "영업중"])
        closed_merchants = total_merchants - operating_merchants
        total_revenue = sum(m.monthly_revenue for m in merchants)
        average_revenue = total_revenue / total_merchants if total_merchants > 0 else 0
        on_nuri_card_merchants = len([m for m in merchants if m.has_on_nuri_card])
        
        # 카테고리별 통계
        category_stats = {}
        for merchant in merchants:
            category_stats[merchant.category] = category_stats.get(merchant.category, 0) + 1
        
        # 규모별 통계
        scale_stats = {}
        for merchant in merchants:
            scale_val = merchant.scale.value
            scale_stats[scale_val] = scale_stats.get(scale_val, 0) + 1
        
        # 동별 통계
        dong_stats = {}
        for merchant in merchants:
            dong_stats[merchant.dong_name] = dong_stats.get(merchant.dong_name, 0) + 1
        
        statistics = StatisticsResponse(
            total_merchants=total_merchants,
            operating_merchants=operating_merchants,
            closed_merchants=closed_merchants,
            operating_rate=operating_merchants / total_merchants * 100 if total_merchants > 0 else 0,
            total_revenue=total_revenue,
            average_revenue=average_revenue,
            on_nuri_card_merchants=on_nuri_card_merchants,
            on_nuri_card_rate=on_nuri_card_merchants / total_merchants * 100 if total_merchants > 0 else 0,
            category_stats=category_stats,
            scale_stats=scale_stats,
            dong_stats=dong_stats
        )
        
        return BaseResponse(
            success=True,
            message="통계 조회 성공",
            data=statistics
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)