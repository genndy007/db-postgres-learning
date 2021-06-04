-- Hennadii Kochev IP-91
-- For PostgreSQL 12

--Задачі:


--1. Створити збережену процедуру, що при виклику буде повертати ваше прізвище, ім’я та по-батькові.

CREATE OR REPLACE PROCEDURE my_name()
LANGUAGE plpgsql AS
$$
BEGIN
	RAISE NOTICE '%', 'Kochev Hennadii Hennadievich';
END;
$$

--2. В контексті бази Northwind створити збережену процедуру, що приймає текстовий параметр мінімальної довжини. У разі виклику процедури з параметром ‘F’ на екран виводяться усі співробітники-жінки, у разі використання параметру ‘M’ – чоловікі. У протилежному випадку вивести на екран повідомлення про те, що параметр не розпізнано.

CREATE OR REPLACE FUNCTION get_employees_by_sex(sex VARCHAR(1))
RETURNS TABLE(
	lastname VARCHAR(20),
	firstname VARCHAR(10)
)
LANGUAGE plpgsql AS
$$
BEGIN
	CASE
		WHEN sex = 'M' THEN RETURN QUERY 
			SELECT "LastName", "FirstName" FROM employees
			WHERE "TitleOfCourtesy" = 'Mr.' OR "TitleOfCourtesy" = 'Dr.';
		WHEN sex = 'F' THEN RETURN QUERY
			SELECT "LastName", "FirstName" FROM employees
			WHERE "TitleOfCourtesy" = 'Ms.' OR "TitleOfCourtesy" = 'Mrs.';
		ELSE RETURN QUERY 
			SELECT 'No such sex available.';
	END CASE;
END;
$$

--3. В контексті бази Northwind створити збережену процедуру, що виводить усі замовлення за заданий період. В тому разі, якщо період не задано – вивести замовлення за поточний день.

CREATE OR REPLACE FUNCTION get_orders_by_date(
	from_date DATE DEFAULT CURRENT_DATE,
	to_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
	LIKE orders
)
LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
	SELECT * FROM orders 
	WHERE "OrderDate" >= from_date AND "OrderDate" <= to_date;
END;
$$

--4. В контексті бази Northwind створити збережену процедуру, що в залежності від переданого параметру категорії виводить категорію та перелік усіх продуктів за цією категорією. Дозволити можливість використати від однієї до п’яти категорій.

CREATE OR REPLACE FUNCTION get_categories_and_products(
	category1 TEXT,
	category2 TEXT DEFAULT NULL,
	category3 TEXT DEFAULT NULL,
	category4 TEXT DEFAULT NULL,
	category5 TEXT DEFAULT NULL
)
RETURNS TABLE(
	category_name VARCHAR(15),
	product_id SMALLINT,
	product_name VARCHAR(40)
)
LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
	SELECT categories."CategoryName", products."ProductID", products."ProductName"
	FROM categories 
	JOIN products USING("CategoryID")
	WHERE categories."CategoryName" IN (
		category1,
		category2,
		category3,
		category4,
		category5
	)
	ORDER BY categories."CategoryName";
END;
$$

--5. В контексті бази Northwind модифікувати збережену процедуру Ten Most Expensive Products для виводу всієї інформації з таблиці продуктів, а також імен постачальників та назви категорій.

CREATE OR REPLACE FUNCTION "Ten Most Expensive Products"()
RETURNS TABLE(
	category_name VARCHAR(15),
	supplier_name VARCHAR(40),
	product_id SMALLINT,
	product_name VARCHAR(40),
	supplier_id SMALLINT,
	category_id SMALLINT,
	quantity_per_unit VARCHAR(20),
	unit_price REAL,
	units_in_stock SMALLINT,
	units_on_order SMALLINT,
	reorder_level SMALLINT,
	discontinued INT
)
LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
	SELECT categories."CategoryName", suppliers."CompanyName", products.*
	FROM products
	JOIN categories USING("CategoryID")
	JOIN suppliers USING("SupplierID")
	ORDER BY products."UnitPrice" DESC LIMIT 10;
END;
$$

--6. В контексті бази Northwind створити функцію, що приймає три параметри (TitleOfCourtesy, FirstName, LastName) та виводить їх єдиним текстом. 
--Приклад: ‘Dr.’, ‘Yevhen’, ‘Nedashkivskyi’ –> ‘Dr. Yevhen Nedashkivskyi’

CREATE OR REPLACE FUNCTION get_full_name(
	TitleOfCourtesy VARCHAR(25),
	FirstName VARCHAR(10),
	LastName VARCHAR(20)
)
RETURNS TABLE(
	full_name TEXT
)
LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
	SELECT CONCAT_WS(' ', TitleOfCourtesy, FirstName, LastName);
END;
$$

--7. В контексті бази Northwind створити функцію, що приймає три параметри (UnitPrice, Quantity, Discount) та виводить кінцеву ціну.

CREATE OR REPLACE FUNCTION get_final_cost(
	UnitPrice NUMERIC,
	Quantity INT,
	Discount NUMERIC
)
RETURNS TABLE(
	final_cost NUMERIC
)
LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
	SELECT UnitPrice * Quantity * (1 - Discount);
END;
$$

--8. Створити функцію, що приймає параметр текстового типу і приводить його до Pascal Case. Приклад: Мій маленький поні –> МійМаленькийПоні

CREATE OR REPLACE FUNCTION get_sentence_in_pascal_case(
	sentence TEXT
)
RETURNS TABLE(
	pascal_text TEXT
)
LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
	SELECT REPLACE(INITCAP(sentence), ' ', '');
END;
$$

--9. В контексті бази Northwind створити функцію, що в залежності від вказаної країни, повертає усі дані про співробітника у вигляді таблиці.

CREATE OR REPLACE FUNCTION get_employees_by_country(
	country VARCHAR(15)
)
RETURNS TABLE(
	LIKE employees
)
LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
	SELECT * FROM employees
	WHERE "Country" = country;
END;
$$

--10. В контексті бази Northwind створити функцію, що в залежності від імені транспортної компанії повертає список клієнтів, якою вони обслуговуються.

CREATE OR REPLACE FUNCTION get_customers_by_shipper(
	shipper_name VARCHAR(40) 
)
RETURNS TABLE(
	LIKE customers
)
LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
	SELECT * FROM customers
	WHERE "CustomerID" IN (
		SELECT "CustomerID" FROM orders
		WHERE "ShipVia" IN (
			SELECT "ShipperID" FROM shippers
			WHERE "CompanyName" = shipper_name
		)
	);
END;
$$












