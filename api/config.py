import socket

# 로컬 환경 감지를 위한 호스트명 리스트
local_name_list = [
    'ieunhoui-MacBookPro.local',
    'ieunhoui-MacBookPro-2.local',
]

class MysqlConfig:
    HOST = 'gbmf.cluster-ccpekrtljkcw.ap-northeast-2.rds.amazonaws.com'
    PORT = 3306
    USER = 'admin'
    PASSWORD = 'Eye12345!'
    DATABASE_PRODUCT = 'seogu119'  # train_village에서 seogu119로 변경

class MysqlConfigLocal:
    HOST = '127.0.0.1'
    PORT = 23307
    USER = 'admin'
    PASSWORD = 'Eye12345!'
    DATABASE_PRODUCT = 'seogu119'  # train_village에서 seogu119로 변경

class AWS:
    REGION = 'ap-northeast-2'
    ACCESS_KEY_ID = 'AKIA4YJ67FJATNCBVHVG'
    SECRET_ACCESS_KEY = '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'

def get_mysql_config():
    """현재 환경에 맞는 MySQL 설정 반환"""
    hostname = socket.gethostname()
    if hostname in local_name_list:
        return MysqlConfigLocal
    else:
        return MysqlConfig

def get_database_url():
    """현재 환경에 맞는 데이터베이스 URL 반환"""
    config = get_mysql_config()
    return f"mysql+pymysql://{config.USER}:{config.PASSWORD}@{config.HOST}:{config.PORT}/{config.DATABASE_PRODUCT}"