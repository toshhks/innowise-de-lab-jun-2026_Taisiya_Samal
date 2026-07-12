import os
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parent / '.env')

DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'EcoMarket')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', '')

connectionString = (
    f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
)

DB_SCHEMA = os.getenv('DB_SCHEMA', 'public2')
CSV_PATH = os.getenv('CSV_PATH', './csv_files/')
CHUNK_SIZE = int(os.getenv('CHUNK_SIZE', 10000))
SEPARATOR = os.getenv('SEPARATOR', ';')
