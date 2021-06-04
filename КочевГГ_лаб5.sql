-- Written by Hennadii Kochev IP-91
-- For PostgreSQL 12


--Задачі:


--1. Створити базу даних з ім’ям, що відповідає вашому прізвищу англійською мовою.

CREATE DATABASE Kochev;

--2. Створити в новій базі таблицю Student з атрибутами StudentId, SecondName, FirstName, Sex.
--Обрати для них оптимальний тип даних в вашій СУБД.

CREATE TABLE "Student" (
    "StudentId" INT,
    "SecondName" VARCHAR(255),
    "FirstName" VARCHAR(255),
    "Sex" VARCHAR(1)
);

--3. Модифікувати таблицю Student. Атрибут StudentId має стати первинним ключем.

ALTER TABLE "Student"
ADD PRIMARY KEY ("StudentId");

--4. Модифікувати таблицю Student. Атрибут StudentId повинен заповнюватися автоматично
--починаючи з 1 і кроком в 1.

ALTER TABLE "Student"
DROP COLUMN "StudentId",
ADD COLUMN "StudentId" SERIAL PRIMARY KEY;

--5. Модифікувати таблицю Student. Додати необов’язковий атрибут BirthDate за відповідним
--типом даних.

ALTER TABLE "Student"
ADD COLUMN "BirthDate" DATE;

--6. Модифікувати таблицю Student. Додати атрибут CurrentAge, що генерується автоматично на
--базі існуючих в таблиці даних.

ALTER TABLE "Student"
ADD COLUMN "CurrentAge" INT;

-- Trigger function
CREATE OR REPLACE FUNCTION find_current_age()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
    -- calculate age
    IF NEW."BirthDate" IS NOT NULL THEN
        NEW."CurrentAge" = EXTRACT(YEAR FROM CURRENT_DATE)::INT - EXTRACT(YEAR FROM NEW."BirthDate")::INT;
    END IF;
    RETURN NEW;
END;
$$

-- Creating trigger
CREATE TRIGGER trig_find_current_age
BEFORE INSERT OR UPDATE
ON "Student" 
FOR EACH ROW EXECUTE PROCEDURE find_current_age();


--7. Реалізувати перевірку вставлення даних. Значення атрибуту Sex може бути тільки ‘m’ та ‘f’.

ALTER TABLE "Student"
ADD CONSTRAINT "SexOnlyMF"
CHECK ("Sex" = 'm' OR "Sex" = 'f');

--8. В таблицю Student додати себе та двох «сусідів» у списку групи.

INSERT INTO "Student"("SecondName", "FirstName", "Sex")
VALUES ('Korobka', 'Ilya', 'm'), ('Kochev', 'Hennadii', 'm'), ('Kratyuk', 'Mihail', 'm');

--9. Створити представлення vMaleStudent та vFemaleStudent, що надають відповідну
--інформацію.

CREATE VIEW "vMaleStudent" AS
SELECT * FROM "Student" WHERE "Sex" = 'm';

CREATE VIEW "vFemaleStudent" AS
SELECT * FROM "Student" WHERE "Sex" = 'f';

--10. Змінити тип даних первинного ключа на TinyInt (або SmallInt) не втрачаючи дані.
 
DROP VIEW "vMaleStudent";   -- views prohibit changes of types
DROP VIEW "vFemaleStudent";

CREATE TABLE "StudentArchive" AS TABLE "Student";    -- create archive

TRUNCATE "Student";   -- clear "Student" table

ALTER TABLE "Student"
ALTER "StudentId" TYPE SMALLINT;   -- now we can change type

INSERT INTO "Student" SELECT * FROM "StudentArchive";  -- fill "Student" back

DROP TABLE "StudentArchive";   -- now we don't need archive 



































