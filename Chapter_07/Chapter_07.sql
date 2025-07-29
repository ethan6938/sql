--------------------------------------------------------------
-- Practical SQL: A Beginner's Guide to Storytelling with Data
-- by Anthony DeBarros

-- Chapter 7 Code Examples
--------------------------------------------------------------

-- Listing 7-1: Declaring a single-column natural key as primary key

-- As a column constraint
CREATE TABLE natural_key_example (
    license_id varchar(10) CONSTRAINT license_key PRIMARY KEY,
    first_name varchar(50),
    last_name varchar(50)
);

-- Drop the table before trying again
DROP TABLE natural_key_example;

-- As a table constraint
CREATE TABLE natural_key_example (
    license_id varchar(10),
    first_name varchar(50),
    last_name varchar(50),
    CONSTRAINT license_key PRIMARY KEY (license_id)
);

-- Listing 7-2: Example of a primary key violation
INSERT INTO natural_key_example (license_id, first_name, last_name)
VALUES ('T229901', 'Lynn', 'Malero');

INSERT INTO natural_key_example (license_id, first_name, last_name)
VALUES ('T229901', 'Sam', 'Tracy');

SELECT * FROM natural_key_example

-- Listing 7-3: Declaring a composite primary key as a natural key
CREATE TABLE natural_key_composite_example (
    student_id varchar(10),
    school_day date,
    present boolean,
    CONSTRAINT student_key PRIMARY KEY (student_id, school_day)
);

-- Listing 7-4: Example of a composite primary key violation

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '1/22/2017', 'Y');

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '1/23/2017', 'Y');

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '1/23/2017', 'N');

SELECT * FROM natural_key_composite_example

-- Listing 7-5: Declaring a bigserial column as a surrogate key

CREATE TABLE surrogate_key_example (
    order_number bigserial,
    product_name varchar(50),
    order_date date,
    CONSTRAINT order_key PRIMARY KEY (order_number)
);

INSERT INTO surrogate_key_example (product_name, order_date)
VALUES ('Beachball Polish', '2015-03-17'),
       ('Wrinkle De-Atomizer', '2017-05-22'),
       ('Flux Capacitor', '1985-10-26');

SELECT * FROM surrogate_key_example;

-- Listing 7-6: A foreign key example

CREATE TABLE licenses (
    license_id varchar(10),
    first_name varchar(50),
    last_name varchar(50),
    CONSTRAINT licenses_key PRIMARY KEY (license_id)
);

SELECT * FROM licenses

CREATE TABLE registrations (
    registration_id varchar(10),
    registration_date date,
    license_id varchar(10) REFERENCES licenses (license_id),
    CONSTRAINT registration_key PRIMARY KEY (registration_id, license_id)
);

SELECT * FROM registrations

INSERT INTO licenses (license_id, first_name, last_name)
VALUES ('T229901', 'Lynn', 'Malero');

INSERT INTO registrations (registration_id, registration_date, license_id)
VALUES ('A203391', '3/17/2017', 'T229901');

INSERT INTO registrations (registration_id, registration_date, license_id)
VALUES ('A75772', '3/17/2017', 'T000001');

-- Listing 7-7: CHECK constraint examples

CREATE TABLE check_constraint_example (
    user_id bigserial,
    user_role varchar(50),
    salary integer,
    CONSTRAINT user_id_key PRIMARY KEY (user_id),
    CONSTRAINT check_role_in_list CHECK (user_role IN('Admin', 'Staff')),
    CONSTRAINT check_salary_not_zero CHECK (salary > 0)
);

-- Both of these will fail:
INSERT INTO check_constraint_example (user_role)
VALUES ('Staff');

INSERT INTO check_constraint_example (salary)
VALUES (10000);

SELECT * FROM check_constraint_example

-- Listing 7-8: UNIQUE constraint example

CREATE TABLE unique_constraint_example (
    contact_id bigserial CONSTRAINT contact_id_key PRIMARY KEY,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(200),
    CONSTRAINT email_unique UNIQUE (email)
);

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Samantha', 'Lee', 'slee@example.org');

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Betty', 'Diaz', 'bdiaz@example.org');

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Sasha', 'Lee', 'slee@example.org');

SELECT * FROM unique_constraint_example

-- Listing 7-9: NOT NULL constraint example

CREATE TABLE not_null_example (
    student_id bigserial,
    first_name varchar(50) NOT NULL,
    last_name varchar(50) NOT NULL,
    CONSTRAINT student_id_key PRIMARY KEY (student_id)
);

-- Listing 7-10: Dropping and adding a primary key and a NOT NULL constraint

-- Drop
ALTER TABLE not_null_example DROP CONSTRAINT student_id_key;

-- Add
ALTER TABLE not_null_example ADD CONSTRAINT student_id_key PRIMARY KEY (student_id);

-- Drop
ALTER TABLE not_null_example ALTER COLUMN first_name DROP NOT NULL;

-- Add
ALTER TABLE not_null_example ALTER COLUMN first_name SET NOT NULL;

SELECT * FROM not_null_example

-- Listing 7-11: Importing New York City address data

CREATE TABLE new_york_addresses (
    longitude numeric(9,6),
    latitude numeric(9,6),
    street_number varchar(10),
    street varchar(32),
    unit varchar(7),
    postcode varchar(5),
    id integer CONSTRAINT new_york_key PRIMARY KEY
);

COPY new_york_addresses
FROM '/tmp/city_of_new_york.csv'
WITH (FORMAT CSV, HEADER);

-- Listing 7-12: Benchmark queries for index performance

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'BROADWAY';

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = '52 STREET';

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'ZWICKY AVENUE';

SELECT * FROM new_york_addresses

-- Listing 7-13: Creating a B-Tree index on the new_york_addresses table

CREATE INDEX street_idx ON new_york_addresses (street);






CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10)
);

CREATE TABLE hobbies (
    hobby_id SERIAL,
    users_id INT,
    hobby_name VARCHAR(100),
    skill_level INT
);


ALTER TABLE users
ADD CONSTRAINT users_pk PRIMARY KEY (users_id);

ALTER TABLE users
ADD CONSTRAINT check_age CHECK (age >= 0 AND age <= 120);

ALTER TABLE hobbies
ADD CONSTRAINT hobbies_pk PRIMARY KEY (hobby_id);

ALTER TABLE hobbies
ADD CONSTRAINT hobbies_users_fk FOREIGN KEY (users_id) REFERENCES usere(users_id);

ALTER TABLE hobbies
ADD CONSTRAINT check_skill_level CHECK (skill_level BETWEEN 1 AND 10);


INSERT INTO users (name, age, gender)
VALUES ('Ethan Hurwitz', 17, 'male');


INSERT INTO hobbies (users_id, hobby_name, skill_level)
VALUES (1, 'Coding', 9);

SELECT * FROM users

SELECT * FROM hobbies







CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INT,
    pages INT CHECK (pages >= 10),
    CONSTRAINT fk_author FOREIGN KEY (author_id)
        REFERENCES authors(author_id)
);

ALTER TABLE books
ADD CONSTRAINT unique_title UNIQUE (title);

INSERT INTO authors (name) VALUES
('J.K. Rowling'),
('George Orwell'),
('J.R.R. Tolkien'),
('Agatha Christie'),
('Stephen King');

INSERT INTO books (title, author_id, pages) VALUES
('Harry Potter and the Philosopher''s Stone', 1, 223),
('1984', 2, 328),
('The Hobbit', 3, 310),
('Murder on the Orient Express', 4, 256),
('The Shining', 5, 447),
('Harry Potter and the Chamber of Secrets', 1, 251);

SELECT b.title, b.pages, a.name AS author
FROM books b
JOIN authors a ON b.author_id = a.author_id;

DROP TABLE hobbies;
