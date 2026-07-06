-- Часть 7 : Финал
-- Для каждого магазина рассчитать агрегаты продаж и аналитические показатели в разрезе страны.
--
-- Для каждого магазина посчитать:
-- - количество продаж (COUNT(sales_id))
-- - общую сумму продаж (SUM(total_price))
-- - Оставить только магазины, у которых не менее 2 продаж.
--
-- Для каждого такого магазина рассчитать:
-- - долю оборота магазина от общего оборота страны
-- - ранг магазина по сумме продаж внутри своей страны
-- - накопительный оборот по стране, отсортированный по убыванию оборота магазина
--
-- Отсортировать результат:
-- - по стране
-- - по рангу магазина

with shop_data as (
    select 
        c2.country_name,
        s2.shop_id,
        s2.address as shop_address,
        count(s.sales_id) as total_sales_count,
        sum(s.total_price) as total_sales_amount
    from sales s
    join employees e on s.employee_id = e.employee_id 
    join shops s2 on e.shop_id = s2.shop_id
    join cities c on s2.city_id = c.city_id
    join countries c2 on c.country_id = c2.country_id
    group by c2.country_name, s2.shop_id, s2.address
    having count(s.sales_id) >= 2
)
select 
    country_name,
    shop_id,
    shop_address,
    total_sales_count,
    total_sales_amount,
    round(100.0 * total_sales_amount / sum(total_sales_amount) over (partition by country_name), 2) as share_percent,
    rank() over (partition by country_name order by total_sales_amount desc) as rank_of_country,
    sum(total_sales_amount) over (partition by country_name order by total_sales_amount desc) as country_running_total
from shop_data
order by country_name, rank_of_country;