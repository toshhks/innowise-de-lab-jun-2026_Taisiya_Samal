-- Silver -> Gold: incremental load of fact_sales

DO $$
DECLARE
    v_load_id       INTEGER;
    v_last_id       BIGINT;
    v_rows          INTEGER;
    v_new_watermark BIGINT;
BEGIN
    SELECT COALESCE(MAX(watermark_value), 0)
    INTO v_last_id
    FROM gold.etl_load_log
    WHERE target_table = 'fact_sales'
      AND status = 'SUCCESS';

    INSERT INTO gold.etl_load_log (target_table, status, watermark_value)
    VALUES ('fact_sales', 'RUNNING', v_last_id)
    RETURNING load_id INTO v_load_id;

    INSERT INTO gold.fact_sales (
        sales_id,
        transaction_number,
        date_key,
        product_key,
        customer_key,
        employee_key,
        shop_key,
        city_key,
        quantity,
        total_revenue,
        discount_amount,
        net_revenue,
        profit,
        margin
    )
    SELECT
        s.sales_id,
        s.transaction_number,
        dd.date_key,
        dp.product_key,
        dc.customer_key,
        de.employee_key,
        dsh.shop_key,
        dci.city_key,
        s.quantity,
        ROUND(s.quantity * p.price, 2) AS total_revenue,
        ROUND(s.quantity * p.price * s.discount, 2) AS discount_amount,
        s.total_price AS net_revenue,
        ROUND(s.total_price - (s.quantity * p.price * 0.65), 2) AS profit,
        ROUND(
            (s.total_price - (s.quantity * p.price * 0.65))
            / NULLIF(s.total_price, 0),
            4
        ) AS margin
    FROM silver.sales s
    JOIN silver.products p ON p.product_id = s.product_id
    JOIN gold.dim_date dd ON dd.full_date = s.sales_timestamp::DATE
    JOIN gold.dim_product dp
        ON dp.product_id = s.product_id
       AND s.sales_timestamp >= dp.valid_from_dt
       AND s.sales_timestamp <= dp.valid_to_dt
    JOIN gold.dim_customer dc ON dc.customer_id = s.customer_id
    JOIN gold.dim_employee de ON de.employee_id = s.employee_id
    JOIN gold.dim_shop dsh ON dsh.shop_id = s.shop_id
    JOIN gold.dim_city dci ON dci.city_id = s.city_id
    WHERE s.sales_id > v_last_id
      AND NOT EXISTS (
          SELECT 1
          FROM gold.fact_sales fs
          WHERE fs.sales_id = s.sales_id
      );

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    SELECT COALESCE(MAX(sales_id), v_last_id)
    INTO v_new_watermark
    FROM gold.fact_sales;

    UPDATE gold.etl_load_log
    SET
        load_finished_at = NOW(),
        rows_affected = v_rows,
        watermark_value = v_new_watermark,
        status = 'SUCCESS'
    WHERE load_id = v_load_id;

EXCEPTION
    WHEN OTHERS THEN
        UPDATE gold.etl_load_log
        SET
            load_finished_at = NOW(),
            status = 'FAILED',
            error_message = SQLERRM
        WHERE load_id = v_load_id;
        RAISE;
END $$;
