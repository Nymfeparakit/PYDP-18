SET search_path TO bookings;

-- 1 -- В каких городах больше одного аэропорта?
select a.city as "Город", count(a.airport_code) as "Кол-во аэропортов"
from airports a
group by a.city
having count(a.airport_code) > 1;

-- 2 -- В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
select aa.airport_name 
from airports aa
join flights f on f.departure_airport = aa.airport_code
where f.aircraft_code = (
	select a.aircraft_code
	from aircrafts a
	where a.range = 
	(
		select MAX(a2.range)
		from aircrafts a2 
	)
)
group by aa.airport_name;

-- 3 -- Вывести 10 рейсов с максимальным временем задержки вылета
select f.flight_no, f.actual_departure, f.actual_arrival, (f.actual_departure - f.scheduled_departure) as "Время задержки отправления"
from flights f
where f.actual_departure notnull and f.scheduled_departure notnull 
order by (f.actual_departure - f.scheduled_departure) desc
limit 10;

-- 4 -- Были ли брони, по которым не были получены посадочные талоны?
select b.book_ref, b.book_date, b.total_amount, t.ticket_no, t.passenger_name, tf.flight_id
from bookings b 
join tickets t on t.book_ref = b.book_ref 
join ticket_flights tf on tf.ticket_no = t.ticket_no 
left join boarding_passes bp on bp.ticket_no = tf.ticket_no and bp.flight_id = tf.flight_id
where bp.boarding_no isnull

-- 5 -- Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
-- Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
-- Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.
select f.flight_id, f.aircraft_code, asts.all_seats as "Всего мест", osts.occ_seats as "Занятые места", (asts.all_seats - osts.occ_seats) as "Свободные места", 
cast((1-1.0*osts.occ_seats/asts.all_seats)*100 as numeric(100,2)) as "Доля свободных мест, %", f.actual_departure as "Время вылета",
f.departure_airport as "Аэропорт отлета",
sum(osts.occ_seats) over (partition by f.departure_airport order by f.actual_departure) as "Сумма вывезенных пассажиров"
from flights f 
join aircrafts a on f.aircraft_code = a.aircraft_code 
join (
	select s.aircraft_code as a_code, count(s.seat_no) as all_seats
	from seats s
	group by s.aircraft_code
) as asts on asts.a_code = a.aircraft_code
join (
	select bp.flight_id as f_id, count(bp.seat_no) as occ_seats
	from boarding_passes bp
	group by bp.flight_id
) as osts on osts.f_id = f.flight_id
where f.actual_departure notnull;

-- 6 -- Найдите процентное соотношение перелетов по типам самолетов от общего количества.
select f.aircraft_code as "Тип самолета", count(f.flight_id) as "Количество перелетов", round(100.0*count(f.flight_id)/(
	select count(ff.flight_id)
	from flights ff
	where ff.actual_departure notnull
), 2) as "Доля перелетов, %"
from flights f
where f.actual_departure notnull
group by f.aircraft_code;

-- 7 -- Были ли города, в которые можно добраться бизнес-классом дешевле, чем эконом-классом в рамках перелета?
with cte_flight_stat as(
	select tf2.flight_id, tf2.fare_conditions, min(tf2.amount) as fl_cost_ecn, tf3.fare_conditions, min(tf3.amount) as fl_cost_bsn
	from ticket_flights tf2
	join ticket_flights tf3 on tf2.flight_id = tf3.flight_id
	where tf2.fare_conditions = 'Economy' and tf3.fare_conditions = 'Business'
	group by tf2.flight_id, tf2.fare_conditions, tf3.fare_conditions 
)
select f.flight_id, f.arrival_airport, f.departure_airport
from flights f 
join cte_flight_stat on f.flight_id = cte_flight_stat.flight_id
where f.actual_departure notnull and cte_flight_stat.fl_cost_ecn > cte_flight_stat.fl_cost_bsn
group by f.flight_id, f.departure_airport, f.arrival_airport

-- 8 -- Между какими городами нет прямых рейсов?
create view city_pairs as 
select a.city as city_1, a2.city as city_2, a.airport_code as airp_1, a2.airport_code as airp_2 
from airports a
cross join airports a2 
where a.city != a2.city;

select city_pairs.city_1, city_pairs.city_2
from(
	select airp_1, airp_2
	from city_pairs
	except
	select f.departure_airport, f.arrival_airport
	from flights f
) as res
join city_pairs on res.airp_1 = city_pairs.airp_1 and  res.airp_2 = city_pairs.airp_2

-- 9 -- Вычислите расстояние между аэропортами, связанными прямыми рейсами, 
-- сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы
create view prep_flights as
	select f.arrival_airport, f.departure_airport, f.aircraft_code
	from flights f 
	group by f.arrival_airport, f.departure_airport, f.aircraft_code;


create view prep_flights_2 as
	select f.arrival_airport, f.departure_airport, f.aircraft_code, 
	6371 * acos(sind(a.latitude)*sind(a2.latitude) + cosd(a.latitude)*cosd(a2.latitude)*cosd(a.longitude - a2.longitude)) as distance
	from prep_flights f 
	join airports a on a.airport_code = f.departure_airport 
	join airports a2 on a2.airport_code = f.arrival_airport;


select f2.arrival_airport, f2.departure_airport, f2.aircraft_code,
f2.distance, a3.model, a3."range",
case
	when a3."range" >= f2.distance then 'Can fly without refueling'
	else 'Fly with refueling'
end
from prep_flights_2 f2
join aircrafts a3 on f2.aircraft_code = a3.aircraft_code;



