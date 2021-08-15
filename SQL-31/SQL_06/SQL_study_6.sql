--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
explain analyze
select f.film_id, f.title, f.special_features
from film f
where f.special_features @> '{"Behind the Scenes"}';




--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
explain analyze
select f.film_id, f.title, f.special_features
from film f
where 'Behind the Scenes' = any(f.special_features);

explain analyze
select f.film_id, f.title, f.special_features
from film f
where array_to_string(f.special_features, ',') like '%Behind the Scenes%';




--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

explain analyze
with cte_film as(
	select f.film_id, f.title, f.special_features
	from film f
	where f.special_features @> '{"Behind the Scenes"}'
)
select c.customer_id, count(cte_film.film_id) 
from customer c 
join rental r on r.customer_id = c.customer_id 
join inventory i on i.inventory_id = r.inventory_id 
join cte_film on cte_film.film_id = i.film_id
group by c.customer_id;



--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

explain analyze
select c.customer_id, count(fsp.film_id) 
from customer c
join rental r on r.customer_id = c.customer_id 
join inventory i on i.inventory_id = r.inventory_id
join (
	select f.film_id, f.title, f.special_features
	from film f
	where f.special_features @> '{"Behind the Scenes"}'
) fsp on fsp.film_id = i.film_id
group by c.customer_id;



--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create materialized view get_special_films as
select f.film_id, f.title, f.special_features
from film f
where f.special_features @> '{"Behind the Scenes"}'
with data;

refresh materialized view 
get_special_films;



--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

-- Решение
-- 1 Быстрее всего происходит поиск с оператором проверки вхождения подмассива в массив @> - 
-- время обработки запроса составило 0.363 ms, в случае использования операторов 'any' и 'like'
-- времена обработки запросов были соответсвенно 1.207 и 1.779 ms

-- 2 Время работы запроса, использующего CTE составило 7.710 ms, а время работы запроса с 
-- подзапросом - 8.328 секунд. Следовательно, вариант использования CTE предпочтительнее 



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

-- Время выполнения запроса - 44.759 мс
-- Просадка по времени выполнения происходит при операции full outer join результата запроса inv c таблицей rental - около 20 мс
-- from rental r 
--	full outer join 
--		(select *, unnest(f.special_features) as sf_string
--		from inventory i
--		full outer join film f on f.film_id = i.film_id) as inv 
--		on r.inventory_id = inv.inventory_id
-- Вторым узким местом является операция full outer join результата запроса ren к таблице customer - еще дополнительно 10 мс


--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
select stf.staff_id, f.film_id, f.title, stf.amount, stf.payment_date, c.last_name as "customer_last_name", c.first_name as "customer_first_name"
from (
	select *
	from (
		select p.staff_id, p.rental_id, p.amount, p.payment_date, row_number() over (partition by p.staff_id order by p.payment_date asc) as ctdate
		from payment p
	) as inf
	where inf.ctdate = 1
) as stf
join rental r on r.rental_id = stf.rental_id 
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id
join customer c on c.customer_id = r.customer_id;


--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

select sel_1.staff_id as "ID сотрудника", sel_1.rdate as "День, когда арендовали больше всего фильмов",
sel_1.cnt as "Количество взятых в аренду фильмов",
sel_2.payment_date as "День, в который продали фильмов на наименьшую сумму",
sel_2.summ as "Сумма продажи"
from(
	select staff_id, rdate, cnt
	from(
		select staff_id, rdate, cnt, rank() over (partition by staff_id order by cnt desc) as mr
		from(
			select r.staff_id, r.rental_date::date as rdate, count(r.inventory_id) as cnt
			from rental r
			group by r.staff_id, r.rental_date::date
		) as t1
	) as s1
	where s1.mr = 1
) as sel_1
join(
	select staff_id, payment_date, summ
	from(
		select staff_id, payment_date, summ, rank() over (partition by staff_id order by summ asc) as ls
		from(
			select r.staff_id as staff_id, p.payment_date::date as payment_date, sum(p.amount) as summ
			from rental r
			join payment p on r.rental_id = p.rental_id 
			group by r.staff_id, p.payment_date::date
		) as t2
	) as s2
	where s2.ls = 1
) as sel_2 on sel_1.staff_id = sel_2.staff_id









