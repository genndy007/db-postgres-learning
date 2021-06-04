-- Written for PostgreSQL 12 by Hennadii Kochev, IP-91 student

-- 1. Вивести за допомогою команди SELECT своє прізвище, ім’я, по-батькові та групу на екран. Українською мовою.

SELECT 'Кочев Геннадій Геннадійович ІП-91';

-- 2. Вибрати всі дані з таблиці Orders.

SELECT * FROM orders;

-- 3. Обрати всі назви товарів з таблиці Products, продаж яких не припинено.

SELECT "ProductName" FROM products WHERE "Discontinued" = 0;

-- 4. Вивести всі міста клієнтів уникаючи дублікатів.

SELECT DISTINCT "City" FROM customers; 

-- 5. Вибрати всі назви компаній-постачальників в порядку зворотному алфавітному.

SELECT "CompanyName" FROM suppliers ORDER BY "CompanyName" DESC;

-- 6. Отримати всі деталі замовлень, замінивши назви в назвах стовпчиків ID на Number.

SELECT "OrderID" AS "OrderNumber", "ProductID" AS "ProductNumber", "UnitPrice", "Quantity", "Discount" FROM order_details;

-- 7. Знайти трьох постачальників з США. Вивести назву, адресу та телефон. 

SELECT "CompanyName", "Address", "Phone" FROM suppliers WHERE "Country" = 'USA' LIMIT 3;

-- 8. Вивести всі контактні імена клієнтів, що починаються з першої літери вашого прізвища, імені, по-батькові. Врахувати чутливість до регістру. 

SELECT "ContactName" FROM customers WHERE "ContactName" SIMILAR TO '(K|H|k|h)%';

-- 9. Показати усі замовлення, в адресах доставки яких немає крапок.

SELECT * FROM orders WHERE "ShipAddress" NOT LIKE '%.%';

-- 10. Вивести назви тих продуктів, що починаються на знак % або _, а закінчуються на останню літеру вашого імені. Навіть якщо такі відсутні. 

SELECT "ProductName" FROM products WHERE "ProductName" SIMILAR TO '[%_]%[iI]';












