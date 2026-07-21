-- Silver -> Gold: load / refresh dimension tables

-- ---------------------------------------------------------------------------
-- dim_date (Type 0)
-- ---------------------------------------------------------------------------
INSERT INTO gold.etl_load_log (target_table, status)
VALUES ('dim_date', 'RUNNING');

INSERT INTO gold.dim_date (
    date_key,
    full_date,
    day_of_week,
    week_num,
    month_num,
    month_name,
    quarter_num,
    year_num
)
SELECT
    TO_CHAR(d::DATE, 'YYYYMMDD')::INTEGER AS date_key,
    d::DATE AS full_date,
    EXTRACT(ISODOW FROM d)::SMALLINT AS day_of_week,
    EXTRACT(WEEK FROM d)::SMALLINT AS week_num,
    EXTRACT(MONTH FROM d)::SMALLINT AS month_num,
    TRIM(TO_CHAR(d, 'Month')) AS month_name,
    EXTRACT(QUARTER FROM d)::SMALLINT AS quarter_num,
    EXTRACT(YEAR FROM d)::SMALLINT AS year_num
FROM generate_series(
    (SELECT MIN(sales_timestamp)::DATE FROM silver.sales),
    (SELECT MAX(sales_timestamp)::DATE FROM silver.sales),
    INTERVAL '1 day'
) AS d
ON CONFLICT (full_date) DO NOTHING;

UPDATE gold.etl_load_log
SET
    load_finished_at = NOW(),
    rows_affected = (SELECT COUNT(*) FROM gold.dim_date),
    status = 'SUCCESS'
WHERE load_id = (SELECT MAX(load_id) FROM gold.etl_load_log WHERE target_table = 'dim_date');

-- ---------------------------------------------------------------------------
-- dim_country (Type 1)
-- ---------------------------------------------------------------------------
INSERT INTO gold.etl_load_log (target_table, status)
VALUES ('dim_country', 'RUNNING');

INSERT INTO gold.dim_country (country_id, country_name, country_code)
SELECT country_id, country_name, country_code
FROM silver.countries
ON CONFLICT (country_id) DO UPDATE
SET
    country_name = EXCLUDED.country_name,
    country_code = EXCLUDED.country_code;

UPDATE gold.etl_load_log
SET
    load_finished_at = NOW(),
    rows_affected = (SELECT COUNT(*) FROM gold.dim_country),
    status = 'SUCCESS'
WHERE load_id = (SELECT MAX(load_id) FROM gold.etl_load_log WHERE target_table = 'dim_country');

-- ---------------------------------------------------------------------------
-- dim_city (Type 1)
-- ---------------------------------------------------------------------------
INSERT INTO gold.etl_load_log (target_table, status)
VALUES ('dim_city', 'RUNNING');

INSERT INTO gold.dim_city (city_id, city_name, zipcode, country_key)
SELECT
    c.city_id,
    c.city_name,
    c.zipcode,
    dc.country_key
FROM silver.cities c
JOIN gold.dim_country dc ON dc.country_id = c.country_id
ON CONFLICT (city_id) DO UPDATE
SET
    city_name = EXCLUDED.city_name,
    zipcode = EXCLUDED.zipcode,
    country_key = EXCLUDED.country_key;

UPDATE gold.etl_load_log
SET
    load_finished_at = NOW(),
    rows_affected = (SELECT COUNT(*) FROM gold.dim_city),
    status = 'SUCCESS'
WHERE load_id = (SELECT MAX(load_id) FROM gold.etl_load_log WHERE target_table = 'dim_city');

-- ---------------------------------------------------------------------------
-- dim_category (Type 1)
-- ---------------------------------------------------------------------------
INSERT INTO gold.etl_load_log (target_table, status)
VALUES ('dim_category', 'RUNNING');

INSERT INTO gold.dim_category (category_id, category_name)
SELECT category_id, category_name
FROM silver.categories
ON CONFLICT (category_id) DO UPDATE
SET category_name = EXCLUDED.category_name;

UPDATE gold.etl_load_log
SET
    load_finished_at = NOW(),
    rows_affected = (SELECT COUNT(*) FROM gold.dim_category),
    status = 'SUCCESS'
WHERE load_id = (SELECT MAX(load_id) FROM gold.etl_load_log WHERE target_table = 'dim_category');

-- ---------------------------------------------------------------------------
-- dim_product (Type 2 / SCD2)
-- ---------------------------------------------------------------------------
INSERT INTO gold.etl_load_log (target_table, status)
VALUES ('dim_product', 'RUNNING');

UPDATE gold.dim_product dp
SET
    valid_to_dt = src.modify_timestamp,
    is_current = FALSE
FROM silver.products src
JOIN gold.dim_category cat ON cat.category_id = src.category_id
WHERE dp.product_id = src.product_id
  AND dp.is_current = TRUE
  AND (
      dp.product_name IS DISTINCT FROM src.product_name
      OR dp.price IS DISTINCT FROM src.price
      OR dp.category_key IS DISTINCT FROM cat.category_key
      OR dp.product_class IS DISTINCT FROM src.class
      OR dp.is_resistant IS DISTINCT FROM src.resistant
      OR dp.is_allergic IS DISTINCT FROM src.is_allergic
      OR dp.vitality_days IS DISTINCT FROM src.vitality_days
  );

INSERT INTO gold.dim_product (
    product_id,
    product_name,
    price,
    category_key,
    product_class,
    is_resistant,
    is_allergic,
    vitality_days,
    valid_from_dt,
    valid_to_dt,
    is_current
)
SELECT
    src.product_id,
    src.product_name,
    src.price,
    cat.category_key,
    src.class,
    src.resistant,
    src.is_allergic,
    src.vitality_days,
    COALESCE(
        (
            SELECT MIN(s2.sales_timestamp)
            FROM silver.sales s2
            WHERE s2.product_id = src.product_id
        ),
        TIMESTAMP '1900-01-01 00:00:00'
    ),
    TIMESTAMP '9999-12-31 23:59:59',
    TRUE
FROM silver.products src
JOIN gold.dim_category cat ON cat.category_id = src.category_id
WHERE NOT EXISTS (
    SELECT 1
    FROM gold.dim_product dp
    WHERE dp.product_id = src.product_id
      AND dp.is_current = TRUE
);

UPDATE gold.etl_load_log
SET
    load_finished_at = NOW(),
    rows_affected = (SELECT COUNT(*) FROM gold.dim_product),
    status = 'SUCCESS'
WHERE load_id = (SELECT MAX(load_id) FROM gold.etl_load_log WHERE target_table = 'dim_product');

-- ---------------------------------------------------------------------------
-- dim_shop (Type 1)
-- ---------------------------------------------------------------------------
INSERT INTO gold.etl_load_log (target_table, status)
VALUES ('dim_shop', 'RUNNING');

INSERT INTO gold.dim_shop (shop_id, address, city_key)
SELECT
    s.shop_id,
    s.address,
    dc.city_key
FROM silver.shops s
JOIN gold.dim_city dc ON dc.city_id = s.city_id
ON CONFLICT (shop_id) DO UPDATE
SET
    address = EXCLUDED.address,
    city_key = EXCLUDED.city_key;

UPDATE gold.etl_load_log
SET
    load_finished_at = NOW(),
    rows_affected = (SELECT COUNT(*) FROM gold.dim_shop),
    status = 'SUCCESS'
WHERE load_id = (SELECT MAX(load_id) FROM gold.etl_load_log WHERE target_table = 'dim_shop');

-- ---------------------------------------------------------------------------
-- dim_customer (Type 1)
-- ---------------------------------------------------------------------------
INSERT INTO gold.etl_load_log (target_table, status)
VALUES ('dim_customer', 'RUNNING');

INSERT INTO gold.dim_customer (
    customer_id,
    first_name,
    middle_initial,
    last_name,
    full_name,
    city_key,
    address
)
SELECT
    c.customer_id,
    c.first_name,
    c.middle_initial,
    c.last_name,
    TRIM(c.first_name || ' ' || c.middle_initial || '. ' || c.last_name) AS full_name,
    dc.city_key,
    c.address
FROM silver.customers c
JOIN gold.dim_city dc ON dc.city_id = c.city_id
ON CONFLICT (customer_id) DO UPDATE
SET
    first_name = EXCLUDED.first_name,
    middle_initial = EXCLUDED.middle_initial,
    last_name = EXCLUDED.last_name,
    full_name = EXCLUDED.full_name,
    city_key = EXCLUDED.city_key,
    address = EXCLUDED.address;

UPDATE gold.etl_load_log
SET
    load_finished_at = NOW(),
    rows_affected = (SELECT COUNT(*) FROM gold.dim_customer),
    status = 'SUCCESS'
WHERE load_id = (SELECT MAX(load_id) FROM gold.etl_load_log WHERE target_table = 'dim_customer');

-- ---------------------------------------------------------------------------
-- dim_employee (Type 1)
-- ---------------------------------------------------------------------------
INSERT INTO gold.etl_load_log (target_table, status)
VALUES ('dim_employee', 'RUNNING');

INSERT INTO gold.dim_employee (
    employee_id,
    first_name,
    middle_initial,
    last_name,
    full_name,
    birth_date,
    gender,
    hire_date,
    shop_key,
    city_key
)
SELECT
    e.employee_id,
    e.first_name,
    e.middle_initial,
    e.last_name,
    TRIM(e.first_name || ' ' || e.middle_initial || '. ' || e.last_name) AS full_name,
    e.birth_date,
    e.gender,
    e.hire_date,
    ds.shop_key,
    dc.city_key
FROM silver.employees e
JOIN gold.dim_shop ds ON ds.shop_id = e.shop_id
JOIN gold.dim_city dc ON dc.city_id = e.city_id
ON CONFLICT (employee_id) DO UPDATE
SET
    first_name = EXCLUDED.first_name,
    middle_initial = EXCLUDED.middle_initial,
    last_name = EXCLUDED.last_name,
    full_name = EXCLUDED.full_name,
    birth_date = EXCLUDED.birth_date,
    gender = EXCLUDED.gender,
    hire_date = EXCLUDED.hire_date,
    shop_key = EXCLUDED.shop_key,
    city_key = EXCLUDED.city_key;

UPDATE gold.etl_load_log
SET
    load_finished_at = NOW(),
    rows_affected = (SELECT COUNT(*) FROM gold.dim_employee),
    status = 'SUCCESS'
WHERE load_id = (SELECT MAX(load_id) FROM gold.etl_load_log WHERE target_table = 'dim_employee');
