-- Stage 5: Primary keys, foreign keys, and business constraints

-- Primary keys
ALTER TABLE silver.countries  ADD CONSTRAINT pk_countries  PRIMARY KEY (country_id);
ALTER TABLE silver.cities     ADD CONSTRAINT pk_cities     PRIMARY KEY (city_id);
ALTER TABLE silver.shops      ADD CONSTRAINT pk_shops      PRIMARY KEY (shop_id);
ALTER TABLE silver.categories ADD CONSTRAINT pk_categories PRIMARY KEY (category_id);
ALTER TABLE silver.products   ADD CONSTRAINT pk_products   PRIMARY KEY (product_id);
ALTER TABLE silver.customers  ADD CONSTRAINT pk_customers  PRIMARY KEY (customer_id);
ALTER TABLE silver.employees  ADD CONSTRAINT pk_employees  PRIMARY KEY (employee_id);
ALTER TABLE silver.sales      ADD CONSTRAINT pk_sales      PRIMARY KEY (sales_id);

-- Foreign keys
ALTER TABLE silver.cities
    ADD CONSTRAINT fk_cities_country
    FOREIGN KEY (country_id) REFERENCES silver.countries (country_id);

ALTER TABLE silver.shops
    ADD CONSTRAINT fk_shops_city
    FOREIGN KEY (city_id) REFERENCES silver.cities (city_id);

ALTER TABLE silver.customers
    ADD CONSTRAINT fk_customers_city
    FOREIGN KEY (city_id) REFERENCES silver.cities (city_id);

ALTER TABLE silver.employees
    ADD CONSTRAINT fk_employees_city
    FOREIGN KEY (city_id) REFERENCES silver.cities (city_id);

ALTER TABLE silver.employees
    ADD CONSTRAINT fk_employees_shop
    FOREIGN KEY (shop_id) REFERENCES silver.shops (shop_id);

ALTER TABLE silver.products
    ADD CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES silver.categories (category_id);

ALTER TABLE silver.sales
    ADD CONSTRAINT fk_sales_employee
    FOREIGN KEY (employee_id) REFERENCES silver.employees (employee_id);

ALTER TABLE silver.sales
    ADD CONSTRAINT fk_sales_customer
    FOREIGN KEY (customer_id) REFERENCES silver.customers (customer_id);

ALTER TABLE silver.sales
    ADD CONSTRAINT fk_sales_product
    FOREIGN KEY (product_id) REFERENCES silver.products (product_id);

ALTER TABLE silver.sales
    ADD CONSTRAINT fk_sales_shop
    FOREIGN KEY (shop_id) REFERENCES silver.shops (shop_id);

ALTER TABLE silver.sales
    ADD CONSTRAINT fk_sales_city
    FOREIGN KEY (city_id) REFERENCES silver.cities (city_id);

-- Business constraint
ALTER TABLE silver.employees
    ADD CONSTRAINT chk_hire_after_birth
    CHECK (hire_date > birth_date);
