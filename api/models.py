from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum

# 가맹점 상태 enum
class MerchantStatusEnum(str, Enum):
    operating = "영업중"
    closed = "휴업"
    relocated = "이전"
    new_open = "신규개점"

# 가맹점 규모 enum
class MerchantScaleEnum(str, Enum):
    small = "소형"
    medium = "중형"
    large = "대형"

# 기본 응답 모델
class BaseResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Any] = None

# 데이터 수집일 모델
class DataCollectionResponse(BaseModel):
    date: str
    phase: str
    title: str
    total_areas: int
    total_stores: int
    on_nuri_card_rate: float
    created_at: datetime

    class Config:
        from_attributes = True

# 동 정보 모델
class DongResponse(BaseModel):
    id: int
    name: str
    color: str
    area_left: float
    area_top: float
    area_width: float
    area_height: float
    area_asset: str
    dong_tag_left: float
    dong_tag_top: float
    dong_tag_width: float
    dong_tag_height: float
    dong_tag_asset: str

    class Config:
        from_attributes = True

# 가맹점 기본 정보 모델
class MerchantResponse(BaseModel):
    id: int
    merchant_id: int
    name: str
    x: float
    y: float

    class Config:
        from_attributes = True

# 가맹점 상세 정보 모델
class MerchantDetailResponse(BaseModel):
    id: int
    dong_name: str
    merchant_id: str
    name: str
    category: str
    status: MerchantStatusEnum
    scale: MerchantScaleEnum
    employee_count: int
    monthly_revenue: float
    has_on_nuri_card: bool
    registered_date: datetime
    address: str
    owner_name: str
    phone_number: str

    class Config:
        from_attributes = True

# 대시보드 요약 정보 모델
class DashboardSummaryResponse(BaseModel):
    areas: int
    stores: int
    completion_rate: float

    class Config:
        from_attributes = True

# 카테고리 분포 모델
class CategoryDistributionResponse(BaseModel):
    category: str
    count: int

    class Config:
        from_attributes = True

# 지역 상세 정보 모델
class AreaDetailResponse(BaseModel):
    name: str
    stores: int
    category: str

    class Config:
        from_attributes = True

# 동별 정보 모델
class DongInfoResponse(BaseModel):
    dong_name: str
    areas: int
    stores: int

    class Config:
        from_attributes = True

# 통합 대시보드 데이터 모델
class CompleteDashboardResponse(BaseModel):
    collection_date: str
    phase: str
    title: str
    total_areas: int
    total_stores: int
    summary: DashboardSummaryResponse
    stores_by_category: Dict[str, int]
    on_nuri_card_rate: float
    area_details: List[AreaDetailResponse]
    areas_by_dong: Dict[str, DongInfoResponse]

# 가맹점 생성 요청 모델
class MerchantDetailCreate(BaseModel):
    dong_name: str
    merchant_id: str
    name: str
    category: str
    status: MerchantStatusEnum
    scale: MerchantScaleEnum
    employee_count: int
    monthly_revenue: float
    has_on_nuri_card: bool
    registered_date: datetime
    address: str
    owner_name: str
    phone_number: str

# 가맹점 업데이트 요청 모델
class MerchantDetailUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    status: Optional[MerchantStatusEnum] = None
    scale: Optional[MerchantScaleEnum] = None
    employee_count: Optional[int] = None
    monthly_revenue: Optional[float] = None
    has_on_nuri_card: Optional[bool] = None
    address: Optional[str] = None
    owner_name: Optional[str] = None
    phone_number: Optional[str] = None

# 동별 가맹점 현황 모델
class DongMerchantStatusResponse(BaseModel):
    dong_name: str
    total_merchants: int
    operating_merchants: int
    on_nuri_card_merchants: int
    average_revenue: float
    operating_rate: float
    on_nuri_card_rate: float
    category_distribution: Dict[str, int]
    status_distribution: Dict[str, int]
    scale_distribution: Dict[str, int]
    merchants: List[MerchantDetailResponse]

# 통계 모델
class StatisticsResponse(BaseModel):
    total_merchants: int
    operating_merchants: int
    closed_merchants: int
    operating_rate: float
    total_revenue: float
    average_revenue: float
    on_nuri_card_merchants: int
    on_nuri_card_rate: float
    category_stats: Dict[str, int]
    scale_stats: Dict[str, int]
    dong_stats: Dict[str, int]

# JWT 토큰 모델
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

# 관리자 로그인 요청 모델
class AdminLoginRequest(BaseModel):
    username: str
    password: str

# 관리자 응답 모델
class AdminResponse(BaseModel):
    id: int
    username: str
    is_active: bool
    created_at: datetime
    last_login: Optional[datetime] = None

    class Config:
        from_attributes = True

# 관리자 생성 요청 모델
class AdminCreate(BaseModel):
    username: str
    password: str

# 관리자 업데이트 요청 모델  
class AdminUpdate(BaseModel):
    username: Optional[str] = None
    password: Optional[str] = None
    is_active: Optional[bool] = None

# 비밀번호 변경 요청 모델
class PasswordChangeRequest(BaseModel):
    current_password: str
    new_password: str