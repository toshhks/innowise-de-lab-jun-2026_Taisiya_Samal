import pandas as pd
from sqlalchemy import create_engine, Column, Integer, String, Float 
from sqlalchemy.orm import declarative_base, sessionmaker
import re

connectionString = 'postgresql://postgres:220056smlTVB@localhost/EcoMarket'

def load_data(df, table_name, con, schema='public2', if_exists='append', index=False, chunksize=None):
    try:
        df.to_sql(
            name=table_name,
            con=con,
            schema=schema,
            if_exists=if_exists,
            index=index,
            chunksize=chunksize
        )
        print('Загрузка данных в таблицу прошла успешно')
        return True
    except Exception as e:
        print('Ошибка! Данные не были загружены в таблицу')
        print(e)
        return False

def connect_to_db(con):
    try:
        engine = create_engine(con, echo=False)
        with engine.connect() as conn:
            print('Подключение к базе данных успешно инициализировано.')
        return engine 
    except:
        print('Ошибка! Подключение к базе не было инициализировано.')
        return None

def read_csv(file_path, sep):
    try:
        df = pd.read_csv(file_path, sep=sep)
        print('Данные с csv файла успешно прочитаны')
        return df
    except:
        print('Ошибка! Не удалось прочитать данные с файла')
        return 0

engine = connect_to_db(connectionString)

file_paths = [
    r'D:\!Taisiya\innowise_lab_jun_2026\csv_files\countries.csv',
    r'D:\!Taisiya\innowise_lab_jun_2026\csv_files\cities.csv',
    r'D:\!Taisiya\innowise_lab_jun_2026\csv_files\categories.csv',
    r'D:\!Taisiya\innowise_lab_jun_2026\csv_files\products.csv',
    r'D:\!Taisiya\innowise_lab_jun_2026\csv_files\shops.csv',
    r'D:\!Taisiya\innowise_lab_jun_2026\csv_files\employees.csv',
    r'D:\!Taisiya\innowise_lab_jun_2026\csv_files\customers.csv'
]

for file_path in file_paths:
    df = read_csv(file_path, ';')
    match = re.search(r'([^\\/]+)\.csv$', file_path)
    load_data(df, 'bronze_'+match.group(1), engine)

sales_file_path = r'D:\!Taisiya\innowise_lab_jun_2026\csv_files\sales.csv'
df = read_csv(sales_file_path, ';')
match = re.search(r'([^\\/]+)\.csv$', sales_file_path)
load_data(df, 'bronze_'+match.group(1), engine, chunksize=10000)
