/*Таблица source1.craft_market_wide ждёт не дождётся, когда она наконец станет соответствовать критериям первой нормальной формы. Напомним их:
в таблице нет дублирующих строк;
данные каждого столбца таблицы приведены к одному типу;
атрибуты таблицы приведены к атомарному виду (то есть их нельзя поделить на более мелкие составные значения).
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
