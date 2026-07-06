-- Задание 2: Работа с DDL
-- Цель: Практика создания и изменения структуры таблиц, управляющих пайплайнами данных.
--
-- Действия:
-- 1. Создать новую таблицу с именем Data_Layers необходимую для описания слоев со столбцами: 
--    LayerID (SERIAL, PRIMARY KEY), LayerName (VARCHAR(50), UNIQUE, NOT NULL), Description (TEXT).
-- 2. Заполнить колонку LayerName тремя значениями 'Bronze', 'Silver', 'Gold', 
--    которые обозначают слои в медальонной архитектуре.
-- 3. Добавить колонку manager_email в таблицу Data_Layers (VARCHAR(100)).
-- 4. Добавить ограничение UNIQUE к столбцу manager_email в таблице Data_Layers 
--    (предварительно заполнив столбец любыми значениями, чтобы избежать ошибки).
-- 5. Переименовать столбец address в таблице Shops в shop_address.


create table data_layers (
    layer_id serial primary key,
    layer_name varchar(50) unique not null,
    description text
);

insert into data_layers (layer_name) values ('Bronze'), ('Silver'), ('Gold');

alter table data_layers add manager_email varchar(100);

update data_layers set manager_email = 'bronze@example.com' where layer_name = 'Bronze';
update data_layers set manager_email = 'silver@example.com' where layer_name = 'Silver';
update data_layers set manager_email = 'gold@example.com' where layer_name = 'Gold';

alter table data_layers add constraint unique_manager_email unique (manager_email);

alter table shops rename column address to shop_address;