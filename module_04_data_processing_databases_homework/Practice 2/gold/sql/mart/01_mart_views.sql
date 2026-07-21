-- Mart layer: schema, location dimension, data marts (materialized views)

CREATE SCHEMA IF NOT EXISTS mart;

-- ---------------------------------------------------------------------------
-- dim_location — BI slicer dimension (Country / City)
-- Relationship: 1 location_key -> Many rows in each mart (1:Many)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW mart.dim_location AS
SELECT
    ci.city_key     AS location_key,
    ci.city_id,
    ci.city_name,
    ci.zipcode,
    co.country_key,
    co.country_id,
    co.country_name,
    co.country_code
FROM gold.dim_city ci
JOIN gold.dim_country co ON co.country_key = ci.country_key;

-- ---------------------------------------------------------------------------
-- mart_daily_anomaly — daily shop revenue vs 30-day expected average
-- Chart: Line chart
-- ---------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS mart.mart_daily_anomaly;

CREATE MATERIALIZED VIEW mart.mart_daily_anomaly AS
WITH daily_shop_revenue AS (
    SELECT
        f.shop_key,
        sh.shop_id,
        sh.address                          AS shop_address,
        sh.city_key                         AS location_key,
        d.full_date,
        ROUND(SUM(f.net_revenue), 2)        AS revenue
    FROM gold.fact_sales f
    JOIN gold.dim_date d ON d.date_key = f.date_key
    JOIN gold.dim_shop sh ON sh.shop_key = f.shop_key
    GROUP BY f.shop_key, sh.shop_id, sh.address, sh.city_key, d.full_date
),
with_expected AS (
    SELECT
        dsr.*,
        ROUND(
            AVG(dsr.revenue) OVER (
                PARTITION BY dsr.shop_key
                ORDER BY dsr.full_date
                ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
            ),
            2
        ) AS expected_revenue
    FROM daily_shop_revenue dsr
)
SELECT
    wer.shop_key,
    wer.shop_id,
    wer.shop_address,
    wer.location_key,
    loc.country_name,
    loc.city_name,
    wer.full_date,
    wer.revenue,
    wer.expected_revenue,
    ROUND(wer.revenue - COALESCE(wer.expected_revenue, 0), 2) AS uplift
FROM with_expected wer
JOIN mart.dim_location loc ON loc.location_key = wer.location_key
WITH DATA;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mart_daily_anomaly_pk
    ON mart.mart_daily_anomaly (shop_key, full_date);
CREATE INDEX IF NOT EXISTS idx_mart_daily_anomaly_location
    ON mart.mart_daily_anomaly (location_key);

-- ---------------------------------------------------------------------------
-- mart_shop_daily — geographic shop performance by day
-- Chart: Map chart, Stacked column chart
-- ---------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS mart.mart_shop_daily;

CREATE MATERIALIZED VIEW mart.mart_shop_daily AS
SELECT
    loc.location_key,
    loc.country_id,
    loc.country_name,
    loc.country_code,
    loc.city_id,
    loc.city_name,
    sh.shop_key,
    sh.shop_id,
    sh.address                              AS shop_address,
    d.full_date,
    d.year_num,
    d.month_num,
    d.month_name,
    d.quarter_num,
    COUNT(f.sales_id)                       AS sales_count,
    ROUND(SUM(f.net_revenue), 2)            AS daily_revenue,
    ROUND(
        AVG(SUM(f.net_revenue)) OVER (PARTITION BY sh.shop_key),
        2
    )                                       AS avg_daily_revenue
FROM gold.fact_sales f
JOIN gold.dim_date d ON d.date_key = f.date_key
JOIN gold.dim_shop sh ON sh.shop_key = f.shop_key
JOIN mart.dim_location loc ON loc.location_key = sh.city_key
GROUP BY
    loc.location_key,
    loc.country_id,
    loc.country_name,
    loc.country_code,
    loc.city_id,
    loc.city_name,
    sh.shop_key,
    sh.shop_id,
    sh.address,
    d.full_date,
    d.year_num,
    d.month_num,
    d.month_name,
    d.quarter_num
WITH DATA;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mart_shop_daily_pk
    ON mart.mart_shop_daily (shop_key, full_date);
CREATE INDEX IF NOT EXISTS idx_mart_shop_daily_location
    ON mart.mart_shop_daily (location_key);
CREATE INDEX IF NOT EXISTS idx_mart_shop_daily_country
    ON mart.mart_shop_daily (country_name);

-- ---------------------------------------------------------------------------
-- mart_customer_behavior — activity status and revenue segmentation
-- Chart: Pie / Donut chart
-- ---------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS mart.mart_customer_behavior;

CREATE MATERIALIZED VIEW mart.mart_customer_behavior AS
WITH customer_metrics AS (
    SELECT
        c.customer_key,
        c.customer_id,
        c.city_key                              AS location_key,
        ROUND(SUM(f.net_revenue), 2)            AS total_revenue,
        COUNT(f.sales_id)                       AS purchases_count,
        MAX(d.full_date)                        AS last_purchase_date
    FROM gold.fact_sales f
    JOIN gold.dim_customer c ON c.customer_key = f.customer_key
    JOIN gold.dim_date d ON d.date_key = f.date_key
    GROUP BY c.customer_key, c.customer_id, c.city_key
),
customer_segments AS (
    SELECT
        cm.*,
        CASE
            WHEN cm.last_purchase_date >= (
                SELECT MAX(full_date) - INTERVAL '90 days'
                FROM gold.dim_date
            ) THEN 'Active'
            ELSE 'Inactive'
        END AS activity_status,
        CASE
            WHEN cm.total_revenue >= 500 THEN 'High'
            WHEN cm.total_revenue >= 150 THEN 'Medium'
            ELSE 'Low'
        END AS revenue_segment
    FROM customer_metrics cm
)
SELECT
    cs.location_key,
    loc.country_name,
    loc.city_name,
    cs.activity_status,
    cs.revenue_segment,
    COUNT(*)                                AS customer_count,
    ROUND(SUM(cs.total_revenue), 2)         AS segment_revenue,
    ROUND(AVG(cs.total_revenue), 2)         AS avg_customer_revenue
FROM customer_segments cs
JOIN mart.dim_location loc ON loc.location_key = cs.location_key
GROUP BY
    cs.location_key,
    loc.country_name,
    loc.city_name,
    cs.activity_status,
    cs.revenue_segment
WITH DATA;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mart_customer_behavior_pk
    ON mart.mart_customer_behavior (
        location_key,
        activity_status,
        revenue_segment
    );
CREATE INDEX IF NOT EXISTS idx_mart_customer_behavior_location
    ON mart.mart_customer_behavior (location_key);

-- ---------------------------------------------------------------------------
-- mart_employee_performance — leaders vs outsiders by profit
-- Chart: Bar / Clustered column chart
-- ---------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS mart.mart_employee_performance;

CREATE MATERIALIZED VIEW mart.mart_employee_performance AS
WITH employee_metrics AS (
    SELECT
        e.employee_key,
        e.employee_id,
        e.full_name,
        e.shop_key,
        sh.shop_id,
        sh.address                              AS shop_address,
        e.city_key                              AS location_key,
        COUNT(f.sales_id)                       AS sales_count,
        ROUND(SUM(f.net_revenue), 2)            AS total_revenue,
        ROUND(SUM(f.profit), 2)                 AS total_profit,
        ROUND(
            SUM(f.profit) / NULLIF(SUM(f.net_revenue), 0),
            4
        )                                       AS margin_ratio
    FROM gold.fact_sales f
    JOIN gold.dim_employee e ON e.employee_key = f.employee_key
    JOIN gold.dim_shop sh ON sh.shop_key = e.shop_key
    GROUP BY
        e.employee_key,
        e.employee_id,
        e.full_name,
        e.shop_key,
        sh.shop_id,
        sh.address,
        e.city_key
),
ranked_employees AS (
    SELECT
        em.*,
        NTILE(3) OVER (ORDER BY em.total_profit DESC) AS profit_tertile
    FROM employee_metrics em
)
SELECT
    re.employee_key,
    re.employee_id,
    re.full_name,
    re.shop_key,
    re.shop_id,
    re.shop_address,
    re.location_key,
    loc.country_name,
    loc.city_name,
    re.sales_count,
    re.total_revenue,
    re.total_profit,
    re.margin_ratio,
    CASE re.profit_tertile
        WHEN 1 THEN 'Leader'
        WHEN 2 THEN 'Average'
        ELSE 'Outsider'
    END AS performance_group
FROM ranked_employees re
JOIN mart.dim_location loc ON loc.location_key = re.location_key
WITH DATA;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mart_employee_performance_pk
    ON mart.mart_employee_performance (employee_key);
CREATE INDEX IF NOT EXISTS idx_mart_employee_performance_location
    ON mart.mart_employee_performance (location_key);
CREATE INDEX IF NOT EXISTS idx_mart_employee_performance_group
    ON mart.mart_employee_performance (performance_group);

-- ---------------------------------------------------------------------------
-- mart_product_seasonality — category sales spikes by month
-- Chart: Line / Area chart (seasonality)
-- ---------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS mart.mart_product_seasonality;

CREATE MATERIALIZED VIEW mart.mart_product_seasonality AS
WITH monthly_category_sales AS (
    SELECT
        cat.category_key,
        cat.category_id,
        cat.category_name,
        d.year_num,
        d.month_num,
        d.month_name,
        d.quarter_num,
        SUM(f.quantity)                         AS total_quantity,
        ROUND(SUM(f.net_revenue), 2)            AS total_revenue
    FROM gold.fact_sales f
    JOIN gold.dim_product pr ON pr.product_key = f.product_key
    JOIN gold.dim_category cat ON cat.category_key = pr.category_key
    JOIN gold.dim_date d ON d.date_key = f.date_key
    GROUP BY
        cat.category_key,
        cat.category_id,
        cat.category_name,
        d.year_num,
        d.month_num,
        d.month_name,
        d.quarter_num
),
seasonality_stats AS (
    SELECT
        mcs.*,
        ROUND(
            AVG(mcs.total_quantity) OVER (PARTITION BY mcs.category_key),
            2
        ) AS avg_monthly_quantity,
        ROUND(
            AVG(mcs.total_revenue) OVER (PARTITION BY mcs.category_key),
            2
        ) AS avg_monthly_revenue,
        MAX(mcs.total_quantity) OVER (
            PARTITION BY mcs.category_key, mcs.month_num
        ) AS peak_quantity_in_month_across_years
    FROM monthly_category_sales mcs
)
SELECT
    ss.category_key,
    ss.category_id,
    ss.category_name,
    ss.year_num,
    ss.month_num,
    ss.month_name,
    ss.quarter_num,
    ss.total_quantity,
    ss.total_revenue,
    ss.avg_monthly_quantity,
    ss.avg_monthly_revenue,
    ROUND(
        ss.total_quantity / NULLIF(ss.avg_monthly_quantity, 0),
        4
    ) AS seasonality_index,
    CASE
        WHEN ss.total_quantity = ss.peak_quantity_in_month_across_years
        THEN TRUE
        ELSE FALSE
    END AS is_peak_period
FROM seasonality_stats ss
WITH DATA;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mart_product_seasonality_pk
    ON mart.mart_product_seasonality (category_key, year_num, month_num);
CREATE INDEX IF NOT EXISTS idx_mart_product_seasonality_category
    ON mart.mart_product_seasonality (category_name);
CREATE INDEX IF NOT EXISTS idx_mart_product_seasonality_peak
    ON mart.mart_product_seasonality (is_peak_period)
    WHERE is_peak_period = TRUE;
