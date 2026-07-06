-- Часть 6

-- Задача 1: Найти выручку всех магазинов в Германии по месяцам 
-- и разницу с предыдущим месяцем. Применить сортировку по месяцам по возрастанию.

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', s.sales_timestamp)::DATE AS sale_month,
        SUM(s.total_price) AS monthly_revenue
    FROM sales s
    JOIN employees e ON s.employee_id = e.employee_id
    JOIN shops sh ON e.shop_id = sh.shop_id
    JOIN cities c ON sh.city_id = c.city_id
    JOIN countries co ON c.country_id = co.country_id
    WHERE co.country_name = 'Germany'
    GROUP BY DATE_TRUNC('month', s.sales_timestamp)
)
SELECT
    sale_month,
    monthly_revenue,
    LAG(monthly_revenue, 1, 0) OVER (ORDER BY sale_month) AS previous_month_revenue,
    monthly_revenue - LAG(monthly_revenue, 1, 0) OVER (ORDER BY sale_month) AS revenue_diff_vs_previous
FROM monthly_revenue
ORDER BY sale_month;