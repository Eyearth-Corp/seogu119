import json
import os
from datetime import datetime
from sqlalchemy.orm import Session
from database import SessionLocal, DataCollection, Dong, Merchant, MerchantDetail, DashboardSummary, CategoryDistribution, AreaDetail, DongInfo
from database import MerchantStatus, MerchantScale

def load_json_data(file_path: str):
    """JSON 파일 데이터 로드"""
    with open(file_path, 'r', encoding='utf-8') as file:
        return json.load(file)

def load_flutter_data_to_db():
    """Flutter 앱의 데이터를 DB에 로드"""
    db = SessionLocal()
    
    try:
        # assets/excel 디렉토리의 JSON 파일들 처리
        excel_dir = "../assets/excel"
        
        # 데이터 파일 매핑
        data_files = [
            {"file": "data_20241205.json", "date": "2024-12-05", "phase": "1차"},
            {"file": "data_20250331.json", "date": "2025-03-31", "phase": "2차"},
            {"file": "data_20250501.json", "date": "2025-05-01", "phase": "3차"},
            {"file": "data_20250516.json", "date": "2025-05-16", "phase": "4차"},
            {"file": "data_20250620.json", "date": "2025-06-20", "phase": "6차"},
            {"file": "data_total.json", "date": "all", "phase": "전체"},
        ]
        
        for data_file in data_files:
            file_path = os.path.join(excel_dir, data_file["file"])
            if os.path.exists(file_path):
                print(f"Processing {data_file['file']}...")
                
                # 기존 데이터 삭제
                db.query(DataCollection).filter(DataCollection.date == data_file["date"]).delete()
                db.query(DashboardSummary).filter(DashboardSummary.date == data_file["date"]).delete()
                db.query(CategoryDistribution).filter(CategoryDistribution.date == data_file["date"]).delete()
                db.query(AreaDetail).filter(AreaDetail.date == data_file["date"]).delete()
                db.query(DongInfo).filter(DongInfo.date == data_file["date"]).delete()
                
                data = load_json_data(file_path)
                
                # DataCollection 생성
                collection = DataCollection(
                    date=data_file["date"],
                    phase=data_file["phase"],
                    title=data.get("title", f"{data_file['phase']} 데이터"),
                    total_areas=data.get("totalAreas", 0),
                    total_stores=data.get("totalStores", 0),
                    on_nuri_card_rate=data.get("onNuriCardRate", 0.0),
                    created_at=datetime.now()
                )
                db.add(collection)
                
                # DashboardSummary 생성
                if "summary" in data:
                    summary = DashboardSummary(
                        date=data_file["date"],
                        areas=data["summary"].get("areas", 0),
                        stores=data["summary"].get("stores", 0),
                        completion_rate=data["summary"].get("completionRate", 0.0)
                    )
                    db.add(summary)
                
                # CategoryDistribution 생성
                if "storesByCategory" in data:
                    for category, count in data["storesByCategory"].items():
                        cat_dist = CategoryDistribution(
                            date=data_file["date"],
                            category=category,
                            count=count
                        )
                        db.add(cat_dist)
                
                # AreaDetail 생성
                if "areaDetails" in data:
                    for area in data["areaDetails"]:
                        area_detail = AreaDetail(
                            date=data_file["date"],
                            name=area.get("name", ""),
                            stores=area.get("stores", 0),
                            category=area.get("category", "")
                        )
                        db.add(area_detail)
                
                # DongInfo 생성
                if "areasByDong" in data:
                    for dong_name, info in data["areasByDong"].items():
                        dong_info = DongInfo(
                            date=data_file["date"],
                            dong_name=dong_name,
                            areas=info.get("areas", 0),
                            stores=info.get("stores", 0)
                        )
                        db.add(dong_info)
                
                db.commit()
                print(f"Successfully loaded {data_file['file']}")
        
        # Flutter의 dong_list.dart 데이터 로드
        load_dong_list_data(db)
        
        # 가상 가맹점 상세 데이터 생성
        generate_mock_merchant_details(db)
        
    except Exception as e:
        print(f"Error loading data: {e}")
        db.rollback()
    finally:
        db.close()

def load_dong_list_data(db: Session):
    """dong_list.dart의 데이터를 DB에 로드"""
    print("Loading dong_list data...")
    
    # 기존 동 데이터 삭제
    db.query(Dong).delete()
    db.query(Merchant).delete()
    
    # dong_list.dart의 데이터 (간략화된 버전)
    dong_data = [
        {
            "name": "동천동", "color": "#d15382",
            "area": {"left": 178, "top": 84, "width": 944, "height": 298},
            "area_asset": "assets/map/dong_동천.png",
            "dong_tag": {"left": 536, "top": 286, "width": 132, "height": 91},
            "dong_tag_asset": "assets/map/tag_동천.png",
            "merchants": [
                {"id": 1, "name": "하남대로가구의거리상인회", "x": 360, "y": 257},
                {"id": 2, "name": "동천동먹자골목1번가상인회", "x": 764, "y": 201},
                {"id": 3, "name": "동천동상인회", "x": 761, "y": 257},
                {"id": 4, "name": "동천동먹자골목2번가상인회", "x": 1018, "y": 139},
                {"id": 5, "name": "동천동벚꽃길상인회", "x": 1061, "y": 91},
            ]
        },
        {
            "name": "유촌동", "color": "#c38753",
            "area": {"left": 630, "top": 314, "width": 454, "height": 276},
            "area_asset": "assets/map/dong_유촌.png",
            "dong_tag": {"left": 973, "top": 345, "width": 133, "height": 90},
            "dong_tag_asset": "assets/map/tag_유촌.png",
            "merchants": [
                {"id": 6, "name": "유촌마을상인회", "x": 888, "y": 349},
                {"id": 7, "name": "버들마을상인회", "x": 794, "y": 459},
                {"id": 8, "name": "유촌동상인회", "x": 861, "y": 432},
            ]
        },
        # 더 많은 동 데이터를 추가할 수 있지만 예시로 2개만
    ]
    
    # 모든 데이터 수집일에 대해 동 데이터 생성
    dates = ["2024-12-05", "2025-03-31", "2025-05-01", "2025-05-16", "2025-06-20", "all"]
    
    for date in dates:
        dong_id = 1
        for dong in dong_data:
            # Dong 생성
            new_dong = Dong(
                date=date,
                name=dong["name"],
                color=dong["color"],
                area_left=dong["area"]["left"],
                area_top=dong["area"]["top"],
                area_width=dong["area"]["width"],
                area_height=dong["area"]["height"],
                area_asset=dong["area_asset"],
                dong_tag_left=dong["dong_tag"]["left"],
                dong_tag_top=dong["dong_tag"]["top"],
                dong_tag_width=dong["dong_tag"]["width"],
                dong_tag_height=dong["dong_tag"]["height"],
                dong_tag_asset=dong["dong_tag_asset"]
            )
            db.add(new_dong)
            db.flush()  # ID 할당을 위해
            
            # Merchant 생성
            for merchant in dong["merchants"]:
                new_merchant = Merchant(
                    date=date,
                    dong_id=new_dong.id,
                    merchant_id=merchant["id"],
                    name=merchant["name"],
                    x=merchant["x"],
                    y=merchant["y"]
                )
                db.add(new_merchant)
            
            dong_id += 1
    
    db.commit()
    print("Successfully loaded dong_list data")

def generate_mock_merchant_details(db: Session):
    """가상의 가맹점 상세 데이터 생성"""
    print("Generating mock merchant detail data...")
    
    # 기존 상세 데이터 삭제
    db.query(MerchantDetail).delete()
    
    dates = ["2024-12-05", "2025-03-31", "2025-05-01", "2025-05-16", "2025-06-20", "all"]
    dong_names = ["동천동", "유촌동", "광천동", "치평동", "상무1동", "화정1동", "농성1동", "양동", "마륵동"]
    categories = ["일반음식점", "수퍼마켓", "편의점", "학원", "병원의원", "이용뷰티", "일반주점", "여가시설", "부동산업", "가구인테리어", "생활서비스", "기타도소매"]
    owner_names = ["김철수", "이영희", "박민수", "최서연", "정도현", "강미영", "윤준호", "임수진", "조현우", "한예진"]
    
    import random
    
    for date in dates:
        merchant_count = 1
        for dong_name in dong_names:
            # 각 동별로 10-20개의 가맹점 생성
            num_merchants = random.randint(10, 20)
            
            for i in range(num_merchants):
                category = random.choice(categories)
                status = random.choice([MerchantStatus.operating, MerchantStatus.closed, MerchantStatus.relocated, MerchantStatus.new_open])
                # 영업중 비율을 높게 설정
                if random.random() < 0.8:
                    status = MerchantStatus.operating
                
                scale = random.choice([MerchantScale.small, MerchantScale.medium, MerchantScale.large])
                
                employee_count = random.randint(1, 25)
                if scale == MerchantScale.small:
                    employee_count = random.randint(1, 3)
                elif scale == MerchantScale.medium:
                    employee_count = random.randint(4, 10)
                else:
                    employee_count = random.randint(11, 25)
                
                merchant_detail = MerchantDetail(
                    date=date,
                    dong_name=dong_name,
                    merchant_id=f"{dong_name}_{merchant_count:03d}",
                    name=f"{random.choice(['맛있는', '신선한', '편리한', '건강한', '아름다운', '깔끔한'])} {category}",
                    category=category,
                    status=status,
                    scale=scale,
                    employee_count=employee_count,
                    monthly_revenue=random.uniform(50, 500),  # 50-500만원
                    has_on_nuri_card=random.choice([True, False]),
                    registered_date=datetime.now(),
                    address=f"{dong_name} {random.randint(1, 200)}번지",
                    owner_name=random.choice(owner_names),
                    phone_number=f"062-{200 + random.randint(0, 799)}-{1000 + random.randint(0, 8999)}"
                )
                
                db.add(merchant_detail)
                merchant_count += 1
    
    db.commit()
    print("Successfully generated mock merchant detail data")

if __name__ == "__main__":
    print("Starting data loading process...")
    load_flutter_data_to_db()
    print("Data loading completed!")