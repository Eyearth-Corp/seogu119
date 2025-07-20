#!/usr/bin/env python3
"""
서구 골목 API 서버 실행 스크립트
"""

import uvicorn
import sys
import os

# 현재 디렉토리를 Python 경로에 추가
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

if __name__ == "__main__":
    print("🚀 서구 골목 API 서버를 시작합니다...")
    print("📍 서버 주소: http://localhost:8000")
    print("📖 API 문서: http://localhost:8000/docs")
    print("🔧 OpenAPI 스펙: http://localhost:8000/openapi.json")
    print("\n서버를 중지하려면 Ctrl+C를 누르세요.\n")
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )