-- Задание 4: DML/DCL (Сложные операции с пайплайнами)
-- Цель: Практика DML с использованием WHERE, JOIN и транзакций для поддержки Data Platform.
--
-- Действия:
-- 1. Увеличить цену всех продуктов категории 'Fruits' на 10%.
-- 2. Удалить всех сотрудников без продаж.
-- 3. Вставить нового сотрудника и первую продажу в одной транзакции.

update products 
set price = price * 1.1
where category_id = (
    select category_id 
    from categories 
    where category_name = 'Fruits'
);

delete from employees 
where employee_id not in (
    select distinct employee_id 
    from sales 
    where employee_id is not null
);

select setval('sales_sales_id_seq', (select max(sales_id) from sales));
select setval('employees_employee_id_seq', (select max(employee_id) from employees));

begin transaction;

insert into employees (first_name, last_name, birth_date, city_id, shop_id, hire_date) 
values ('Grisha', 'Zubik', '2008-08-20', 1, 1, '2013-11-06');
insert into sales (employee_id, customer_id, product_id, quantity, total_price, sales_timestamp, transaction_number) 
values (4, 4, 4, 4, 160, current_timestamp, 'T00000001234567890028');

commit;