-- Written by Kochev Hennadii IP-91 for PostgreSQL 12

-- Задача № 1:

-- 1. Необхідно знайти кількість рядків в таблиці, що містить більше ніж 2147483647 записів.
-- Напишіть код для MS SQL Server та ще однієї СУБД (на власний вибір).


SELECT COUNT_BIG(*) FROM given_big_table; -- MS SQL Server
SELECT COUNT(*) FROM given_big_table; -- PostgreSQL


-- 2. Підрахувати довжину свого прізвища, імені та по-батькові за допомогою SQL. Результат
-- вивести в три колонки.


SELECT LENGTH('Kochev') AS surname_length,
       LENGTH('Hennadii') AS name_length,
	   LENGTH('Hennadievich') AS father_length;


-- 3. Взявши рядок з виконавцем та назвою пісні, яку ви слухали останньою, замінити пробіли на
-- знаки нижнього підкреслювання.


SELECT REPLACE('Гимн Украинской ССР - "Живи, Україно, прекрасна і сильна"', ' ', '_') AS last_song;


-- 4. Створити генератор імені електронної поштової скриньки, що шляхом конкатенації
-- об’єднував би дві перші літери з колонки імені, та чотири перші літери з колонки прізвища
-- користувача, що зберігаються в базі даних, а також домену з вашим прізвищем.


SELECT CONCAT(LEFT(first_name, 2), LEFT(last_name, 4), '@kochev.site') AS email FROM given_table; 


-- 5. За допомогою SQL визначити, в який день тижня ви народилися.


SELECT TO_CHAR(DATE '2002-03-18', 'Day') AS day_of_week;


----------------------------------------------------------------------------------------------------

-- Задача №2:

-- Виконати наступні завдання в контексті бази Northwind:

-- 1. Вивести усі данні по продуктам, їх категоріям, та постачальникам, навіть якщо останні з
-- певних причин відсутні.


SELECT * FROM products
LEFT JOIN categories ON products."CategoryID" = categories."CategoryID"
LEFT JOIN suppliers ON products."SupplierID" = suppliers."SupplierID";


-- 2. Показати усі замовлення, що були зроблені в квітні 1998 року та не були відправлені.


SELECT * FROM orders
WHERE TO_CHAR("OrderDate", 'YYYY-MM-DD') LIKE '1998-04%' 
AND "ShippedDate" IS NULL;


-- 3. Відібрати усіх працівників, що відповідають за південний регіон.


-- get employee
SELECT * FROM employees WHERE "EmployeeID" IN
(
    -- get employee id
	SELECT "EmployeeID" FROM employeeterritories WHERE "TerritoryID" IN 
	(
        -- get territory id
		SELECT "TerritoryID" FROM territories WHERE "RegionID" IN 
		(
            -- get region id
			SELECT "RegionID" FROM region WHERE "RegionDescription" = 'Southern'
		)
	)
);


-- 4. Вирахувати загальну вартість з урахуванням знижки усіх замовлень, що були здійснені на
-- непарну дату.


-- get absolute cost sum
SELECT SUM("TotalCost") AS "AbsoluteCost" FROM
(
	-- get total cost for every position
	SELECT "UnitPrice" * "Quantity" * (1 - "Discount") AS "TotalCost" 
	FROM order_details WHERE "OrderID" IN
	(
		-- get odd daynumbers
		SELECT "OrderID" from orders 
		WHERE EXTRACT(DAY FROM "OrderDate")::INT % 2 <> 0
	)
) AS "AbsoluteCost";


-- 5. Знайти адресу відправлення замовлення з найбільшою ціною позиції (враховуючи вартість
-- товару, його кількість та наявність знижки). Якщо таких замовлень декілька – повернути
-- найновіше.


-- get ship address
SELECT "ShipAddress" FROM orders
WHERE "OrderID" IN
(
	-- get order id
	SELECT "OrderID" FROM order_details 
	WHERE "UnitPrice" * "Quantity" * (1 - "Discount") IN
	(
		-- find max total cost
		SELECT MAX("UnitPrice" * "Quantity" * (1 - "Discount")) AS "MaxCost"
		FROM order_details
	)
)
-- newest is first
ORDER BY "OrderDate" DESC LIMIT 1;






