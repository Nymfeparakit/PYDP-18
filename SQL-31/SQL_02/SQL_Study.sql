--=============== ������ 2. ������ � ������ ������ =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ���������� �������� �������� �� ������� �������

SELECT DISTINCT district FROM address;





--������� �2
--����������� ������ �� ����������� �������, ����� ������ ������� ������ �� �������, 
--�������� ������� ���������� �� "K" � ������������� �� "a", � �������� �� �������� ��������

SELECT DISTINCT district FROM address WHERE district LIKE 'K%a' AND district NOT LIKE '% %';




--������� �3
--�������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� 
--� ���������� � 17 ����� 2007 ���� �� 19 ����� 2007 ���� ������������, 
--� ��������� ������� ��������� 1.00.
--������� ����� ������������� �� ���� �������.

SELECT payment_id, payment_date, amount 
FROM payment 
WHERE payment_date BETWEEN '2007-03-17' AND '2007-03-20'
AND amount > 1.00
ORDER BY payment_date;




--������� �4
-- �������� ���������� � 10-�� ��������� �������� �� ������ �������.

SELECT payment_id, payment_date, amount 
FROM payment 
ORDER BY payment_date DESC
LIMIT 10;




--������� �5
--�������� ��������� ���������� �� �����������:
--  1. ������� � ��� (� ����� ������� ����� ������)
--  2. ����������� �����
--  3. ����� �������� ���� email
--  4. ���� ���������� ���������� ������ � ���������� (��� �������)
--������ ������� ������� ������������ �� ������� �����.

SELECT CONCAT(first_name, ' ', last_name) AS "������� � ���", email AS "����������� �����", 
LENGTH(email) AS "����� Email", last_update::DATE AS "����"
FROM customer;



--������� �6
--�������� ����� �������� �������� �����������, ����� ������� Kelly ��� Willie.
--��� ����� � ������� � ����� �� ������� �������� ������ ���� ���������� � ������� �������.

SELECT UPPER(last_name) AS "last_name", UPPER(first_name) AS "first_name"
FROM customer
WHERE first_name ILIKE 'Kelly' OR first_name ILIKE 'Willie'
AND activebool = 'true';



--======== �������������� ����� ==============

--������� �1
--�������� ����� �������� ���������� � �������, � ������� ������� "R" 
--� ��������� ������ ������� �� 0.00 �� 3.00 ������������, 
--� ����� ������ c ��������� "PG-13" � ���������� ������ ������ ��� ������ 4.00.

SELECT film_id, title, description, rating, rental_rate 
FROM film
WHERE rating::TEXT ILIKE 'R' AND rental_rate >= 0.00 AND rental_rate <= 3.00
OR rating::TEXT ILIKE 'PG-13' AND rental_rate >= 4;



--������� �2
--�������� ���������� � ��� ������� � ����� ������� ��������� ������.

SELECT film_id, title, description
FROM film
ORDER BY LENGTH(description) DESC
LIMIT 3;


--������� �3
-- �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
--� ������ ������� ������ ���� ��������, ��������� �� @, 
--�� ������ ������� ������ ���� ��������, ��������� ����� @.

SELECT customer_id, email AS "Email", 
SUBSTRING(email FROM 1 FOR STRPOS(email, '@')-1) AS "Email before @",
SUBSTRING(email FROM STRPOS(email,'@')+1 FOR LENGTH(email)-STRPOS(email, '@')) AS "Email after @"
FROM customer
WHERE email LIKE '%@%'
ORDER BY customer_id;



--������� �4
--����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: 
--������ ����� ������ ���� ���������, ��������� ���������.

SELECT customer_id, email AS "Email", 
CONCAT(UPPER(SUBSTRING(email FROM 1 FOR 1)), SUBSTRING(email FROM 2 FOR STRPOS(email, '@')-1)) AS "Email before @",
CONCAT(UPPER(SUBSTRING(email FROM STRPOS(email,'@')+1 FOR 1)), SUBSTRING(email FROM STRPOS(email,'@')+2 FOR LENGTH(email)-STRPOS(email, '@')-1)) AS "Email after @"
FROM customer
WHERE email LIKE '%@%'
ORDER BY customer_id;


