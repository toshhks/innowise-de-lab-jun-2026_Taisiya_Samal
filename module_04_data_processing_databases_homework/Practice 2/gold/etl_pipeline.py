import sys
from pathlib import Path

GOLD_DIR = Path(__file__).resolve().parent
ROOT_DIR = GOLD_DIR.parent

sys.path.insert(0, str(ROOT_DIR))

from db import run_sql_file, test_connection

SQL_DIR = GOLD_DIR / 'sql'

GOLD_STAGES = [
    SQL_DIR / '01_gold_ddl.sql',
    SQL_DIR / '02_load_dimensions.sql',
    SQL_DIR / '03_load_fact_sales.sql',
]


def main():
    if not test_connection():
        raise RuntimeError('Database connection failed')

    print('Starting Gold ETL pipeline (Silver -> Gold)...')

    for sql_stage in GOLD_STAGES:
        run_sql_file(sql_stage)

    print('Gold ETL pipeline completed successfully')


if __name__ == '__main__':
    main()
