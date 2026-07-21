from functions import (
    convert_yes_no_to_bool,
    fix_datetime,
    fix_sales_timestamp,
    validate_and_fix_date,
)

SCHEMA = 'silver'


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
