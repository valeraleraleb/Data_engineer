/*Таблица source1.craft_market_wide ждёт когда она станет соответствовать критериям первой нормальной формы:
- в таблице нет дублирующих строк;
- данные каждого столбца таблицы приведены к одному типу;
- атрибуты таблицы приведены к атомарному виду (то есть их нельзя поделить на более мелкие составные значения).
*/

/* Создание схемы nf_lesson */
create schema nf_lesson;

/* Создание таблицы nf_lesson.preparatory_1_1nf */
DROP TABLE IF EXISTS nf_lesson.preparatory_1_1nf;

CREATE TABLE nf_lesson.preparatory_1_1nf AS
SELECT
	id -- идентификатор записи
	, craftsman_name
	, craftsman_address
	, customer_name
	, customer_address
FROM source1.craft_market_wide;

/* Задание первичного ключа таблицы */
ALTER TABLE nf_lesson.preparatory_1_1nf ADD CONSTRAINT pk_preparatory_1_1nf PRIMARY KEY (id);

DROP TABLE IF EXISTS nf_lesson.preparatory_2_1nf;

CREATE TABLE nf_lesson.preparatory_2_1nf AS
SELECT  id
	, (regexp_split_to_array(craftsman_name, '\s+'))[1] as craftsman_name -- имя мастера
	, (regexp_split_to_array(craftsman_name, '\s+'))[2] as craftsman_surname -- фамилия мастера
	, craftsman_address -- адрес мастера
	, (regexp_split_to_array(customer_name, '\s+'))[1] as customer_name -- имя заказчика
	, (regexp_split_to_array(customer_name, '\s+'))[2] as customer_surname -- фамилия заказчика
	, customer_address -- адрес заказчика
FROM nf_lesson.preparatory_1_1nf;

/* Задание первичного ключа таблицы */
ALTER TABLE nf_lesson.preparatory_2_1nf ADD CONSTRAINT pk_preparatory_2_1nf PRIMARY KEY (id);

/* Создание таблицы nf_lesson.preparatory_3_1nf */

DROP TABLE IF EXISTS nf_lesson.preparatory_3_1nf;
CREATE TABLE nf_lesson.preparatory_3_1nf AS
/* Запрос */
SELECT id -- идентификатор записи 
	/* Задайте выражение для создания колонок:
				-- имя мастера
				-- фамилия мастера
				-- номер дома мастера
				-- название улицы мастера
				-- имя заказчика
				-- фамилия заказчика
				-- номер дома заказчика
				-- название улицы заказчика
 */
	, craftsman_name -- имя мастера
	, craftsman_surname -- фамилия мастера
	--, craftsman_address -- адрес мастера
	, (regexp_match(craftsman_address, '\d+'))[1] as craftsman_address_building
	, (regexp_match(craftsman_address, '[a-zA-Z]+[a-zA-Z\s]+'))[1] as craftsman_address_street
	, customer_name -- имя заказчика
	, customer_surname -- фамилия заказчика
	--, customer_address -- адрес заказчика
	, (regexp_match(customer_address, '\d+'))[1] as customer_address_building
	, (regexp_match(customer_address, '[a-zA-Z]+[a-zA-Z\s]+'))[1] as customer_address_street
FROM nf_lesson.preparatory_2_1nf;

/* Задание первичного ключа таблицы */
ALTER TABLE nf_lesson.preparatory_3_1nf ADD CONSTRAINT pk_preparatory_3_1nf PRIMARY KEY (id);

/////////////////////////////////////////////////////////////////////////////////
DROP TABLE IF EXISTS nf_lesson.craft_market_wide_1nf;
CREATE TABLE nf_lesson.craft_market_wide_1nf AS
/* Запрос */
SELECT id -- идентификатор записи 
	, (regexp_split_to_array(craftsman_name, '\s+'))[1] as craftsman_name -- имя мастера
	, (regexp_split_to_array(craftsman_name, '\s+'))[2] as craftsman_surname -- фамилия мастера
	, (regexp_match(craftsman_address, '\d+'))[1] as craftsman_address_building
	, (regexp_match(craftsman_address, '[a-zA-Z]+[a-zA-Z\s]+'))[1] as craftsman_address_street
	, (regexp_split_to_array(customer_name, '\s+'))[1] as customer_name -- имя заказчика
	, (regexp_split_to_array(customer_name, '\s+'))[2] as customer_surname -- фамилия заказчика
	, (regexp_match(customer_address, '\d+'))[1] as customer_address_building
	, (regexp_match(customer_address, '[a-zA-Z]+[a-zA-Z\s]+'))[1] as customer_address_street
FROM source1.craft_market_wide;

ALTER TABLE nf_lesson.craft_market_wide_1nf ADD CONSTRAINT pk_craft_market_wide_1nf PRIMARY KEY (id);

-- Чтобы перевести модель данных в 2NF, должны выполняться следующие критерии:
-- модель данных находится в 1NF;
-- у всех таблиц модели есть первичный ключ;
-- неключевые поля таблиц зависят от первичного ключа.

-- Изучите данные в таблице nf_lesson.craft_market_wide_1nf. Убедитесь, что таблица не соответствует критериям 2NF. 
-- Проверьте, есть ли в идентификаторах craftsman_id, product_id, order_id и customer_id поля с повторяющимися значениями
SELECT craftsman_id, Count(*)
from nf_lesson.craft_market_wide_1nf
group by craftsman_id
having COUNT(*) > 1;

SELECT product_id, Count(*)
from nf_lesson.craft_market_wide_1nf
group by product_id
having COUNT(*) > 1;


SELECT order_id, Count(*)
from nf_lesson.craft_market_wide_1nf
group by order_id
having COUNT(*) > 1;

SELECT 
customer_id, Count(*)
from nf_lesson.craft_market_wide_1nf
group by customer_id
having COUNT(*) > 1;

-- Чтобы перевести таблицу nf_lesson.craft_market_wide_1nf во вторую нормальную форму, нужно разделить её на две сущности — order и product. 
-- В order будет храниться информация о заказе и покупателе, а в product — об изделии и мастере.
-- Создайте таблицу nf_lesson.order_2nf для выделенной сущности order. 

DROP TABLE IF EXISTS nf_lesson.order_2nf;

CREATE TABLE nf_lesson.order_2nf AS
SELECT DISTINCT 
	order_id
	, product_id
	, order_created_date
	, order_completion_date
	, order_status
	, customer_id
	, customer_name
	, customer_surname
	, customer_address_street
	, customer_address_building
	, customer_birthday
	, customer_email
FROM nf_lesson.craft_market_wide_1nf;

ALTER TABLE nf_lesson.order_2nf ADD CONSTRAINT pk_order_2nf PRIMARY KEY (order_id);

-- Создайте таблицу nf_lesson.product_2nf для выделенной сущности product.

DROP TABLE IF EXISTS nf_lesson.product_2nf;

CREATE TABLE nf_lesson.product_2nf AS
SELECT DISTINCT 
	craftsman_id
	, craftsman_name
	, craftsman_surname
	, craftsman_address_street
	, craftsman_address_building
	, craftsman_birthday
	, craftsman_email
	, product_id
	, product_name
	, product_description
	, product_type
	, product_price
FROM nf_lesson.craft_market_wide_1nf;

ALTER TABLE nf_lesson.product_2nf ADD CONSTRAINT pk_product_2nf PRIMARY KEY (craftsman_id, product_id);

-- Таким образом, таблица находится в 3NF, если:
-- она находится во второй нормальной форме;
-- все неключевые поля таблицы нетранзитивно зависят от ключевого поля.

-- Для начала декомпозируйте таблицу nf_lesson.order_2nf — создайте таблицы nf_lesson.order_3nf 
-- и nf_lesson.customer_3nf, в которых все неключевые поля будут нетранзитивно зависеть от ключевого поля

DROP TABLE IF EXISTS nf_lesson.order_3nf;
CREATE TABLE nf_lesson.order_3nf AS
SELECT DISTINCT 
	order_id
	, order_created_date
	, order_completion_date
	, order_status
	, customer_id
	, product_id
FROM nf_lesson.order_2nf;

ALTER TABLE nf_lesson.order_3nf ADD CONSTRAINT pk_order_3nf PRIMARY KEY (order_id);

DROP TABLE IF EXISTS nf_lesson.customer_3nf;
CREATE TABLE nf_lesson.customer_3nf AS
SELECT DISTINCT 
	customer_id
	, customer_name
	, customer_surname
	, customer_address_street
	, customer_address_building
	, customer_birthday
	, customer_email
FROM nf_lesson.order_2nf;

ALTER TABLE nf_lesson.customer_3nf ADD CONSTRAINT pk_customer_3nf PRIMARY KEY (customer_id);


-- Теперь декомпозируйте таблицу nf_lesson.product_2nf. 
-- Создайте таблицы nf_lesson.product_3nf и nf_lesson.craftsman_3nf, в которых все неключевые поля будут нетранзитивно зависеть от ключевого поля

/*Создание таблиц nf_lesson.product_3nf*/
DROP TABLE IF EXISTS nf_lesson.product_3nf;
CREATE TABLE nf_lesson.product_3nf AS
SELECT DISTINCT 
	product_id
	, product_name
	, product_description
	, product_type
	, product_price
	, craftsman_id
FROM nf_lesson.product_2nf;

ALTER TABLE nf_lesson.product_3nf ADD CONSTRAINT pk_product_3nf PRIMARY KEY (product_id);

/*Создание таблиц nf_lesson.craftsman_3nf*/

DROP TABLE IF EXISTS nf_lesson.craftsman_3nf;
CREATE TABLE nf_lesson.craftsman_3nf AS
SELECT DISTINCT 
	craftsman_id
	, craftsman_name
	, craftsman_surname
	, craftsman_address_street
	, craftsman_address_building
	, craftsman_birthday
	, craftsman_email 
FROM nf_lesson.product_2nf;

ALTER TABLE nf_lesson.craftsman_3nf ADD CONSTRAINT pk_craftsman_3nf PRIMARY KEY (craftsman_id);

-- Чтобы перевести модель данных из третьей формы в четвёртую, нужно избавиться от  многозначных зависимостей. 
-- Они могут возникать только в таблицах с тремя и более колонками.
