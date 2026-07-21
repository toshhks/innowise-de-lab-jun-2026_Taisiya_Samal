-- =============================================================================
-- EcoMarket Gold Layer — Analytical Queries (5)
-- Uses only schema: gold
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Query 1: Monthly net revenue (выручка по месяцам)
-- Dimensions: dim_date
-- -----------------------------------------------------------------------------
SELECT
    d.year_num,
    d.month_num,
    d.month_name,
    COUNT(f.sales_id)                   AS sales_count,
    SUM(f.quantity)                     AS units_sold,
    ROUND(SUM(f.net_revenue), 2)        AS net_revenue,
    ROUND(SUM(f.discount_amount), 2)    AS total_discount
FROM gold.fact_sales f
JOIN gold.dim_date d ON d.date_key = f.date_key
GROUP BY d.year_num, d.month_num, d.month_name
ORDER BY d.year_num, d.month_num;


-- -----------------------------------------------------------------------------
-- Query 2: Net revenue by shop and product category
-- (выручка по магазинам и категориям)
-- Dimensions: dim_shop, dim_city, dim_product, dim_category
-- -----------------------------------------------------------------------------
SELECT
    sh.shop_id,
    sh.address                          AS shop_address,
    ci.city_name,
    cat.category_name,
    COUNT(f.sales_id)                   AS sales_count,
    ROUND(SUM(f.net_revenue), 2)        AS net_revenue
FROM gold.fact_sales f
JOIN gold.dim_shop sh ON sh.shop_key = f.shop_key
JOIN gold.dim_city ci ON ci.city_key = sh.city_key
JOIN gold.dim_product pr ON pr.product_key = f.product_key
JOIN gold.dim_category cat ON cat.category_key = pr.category_key
GROUP BY sh.shop_id, sh.address, ci.city_name, cat.category_name
ORDER BY net_revenue DESC
LIMIT 20;


-- -----------------------------------------------------------------------------
-- Query 3: Top 10 customers by net revenue (топ-10 клиентов)
-- Dimensions: dim_customer, dim_city
-- -----------------------------------------------------------------------------
SELECT
    c.customer_id,
    c.full_name,
    ci.city_name,
    COUNT(f.sales_id)                   AS purchases_count,
    SUM(f.quantity)                     AS units_bought,
    ROUND(SUM(f.net_revenue), 2)        AS net_revenue,
    ROUND(AVG(f.net_revenue), 2)        AS avg_line_amount
FROM gold.fact_sales f
JOIN gold.dim_customer c ON c.customer_key = f.customer_key
JOIN gold.dim_city ci ON ci.city_key = c.city_key
GROUP BY c.customer_id, c.full_name, ci.city_name
ORDER BY net_revenue DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Query 4: Employee sales performance (анализ продаж по сотрудникам)
-- Dimensions: dim_employee, dim_shop
-- -----------------------------------------------------------------------------
SELECT
    e.employee_id,
    e.full_name,
    sh.shop_id,
    sh.address                          AS shop_address,
    COUNT(f.sales_id)                   AS sales_count,
    COUNT(DISTINCT f.transaction_number) AS transactions_count,
    ROUND(SUM(f.net_revenue), 2)        AS net_revenue,
    ROUND(SUM(f.profit), 2)             AS total_profit,
    ROUND(SUM(f.profit) / NULLIF(SUM(f.net_revenue), 0), 4) AS margin_ratio
FROM gold.fact_sales f
JOIN gold.dim_employee e ON e.employee_key = f.employee_key
JOIN gold.dim_shop sh ON sh.shop_key = e.shop_key
GROUP BY e.employee_id, e.full_name, sh.shop_id, sh.address
ORDER BY net_revenue DESC
LIMIT 15;


-- -----------------------------------------------------------------------------
-- Query 5: Best-selling products, average check, margin by category
-- (топ товаров, средний чек, маржинальность по категориям)
-- Dimensions: dim_product, dim_category, dim_date
-- -----------------------------------------------------------------------------

-- Top 10 products by sold quantity
SELECT
    pr.product_id,
    pr.product_name,
    cat.category_name,
    SUM(f.quantity)                     AS total_quantity,
    ROUND(SUM(f.net_revenue), 2)        AS net_revenue,
    ROUND(SUM(f.profit) / NULLIF(SUM(f.net_revenue), 0), 4) AS margin_ratio
FROM gold.fact_sales f
JOIN gold.dim_product pr ON pr.product_key = f.product_key
JOIN gold.dim_category cat ON cat.category_key = pr.category_key
WHERE pr.is_current = TRUE
GROUP BY pr.product_id, pr.product_name, cat.category_name
ORDER BY total_quantity DESC
LIMIT 10;

-- Average check by month (средний чек)
SELECT
    d.year_num,
    d.month_name,
    ROUND(
        SUM(f.net_revenue) / NULLIF(COUNT(DISTINCT f.transaction_number), 0),
        2
    ) AS average_check
FROM gold.fact_sales f
JOIN gold.dim_date d ON d.date_key = f.date_key
GROUP BY d.year_num, d.month_num, d.month_name
ORDER BY d.year_num, d.month_num;

-- Margin by category (маржинальность)
SELECT
    cat.category_name,
    ROUND(SUM(f.net_revenue), 2)        AS net_revenue,
    ROUND(SUM(f.profit) / NULLIF(SUM(f.net_revenue), 0), 4) AS margin_ratio
FROM gold.fact_sales f
JOIN gold.dim_product pr ON pr.product_key = f.product_key
JOIN gold.dim_category cat ON cat.category_key = pr.category_key
GROUP BY cat.category_name
ORDER BY margin_ratio DESC;
