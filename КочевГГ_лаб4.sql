-- Written by Hennadii Kochev IP-91
-- For PostgreSQL 12

--Задачі:
--Виконати в контексті бази Northwind:

--1. Додати себе як співробітника компанії на позицію Intern.

INSERT INTO employees("EmployeeID", "LastName", "FirstName", "Title", "TitleOfCourtesy", "City", "Country", "HomePhone")
VALUES (10, 'Kochev', 'Hennadii', 'Intern', 'Mr.', 'Kiev', 'Ukraine', '8 (800) 555-3535');

--2. Змінити свою посаду на Director.

UPDATE employees
SET "Title" = 'Director'
WHERE "LastName" = 'Kochev' AND "FirstName" = 'Hennadii';

--3. Скопіювати таблицю Orders в таблицю OrdersArchive.

SELECT * INTO "OrdersArchive" FROM orders;

--4. Очистити таблицю OrdersArchive.

TRUNCATE TABLE "OrdersArchive";

--5. Не видаляючи таблицю OrdersArchive, наповнити її інформацією повторно.

INSERT INTO "OrdersArchive"
SELECT * FROM orders; 

--6. З таблиці OrdersArchive видалити десять замовлень, що були зроблені замовниками із
--Берліну.

DELETE FROM "OrdersArchive"
WHERE EXISTS (
  SELECT 1 FROM customers
  WHERE "City" = 'Berlin' AND "OrdersArchive"."CustomerID" = customers."CustomerID"
  LIMIT 10
);

--7. Внести в базу два продукти з власним іменем та іменем групи.

INSERT INTO products("ProductID", "ProductName", "Discontinued") 
VALUES (78, 'Kochev Hennadii', 0), (79, 'IP-91', 0);

--8. Помітити продукти, що не фігурують в замовленнях, як такі, що більше не виробляються.

UPDATE products
SET "Discontinued" = 1
WHERE "ProductID" NOT IN (
	SELECT "ProductID" FROM order_details
);

--9. Видалити таблицю OrdersArchive.

DROP TABLE "OrdersArchive";

--10. Видалити базу Northwind.

DROP DATABASE northwind;






