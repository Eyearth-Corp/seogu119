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

def explore_database_structure():
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
        
        print("Database structure analysis:")
        print("=" * 50)
        
        # Get all table names
        with connection.cursor() as cursor:
            cursor.execute("SHOW TABLES")
            tables = cursor.fetchall()
            table_names = [list(table.values())[0] for table in tables]
            
        # For each table, get column information
        for table_name in table_names:
            print(f"\nTable: {table_name}")
            print("-" * 30)
            
            with connection.cursor() as cursor:
                # Get table schema
                cursor.execute(f"DESCRIBE {table_name}")
                columns = cursor.fetchall()
                
                # Display column information
                for col in columns:
                    nullable = "NULL" if col['Null'] == 'YES' else "NOT NULL"
                    key = f" ({col['Key']})" if col['Key'] else ""
                    default = f" DEFAULT {col['Default']}" if col['Default'] is not None else ""
                    extra = f" {col['Extra']}" if col['Extra'] else ""
                    print(f"  {col['Field']:<20} {col['Type']:<15} {nullable}{key}{default}{extra}")
                
                # Get row count
                cursor.execute(f"SELECT COUNT(*) as count FROM {table_name}")
                count_result = cursor.fetchone()
                print(f"  Row count: {count_result['count']}")
                
        connection.close()
        
    except Exception as e:
        print(f"Error exploring database structure: {e}")

if __name__ == "__main__":
    explore_database_structure()