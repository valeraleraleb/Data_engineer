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
