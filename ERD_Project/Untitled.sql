-- 1. Drop tables in dependency order
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS salaries CASCADE;
DROP TABLE IF EXISTS overtime_hours CASCADE;

-- 2. Create tables
CREATE TABLE department (
    depart_id SERIAL PRIMARY KEY,
    depart_name VARCHAR(100),
    depart_city VARCHAR(100)
);

CREATE TABLE overtime_hours (
    overtime_id SERIAL PRIMARY KEY,
    overtime_hours INTEGER
);

CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role VARCHAR(100)
);

CREATE TABLE salaries (
    salary_id SERIAL PRIMARY KEY,
    salary_pa NUMERIC(10,2)
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    surname VARCHAR(50),
    gender VARCHAR(10),
    address VARCHAR(255),
    email VARCHAR(100),
    depart_id INTEGER REFERENCES department(depart_id),
    role_id INTEGER REFERENCES roles(role_id),
    salary_id INTEGER REFERENCES salaries(salary_id),
    overtime_id INTEGER REFERENCES overtime_hours(overtime_id)
);

-- 3. Insert sample data
INSERT INTO department (depart_name, depart_city)
VALUES
('IT', 'New York'),
('HR', 'Chicago'),
('Finance', 'Boston');

INSERT INTO overtime_hours (overtime_hours)
VALUES
(5),
(10),
(0);

INSERT INTO roles (role)
VALUES
('Developer'),
('Manager'),
('Analyst');

INSERT INTO salaries (salary_pa)
VALUES
(80000.00),
(95000.00),
(70000.00);

INSERT INTO employees (first_name, surname, gender, address, email, depart_id, role_id, salary_id, overtime_id)
VALUES
('John', 'Doe', 'M', '123 Main St', 'john.doe@example.com', 1, 1, 1, 1),
('Jane', 'Smith', 'F', '456 Oak St', 'jane.smith@example.com', 2, 2, 2, 2),
('Bob', 'Brown', 'M', '789 Pine St', 'bob.brown@example.com', 3, 3, 3, 3);

-- 4. LEFT JOIN query to show Department, Role, Salary, and Overtime Hours
SELECT 
    d.depart_name, 
    r.role, 
    s.salary_pa, 
    o.overtime_hours
FROM employees e
LEFT JOIN department d ON e.depart_id = d.depart_id
LEFT JOIN roles r ON e.role_id = r.role_id
LEFT JOIN salaries s ON e.salary_id = s.salary_id
LEFT JOIN overtime_hours o ON e.overtime_id = o.overtime_id;