-- Gold layer DDL: schema, dimensions, fact table, ETL log

CREATE SCHEMA IF NOT EXISTS gold;

-- Optional full reset (uncomment for clean rebuild):
-- DROP SCHEMA IF EXISTS gold CASCADE;
-- CREATE SCHEMA gold;

CREATE TABLE IF NOT EXISTS gold.etl_load_log (
    load_id          SERIAL PRIMARY KEY,
    target_table     VARCHAR(100)  NOT NULL,
    load_started_at  TIMESTAMP     NOT NULL DEFAULT NOW(),
    load_finished_at TIMESTAMP,
    rows_affected    INTEGER,
    watermark_value  BIGINT,
    status           VARCHAR(20)   NOT NULL,
    error_message    TEXT
);

CREATE INDEX IF NOT EXISTS idx_etl_load_log_target_status
    ON gold.etl_load_log (target_table, status);

CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_key     INTEGER      PRIMARY KEY,
    full_date    DATE         NOT NULL UNIQUE,
    day_of_week  SMALLINT     NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    week_num     SMALLINT     NOT NULL CHECK (week_num BETWEEN 1 AND 53),
    month_num    SMALLINT     NOT NULL CHECK (month_num BETWEEN 1 AND 12),
    month_name   VARCHAR(20)  NOT NULL,
    quarter_num  SMALLINT     NOT NULL CHECK (quarter_num BETWEEN 1 AND 4),
    year_num     SMALLINT     NOT NULL CHECK (year_num BETWEEN 1900 AND 2100)
);

CREATE TABLE IF NOT EXISTS gold.dim_country (
    country_key   SERIAL PRIMARY KEY,
    country_id    INTEGER      NOT NULL UNIQUE,
    country_name  VARCHAR(100) NOT NULL,
    country_code  VARCHAR(2)   NOT NULL UNIQUE
);

CREATE INDEX IF NOT EXISTS idx_dim_country_country_id
    ON gold.dim_country (country_id);

CREATE TABLE IF NOT EXISTS gold.dim_city (
    city_key     SERIAL PRIMARY KEY,
    city_id      INTEGER      NOT NULL UNIQUE,
    city_name    VARCHAR(100) NOT NULL,
    zipcode      VARCHAR(20)  NOT NULL,
    country_key  INTEGER      NOT NULL REFERENCES gold.dim_country (country_key)
);

CREATE INDEX IF NOT EXISTS idx_dim_city_city_id
    ON gold.dim_city (city_id);
CREATE INDEX IF NOT EXISTS idx_dim_city_country_key
    ON gold.dim_city (country_key);

CREATE TABLE IF NOT EXISTS gold.dim_category (
    category_key   SERIAL PRIMARY KEY,
    category_id    INTEGER      NOT NULL UNIQUE,
    category_name  VARCHAR(100) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_dim_category_category_id
    ON gold.dim_category (category_id);

CREATE TABLE IF NOT EXISTS gold.dim_product (
    product_key    SERIAL PRIMARY KEY,
    product_id     INTEGER        NOT NULL,
    product_name   VARCHAR(255)   NOT NULL,
    price          NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    category_key   INTEGER        NOT NULL REFERENCES gold.dim_category (category_key),
    product_class  VARCHAR(1)     NOT NULL,
    is_resistant   BOOLEAN        NOT NULL,
    is_allergic    BOOLEAN        NOT NULL,
    vitality_days  INTEGER        NOT NULL CHECK (vitality_days > 0),
    valid_from_dt  TIMESTAMP      NOT NULL,
    valid_to_dt    TIMESTAMP      NOT NULL,
    is_current     BOOLEAN        NOT NULL CHECK (is_current IN (TRUE, FALSE)),
    CHECK (valid_to_dt >= valid_from_dt),
    UNIQUE (product_id, valid_from_dt)
);

CREATE INDEX IF NOT EXISTS idx_dim_product_product_id
    ON gold.dim_product (product_id);
CREATE INDEX IF NOT EXISTS idx_dim_product_category_key
    ON gold.dim_product (category_key);
CREATE INDEX IF NOT EXISTS idx_dim_product_current
    ON gold.dim_product (product_id)
    WHERE is_current = TRUE;

CREATE TABLE IF NOT EXISTS gold.dim_shop (
    shop_key   SERIAL PRIMARY KEY,
    shop_id    INTEGER      NOT NULL UNIQUE,
    address    VARCHAR(255) NOT NULL,
    city_key   INTEGER      NOT NULL REFERENCES gold.dim_city (city_key)
);

CREATE INDEX IF NOT EXISTS idx_dim_shop_shop_id
    ON gold.dim_shop (shop_id);
CREATE INDEX IF NOT EXISTS idx_dim_shop_city_key
    ON gold.dim_shop (city_key);

CREATE TABLE IF NOT EXISTS gold.dim_customer (
    customer_key    SERIAL PRIMARY KEY,
    customer_id     INTEGER      NOT NULL UNIQUE,
    first_name      VARCHAR(100) NOT NULL,
    middle_initial  VARCHAR(1)   NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    full_name       VARCHAR(255) NOT NULL,
    city_key        INTEGER      NOT NULL REFERENCES gold.dim_city (city_key),
    address         VARCHAR(255) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_dim_customer_customer_id
    ON gold.dim_customer (customer_id);
CREATE INDEX IF NOT EXISTS idx_dim_customer_city_key
    ON gold.dim_customer (city_key);

CREATE TABLE IF NOT EXISTS gold.dim_employee (
    employee_key    SERIAL PRIMARY KEY,
    employee_id     INTEGER      NOT NULL UNIQUE,
    first_name      VARCHAR(100) NOT NULL,
    middle_initial  VARCHAR(1)   NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    full_name       VARCHAR(255) NOT NULL,
    birth_date      DATE         NOT NULL,
    gender          VARCHAR(1)   NOT NULL CHECK (gender IN ('M', 'F')),
    hire_date       DATE         NOT NULL,
    shop_key        INTEGER      NOT NULL REFERENCES gold.dim_shop (shop_key),
    city_key        INTEGER      NOT NULL REFERENCES gold.dim_city (city_key),
    CHECK (hire_date > birth_date)
);

CREATE INDEX IF NOT EXISTS idx_dim_employee_employee_id
    ON gold.dim_employee (employee_id);
CREATE INDEX IF NOT EXISTS idx_dim_employee_shop_key
    ON gold.dim_employee (shop_key);
CREATE INDEX IF NOT EXISTS idx_dim_employee_city_key
    ON gold.dim_employee (city_key);

CREATE TABLE IF NOT EXISTS gold.fact_sales (
    sales_key           BIGSERIAL PRIMARY KEY,
    sales_id            INTEGER        NOT NULL UNIQUE,
    transaction_number  VARCHAR(20)    NOT NULL,
    date_key            INTEGER        NOT NULL REFERENCES gold.dim_date (date_key),
    product_key         INTEGER        NOT NULL REFERENCES gold.dim_product (product_key),
    customer_key        INTEGER        NOT NULL REFERENCES gold.dim_customer (customer_key),
    employee_key        INTEGER        NOT NULL REFERENCES gold.dim_employee (employee_key),
    shop_key            INTEGER        NOT NULL REFERENCES gold.dim_shop (shop_key),
    city_key            INTEGER        NOT NULL REFERENCES gold.dim_city (city_key),
    quantity            INTEGER        NOT NULL CHECK (quantity > 0),
    total_revenue       NUMERIC(12, 2) NOT NULL CHECK (total_revenue >= 0),
    discount_amount     NUMERIC(12, 2) NOT NULL CHECK (discount_amount >= 0),
    net_revenue         NUMERIC(12, 2) NOT NULL CHECK (net_revenue >= 0),
    profit              NUMERIC(12, 2) NOT NULL,
    margin              NUMERIC(8, 4)  NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_sales_id
    ON gold.fact_sales (sales_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_date_key
    ON gold.fact_sales (date_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_product_key
    ON gold.fact_sales (product_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer_key
    ON gold.fact_sales (customer_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_employee_key
    ON gold.fact_sales (employee_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_shop_key
    ON gold.fact_sales (shop_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_city_key
    ON gold.fact_sales (city_key);
