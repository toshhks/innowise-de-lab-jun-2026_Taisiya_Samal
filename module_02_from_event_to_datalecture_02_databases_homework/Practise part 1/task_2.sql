-- Часть 2

-- Задача 1: Вывести все магазины расположенные в 'Poland'.

SELECT
    s.shop_id,
    s.address,
    c.city_name,
    co.country_name
FROM shops AS s
INNER JOIN cities AS c ON s.city_id = c.city_id
INNER JOIN countries AS co ON c.country_id = co.country_id
WHERE co.country_name = 'Poland';

-- Задача 2: Вывести все транзакции с суммой продажи выше 1500 (total_price > 1500) 
-- для продуктов класса A (class = 'A'), выполнить сортировку по номеру транзакции.

SELECT
    s.transaction_number,
    p.product_name,
    s.total_price,
    s.customer_id,
    s.sales_timestamp
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE p.class = 'A' AND s.total_price > 1500
ORDER BY s.transaction_number;