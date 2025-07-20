#!/bin/bash

cd /var/app/current

# 데이터베이스 테이블 생성
python3 -c "
from database import create_tables
try:
    create_tables()
    print('Database tables created successfully')
except Exception as e:
    print(f'Error creating tables: {e}')
"

echo "Post-deploy hook completed"