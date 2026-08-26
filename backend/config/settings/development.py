import sys
import os
from .base import *

DEBUG = True

ALLOWED_HOSTS = ["*"]


# PostgreSQL Development Database Configuration
# Local PostgreSQL 16 installation
# Database: vewra
# Host: localhost
# Port: 5432

DB_ENGINE = os.getenv(
    "DB_ENGINE",
    "django.db.backends.postgresql"
)

DB_NAME = os.getenv(
    "DB_NAME",
    "vewra"
)

DB_USER = os.getenv(
    "DB_USER",
    "postgres"
)

DB_PASSWORD = os.getenv(
    "DB_PASSWORD",
    ""
)

DB_HOST = os.getenv(
    "DB_HOST",
    "localhost"
)

DB_PORT = os.getenv(
    "DB_PORT",
    "5432"
)


# Test database isolation
if "test" in sys.argv:

    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": ":memory:",
        }
    }

else:

    DATABASES = {
        "default": {
            "ENGINE": DB_ENGINE,
            "NAME": DB_NAME,
            "USER": DB_USER,
            "PASSWORD": DB_PASSWORD,
            "HOST": DB_HOST,
            "PORT": DB_PORT,

            "OPTIONS": {},
        }
    }


# Development CORS settings for mobile testing
CORS_ALLOW_ALL_ORIGINS = True


# Allow Flutter physical device connection
CSRF_TRUSTED_ORIGINS = [
    "http://10.38.20.241:8000",
    "http://192.168.1.45:8000",
    "http://localhost:8000",
    "http://127.0.0.1:8000",
]