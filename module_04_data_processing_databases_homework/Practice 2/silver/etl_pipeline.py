import sys
from pathlib import Path

import pandas as pd

SILVER_DIR = Path(__file__).resolve().parent
ROOT_DIR = SILVER_DIR.parent

sys.path.insert(0, str(ROOT_DIR))
sys.path.insert(0, str(SILVER_DIR))

from db import CSV_DIR, engine, run_sql_file, test_connection
from load import load_data

SQL_DIR = SILVER_DIR / 'sql'
DEFAULT_CSV_DIR = ROOT_DIR.parent.parent / 'csv_files'

LOAD_ORDER = [
    'countries',
    'cities',
    'categories',
    'shops',
    'products',
    'customers',
    'employees',
    'sales',
]

SQL_STAGES = [
    SQL_DIR / '01_silver_ddl.sql',
    SQL_DIR / '02_data_hygiene.sql',
    SQL_DIR / '03_data_enrichment.sql',
    SQL_DIR / '04_constraints.sql',
]


def get_csv_dir():
    if CSV_DIR:
        return Path(CSV_DIR)
    return DEFAULT_CSV_DIR


def load_csv(table_name, csv_dir):
    csv_path = csv_dir / f'{table_name}.csv'
    if not csv_path.exists():
        raise FileNotFoundError(f'CSV file not found: {csv_path}')
    return pd.read_csv(csv_path, sep=';')


def main():
    if not test_connection():
        raise RuntimeError('Database connection failed')

    csv_dir = get_csv_dir()
    print(f'Using CSV directory: {csv_dir}')

    run_sql_file(SQL_STAGES[0])

    for table_name in LOAD_ORDER:
        df = load_csv(table_name, csv_dir)
        load_data(df, table_name, engine)

    for sql_stage in SQL_STAGES[1:]:
        run_sql_file(sql_stage)

    print('Silver ETL pipeline completed successfully')


if __name__ == '__main__':
    main()
