--=============== ������ 3. ������ SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ��� ������� ���������� ��� ����� ����������, 
--����� � ������ ����������.
SELECT CONCAT(c.last_name, ' ', c.first_name) AS "������� � ���", a.address AS "�����", c2.city AS "�����", c3.country AS "������" 
FROM customer c
INNER JOIN address a ON c.address_id = a.address_id 
INNER JOIN city c2 ON a.city_id = c2.city_id 
INNER JOIN country c3 ON c2.country_id = c3.country_id;




--������� �2
--� ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.
SELECT store_id AS "ID ��������", COUNT(customer_id) AS "���������� �����������"
FROM customer
GROUP BY store_id;




--����������� ������ � �������� ������ �� ��������, 
--� ������� ���������� ����������� ������ 300-��.
--��� ������� ����������� ���������� �� ��������������� ������� 
--� �������������� ������� ���������.
SELECT store_id AS "ID ��������", COUNT(customer_id) AS "���������� �����������"
FROM customer
GROUP BY store_id
HAVING COUNT(customer_id) > 300;




-- ����������� ������, ������� � ���� ���������� � ������ ��������, 
--� ����� ������� � ��� ��������, ������� �������� � ���� ��������.
SELECT c.store_id AS "ID ��������", COUNT(c.customer_id) AS "���������� �����������", c2.city AS "����� ��������", CONCAT(s2.last_name, ' ', s2.first_name)
FROM customer c
JOIN store s ON c.store_id = s.store_id 
JOIN address a ON s.address_id = a.address_id 
JOIN city c2 ON a.city_id = c2.city_id
JOIN staff s2 ON s.manager_staff_id = s2.staff_id
GROUP BY c.store_id, c2.city_id, s2.staff_id
HAVING COUNT(c.customer_id) > 300;




--������� �3
--�������� ���-5 �����������, 
--������� ����� � ������ �� �� ����� ���������� ���������� �������
SELECT CONCAT(c.last_name, ' ', c.first_name) AS "������� � ��� ����������", COUNT(r.inventory_id) AS "���������� �������"
FROM customer c 
JOIN rental r ON c.customer_id = r.customer_id 
GROUP BY c.customer_id
ORDER BY COUNT(r.inventory_id) DESC
LIMIT 5;




--������� �4
--���������� ��� ������� ���������� 4 ������������� ����������:
--  1. ���������� �������, ������� �� ���� � ������
--  2. ����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����)
--  3. ����������� �������� ������� �� ������ ������
--  4. ������������ �������� ������� �� ������ ������
SELECT CONCAT(c.last_name, ' ', c.first_name) AS "������� � ��� ����������", COUNT(r.inventory_id) AS "���������� �������",
ROUND(SUM(p.amount)) AS "����� ��������� ��������", MIN(p.amount) AS "����������� ��������� �������",
MAX(p.amount) AS "������������ ��������� �������"
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id 
JOIN rental r ON  p.rental_id = r.rental_id
GROUP BY c.customer_id; 




--������� �5
--��������� ������ �� ������� ������� ��������� ����� �������� ������������ ���� ������� ����� �������,
 --����� � ���������� �� ���� ��� � ����������� ���������� �������. 
 --��� ������� ���������� ������������ ��������� ������������.
SELECT c.city AS "����� 1", c2.city AS "����� 2"
FROM city c 
CROSS JOIN city c2
WHERE c.city != c2.city;




--������� �6
--��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date)
--� ���� �������� ������ (���� return_date), 
--��������� ��� ������� ���������� ������� ���������� ����, �� ������� ���������� ���������� ������.
SELECT r.customer_id AS "ID ����������", 
ROUND(AVG(DATE_PART('day', r.return_date - r.rental_date) + DATE_PART('hour', r.return_date - r.rental_date)/24 + DATE_PART('minute', r.return_date - r.rental_date)/1440)::numeric, 2) AS "������� ���-�� ���� �� �������"
FROM rental r 
GROUP BY r.customer_id
ORDER BY r.customer_id ASC;




--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� ������ ������� ��� ��� ����� � ������ � �������� ����� ��������� ������ ������ �� �� �����.
SELECT f.title AS "��������", f.rating AS "�������", c.name AS "����", f.release_year AS "��� �������", 
l.name AS "����", COUNT(r.rental_id) AS "���������� �����", SUM(p.amount) AS "����� ��������� ������"
FROM rental r 
JOIN inventory i ON r.inventory_id = i.inventory_id 
JOIN payment p ON r.rental_id = p.rental_id 
JOIN film f ON i.film_id = f.film_id 
JOIN language l ON f.language_id = l.language_id 
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id 
GROUP BY f.film_id, c.category_id, l.language_id
ORDER BY f.title ASC;




--������� �2
--����������� ������ �� ����������� ������� � �������� � ������� ������� ������, ������� �� ���� �� ����� � ������.

SELECT f.title AS "��������", f.rating AS "�������", c.name AS "����", f.release_year AS "��� �������", 
l.name AS "����", COUNT(r.rental_id) AS "���������� �����", SUM(p.amount) AS "����� ��������� ������"
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




--������� �3
--���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� "������".
--���� ���������� ������ ��������� 7300, �� �������� � ������� ����� "��", ����� ������ ���� �������� "���".
SELECT s.staff_id AS "ID ����������", COUNT(p.payment_id) AS "���������� ������", 
	CASE
		WHEN COUNT(p.payment_id) > 7300 THEN '��'
		ELSE '���'
	END "������"
FROM staff s 
JOIN payment p ON s.staff_id = p.staff_id 
GROUP BY s.staff_id;





