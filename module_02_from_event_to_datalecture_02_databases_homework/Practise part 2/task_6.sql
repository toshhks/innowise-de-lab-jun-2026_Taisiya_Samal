-- Задание 6: DML (Управление платформой)
-- Цель: Объединение DML с JOIN, подзапросами и транзакциями.
--
-- Действия:
-- 1. Найти сотрудников с продажами > 1000.
-- 2. Обновить класс продуктов на 'A' для категорий с общей выручкой > 5000.
-- 3. Установить modify_timestamp (функция NOW()) для продуктов без даты.

begin transaction;

select 
    e.employee_id,
    e.first_name,
    e.last_name,
    count(s.sales_id) as sales_count
from employees e
join sales s on s.employee_id = e.employee_id 
group by e.employee_id, e.first_name, e.last_name 
having count(s.sales_id) > 1000
order by sales_count;

update products 
set class = 'A'
where product_id in (
    select product_id
    from sales 
    group by product_id 
    having sum(total_price) > 5000
);

update products 
set modify_timestamp = now()
where modify_timestamp is null;

commit;