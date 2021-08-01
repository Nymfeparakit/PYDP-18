--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия регионов из таблицы адресов

SELECT DISTINCT district FROM address;





--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те регионы, 
--названия которых начинаются на "K" и заканчиваются на "a", и названия не содержат пробелов

SELECT DISTINCT district FROM address WHERE district LIKE 'K%a' AND district NOT LIKE '% %';




--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 марта 2007 года по 19 марта 2007 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.

SELECT payment_id, payment_date, amount 
FROM payment 
WHERE payment_date BETWEEN '2007-03-17' AND '2007-03-20'
AND amount > 1.00
ORDER BY payment_date;




--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.

SELECT payment_id, payment_date, amount 
FROM payment 
ORDER BY payment_date DESC
LIMIT 10;




--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.

SELECT CONCAT(first_name, ' ', last_name) AS "Фамилия и имя", email AS "Электронная почта", 
LENGTH(email) AS "Длина Email", last_update::DATE AS "Дата"
FROM customer;



--ЗАДАНИЕ №6
--Выведите одним запросом активных покупателей, имена которых Kelly или Willie.
--Все буквы в фамилии и имени из нижнего регистра должны быть переведены в высокий регистр.

SELECT UPPER(last_name) AS "last_name", UPPER(first_name) AS "first_name"
FROM customer
WHERE first_name ILIKE 'Kelly' OR first_name ILIKE 'Willie'
AND activebool = 'true';



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.

SELECT film_id, title, description, rating, rental_rate 
FROM film
WHERE rating::TEXT ILIKE 'R' AND rental_rate >= 0.00 AND rental_rate <= 3.00
OR rating::TEXT ILIKE 'PG-13' AND rental_rate >= 4;



--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.

SELECT film_id, title, description
FROM film
ORDER BY LENGTH(description) DESC
LIMIT 3;


--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.

SELECT customer_id, email AS "Email", 
SUBSTRING(email FROM 1 FOR STRPOS(email, '@')-1) AS "Email before @",
SUBSTRING(email FROM STRPOS(email,'@')+1 FOR LENGTH(email)-STRPOS(email, '@')) AS "Email after @"
FROM customer
WHERE email LIKE '%@%'
ORDER BY customer_id;



--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.

SELECT customer_id, email AS "Email", 
CONCAT(UPPER(SUBSTRING(email FROM 1 FOR 1)), SUBSTRING(email FROM 2 FOR STRPOS(email, '@')-1)) AS "Email before @",
CONCAT(UPPER(SUBSTRING(email FROM STRPOS(email,'@')+1 FOR 1)), SUBSTRING(email FROM STRPOS(email,'@')+2 FOR LENGTH(email)-STRPOS(email, '@')-1)) AS "Email after @"
FROM customer
WHERE email LIKE '%@%'
ORDER BY customer_id;


