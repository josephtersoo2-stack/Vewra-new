import sys
from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

# Database configuration for development - Default to MySQL
DB_ENGINE = os.getenv('DB_ENGINE', 'django.db.backends.mysql')
DB_NAME = os.getenv('DB_NAME', 'vewra')
DB_USER = os.getenv('DB_USER', 'root')
DB_PASSWORD = os.getenv('DB_PASSWORD', '')
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '3306')

if 'test' in sys.argv:
    # Dedicated in-memory test database for test runner isolation
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': ':memory:',
        }
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': DB_ENGINE,
            'NAME': DB_NAME,
            'USER': DB_USER,
            'PASSWORD': DB_PASSWORD,
            'HOST': DB_HOST,
            'PORT': DB_PORT,
            'OPTIONS': {
                'charset': 'utf8mb4',
                'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
            } if 'mysql' in DB_ENGINE else {},
        }
    }
