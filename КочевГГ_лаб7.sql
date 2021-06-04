-- Kochev Hennadii IP-91
-- PostgreSQL 12


--Задачі:

--1. Вивести на екран перший рядок з усіх таблиць без прив’язки до конкретної бази даних.

DO
$$
DECLARE
    table_row RECORD;
    line_to_print RECORD;
BEGIN
    FOR table_row IN (
        SELECT * FROM information_schema.tables
        WHERE table_schema = 'public'
    )
    LOOP
        EXECUTE ('SELECT * FROM ' || quote_ident(table_row.table_name) || ' LIMIT 1') INTO line_to_print;
        RAISE NOTICE 'Table: %, First row: %', table_row.table_name, line_to_print;
    END LOOP;
END
$$;

--2. Видати дозвіл на читання бази даних Northwind усім користувачам вашої СУБД. Користувачі,
--що будуть створені після виконання запиту, доступ на читання отримати не повинні.

GRANT SELECT ON ALL TABLES IN SCHEMA public TO PUBLIC;

--3. За допомогою курсору заборонити користувачеві TestUser доступ до всіх таблиць поточної
--бази даних, імена котрих починаються на префікс ‘prod_’. 

DO
$$
DECLARE
    table_row RECORD;
    table_cur CURSOR FOR
        SELECT * FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name LIKE 'prod[_]%';
BEGIN
    OPEN table_cur;
    LOOP
        FETCH table_cur INTO table_row;
        EXIT WHEN NOT FOUND;
        EXECUTE ('REVOKE ALL PRIVILEGES ON TABLE ' || quote_ident(table_row.table_name) || ' FROM TestUser');
    END LOOP;
    CLOSE table_cur;
END;
$$;


--4. В контексті бази Northwind створити збережену процедуру (або функцію), що приймає в якості
--параметра номер замовлення та виводить імена продуктів, їх кількість, та загальну суму по
--кожній позиції в залежності від вартості, кількості та наявності знижки. Запустити виконання
--збереженої процедури для всіх наявних замовлень.

CREATE OR REPLACE FUNCTION get_order_by_id(order_id SMALLINT)
RETURNS TABLE (
    product_name VARCHAR(40),
    quantity SMALLINT,
    total_price DOUBLE PRECISION
)
LANGUAGE plpgsql AS
$$
BEGIN
    RETURN QUERY 
    SELECT products."ProductName", order_details."Quantity", 
    order_details."UnitPrice" * order_details."Quantity" * (1 - order_details."Discount") AS total_price
    FROM order_details
    JOIN products USING ("ProductID")
    WHERE "OrderID" = order_id;
    
END;
$$

SELECT get_order_by_id("OrderID") FROM orders;  -- Run on all orders

--5. Видаліть дані з усіх таблиць в усіх базах даних наявної СУБД. Код повинен бути незалежним
--від наявних імен об’єктів.

DO
$$
DECLARE
    table_row RECORD;
BEGIN
    FOR table_row IN (
        SELECT * FROM information_schema.tables
        WHERE table_schema = 'public'
    )
    LOOP
        EXECUTE ('DELETE FROM ' || quote_ident(table_row.table_name));
    END LOOP;
END
$$;

--6. Створити тригер на таблиці Customers, що при вставці нового телефонного номеру буде
--видаляти усі символи крім цифр.

-- Trigger function
CREATE OR REPLACE FUNCTION trim_phone_number()
RETURNS TRIGGER 
LANGUAGE plpgsql AS
$$
BEGIN
    NEW."Phone" := regexp_replace(NEW."Phone", '[^0-9]+', '', 'g');
    RETURN NEW;
END;
$$

-- Creating trigger
CREATE TRIGGER trig_trim_phone_number
BEFORE INSERT OR UPDATE 
ON customers
FOR EACH ROW EXECUTE PROCEDURE trim_phone_number();

--7. В контексті бази Northwind створити тригер який при вставці даних в таблицю Order Details
--нових записів буде перевіряти загальну вартість замовлення. Якщо загальна вартість
--перевищує 100 грошових одиниць – надати знижку в 3%, якщо перевищує 500 – 5%, більш ніж
--1000 – 8%.

-- Trigger function
CREATE OR REPLACE FUNCTION give_discount_to_order()
RETURNS TRIGGER 
LANGUAGE plpgsql AS
$$
DECLARE
    total_price DOUBLE PRECISION;
    given_discount DOUBLE PRECISION := 0;
BEGIN
    -- Calculate total price
    SELECT sum("UnitPrice" * "Quantity" * (1 - "Discount")) INTO total_price
    FROM order_details
    WHERE "OrderID" = NEW."OrderID";

    -- Setting value of given discount
    IF total_price > 1000 THEN
        given_discount := 0.08;
    ELSIF total_price > 500 THEN
        given_discount := 0.05;
    ELSIF total_price > 100 THEN
        given_discount := 0.03;
    END IF;

    -- Give new discount to old rows
    UPDATE order_details
    SET "Discount" = given_discount
    WHERE "OrderID" = NEW."OrderID";

    -- New row discount setting
    NEW."Discount" = given_discount;
    RETURN NEW;
END;
$$

-- Creating trigger
CREATE TRIGGER trig_give_discount_to_order 
BEFORE INSERT 
ON order_details
FOR EACH ROW EXECUTE PROCEDURE give_discount_to_order();


--8. Створити таблицю Contacts (ContactId, LastName, FirstName, PersonalPhone, WorkPhone, Email,
--PreferableNumber). Створити тригер, що при вставці даних в таблицю Contacts вставить в
--якості PreferableNumber WorkPhone якщо він присутній, або PersonalPhone, якщо робочий
--номер телефона не вказано.

-- Creating table
CREATE TABLE contacts (
    "ContactId" INT,
    "LastName" VARCHAR(64),
    "FirstName" VARCHAR(64),
    "PersonalPhone" VARCHAR(20),
    "WorkPhone" VARCHAR(20),
    "Email" VARCHAR(64),
    "PreferableNumber" VARCHAR(20)
);

-- Trigger function
CREATE OR REPLACE FUNCTION set_preferable_number()
RETURNS TRIGGER 
LANGUAGE plpgsql AS
$$
BEGIN
    -- Set preferable number
    IF NEW."WorkPhone" IS NOT NULL THEN
        NEW."PreferableNumber" = NEW."WorkPhone";
    ELSE
        NEW."PreferableNumber" = NEW."PersonalPhone";
    END IF;

    RETURN NEW;
END;
$$

-- Creating trigger
CREATE TRIGGER trig_set_preferable_number
BEFORE INSERT OR UPDATE
ON contacts
FOR EACH ROW EXECUTE PROCEDURE set_preferable_number();


--9. Створити таблицю OrdersArchive що дублює таблицію Orders та має додаткові атрибути
--DeletionDateTime та DeletedBy. Створити тригер, що при видаленні рядків з таблиці Orders
--буде додавати їх в таблицю OrdersArchive та заповнювати відповідні колонки.

-- Creating table
CREATE TABLE orders_archive (
    LIKE orders,
    "DeletionDateTime" TIMESTAMP,
    "DeletedBy" TEXT
);

-- Trigger function
CREATE OR REPLACE FUNCTION deleted_row_to_archive()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO orders_archive 
        SELECT OLD.*, current_timestamp AS "DeletionDateTime", current_user AS "DeletedBy";
    
    RETURN NULL;
END;
$$

-- Creating trigger
CREATE TRIGGER trig_deleted_row_to_archive
AFTER DELETE 
ON orders
FOR EACH ROW EXECUTE PROCEDURE deleted_row_to_archive();



--10. Створити три таблиці: TriggerTable1, TriggerTable2 та TriggerTable3. Кожна з таблиць має
--наступну структуру: TriggerId(int) – первинний ключ з автоінкрементом, TriggerDate(Date).
--Створити три тригера. Перший тригер повинен при будь-якому записі в таблицю TriggerTable1
--додати дату запису в таблицю TriggerTable2. Другий тригер повинен при будь-якому записі в
--таблицю TriggerTable2 додати дату запису в таблицю TriggerTable3. Третій тригер працює
--аналогічно за таблицями TriggerTable3 та TriggerTable1. Вставте один рядок в таблицю
--TriggerTable1. Напишіть, що відбулось в коментарі до коду. Чому це сталося?


-- Creating tables
CREATE TABLE trigger_table1 (
    "TriggerId" SERIAL PRIMARY KEY,
    "TriggerDate" DATE
);
CREATE TABLE trigger_table2 (
    "TriggerId" SERIAL PRIMARY KEY,
    "TriggerDate" DATE
);
CREATE TABLE trigger_table3 (
    "TriggerId" SERIAL PRIMARY KEY,
    "TriggerDate" DATE
);


-- Trigger functions
CREATE OR REPLACE FUNCTION date1to2()
RETURNS TRIGGER 
LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO trigger_table2("TriggerDate") VALUES (current_date);
    RETURN NEW;
END;
$$

CREATE OR REPLACE FUNCTION date2to3()
RETURNS TRIGGER 
LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO trigger_table3("TriggerDate") VALUES (current_date);
    RETURN NEW;
END;
$$

CREATE OR REPLACE FUNCTION date3to1()
RETURNS TRIGGER 
LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO trigger_table1("TriggerDate") VALUES (current_date);
    RETURN NEW;
END;
$$


-- Creating triggers
CREATE TRIGGER trig_date1to2
BEFORE INSERT 
ON trigger_table1
FOR EACH ROW EXECUTE PROCEDURE date1to2();

CREATE TRIGGER trig_date2to3
BEFORE INSERT 
ON trigger_table2
FOR EACH ROW EXECUTE PROCEDURE date2to3();

CREATE TRIGGER trig_date3to1
BEFORE INSERT 
ON trigger_table3
FOR EACH ROW EXECUTE PROCEDURE date3to1();


INSERT INTO trigger_table1 ("TriggerDate") VALUES ('2020-12-12')

-- Произошла ошибка такого содержания:
-- ERROR: stack depth limit exceeded.
-- Произошла такая ошибка по очевидной причине: триггеры реагируют друг друга поочередно и вызывают бесконечный цикл таких реакций. Каждый триггер сохраняет результат полученного текущего времени в стеке, а поскольку триггеры вызываются постоянно, то место в стеке заканчивается и происходит переполнение, о чем и говорит ошибка. 































