-- Часть 4

-- Задача 1: Вывести по каждому продукту сумму продаж и средний чек,
-- где сумма продаж выше 400,000.00.
-- Отсортировать по сумме продаж по убыванию.

SELECT
    p.product_name,
    SUM(s.total_price) AS total_revenue,
    AVG(s.total_price) AS avg_sale
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
HAVING SUM(s.total_price) > 400000.00
ORDER BY total_revenue DESC;