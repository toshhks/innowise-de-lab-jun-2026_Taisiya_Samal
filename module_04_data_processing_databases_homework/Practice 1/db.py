import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

from functions import (
    convert_yes_no_to_bool,
    fix_datetime,
    fix_sales_timestamp,
    validate_and_fix_date,
)

load_dotenv()

SCHEMA = 'silver'
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


def load_data(df, table_name, con, schema=SCHEMA, if_exists='append', index=False, chunksize=None):
    if table_name == 'employees':
        for column in ('birth_date', 'hire_date'):
            df[column] = df[column].apply(validate_and_fix_date)

    elif table_name == 'sales':
        df['sales_timestamp'] = df['sales_timestamp'].apply(fix_sales_timestamp)
        df = df.dropna(subset=['sales_timestamp'])
        df['shop_id'] = None
        df['city_id'] = None

    elif table_name == 'products':
        df['modify_timestamp'] = df['modify_timestamp'].apply(fix_datetime)
        df['resistant'] = df['resistant'].apply(convert_yes_no_to_bool)
        df['is_allergic'] = df['is_allergic'].apply(convert_yes_no_to_bool)
        df = df.drop_duplicates(subset=['product_name'], keep='first')

    try:
        df.to_sql(
            name=table_name,
            con=con,
            schema=schema,
            if_exists=if_exists,
            index=index,
            chunksize=chunksize,
        )
        print(f'Data loaded successfully into silver.{table_name} ({len(df)} rows)')
        return True
    except Exception as exc:
        print(f'Failed to load data into silver.{table_name}')
        print(exc)
        return False
