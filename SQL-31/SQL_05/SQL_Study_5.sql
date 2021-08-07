--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--	Пронумеруйте все платежи от 1 до N по дате
--	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
--	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--	Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
-- Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

select p.customer_id, p.payment_id, p.payment_date, row_number() over(order by p.payment_date)
from payment p 

select p.customer_id, p.payment_id, p.payment_date, row_number() over(partition by p.customer_id order by p.payment_date)
from payment p

select p.customer_id, p.payment_id, p.payment_date, p.amount, sum(p.amount) over(partition by p.customer_id order by p.payment_date::date, p.amount)
from payment p

select p.customer_id, p.payment_id, p.amount,  dense_rank() over (partition by p.customer_id order by p.amount)
from payment p



--ЗАДАНИЕ №2
-- С помощью оконной функции выведите для каждого покупателя стоимость платежа 
-- и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
 
select p.customer_id, p.payment_id, p.payment_date, p.amount,
	lag(p.amount, 1, 0.) over (partition by p.customer_id order by p.payment_date) as "last_amount"
from payment p 



--ЗАДАНИЕ №3
-- С помощью оконной функции определите, на сколько каждый 
-- следующий платеж покупателя больше или меньше текущего.

select p.customer_id, p.payment_id, p.payment_date, p.amount,
	p.amount-lead(p.amount, 1, 0.) over (partition by p.customer_id order by p.payment_date) as "difference"
from payment p 


--ЗАДАНИЕ №4
-- С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

select p2.customer_id, p2.payment_id, p2.payment_date, p2.amount
from (
	select p.*,
		row_number() over (partition by p.customer_id order by p.payment_date desc) as cpdate
	from payment p
) p2
where cpdate = 1



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за март 2007 года
-- с нарастающим итогом по каждому сотруднику и 
-- по каждой дате продажи (без учёта времени) с сортировкой по дате.




--ЗАДАНИЕ №2
--10 апреля 2007 года в магазинах проходила акция: покупатель, совершивший каждый 100ый платеж
-- получал дополнительную скидку на следующую аренду.
-- С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.




--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм






