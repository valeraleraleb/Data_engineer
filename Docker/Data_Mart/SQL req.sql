-- Изучите, с какими полями предстоит работать — по каким столбцам распределены данные
SELECT c.table_schema,
             c.table_name,
             c.column_name,
             pgd.description
FROM pg_catalog.pg_statio_all_tables AS st
INNER JOIN pg_catalog.pg_description pgd ON (pgd.objoid=st.relid)
INNER JOIN information_schema.columns c ON (pgd.objsubid=c.ordinal_position
AND  c.table_schema=st.schemaname AND c.table_name=st.relname)

-- Напишите для каждой таблицы запрос, который выведет первые 100 записей с перечислением всех полей.
-- Сначала напишите запрос к таблице user_attributes.
-- Не забудьте перечислить все нужные поля, а не запросить их разом.
SELECT id, client_id, utm_campaign
FROM public.user_attributes
limit 100;

-- Теперь напишите запрос к таблице user_payment_log.
SELECT id, client_id, hitdatetime, "action", payment_amount
FROM public.user_payment_log
limit 100;

-- Сейчас напишите запрос к таблице user_activity_log. Выведите из таблицы три поля: client_id, hitdatetime и action.
SELECT client_id, hitdatetime, "action"
FROM public.user_activity_log
limit 100;

-- Теперь нужно узнать, как таблицы связаны. В метаданных таблиц перечислены внешние ключи.
SELECT
tc.table_name,
kcu.column_name,
ccu.table_name AS foreign_table_name,
ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
ON tc.constraint_name = kcu.constraint_name
AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
ON ccu.constraint_name = tc.constraint_name
AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY';

-- Соедините таблицы user_attributes и user_activity_log по найденным связям так, чтобы вошли только записи, которые есть в них обеих. В SELECT выведите все поля.
-- Выведите только 100 записей со столбцами левой и правой таблиц.
 select *
 from user_attributes
 inner join user_activity_log
 using (client_id)
 limit 100;

-- Соедините таблицы user_attributes и user_payment_log по найденным связям так, чтобы вошли только записи, которые есть в них обеих. В SELECT выведите все поля.
 select *
 from user_attributes
 join user_payment_log
 using (client_id)
 limit 100;

-- 





