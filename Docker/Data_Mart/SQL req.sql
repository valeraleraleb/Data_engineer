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

-- Выгрузите из таблицы user_activity_log первые 10 записей с идентификатором клиента, датой захода (дата события, если событие visit, и NULL иначе) и флагом регистрации (1, если событие registration, и 0 иначе).
-- Метрики положите в новые столбцы visit_dt и is_registration.
SELECT 
client_id
, case
	when action = 'visit' then hitdatetime else NULL
end as visit_dt
, case
	when action = 'registration' then 1 else 0
end is_registration
FROM public.user_activity_log
limit 10;

-- В конечной витрине данные нужны совокупно по каждому клиенту, поэтому метрики из предыдущего задания нужно агрегировать.
-- Выгрузите первые 10 записей, в которых для каждого пользователя содержится:
-- client_id — идентификатор клиента;
-- fst_visit_dt — дата первого посещения сайта;
-- registration_dt — дата регистрации. Если таких событий несколько, возьмите самое раннее;
-- is_registration — флаг регистрации ( 1, если пользователь когда-либо зарегистрировался, и 0 иначе).
-- Приведите колонки с датами к типу DATE.

SELECT client_id,
       DATE(MIN(CASE WHEN action = 'visit' THEN hitdatetime ELSE NULL END)) AS fst_visit_dt,
       DATE(MIN(CASE WHEN action = 'registration' THEN hitdatetime ELSE NULL END)) AS registration_dt,
       MAX(CASE WHEN action = 'registration' THEN 1 ELSE 0 END) AS is_registration
FROM user_activity_log
GROUP BY client_id
LIMIT 10;

-- Помимо данных по посещению и регистрации, в витрине необходима также информация о платежах и о маркетинговой кампании, чтобы проанализировать оборот. 
-- Для этого нужно объединить данные из нескольких таблиц.
-- Соберите все данные в витрину с полями:
-- client_id — идентификатор клиента;
-- utm_campaign — маркетинговая кампания;
-- fst_visit_dt — дата первого посещения сайта;
-- registration_dt — дата регистрации клиента;
-- is_registration — 1, если клиент регистрировался, 0 иначе;
-- total_payment_amount — сумма платежей клиента.

SELECT ua.client_id,
       ua.utm_campaign,
       ual.fst_visit_dt,
       ual.registration_dt,
       ual.is_registration,
       upl.total_payment_amount
FROM user_attributes AS ua
LEFT JOIN (
       SELECT client_id,
              DATE(MIN(CASE WHEN action = 'visit' THEN hitdatetime ELSE NULL END)) AS fst_visit_dt,
              DATE(MIN(CASE WHEN action = 'registration' THEN hitdatetime ELSE NULL END)) AS registration_dt,
              MAX(CASE WHEN action = 'registration' THEN 1 ELSE 0 END) AS is_registration
       FROM user_activity_log
       GROUP BY client_id
) AS ual
ON ua.client_id = ual.client_id
LEFT JOIN (
       SELECT client_id,
              SUM(payment_amount) AS total_payment_amount
       FROM user_payment_log
       GROUP BY client_id
) AS upl
ON ua.client_id = upl.client_id
limit 10;

-- Запрос из предыдущего задания получился очень громоздкий. Читать его сложно и неудобно. 
-- Сделайте запрос более понятным, вынеся все подзапросы в CTE.

WITH ual AS (
    SELECT client_id,
              DATE(MIN(CASE WHEN action = 'visit' THEN hitdatetime ELSE NULL END)) AS fst_visit_dt,
              DATE(MIN(CASE WHEN action = 'registration' THEN hitdatetime ELSE NULL END)) AS registration_dt,
              MAX(CASE WHEN action = 'registration' THEN 1 ELSE 0 END) AS is_registration
       FROM user_activity_log
       GROUP BY client_id
),

upl AS (
	 SELECT client_id,
	              SUM(payment_amount) AS total_payment_amount
	       FROM user_payment_log
	       GROUP BY client_id
)

SELECT ua.client_id,
       ua.utm_campaign,
       ual.fst_visit_dt,
       ual.registration_dt,
       ual.is_registration,
       upl.total_payment_amount
FROM user_attributes AS ua
LEFT JOIN ual using (client_id)
LEFT JOIN upl using (client_id)
limit 10;
