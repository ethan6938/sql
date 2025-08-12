
-- Lookup tables
CREATE TABLE profession (
  prof_id SERIAL PRIMARY KEY,
  profession TEXT NOT NULL UNIQUE     -- (1) UNIQUE on profession
);

CREATE TABLE zip_code (
  zip_code CHAR(4) PRIMARY KEY,       -- natural key
  city     TEXT NOT NULL,
  province TEXT NOT NULL,
  CONSTRAINT zip_format CHECK (zip_code ~ '^\d{4}$')  -- 4 digits only
);

CREATE TABLE status (
  status_id SERIAL PRIMARY KEY,
  status    TEXT NOT NULL UNIQUE
);

CREATE TABLE interests (
  interest_id SERIAL PRIMARY KEY,
  interest    TEXT NOT NULL UNIQUE
);

CREATE TABLE seeking (
  seeking_id SERIAL PRIMARY KEY,
  seeking    TEXT NOT NULL UNIQUE
);

-- Main contacts table
CREATE TABLE my_contacts (
  contact_id SERIAL PRIMARY KEY,
  last_name  TEXT NOT NULL,
  first_name TEXT NOT NULL,
  phone      TEXT,
  email      TEXT,
  gender     TEXT,
  birthday   DATE,
  prof_id    INT REFERENCES profession(prof_id),
  zip_code   CHAR(4) REFERENCES zip_code(zip_code),
  status_id  INT REFERENCES status(status_id)
);

-- Join tables (composite PKs)
CREATE TABLE contact_interest (
  contact_id  INT NOT NULL REFERENCES my_contacts(contact_id) ON DELETE CASCADE,
  interest_id INT NOT NULL REFERENCES interests(interest_id) ON DELETE CASCADE,
  PRIMARY KEY (contact_id, interest_id)
);

CREATE TABLE contact_seeking (
  contact_id INT NOT NULL REFERENCES my_contacts(contact_id) ON DELETE CASCADE,
  seeking_id INT NOT NULL REFERENCES seeking(seeking_id) ON DELETE CASCADE,
  PRIMARY KEY (contact_id, seeking_id)
);

-- Seed data
-- (3) zip_code has province (not state)
-- (4) all 9 South African provinces, two cities each
INSERT INTO zip_code (zip_code, city, province) VALUES
-- Western Cape
('8001','Cape Town','Western Cape'),
('7600','Stellenbosch','Western Cape'),
-- Gauteng
('2000','Johannesburg','Gauteng'),
('0002','Pretoria','Gauteng'),
-- KwaZulu-Natal
('4001','Durban','KwaZulu-Natal'),
('3201','Pietermaritzburg','KwaZulu-Natal'),
-- Eastern Cape
('6001','Gqeberha','Eastern Cape'),
('5201','East London','Eastern Cape'),
-- Free State
('9301','Bloemfontein','Free State'),
('9460','Welkom','Free State'),
-- North West
('0299','Rustenburg','North West'),
('2745','Mahikeng','North West'),
-- Limpopo
('0700','Polokwane','Limpopo'),
('0950','Thohoyandou','Limpopo'),
-- Mpumalanga
('1201','Mbombela','Mpumalanga'),
('1035','eMalahleni','Mpumalanga'),
-- Northern Cape
('8301','Kimberley','Northern Cape'),
('8801','Upington','Northern Cape');

INSERT INTO profession (profession) VALUES
('Software Engineer'),('Designer'),('Teacher'),('Nurse'),('Lawyer'),
('Accountant'),('Data Analyst'),('Project Manager'),('Chef'),('Electrician'),
('Photographer'),('Journalist');

INSERT INTO status (status) VALUES
('Single'),('In a relationship'),('It''s complicated'),('Married');

INSERT INTO interests (interest) VALUES
('Hiking'),('Running'),('Cycling'),('Swimming'),('Reading'),
('Cooking'),('Travel'),('Gaming'),('Music'),('Art'),
('Tech'),('Fitness'),('Yoga'),('Movies'),('Photography');

INSERT INTO seeking (seeking) VALUES
('Friendship'),('Dating'),('Long-term'),('Activity partner');

-- (6) 16+ contacts
INSERT INTO my_contacts (last_name, first_name, phone, email, gender, birthday, prof_id, zip_code, status_id) VALUES
('Smith','Ava','071-000-0001','ava.smith@example.com','F','1994-01-10',1,'8001',1),
('Johnson','Liam','071-000-0002','liam.j@example.com','M','1991-03-22',2,'7600',1),
('Naidoo','Maya','071-000-0003','maya.n@example.com','F','1996-07-14',3,'2000',2),
('Peters','Noah','071-000-0004','noah.p@example.com','M','1990-11-05',4,'0002',1),
('Mokoena','Leah','071-000-0005','leah.m@example.com','F','1993-02-02',5,'4001',3),
('Botha','Ethan','071-000-0006','ethan.b@example.com','M','1989-09-30',6,'3201',1),
('Dlamini','Isla','071-000-0007','isla.d@example.com','F','1995-04-28',7,'6001',4),
('van Wyk','Lucas','071-000-0008','lucas.vw@example.com','M','1992-08-18',8,'5201',2),
('Khoza','Mila','071-000-0009','mila.k@example.com','F','1997-12-07',9,'9301',1),
('Patel','Arjun','071-000-0010','arjun.p@example.com','M','1990-05-19',10,'9460',2),
('Daniels','Zoe','071-000-0011','zoe.d@example.com','F','1993-06-21',11,'0299',1),
('Sithole','Kai','071-000-0012','kai.s@example.com','M','1988-10-03',12,'2745',3),
('Jacobs','Ruby','071-000-0013','ruby.j@example.com','F','1994-03-11',1,'0700',2),
('Ngcobo','Leo','071-000-0014','leo.n@example.com','M','1992-01-29',2,'0950',1),
('Meyer','Ella','071-000-0015','ella.m@example.com','F','1998-07-01',3,'1201',1),
('Coetzee','Max','071-000-0016','max.c@example.com','M','1991-02-15',4,'1035',2),
('Adams','Lily','071-000-0017','lily.a@example.com','F','1995-09-09',5,'8301',1),
('Fourie','Noa','071-000-0018','noa.f@example.com','X','1993-12-24',6,'8801',4);

-- (5) give EVERY contact more than 2 interests (3 each below)
-- helper: map interest names to IDs as inserted above
-- HIKING=1 RUNNING=2 CYCLING=3 SWIMMING=4 READING=5 COOKING=6 TRAVEL=7
-- GAMING=8 MUSIC=9 ART=10 TECH=11 FITNESS=12 YOGA=13 MOVIES=14 PHOTOGRAPHY=15
INSERT INTO contact_interest (contact_id, interest_id) VALUES
(1,1),(1,5),(1,11),
(2,6),(2,7),(2,9),
(3,2),(3,12),(3,14),
(4,3),(4,11),(4,15),
(5,5),(5,6),(5,13),
(6,1),(6,3),(6,12),
(7,5),(7,9),(7,10),
(8,7),(8,8),(8,14),
(9,4),(9,6),(9,12),
(10,1),(10,2),(10,11),
(11,9),(11,10),(11,15),
(12,3),(12,7),(12,8),
(13,5),(13,13),(13,14),
(14,2),(14,11),(14,12),
(15,6),(15,7),(15,9),
(16,1),(16,3),(16,5),
(17,10),(17,14),(17,15),
(18,4),(18,6),(18,12);

-- seeking preferences (at least one each; mix it up)
INSERT INTO contact_seeking (contact_id, seeking_id) VALUES
(1,2),(1,3),
(2,2),
(3,1),(3,2),
(4,3),
(5,2),(5,4),
(6,1),
(7,3),
(8,2),
(9,4),
(10,2),(10,3),
(11,1),(11,4),
(12,2),
(13,3),
(14,2),
(15,1),(15,2),
(16,4),
(17,3),
(18,2);

-- Quick verification queries (optional)
-- Count contacts
-- SELECT COUNT(*) FROM my_contacts;                    -- should be >= 16
-- Ensure each contact has > 2 interests
-- SELECT contact_id, COUNT(*) c FROM contact_interest GROUP BY contact_id HAVING COUNT(*) <= 2;
-- Provinces coverage
-- SELECT province, COUNT(*) FROM zip_code GROUP BY province ORDER BY province; -- should be 2 each
