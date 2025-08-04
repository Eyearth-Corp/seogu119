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

def test_database_connection():
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
        
        print("Successfully connected to the database!")
        
        # Test query to get some data
        with connection.cursor() as cursor:
            # Get table names
            cursor.execute("SHOW TABLES")
            tables = cursor.fetchall()
            print("\nDatabase tables:")
            for table in tables:
                print(f"  - {list(table.values())[0]}")
                
            # Try to get some sample data from a few tables if they exist
            for table_dict in tables:
                table_name = list(table_dict.values())[0]
                try:
                    cursor.execute(f"SELECT COUNT(*) as count FROM {table_name}")
                    count_result = cursor.fetchone()
                    print(f"  - {table_name}: {count_result['count']} records")
                    
                    # Get a sample row if table is not empty
                    if count_result['count'] > 0:
                        cursor.execute(f"SELECT * FROM {table_name} LIMIT 1")
                        sample_row = cursor.fetchone()
                        print(f"    Sample row: {sample_row}")
                        break  # Just show one sample
                except Exception as e:
                    print(f"  - {table_name}: Could not query (error: {e})")
                break  # Just check the first table
                
        connection.close()
        return True
        
    except Exception as e:
        print(f"Error connecting to the database: {e}")
        return False

if __name__ == "__main__":
    test_database_connection()