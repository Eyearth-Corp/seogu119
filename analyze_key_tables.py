import pymysql
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv('/Users/ieunho/StudioProjects/seogu119_api/.env')

# Database connection parameters from the .env file
DB_HOST = os.getenv('LOCAL_MYSQL_HOST')
DB_PORT = int(os.getenv('LOCAL_MYSQL_PORT'))
DB_USER = os.getenv('LOCAL_MYSQL_USER')
DB_PASSWORD = os.getenv('LOCAL_MYSQL_PASSWORD')
DB_NAME = os.getenv('LOCAL_MYSQL_DATABASE')

def analyze_key_tables():
    try:
        # Create a connection to the database
        connection = pymysql.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
        
        print("Key Tables Analysis for Admin Dashboard")
        print("=" * 50)
        
        # Analyze admins table
        print("\n1. Admins Table")
        print("-" * 20)
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM admins LIMIT 5")
            admins = cursor.fetchall()
            for admin in admins:
                print(f"  ID: {admin['id']}, Username: {admin['username']}, Active: {admin['is_active']}")
        
        # Analyze living_zones table
        print("\n2. Living Zones Table")
        print("-" * 20)
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM living_zones")
            zones = cursor.fetchall()
            for zone in zones:
                print(f"  ID: {zone['id']}, Name: {zone['zone_name']}")
        
        # Analyze districts table
        print("\n3. Districts Table (Sample)")
        print("-" * 20)
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM districts LIMIT 5")
            districts = cursor.fetchall()
            for district in districts:
                print(f"  ID: {district['id']}, Name: {district['dong_name']}, Zone ID: {district['living_zone_id']}")
        
        # Analyze merchants table
        print("\n4. Merchants Table (Sample)")
        print("-" * 20)
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM merchants LIMIT 5")
            merchants = cursor.fetchall()
            for merchant in merchants:
                print(f"  ID: {merchant['id']}, Name: {merchant['merchant_name']}, District ID: {merchant['district_id']}")
        
        # Analyze global_metrics table
        print("\n5. Global Metrics Table")
        print("-" * 20)
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM global_metrics")
            metrics = cursor.fetchall()
            for metric in metrics:
                print(f"  ID: {metric['id']}, Title: {metric['title']}, Value: {metric['value']}, Unit: {metric['unit']}")
        
        # Analyze trend_data table
        print("\n6. Trend Data Table (Sample)")
        print("-" * 20)
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM trend_data ORDER BY trend_date DESC LIMIT 5")
            trends = cursor.fetchall()
            for trend in trends:
                zone_info = f"Zone {trend['living_zone_id']}" if trend['living_zone_id'] else "Global"
                print(f"  ID: {trend['id']}, Type: {trend['trend_type']}, {zone_info}, Date: {trend['trend_date']}, Value: {trend['value']}")
        
        # Analyze living_zone_stats table
        print("\n7. Living Zone Stats Table (Sample)")
        print("-" * 20)
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM living_zone_stats LIMIT 5")
            stats = cursor.fetchall()
            for stat in stats:
                print(f"  Zone ID: {stat['living_zone_id']}, Merchants: {stat['merchant_count']}, Stores: {stat['total_stores']}, Member Stores: {stat['member_stores']}, Rate: {stat['membership_rate']}")
        
        connection.close()
        
    except Exception as e:
        print(f"Error analyzing key tables: {e}")

if __name__ == "__main__":
    analyze_key_tables()