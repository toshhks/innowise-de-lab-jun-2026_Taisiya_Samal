import sys
from pathlib import Path

GOLD_DIR = Path(__file__).resolve().parent
ROOT_DIR = GOLD_DIR.parent

sys.path.insert(0, str(ROOT_DIR))

from db import run_sql_file, test_connection

MART_SQL_DIR = GOLD_DIR / 'sql' / 'mart'

MART_STAGES = [
    MART_SQL_DIR / '01_mart_views.sql',
]


def main():
    if not test_connection():
        raise RuntimeError('Database connection failed')

    print('Starting Mart layer build (Gold -> Mart)...')

    for sql_stage in MART_STAGES:
        run_sql_file(sql_stage)

    print('Mart layer completed successfully')


if __name__ == '__main__':
    main()
