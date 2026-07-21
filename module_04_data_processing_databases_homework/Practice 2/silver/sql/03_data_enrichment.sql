-- Stage 4: Enrich sales with shop_id and city_id from employees

UPDATE silver.sales s
SET
    shop_id = e.shop_id,
    city_id = e.city_id
FROM silver.employees e
WHERE s.employee_id = e.employee_id;
