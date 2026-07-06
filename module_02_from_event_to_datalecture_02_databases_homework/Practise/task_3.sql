-- Часть 3

-- Задача 1: Вывести количество магазинов (Shops) в каждой стране
-- и отсортировать по количеству магазинов по убыванию.

SELECT
    co.country_name,
    COUNT(*) AS shops_count
FROM shops AS s
JOIN cities AS c ON s.city_id = c.city_id
JOIN countries AS co ON c.country_id = co.country_id
GROUP BY co.country_name
ORDER BY shops_count DESC;