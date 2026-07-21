-- Stage 1: Silver layer DDL (no PK/FK constraints)

CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.sales CASCADE;
DROP TABLE IF EXISTS silver.employees CASCADE;
DROP TABLE IF EXISTS silver.customers CASCADE;
DROP TABLE IF EXISTS silver.products CASCADE;
DROP TABLE IF EXISTS silver.shops CASCADE;
DROP TABLE IF EXISTS silver.categories CASCADE;
DROP TABLE IF EXISTS silver.cities CASCADE;
DROP TABLE IF EXISTS silver.countries CASCADE;

CREATE TABLE silver.countries (
    country_id   INTEGER      NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(2)   NOT NULL
);

CREATE TABLE silver.cities (
    city_id    INTEGER      NOT NULL,
    city_name  VARCHAR(100) NOT NULL,
    zipcode    VARCHAR(20)  NOT NULL,
    country_id INTEGER      NOT NULL
);

CREATE TABLE silver.shops (
    shop_id INTEGER      NOT NULL,
    city_id INTEGER      NOT NULL,
    address VARCHAR(255) NOT NULL
);

CREATE TABLE silver.categories (
    category_id   INTEGER      NOT NULL,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE silver.products (
    product_id        INTEGER       NOT NULL,
    product_name      VARCHAR(255)  NOT NULL,
    price             NUMERIC(10, 2) NOT NULL,
    category_id       INTEGER       NOT NULL,
    class             VARCHAR(1)    NOT NULL,
    modify_timestamp  TIMESTAMP     NOT NULL,
    resistant         BOOLEAN       NOT NULL,
    is_allergic       BOOLEAN       NOT NULL,
    vitality_days     INTEGER       NOT NULL
);

CREATE TABLE silver.customers (
    customer_id    INTEGER      NOT NULL,
    first_name     VARCHAR(100) NOT NULL,
    middle_initial VARCHAR(1)   NOT NULL,
    last_name      VARCHAR(100) NOT NULL,
    city_id        INTEGER      NOT NULL,
    address        VARCHAR(255) NOT NULL
);

CREATE TABLE silver.employees (
    employee_id    INTEGER      NOT NULL,
    first_name     VARCHAR(100) NOT NULL,
    middle_initial VARCHAR(1)   NOT NULL,
    last_name      VARCHAR(100) NOT NULL,
    birth_date     DATE         NOT NULL,
    gender         VARCHAR(1)   NOT NULL,
    city_id        INTEGER      NOT NULL,
    shop_id        INTEGER      NOT NULL,
    hire_date      DATE         NOT NULL
);

CREATE TABLE silver.sales (
    sales_id             INTEGER        NOT NULL,
    employee_id          INTEGER        NOT NULL,
    customer_id          INTEGER        NOT NULL,
    product_id           INTEGER        NOT NULL,
    quantity             INTEGER        NOT NULL,
    discount             NUMERIC(5, 2)  NOT NULL,
    total_price          NUMERIC(10, 2) NOT NULL,
    sales_timestamp      TIMESTAMP      NOT NULL,
    transaction_number   VARCHAR(20)    NOT NULL,
    shop_id              INTEGER,
    city_id              INTEGER
);
