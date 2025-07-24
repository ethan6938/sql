SELECT * FROM teachers;

SELECT first_name FROM teachers;

SELECT last_name, first_name FROM teachers;

SELECT DISTINCT school
FROM teachers;

SELECT DISTINCT salary
FROM teachers;


SELECT first_name, last_name, school
FROM teachers
ORDER BY school DESC;

DELETE FROM teachers
WHERE first_name IS NULL
  AND last_name IS NULL
  AND school IS NULL;

ALTER TABLE teachers ADD COLUMN age INTEGER;

UPDATE teachers SET age = 17 WHERE id = 7;
UPDATE teachers SET age = 9 WHERE id = 8;


SELECT last_name, school, hire_date
FROM teachers
WHERE school = 'Myers Middle School';


SELECT first_name, last_name, school
FROM teachers
WHERE first_name = 'Janet';


SELECT first_name, last_name, school, salary
FROM teachers
WHERE salary BETWEEN 40000 AND 65000;


SELECT first_name
FROM teachers
WHERE first_name ILIKE 'sam%';

SELECT first_name
FROM teachers
WHERE first_name LIKE 'sam%';

SELECT *
FROM teachers
WHERE school = 'Myers Middle School'
      AND salary < 40000;


SELECT *
FROM teachers
WHERE last_name = 'Cole'
      OR last_name = 'Bush';


SELECT *
FROM teachers
WHERE school = 'F.D. Roosevelt HS'
      AND (salary < 38000 OR salary > 40000);


SELECT first_name, last_name, school, hire_date, salary, age
FROM teachers
WHERE school LIKE '%Roos%'
ORDER BY hire_date DESC;