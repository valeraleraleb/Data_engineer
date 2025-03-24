-- В конце предыдущего урока вы изучили таблицу nf_lesson.source_4nf и нашли в ней многозначную зависимость (Subject → Teacher и Subject → Book). Пора с ней попрощаться.
-- Чтобы перевести модель данных из третьей формы в четвёртую, нужно избавиться от  многозначных зависимостей. Они могут возникать только в таблицах с тремя и более колонками. 

/*Создание таблицы nf_lesson.subject_teacher_4nf*/

DROP TABLE IF EXISTS nf_lesson.subject_teacher_4nf;
CREATE TABLE nf_lesson.subject_teacher_4nf AS
SELECT DISTINCT 
	subject, 
	teacher
FROM nf_lesson.source_4nf;


/*Создание таблицы nf_lesson.subject_book_4nf*/

DROP TABLE IF EXISTS nf_lesson.subject_book_4nf;
CREATE TABLE nf_lesson.subject_book_4nf AS
SELECT DISTINCT 
	subject, 
	book
FROM nf_lesson.source_4nf;

-- 5 NF
-- Декомпозиция может привести к потере данных, если в исходной таблице есть зависимости соединения — зависимости между частью данных одного столбца и частью данных другого столбца
-- На какие сущности необходимо декомпозировать таблицу nf_lesson.source_5nf, чтобы избавиться от зависимостей соединения без потерь данных?
-- marketplace-craftsman, marketplace-product и craftsman-product

|marketplace  |craftsman   |craftsman_status|product           |create_dttm            |
|-------------|------------|----------------|------------------|-----------------------|
|Яндекс.Маркет|Иванова А.Л.|ИП              |Джутовая корзина  |2022-02-22 18:15:30.000|
|Яндекс.Маркет|Иванова А.Л.|ИП              |Кухонное полотенце|2022-02-22 18:15:30.000|
|Вайлдберриз  |Сидоров В.П.|ЮЛ              |Свеча             |2022-04-03 16:47:21.000|
|Вайлдберриз  |Сидоров В.П.|ЮЛ              |Джутовая корзина  |2022-04-03 16:47:21.000|
|Вайлдберриз  |Сидоров В.П.|ЮЛ              |Кухонное полотенце|2022-04-03 16:47:21.000|
|Вайлдберриз  |Сидоров В.П.|ЮЛ              |Постельное белье  |2022-04-03 16:47:21.000|
|Озон         |Сидоров В.П.|ЮЛ              |Джутовая корзина  |2022-04-10 10:12:13.000|
|Озон         |Сидоров В.П.|ЮЛ              |Глиняная посуда   |2022-04-10 10:12:13.000|
|Озон         |Иванова А.Л.|ИП              |Джутовая корзина  |2022-04-10 10:12:13.000|
|Озон         |Иванова А.Л.|ИП              |Лампа             |2022-04-10 10:12:13.000|
|Озон         |Петров И.И. |Самозанятый     |Вешалка           |2022-04-10 10:12:13.000|

/*Создание таблицы nf_lesson.marketplace_craftsman_5nf*/

DROP TABLE IF EXISTS nf_lesson.marketplace_craftsman_5nf;
CREATE TABLE nf_lesson.marketplace_craftsman_5nf AS
SELECT DISTINCT 
	marketplace, craftsman, create_dttm
FROM nf_lesson.source_5nf;

/*Создание таблицы nf_lesson.marketplace_product_5nf*/

DROP TABLE IF EXISTS nf_lesson.marketplace_product_5nf;
CREATE TABLE nf_lesson.marketplace_product_5nf AS
SELECT DISTINCT 
	marketplace, product
FROM nf_lesson.source_5nf;

/*Создание таблицы nf_lesson.craftsman_product_5nf*/

DROP TABLE IF EXISTS nf_lesson.craftsman_product_5nf;
CREATE TABLE nf_lesson.craftsman_product_5nf AS
SELECT DISTINCT 
craftsman, craftsman_status, product, create_dttm
FROM nf_lesson.source_5nf;

-- проверка
SELECT DISTINCT 
    mcp.marketplace,
    mcp.craftsman,
    cp.craftsman_status,
    mp.product,
    mcp.create_dttm  -- используем create_dttm из marketplace_craftsman_5nf
FROM nf_lesson.marketplace_craftsman_5nf AS mcp
JOIN nf_lesson.craftsman_product_5nf AS cp 
    ON mcp.craftsman = cp.craftsman
    AND mcp.create_dttm = cp.create_dttm -- добавляем условие, чтобы не было дубликатов
JOIN nf_lesson.marketplace_product_5nf AS mp 
    ON mcp.marketplace = mp.marketplace 
    AND cp.product = mp.product;

--  шестая нормальная форма используется при якорном моделировании хранилищ данных
-- таблица находится в 5NF;
-- таблица неприводима — то есть её нельзя декомпозировать без потерь данных.

-- Взгляните на таблицы из предыдущего урока — мы обогатили их колонкой  create_dttm, чтобы БД стала хронологической. 
-- nf_lesson.marketplace_craftsman_5nf и nf_lesson.craftsman_product_5nf
-- Из этих таблиц можно вынести сущность craftsman_status.

- В конце предыдущего урока вы определились, что из таблиц nf_lesson.marketplace_craftsman_5nf и nf_lesson.craftsman_product_5nf необходимо выделить сущность craftsman_status.

DROP TABLE IF EXISTS nf_lesson.craftsman_craftsman_status_6nf;
CREATE TABLE nf_lesson.craftsman_craftsman_status_6nf AS
SELECT DISTINCT craftsman, craftsman_status, create_dttm
FROM nf_lesson.marketplace_craftsman_5nf;

DROP TABLE IF EXISTS nf_lesson.marketplace_craftsman_6nf;
CREATE TABLE nf_lesson.marketplace_craftsman_6nf AS
SELECT DISTINCT marketplace, craftsman, create_dttm
FROM nf_lesson.marketplace_craftsman_5nf;

DROP TABLE IF EXISTS nf_lesson.craftsman_product_6nf;
CREATE TABLE nf_lesson.craftsman_product_6nf AS
SELECT DISTINCT craftsman, product, create_dttm  
FROM nf_lesson.craftsman_product_5nf;
