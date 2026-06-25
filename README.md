# EcoMarket

Project EcoMarket — учебный проект, созданный для моделирования работы сети продуктовых магазинов, специализирующейся на фермерских и экологически чистых товарах.

Проект помогает компании анализировать продажи, клиентов, сотрудников и категории товаров, а также получать ответы на ключевые бизнес-вопросы с помощью построенной Data Platform.

## 🎯 Цель проекта

Построить учебную Data Platform, которая объединяет данные из CSV-файлов и демонстрирует полный цикл работы с данными: загрузку, обработку, очистку и формирование аналитических витрин.

## 📊 Источники данных (CSV файлы)

- **sales.csv**
- **customers.csv**
- **products.csv**
- **categories.csv**
- **employees.csv**
- **cities.csv**
- **countries.csv**
- **shops.csv**

## 🗄️ Целевое хранилище

- **СУБД:** PostgreSQL
- **Схема:** raw
- **Таблицы:** sales_data, customers_data, products_data, categories_data, employees_data, cities_data, countries_data, shops_data

## 🚀 Как запустить проект

1. Клонировать репозиторий: `git clone <ссылка на репозиторий>`
2. Установить зависимости: `pip install -r requirements.txt`
3. Запустить скрипт загрузки данных: `python load_data.py`
4. Выполнить ETL-процесс: `python etl_pipeline.py`

## 👨‍💻 Автор проекта

**Taisiya Samal**  
taya.samal@gmail.com
