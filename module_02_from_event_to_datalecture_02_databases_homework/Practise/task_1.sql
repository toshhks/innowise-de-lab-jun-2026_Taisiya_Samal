-- Часть 1

-- Задача 1: Вывести для каждой продажи (sales_id) название продукта и адрес магазина

SELECT
    s.sales_id,
    p.product_name,
    sh.address
FROM sales AS s
INNER JOIN products  AS p  ON s.product_id = p.product_id
INNER JOIN employees AS e  ON s.employee_id = e.employee_id
INNER JOIN shops     AS sh ON e.shop_id = sh.shop_id;

