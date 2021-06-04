-- Written by Kochev Hennadii from IP-91
-- For PostgreSQL 12

--Задача №1:
--Виконати наступні завдання:

--1. Використовуючи SELECT без FROM, поверніть набір з п’яти рядків, що включають дві колонки з
--вашими улюбленими виконавцями та піснями.


SELECT 'Би-2' AS "SINGER", 'Полковник' AS "SONG"
UNION
SELECT 'Смысловые Галлюцинации' AS "SINGER", 'Вечно Молодой' AS "SONG"
UNION
SELECT 'Вячеслав Бутусов' AS "SINGER", 'Гибралтар Лабрадор' AS "SONG"
UNION
SELECT 'Сплин' AS "SINGER", 'Линия Жизни' AS "SONG"
UNION
SELECT 'Детский хор под рук. М.И.Славкина' AS "SINGER", 'Прощальное Письмо' AS "SONG";


--2. Порівнявши власний порядковий номер в групі з набором із всіх номерів в групі, вивести на
--екран ;-) якщо він менший за усі з них, або :-D в протилежному випадку.


SELECT 
	CASE WHEN 13 < ALL (SELECT generate_series(1, 27)) THEN ';-)'
	ELSE ':-D'
	END;


--3. Не використовуючи таблиці, вивести на екран прізвище та ім’я усіх дівчат своєї групи за
--винятком тих, хто має спільне ім’я з студентками іншої групи.


SELECT * FROM 
(
SELECT 'Дубогрыз' AS "SURNAME", 'Елизавета' AS "FIRSTNAME"
UNION 
SELECT 'Карявка' AS "SURNAME", 'Дарья' AS "FIRSTNAME"
UNION 
SELECT 'Личман' AS "SURNAME", 'Дарья' AS "FIRSTNAME"
UNION 
SELECT 'Тимченко' AS "SURNAME", 'Елизавета' AS "FIRSTNAME"
UNION 
SELECT 'Шаховская' AS "SURNAME", 'Дарья' AS "FIRSTNAME"
UNION 
SELECT 'Ярмак' AS "SURNAME", 'Юлия' AS "FIRSTNAME"
) AS "GROUP91"
WHERE "FIRSTNAME" NOT IN 
(
	SELECT "FIRSTNAME" FROM 
	(
		SELECT 'Грымальская' AS "SURNAME", 'Дарья' AS "FIRSTNAME"
		UNION
		SELECT 'Бондаренко' AS "SURNAME", 'Анастасия' AS "FIRSTNAME"
	) AS "STREAM9X"
);


--4. Вивести усі рядки з таблиці Numbers (Number INT). Замінити цифру від 0 до 9 на її назву
--літерами. Якщо цифра більше, або менша за названі, залишити її без змін.


SELECT 
	CASE WHEN "Number"=0 THEN 'ZERO'
	WHEN "Number"=1 THEN 'ONE'
	WHEN "Number"=2 THEN 'TWO'
	WHEN "Number"=3 THEN 'THREE'
	WHEN "Number"=4 THEN 'FOUR'
	WHEN "Number"=5 THEN 'FIVE'
	WHEN "Number"=6 THEN 'SIX'
	WHEN "Number"=7 THEN 'SEVEN'
	WHEN "Number"=8 THEN 'EIGHT'
	WHEN "Number"=9 THEN 'NINE'
	ELSE "Number"::TEXT
	END
FROM "Numbers";


--5. Навести приклад синтаксису декартового об’єднання для вашої СУБД.


SELECT * FROM "TABLE1" CROSS JOIN "TABLE2";





--Задача №2:
--Виконати наступні завдання в контексті бази Northwind:


--6. Вивести усі замовлення та їх службу доставки. В результуючому наборі в залежності від
--ідентифікатора, перейменувати одну із служб на таку, що відповідає вашому імені, прізвищу,
--або по-батькові.


SELECT orders.*, shippers."ShipperID",
CASE
	WHEN shippers."ShipperID" = 3 THEN 'Hennadii'
	ELSE shippers."CompanyName"
END,
shippers."Phone"
FROM orders
LEFT JOIN shipper
ON orders."ShipVia" = shippers."ShipperID";


--7. Вивести в алфавітному порядку усі країни, що фігурують в адресах клієнтів, працівників, та
--місцях доставки замовлень.


SELECT DISTINCT "Country" FROM customers
UNION
SELECT DISTINCT "Country" FROM employees
UNION
SELECT DISTINCT "ShipCountry" FROM orders AS "Country"
ORDER BY "Country";


--8. Вивести прізвище та ім’я працівника, а також кількість замовлень, що він обробив за перший
--квартал 1998 року.


SELECT employees."FirstName", employees."LastName", COUNT(orders."OrderID") AS "OrdersAmount"
FROM orders
LEFT JOIN employees USING("EmployeeID")
WHERE orders."OrderDate" >= '1998-01-01'::DATE AND orders."OrderDate" <= '1998-03-31'::DATE
GROUP BY employees."FirstName", employees."LastName";


--9. Використовуючи СTE знайти усі замовлення, в які входять продукти, яких на складі більше 80
--одиниць, проте по яким немає максимальних знижок.


WITH "MaxDiscount" AS 
(
	SELECT MAX("Discount") AS "Discount" FROM order_details
), 
"Orders" AS 
(
	SELECT DISTINCT "OrderID"
	FROM order_details
	WHERE "ProductID" IN 
	(
		SELECT "ProductID"
		FROM products
		WHERE "UnitsInStock" > 80
	) 
	AND
	"Discount" <> (SELECT "Discount" FROM "MaxDiscount")
)
SELECT * FROM orders
WHERE "OrderID" IN (SELECT * FROM "Orders");


--10. Знайти назви усіх продуктів, що не продаються в південному регіоні.


SELECT "ProductName" FROM products
WHERE "ProductID" IN
(
	SELECT DISTINCT order_details."ProductID" FROM order_details
	WHERE "OrderID" IN
	(
		SELECT orders."OrderID" FROM orders
		WHERE "EmployeeID" IN 
		(
			SELECT DISTINCT employeeterritories."EmployeeID" FROM employeeterritories
			WHERE "TerritoryID" IN
			(
				SELECT territories."TerritoryID" FROM territories
				WHERE "RegionID" IN
				(
					SELECT region."RegionID" FROM region
					WHERE "RegionDescription" <> 'Southern'
				)
			)
		)
	)
);





































