import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

ROOT_DIR = Path(__file__).resolve().parent

load_dotenv(ROOT_DIR / '.env')

DATABASE_URL = os.getenv('DATABASE_URL')
CSV_DIR = os.getenv('CSV_DIR')

if not DATABASE_URL:
    raise ValueError('DATABASE_URL is not set in the environment or .env file')

engine = create_engine(DATABASE_URL)


def test_connection():
    """Tests database connectivity."""
    try:
        with engine.connect() as conn:
            conn.execute(text('SELECT 1'))
            print('Connection successful!')
            return True
    except Exception as exc:
        print(f'Connection error: {exc}')
        return False


def run_sql_file(sql_path):
    """Executes a SQL script file against the database."""
    sql_text = Path(sql_path).read_text(encoding='utf-8')
    with engine.begin() as conn:
        conn.execute(text(sql_text))
    print(f'SQL script executed: {sql_path}')
