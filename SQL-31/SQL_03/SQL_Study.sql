--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
SELECT CONCAT(c.last_name, ' ', c.first_name) AS "Фамилия и имя", a.address AS "Адрес", c2.city AS "Город", c3.country AS "Страна" 
FROM customer c
INNER JOIN address a ON c.address_id = a.address_id 
INNER JOIN city c2 ON a.city_id = c2.city_id 
INNER JOIN country c3 ON c2.country_id = c3.country_id;




--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
SELECT store_id AS "ID магазина", COUNT(customer_id) AS "Количество покупателей"
FROM customer
GROUP BY store_id;




--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
SELECT store_id AS "ID магазина", COUNT(customer_id) AS "Количество покупателей"
FROM customer
GROUP BY store_id
HAVING COUNT(customer_id) > 300;




-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
SELECT c.store_id AS "ID магазина", COUNT(c.customer_id) AS "Количество покупателей", c2.city AS "Город магазина", CONCAT(s2.last_name, ' ', s2.first_name)
FROM customer c
JOIN store s ON c.store_id = s.store_id 
JOIN address a ON s.address_id = a.address_id 
JOIN city c2 ON a.city_id = c2.city_id
JOIN staff s2 ON s.manager_staff_id = s2.staff_id
GROUP BY c.store_id, c2.city_id, s2.staff_id
HAVING COUNT(c.customer_id) > 300;




--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
SELECT CONCAT(c.last_name, ' ', c.first_name) AS "Фамилия и имя покупателя", COUNT(r.inventory_id) AS "Количество фильмов"
FROM customer c 
JOIN rental r ON c.customer_id = r.customer_id 
GROUP BY c.customer_id
ORDER BY COUNT(r.inventory_id) DESC
LIMIT 5;




--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
SELECT CONCAT(c.last_name, ' ', c.first_name) AS "Фамилия и имя покупателя", COUNT(r.inventory_id) AS "Количество фильмов",
ROUND(SUM(p.amount)) AS "Общая стоимость платежей", MIN(p.amount) AS "Минимальная стоимость платежа",
MAX(p.amount) AS "Максимальная стоимость платежа"
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id 
JOIN rental r ON  p.rental_id = r.rental_id
GROUP BY c.customer_id; 




--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
SELECT c.city AS "Город 1", c2.city AS "Город 2"
FROM city c 
CROSS JOIN city c2
WHERE c.city != c2.city;




--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
SELECT r.customer_id AS "ID покупателя", 
ROUND(AVG(DATE_PART('day', r.return_date - r.rental_date) + DATE_PART('hour', r.return_date - r.rental_date)/24 + DATE_PART('minute', r.return_date - r.rental_date)/1440)::numeric, 2) AS "Среднее кол-во дней на возврат"
FROM rental r 
GROUP BY r.customer_id
ORDER BY r.customer_id ASC;




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
SELECT f.title AS "Название", f.rating AS "Рейтинг", c.name AS "Жанр", f.release_year AS "Год выпуска", 
l.name AS "Язык", COUNT(r.rental_id) AS "Количество аренд", SUM(p.amount) AS "Общая стоимость аренды"
FROM rental r 
JOIN inventory i ON r.inventory_id = i.inventory_id 
JOIN payment p ON r.rental_id = p.rental_id 
JOIN film f ON i.film_id = f.film_id 
JOIN language l ON f.language_id = l.language_id 
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id 
GROUP BY f.film_id, c.category_id, l.language_id
ORDER BY f.title ASC;




--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

SELECT f.title AS "Название", f.rating AS "Рейтинг", c.name AS "Жанр", f.release_year AS "Год выпуска", 
l.name AS "Язык", COUNT(r.rental_id) AS "Количество аренд", SUM(p.amount) AS "Общая стоимость аренды"
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id 
JOIN category c ON c.category_id = fc.category_id 
JOIN language l ON f.language_id = l.language_id 
LEFT JOIN inventory i ON i.film_id  = f.film_id 
LEFT JOIN rental r ON r.inventory_id = i.inventory_id
LEFT JOIN payment p ON p.rental_id = r.rental_id 
GROUP BY f.film_id, c.name, l.name
HAVING COUNT(r.rental_id) = 0
ORDER BY f.title ASC;




--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
SELECT s.staff_id AS "ID сотрудника", COUNT(p.payment_id) AS "Количество продаж", 
	CASE
		WHEN COUNT(p.payment_id) > 7300 THEN 'Да'
		ELSE 'Нет'
	END "Премия"
FROM staff s 
JOIN payment p ON s.staff_id = p.staff_id 
GROUP BY s.staff_id;





