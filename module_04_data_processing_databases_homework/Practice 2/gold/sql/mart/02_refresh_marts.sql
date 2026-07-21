-- Refresh all mart materialized views (run after Gold ETL)

REFRESH MATERIALIZED VIEW mart.mart_daily_anomaly;
REFRESH MATERIALIZED VIEW mart.mart_shop_daily;
REFRESH MATERIALIZED VIEW mart.mart_customer_behavior;
REFRESH MATERIALIZED VIEW mart.mart_employee_performance;
REFRESH MATERIALIZED VIEW mart.mart_product_seasonality;
