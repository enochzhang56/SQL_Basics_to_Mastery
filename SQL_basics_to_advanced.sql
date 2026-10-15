/* SQL foundations: basics to advanced roadmap */ 

-- Step 1 *Basics* 
--Databases
--Tables
--Data Types and NULL 
--CRUD Operations (Create, Read, Update, Delete) 
--DDL vs DML basics 

-- Step 2 *Queries* 
--SELECT
--FROM
--WHERE (AND, OR, NOT) 
--ORDER BY
--GROUP BY 
--LIMIT, DISTINCT 

-- Step 3 *Functions*
--Aggregate Functions COUNT, SUM, AVG, MIN, MAX 
--String Functions UPPER, LOWER, CONCAT 
--Date Functions NOW, DATE, DATEIFF
--NULL Handling COALESCE 

-- Step 4 *Joins*
--INNER JOIN 
--LEFT JOIN 
--RIGHT JOIN 
--FULL JOIN
--SELF JOIN 
--CROSS JOIN 

-- Step 5 *Subqueries*
--Subqueries in SELECT, FROM, WHERE
--Correlated Subqueries 

-- Step 6 *Constraints*
--PRIMARY KEY
--FOREIGN KEY
--UNIQUE
--NOT NULL
--CHECK
--DEFAULT

-- Step 7 *Indexes and Views*
--Indexing for performance
--Index trade-offs
--Creating & using views

-- Step 8 *Normalization*
--First Normal Form (1NF) 
--Second Normal Form (2NF) 
--Third Normal Form (3NF) 
--When to denormalize 

--Step 9 *Transactions*
--BEGIN, COMMIT, ROLLBACK, SAVEPOINT
--ACID properties
--Isolation levels

--Step 10 *Advanced SQL*
--Window Functions 
--Common Table Expressions (CTEs) 
--Functions
--Triggers 

--Extra Step *Additional Data Analyst Skills*
-- CASE WHEN 
-- Conditional Aggregation
-- Safe division
-- Time Series
-- Subtotal and grandtotals in one query
-- Median and percentiles 
-- LATERAL JOIN
-- Set operations 

--Data Cleaning Toolkit 
-- 9 step cleaning process

/* Step 1 Basics */

--Databases
/* A database is an organized collection of data that can be searched, 
 * 		updated, and managed efficiently. 
 * In postgres, the default database is 'postgres.' In order to make 
 * 		new databases, you can creature using the query:
 * CREATE DATABASE database_name;
 * Then change the connection to the new database.
 */

CREATE DATABASE sqlroadmap;


--Tables

/* Tables store data in rows and columns and must be created with the syntax:
 * CREATE TABLE table_name ( 
 * column_name data_type [contraints] 
 * ... );
 * 
 * Creating Table for Spotify Charts data from kaggle. 
 * https://www.kaggle.com/datasets/dhruvildave/spotify-charts
 */ 

CREATE TABLE spotify_charts_unclean (
	title VARCHAR, 
	rank INT, 
	date DATE, 
	artist VARCHAR,
	url VARCHAR,
	region VARCHAR, 
	chart VARCHAR,
	trend VARCHAR,
	streams INT
);

/* import data from downloads*/


--Data Types and NULL 
/* A Data Type definds the kind of value that a column can hold. 
 * Common postgresql data types include: 
 	* INT / BIGINT: whole numbers 
 	* NUMERIC(10, 2): exact decimals
 	* VARCHAR(n) / TEXT: strings and characters
 	* DATE / TIMPESTAMP: calendar date and date + time
 	* BOOLEAN: TRUE FALSE
 * Choosing the right data type is important because it affects the amount of data that 
 * can be stored and rejects data does not belong in the row (ie: letters in an INT column) 
 */

/* NULL mean "no value" or "missing value" 
 * It does not equate to 0
 * Things to rememeber when encountering NULL 
 	* Compare with IS NULL / IS NOT NULL. = NULL will return no rows in queries
 	* Arithmetric performed on NULL columns will return back NULL
 	* Aggregates like SUM or COUNT() ignores NULL 
 */

-- CRUD Operations (Create, Read, Update, Delete) 
/* CRUD is the four basic things you can do with data in a database. 
 	* Create -> INSERT
 	* Read -> SELECT
 	* Update -> UPDATE
 	* Delete -> DELETE
 * Notes for some of the statements: 
 	* CREATE is a separate query that creates a table itself, not merely adding a row. 
 	* UPDATE and DELETE without a WHERE clause affect every row in the tale. 
 */

/* examples of CRUD syntax */
INSERT INTO spotify_charts_unclean (title, rank, date, artist, url, region, chart, trend, streams)
VALUES ('not a real song', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20000);

SELECT title, streams
FROM spotify_charts_unclean 
WHERE title = 'not a real song';

UPDATE spotify_charts_unclean 
SET streams = 400000000
WHERE title = 'not a real song';

DELETE FROM spotify_charts_unclean 
WHERE streams = 400000000;

-- DDL vs DML basics 
/* DDL (Data Definition Language) defines and changes the structure of the database: its tables,
 * columns, and other obects. 
 * Examples: 
 	* CREATE: build a new object
 	* ALTER: modifies an existing obkect
 	* DROP: deletes an object entirely 
 	* TRUNCATE: removes all the rows but keeps the table itself
 */

/* examples of DDL syntax */
CREATE TABLE temp_table (
	useless INT,
	even_more VARCHAR, 
	the_most DATE
);

ALTER TABLE temp_table ADD COLUMN nvm_this_the_most_useless BOOLEAN;

TRUNCATE TABLE temp_table; 

DROP TABLE temp_table;

/* DML (Data Manipulation Language) works with the data inside the structure. 
 * Examples:
 	* INSERT
 	* SELECT
 	* UPDATE
 	* DELETE
 * These are the SQL commands that perform the CRUD operations.
 * These commands DO NOT change the actual data or the data 
 * structure. They only affect the output! No worries of alterning data. 
 */


/* Step 2 Queries */

--Queries
/* A query is a request you send to the database to retrieve data. 
 * There is a basic structure of a query: 
 	* SELECT: which columns to return 
 	* FROM: which table to read data from
 	* WHERE: which rows to keep (acts as the filter) 
 	* GROUP BY: when aggregating (will cover below), how to bundle rows 
 	* ORDER BY: how to sort results 
 	* LIMIT: how many rows to return
 	* ;: end queries with ;
 */

/* example query */
SELECT title, rank, streams, streams/100 AS streams_per_100 --setting an Alias (a temporary name for a column that we created) 
FROM spotify_charts_unclean
WHERE rank = 1
ORDER BY streams ASC
LIMIT 200;

/* The order in which you write a query is not the order the database runs each command.
 * The actual order is: 
 	* FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT
 * For Aliases, because these queries outputs do not change the data itself, the names are 
 * temporary because they only exist in the output of the query.  
 */

/* Important Caveat */
/* Queries can grow far beyond this basic structure. 
 * Each clause has more options, and queries can be combined or nested inside each other
 */ 

/* Example of a fuller syntax for each command (not exhaustive)*/
SELECT DISTINCT region -- DISTINCT removes duplicate rows
SELECT * -- all columns
SELECT streams / 1000 AS streams_k -- expressions and aliases
SELECT COUNT(*), AVG(streams) -- aggregates, functions

FROM spotify_charts_unclean AS s -- table alias
FROM a JOIN b ON a.id = b.id -- joins (will be covered in Step 4)
FROM (SELECT ...) AS sub -- subquery in FROM (will be covered in Step 5)

WHERE rank = 1 -- comparison: = <> < > <= >=
WHERE rank = 1 AND region = 'us' -- AND, OR, NOT
WHERE rank IN (1, 2, 3) -- match a list
WHERE rank BETWEEN 1 AND 10 -- inclusive range
WHERE title LIKE 'Love%' -- pattern; ILIKE ignores case
WHERE streams IS NOT NULL -- NULL checks

GROUP BY region, chart -- one output row per group

HAVING COUNT(*) > 100 -- filters groups, after aggregation

ORDER BY streams DESC, title ASC -- multiple sort keys
ORDER BY streams DESC NULLS LAST -- control where NULLs land

LIMIT 10 OFFSET 20 -- skip 20 rows, return the next 10


/* Step 3 Functions */

--Functions
/* A function takes an input (a column or value), does something to it, 
 * and returns a result. Functions can be used in SELECT, WHERE, GROUP BY,
 * ORDER BY, and HAVING clauses.
 */

-- Aggregate Functions
/* Aggregate Functions collapse many rows into a single value and performs an operation on them.
 * Examples: 
 	* COUNT(*): number of rows 
 	* COUNT(column): number of non-NULL values in that column 
 	* SUM, AVG: total sum and average of a numeric column 
 	* MIN, MAX: returns smallest and biggest value
* Aggregates ignore NULLS (except COUNT(*)). With GROUP BY, return one value per group, instead
* of on for the whole table. 
* You cannot use a WHERE clause after an aggregate function. Use HAVING to filter. 
*/

/* Aggregate Function Examples */
SELECT COUNT(*) AS total_rows, 
	SUM(streams) AS total_streams, 
	ROUND(AVG(streams), 0) as avg_streams,
	MIN(streams) AS min_streams,
	MAX(streams) as max_streams
FROM spotify_charts_unclean;
/* This query returns 5 columns with each respective aggregate function and their aliases 
 * Each clause collapsed all of the rows into 1, that is why only 1 row is returned.
 * Each clause also created its own column ouput, thus why we hvae 5 columns.
 */

SELECT region, COUNT(*) AS chart_entries
FROM spotify_charts_unclean
GROUP BY region 
HAVING COUNT(*) > 200
ORDER BY chart_entries DESC;
/* This query adds more nuance to aggregate queries. Remeber that queries don't run in
 * the order that it is written. 
 * FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT
 * This query first groups the data into regions, then counts the total number,
 * then filters those, then orders them, putting the largest at the top. 
 */

-- String Functions
/* String Functions transform text.
 * Examples: 
 	* UPPER(text), LOWER(text): changes case 
 	* CONCAT(a, b, ...): joins strings (the || operator does the same)
 * Useful for cleaning data!  
 */

/* String Function Examples */
SELECT UPPER(region) AS region_upper, 
	LOWER(artist) AS artist_lower,
	CONCAT(title, ' - ', artist) AS song_and_artist
FROM spotify_charts_unclean
LIMIT 100;

--Date Functions
/* Date functions work with dates and timestamps.
 * Examples:
 	* NOW(): current date and time
 	* CURRENT_DATE: today's date 
 	* date - date: number of days between two dates 
 	* AGE(a; b): interval between two dates, as years/months/days
 	* EXTRACT(part FROM date): pull out year, month, day, etc... 
 */ 

/* Date Function Examples */
SELECT title,
	NOW() AS current_time, 
	CURRENT_DATE - date AS days_since_chart,
	EXTRACT(YEAR FROM date) AS chart_year
FROM spotify_charts_unclean
LIMIT 100;

--NULL Handling
/* NULL Handling primarily uses the function COALESCE(a, b, ...) which returns the first non-NULL value. 
 * Use it to replace mising data with a default, so NULLs are addressed in data. 
 */

/* COALESCE Example */
SELECT title,
	COALESCE(streams, 0) AS streams_clean, 
	COALESCE(artist, 'Unknown') AS artist_clean
FROM spotify_charts_unclean
LIMIT 100;
/* This query returns everything, but if there is a NULL in the data, then it will return 
 * either 0 or unknown
 */


/* Step 4 Joins */ 

/* A join combines rows from two tables based on a related column.
 * Different types of joins keeps different parts of the data. 
 * For the purpose of demonstrating joins, we will create new smaller tables
 * to see the output of joins. 
 */

/* Example of Different Types of Joins */

CREATE TABLE departments (
	dept_id INT PRIMARY KEY, -- Will talk more in depth about KEYS in step 6 
	dept_name VARCHAR(30) NOT NULL
);

CREATE TABLE employees (
	emp_id INT PRIMARY KEY, 
	name VARCHAR(30) NOT NULL,
	dept_id INT,
	manager_id INT
);

INSERT INTO departments VALUES 
	(1, 'Sales'),
	(2, 'Engineering'), 
	(3, 'Marketing');

INSERT INTO employees VALUES
	(1, 'Ana', 1, NULL),
    (2, 'Ben', 1, 1),
    (3, 'Cara', 2, 1),
    (4, 'Dev', 2, 3),
    (5, 'Eli', NULL, 3);

/* Syntax for JOINS 
SELECT column1, column2, ...
FROM table1
JOIN table2
    ON table1.common_column = table2.common_column;
*/

--INNER JOIN: only rows that match in both tables 
SELECT e.name, d.dept_name -- e and d are aliases set below
FROM employees e
INNER JOIN departments d 
	ON e.dept_id = d.dept_id;

--LEFT JOIN: FROM table is left table. keeps all rows from left, and if matched with right table then joined.
SELECT e.name, d.dept_name
FROM employees e
LEFT JOIN departments d
	ON e.dept_id = d.dept_id; 
/* unmatched data will remain NULL but will be returned */

--RIGHT JOIN: same as above, but keeps all rows from right and drops what isn't matched on left. 
SELECT e.name, d.dept_name
FROM employees e
RIGHT JOIN departments d
	ON e.dept_id = d.dept_id; 
/* unmatched data will remain NULL but will be returned */

--FULL JOIN: everything from both sides 
SELECT e.name, d.dept_name
FROM employees e
FULL JOIN departments d
	ON e.dept_id = d.dept_id; 

--CROSS JOIN: every combination of rows, doesn't need ON condition 
SELECT e.name, d.dept_name
FROM employees e
CROSS JOIN departments d;
/* Doesn't seem that useful, but if you want to show every combination, or create 
 * a full grid, it can be used. 
 */


/* Step 5 Subqueries */

--Subqueries
/* Subqueries are a SELECT nested inside another query. 
 * The inner query runs first and the outer query takes the result and subsequently runs. 
 * What the subquery returns depends on where it is nested.
 */

/*Subquery Examples */

--Subquery in WHERE (single value)
SELECT title, artist, streams
FROM spotify_charts_unclean
WHERE streams > (SELECT AVG(streams) FROM spotify_charts_unclean)
ORDER BY streams DESC 
LIMIT 100;
/* Returns songs with streams above the overall average streams */

--Subquery in WHERE (list, with IN)
SELECT title, artist, streams, rank
FROM spotify_charts_unclean
WHERE artist IN (SELECT artist FROM spotify_charts_unclean WHERE rank = 1)
LIMIT 100
/* Returns all songs with artists who have hit rank 1 */

--Subquery in SELECT
SELECT title, streams,
	(SELECT ROUND(AVG(streams)) FROM spotify_charts_unclean) AS overall_avg
FROM spotify_charts_unclean
LIMIT 100;
/* Returns an extra column with overall average for comparison */

--Subquery in FROM: 
SELECT ROUND(AVG(region_total)) AS avg_region_total
FROM (
	SELECT region, SUM(streams) as region_total
	FROM spotify_charts_unclean
	GROUP BY region 
) AS region_totals;
/* Sets the dataset from which the outer query pulls data from */

--Correlated Subqueries 
/* A correlated subquery correlates to different columns in the outer query, so
 * it runs multiple times for each outer row it is associated with. 
 */

/* Correlated Subquery Examples */ 
SELECT s.title, s.region, s.streams
FROM spotify_charts_unclean s 
WHERE s.streams > (
	SELECT AVG(streams)
	FROM spotify_charts_unclean
	WHERE region = s.region)
LIMIT 100;
/* Returns songs in which streams are more than regional average */

SELECT DISTINCT s.artist 
FROM spotify_charts_unclean s
WHERE EXISTS (  --EXISTS checks whether rows match condition in the subquery
	SELECT 1 -- returns a 1 
	FROM spotify_charts_unclean x
	WHERE x.artist = s.artist
		AND x.region <> s.region)
LIMIT 100;
/* Returns artists with songs from different regions */


/* Step 6 Constraints */


/* Contsraints are rules attached to a table that the database
 * enacts on every INSERT and UPDATE. Data that doesn't adhere to rules are rejected. 
 * The contraints are set either in CREATE TABLE or ALTER TABLE. 
 * Examples of constraints:
 	* PRIMARY KEY: uniquely identifies each row. One per table 
 	* FOREIGN KEY: links a column to the primary key of another table
 	* UNIQUE: every row must have a unique value
 	* NOT NULL: the column must always contain a value
 	* CHECK: the value must satisfy a condition that is defined
 	* DEFAULT: the value used when nothing is given on INSERT  
 * Examples will not be used on spotify dataset again like Step 4.  
 */ 

/* Constraints Example */ 

CREATE TABLE customers (
	customer_id SERIAL PRIMARY KEY, -- Establishes Primary Key
	email VARCHAR(100) UNIQUE NOT NULL, -- Forces Unique values and non-NULL values 
	name VARCHAR(50) NOT NULL, -- Forces data to not be NULL
	signup_date DATE DEFAULT CURRENT_DATE -- If no date is present, row defaults to current date.
);

CREATE TABLE orders (
	order_id SERIAL PRIMARY KEY,
	customer_id INT NOT NULL REFERENCES customers (customer_id), --Sets Foreign Key
	amount NUMERIC (10,2) CHECK (amount > 0), --Sets CHECK rules
	status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'shipped', 'cancelled')) --another CHECK rule
);

--Valid Inserts 
INSERT INTO customers (email, name) VALUES ('ana@example.com', 'Ana');
INSERT INTO orders (customer_id, amount) VALUES (1, 49.99);

--Failed Inserts
INSERT INTO customers (email, name) VALUES ('ana@example.com', 'Ana B');  -- UNIQUE violation
INSERT INTO customers (email, name) VALUES ('ben@example.com', NULL);     -- NOT NULL violation
INSERT INTO orders (customer_id, amount) VALUES (99, 10.00);              -- FOREIGN KEY violation (no customer 99)
INSERT INTO orders (customer_id, amount) VALUES (1, -5.00);

--Contraints can also be added: 
ALTER TABLE customers ADD CONSTRAINT name_not_blank CHECK (name <> '');



/* Step 7 Indexes and Views */

--Indexing for Performance
/* An index is a separate data structure, usually a Balance Tree (B-tree), which 
 * stores values in a sorted tree structure to speed up lookups and sorting. 
 * It allows the database to find rows without reading the whole table, 
 * like a table of contents. 
 * 
 * Without an index, a filter like WHERE artist = 'X' would have SQL go sequentially
 * through every row. With an index on artists, it can jump straight to matching rows. 
 */

/* NOTE: PRIMARY KEY and UNIQUE constraints create an index automatically */ 

/* Indexing Example */

EXPLAIN ANALYZE -- This line executes the query and displays the execution plan. 
                -- We will use this as the baseline before we index. 
SELECT title, artist, streams
FROM spotify_charts_unclean
WHERE artist = 'Taylor Swift'; -- Execution Time: 9185.129 ms

--Creating the Index General Syntax 
	-- CREATE INDEX index_name 
	-- ON table_name (column_name);

CREATE INDEX idx_spotify_artist -- idx_ standard naming convention
	ON spotify_charts_unclean (artist);

EXPLAIN ANALYZE -- Rerun after Index is created
SELECT title, artist, streams
FROM spotify_charts_unclean
WHERE artist = 'Taylor Swift'; -- Execution Time: 4416.884 ms

--Creating More complicated Indexes 

CREATE INDEX idx_spotify_region_chart
	ON spotify_charts_unclean (region, chart); -- indexing based off of region, then chart
CREATE UNIQUE INDEX idk_customer_email
	ON customers (email); -- enforces uniqueness. returns error message if index cannot be fulfilled. 
DROP INDEX IF EXISTS index_name


--Index Trade-offs
/* Indexes do have downsides: 
 	* The generall have slower writes: every INSERT, UPDATE, and DELETE 
 		* must be updated on each index 
 	* Indexes also take up separate storage spaces 
 	* On smaller tables, sequential scan might be faster 
 	* Composite indexes help only when the query filters on the leading
 		* column. An index on (region, chart) will only run faster on the region, but
 		* not if you are looking for specific charts. 
 * Rule of thumb: index columns used often in WHERE, JOIN, and ORDER BY, especially
 * on large, read-heavy tables. DO NOT INDEX EVERYTHING! 
 */


--Views 
/* A view is a saved query that behaves like a table. It doesn't store any data on it's own, so
 * each time you query the view, the underlying query runs. 
 * Uses: reuse complex queries, simplify access for other uses, and hide columns 
 * or rows you don't want shown. 
 */

/* Views Examples */ 
CREATE VIEW top_hits AS
SELECT title, artist, region, streams
FROM spotify_charts_unclean
WHERE rank = 1; 

--Now that the view is created, we can use it like a table and query it 
SELECT region, COUNT(*) AS number_one_songs
FROM top_hits 
GROUP BY region 
ORDER BY number_one_songs DESC;
	
--To replace/remove views:
CREATE OR REPLACE VIEW top_hits AS 
SELECT title, artist, region, streams
FROM spotify_charts_unclean
WHERE rank = 1 AND streams IS NOT NULL; 

DROP VIEW IF EXISTS top_hits;


-- Materialized Views
/* Materialized Views stores the query's results in storage, so reads are faster. 
 * But the data does not update unless you update the view by running the refresh code. 
 * You can use materalized views when you have an expensive query that needs to be run 
 * over and over again, but doesn't need to be that up to date. 
 */

/* Materialized View Example */
CREATE MATERIALIZED VIEW region_stream_totals AS
SELECT region, SUM(streams) AS total_streams
FROM spotify_charts_unclean
GROUP BY region;

REFRESH MATERIALIZED VIEW region_stream_totals;


/* Step 8 Normalization */

--Normalization: what is it? 
/* Normalization is organizing tables so each fact is storied only in one place. 
 * It reduces redundancy (which is the same data across rows) and prevents three 
 * kinds of anomalies: 
 	* Update anomaly: when data is stored in multiple rows, if you edit one row, 
	* 				  but there is a duplicate row, the duplicate row will remain unupdated.
	* Insert anomaly: not a redundancy, but lets say you are cataloging purchases. There is
	* 				  a new product, but no one has bought it yet. You can't catalogue the
	* 				  new product unless someone orders it. 
	* Delete anomaly: deleting one fact accidently destroys another. let's say you delete a 
	* 				  customers only order, and the customer would disappear.
 */

/* There are 3 different normal forms and each one cumulates ontop of the previous one. 
 	* 1NF: Every column holds a single value. Every row is uniquely identifiable.
 	* 	   For example, lets say you are storing students and their classes. There should 
 	* 	   not be more than 1 class per student. This is a problem because if you want to 
 	* 	   find a speciifc piece of data, you don't want stacked data that has multiple
 	* 	   outputs, just one. To solve this, you would have to separate the student into 2 
 	* 	   rows, one class per row.   
 	* 2NF: 1NF, plus every non-key column depends on the WHOLE primary key. For example, 
 	* 	   in your database you have student ID and student name, along with their classes. 
 	* 	   The student ID should be the same as name. This is a problem because if you want 
 	* 	   to update the name for the student ID, you have to update multiple rows. To solve 
 	*      this, you can split the data to be in 2 tables, one for student ID and name, and 
 	* 	   one for student ID and classes. 
 	* 3NF: 2NF, plus non-key columns depend only on the key not other non-key columns. For
 	* 	   example, in your database, you have student ID, gym period, and gym teacher. But
 	* 	   gym teacher depends on the gym period. This is a problem because if you update the
 	* 	   gym teacher's name for one row, it might not be adjusted for the other rows. To solve 
 	* 	   this, split the data.  
 	* Technical Terms: 
 	 	* 1NF needs the data to be ATOMIC 
 	 	* 2NF needs the data to not include any PARTIAL DEPENDENCIES
 	 	* 3NF needs the data to not have any TRANSITIVE DEPENDENCIES
 */

/* Normalization Example */ 
/* will be making new tables for normalization, will not work with spotify data */

--If you have a table that violates 1NF like this one: 
CREATE TABLE demo_0nf (
	order_id INT, 
	order_date DATE,
	customer_name VARCHAR(50),
	customer_email VARCHAR(100),
	customer_city VARCHAR(50),
	products VARCHAR(200) -- "Notebook, Pen"
);
-- you would have to normalize it. Drop the table and separate products.
DROP TABLE IF EXISTS demo;
CREATE TABLE demo_1NF (
	order_id INT, 
	order_date DATE,
	customer_name VARCHAR(50),
	customer_email VARCHAR(100),
	customer_city VARCHAR(50),
	product_id INT,
	proudct_name VARCHAR(50),
	unit_price NUMERIC(8,2),
	quantity INT, 
	PRIMARY KEY (order_id, product_id) -- Sets Primary Key 
);
--This data is in 1NF, but it is not in 2NF. It can have multiple rows for a single customer. 
--If you wanted to updated the customers email, you woul dhave to update it multiple times. 
--To solve this, we have to split into 3 different tables 
DROP TABLE IF EXISTS demo_1NF;
CREATE TABLE demo_2NF_products ( 
	product_id INT,
	product_name VARCHAR(50),
	unit_price NUMERIC(8,2)
);
CREATE TABLE demo_2NF_orders (
	order_id INT, 
	order_date DATE,
	customer_name VARCHAR(50),
	customer_email VARCHAR(100),
	customer_city VARCHAR(50)
);
CREATE TABLE demo_2NF_order_items(
	order_id INT,
	product_id INT,
	quantity INT,
);
--These 3 tables complete the 2NF. But, customer details still repeat across orders.
-- customer_email and customer_city depend on the customer, not the order. 
-- To solve this, we can give each customer their own table. 
DROP TABLE IF EXISTS demo_2NF_products;
DROP TABLE IF EXISTS demo_2NF_orders;
DROP TABLE IF EXISTS demo_2NF_order_items;
CREATE TABLE demo_3NF_customers (
	customer_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	email VARCHAR(100) UNIQUE NOT NULL,
	city VARCHAR(50)
);
CREATE TABLE demo_3NF_products (
	product_id INT PRIMARY KEY, 
	product_name VARCHAR(50) NOT NULL,
	unit_price NUMERIC (8,2) NOT NULL  
);
CREATE TABLE demo_3NF_orders (
	order_id INT PRIMARY KEY,
	order_date DATE NOT NULL,
	customer_id INT NOT NULL REFERENCES demo_3NF_customers (customer_id) --creates a foreign key relationship 
);
CREATE TABLE demo_3NF_order_items (
	order_id INT REFERENCES demo_3NF_orders (order_id),
	product_id INT REFERENCES demo_3NF_products (product_id),
	quantity INT NOT NULL CHECK (quantity > 0),
	PRIMARY KEY (order_id, product_id)
);
--Nice! Database is now in 3NF! 


--When to Denormalize
/* Denormalizing is when you want to deliberately add redundancy back. 
 * Some situations that you would want to denormalize:
 	* Read-heavy workloads that do not usually need writes/udpates. 
 	* Storign historical values that must not change.
 * Why? 
 	* Reads faster!  
 */



/* Step 9 Transactions */

--BEGIN, COMMIT, ROLLBACK
--ACID properties
--Isolation levels

--Transactions 
/* Transactions are a group of SQL statements that run as one unit: either al of them run 
 * together, or none of them. A simple analogy would be a zelle or venmo transaction. 
 * Subtracting from one bank means adding to another. 
 * 
 * Explicit Transactions in SQL have 4 commands: 
 	* BEGIN: starts the transaction 
 	* COMMIT: make every change permanent
 	* ROLLBACK: undo every change since BEGIN
 	* SAVEPOINT: mark a point inside a transaction you can roll back to  
 */

/* Transaction Example */
/* Using separate table once again */ 

CREATE TABLE accounts (
	account_id INT PRIMARY KEY, 
	owner VARCHAR(30) NOT NULL,
	balance NUMERIC(10,2) NOT NULL CHECK (balance >= 0)
);

--Insert exemplary accounts 
INSERT INTO accounts VALUES (1, 'Ana', 500.00), (2, 'Ben', 200.00);

--COMMIT: transfer $100 from Ana to Ben
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;

--Show the COMMIT
SELECT * FROM accounts;

--ROLLBACK: before you commit, you can undo the transaction 
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
SELECT * FROM accounts; --shows Ana at 300 
ROLLBACK; --undoes the transaction
SELECT * FROM accounts;-- Ana is back to 400 

--ROLLBACK can run automatically if CHECK constraint faills 
BEGIN;
UPDATE accounts SET balance = balance + 1000 WHERE account_id = 2;
UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1; --fails the check! 
ROLLBACK;
SELECT * FROM accounts; --transaction never occured

--SAVEPOINT: undo part of the transaction without completely restarting
BEGIN;
UPDATE accounts SET balance = balance - 50 WHERE account_id = 1;
SAVEPOINT after_first_step;
UPDATE accounts SET balance = balance - 9999 WHERE account_id = 1; --Fails the check!
ROLLBACK TO after_first_step;                                  
COMMIT;
SELECT * FROM accounts; --shows only the first step!


--ACID Properties
/* Acronym to ensure a transactional database covers: 
 	* Atomicity: all commands succeed or none of them do 
 	* Consistency: a transaction does not violate contraints
 	* Isoalation: concurrent transactions don't interfere with one another. 
 	* 			  if a transaction has not finished, it will not affect another.
 	* Durability: once a COMMIT is ran, the change will survive a crash or power loss. 
 */ 


--Isolation Levels 
/* With the I in ACID, isolation occurs at different levels. 
 * Higher levels prevent more concurrency problems, but may cause 
 * locking, retries, or performance problems. 
 * 
 * Specific problems that occur: 
 	* Dirty read: reading another transaction's UNCOMMITTED changes 
 	* Non-repeatable read: the same row gives different values when read twice in one 
 	* 					   transaction because a different transaction committed inbetween. 
 	* Phantom read: the same query returns a different set of rows the second time, because 
 	* 				another transaction inserted or deleted matching rows. 
 */

/* Standard SQL Isolation Levels to set: 
 	* READ UNCOMMITTED: Allows dirty reads
 	* READ COMMITTED: sees only committed data (DEFAULT)
 	* REPEATABLE READ: one snapshot for the whole transaction 
 	* SERIALIZABLE: behaves as if one transaction ran one at a time
 */

/* Isolation Level Example (just setting)*/
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;



/* Step 10 Advanced SQL */ 

--Window Functions 
/* A Window Functions calculates across a set of related rows without collapsing them. 
 * To contrast: GROUP BY returns one row per group, while a window function keeps 
 * every row and adds a calculated column 
 * Similar to: a subquery in SELECT. Returns an extra column instead of collapsing the rows. 
 */

/* Syntax for Window Finctions 
 * 
 * function() OVER (PARTITION BY ... ORDER BY ... [frame]) 
 	* function() can be any function. Four main categories of functions()
 		* Ranking: 
 			* ROW_NUMBER()
 			* RANK()
 			* DENSE_RANK() 
		* Offset: 
			* LAG()
			* LEAD()
		* Aggregate: 
			* SUM()
			* AVG()
			* COUNT()
	 	* Other: 
	 		* NTILE(n) splits rows into n buckets    
	* OVER sets the window function 
	* PARTITION BY ...
		* determines how to split the rows into groups 
		*  ... can be a lot of things: 
			* column_name
			* DATE_TRUNC('year', order_date)
			* CASE WHEN STREAMS...
			* column_name1, column_name2

 	* ORDER BY ...
 		* establishes how you want to order the rows within each partition
 */

/*Window Function Examples */

--Retrieve top 3 songs per region (ranking within groups)
SELECT * 
FROM (
	SELECT region, title, streams,
		ROW_NUMBER() OVER (PARTITION BY region ORDER BY streams DESC) AS row_num
	FROM spotify_charts_unclean 
	WHERE streams IS NOT NULL
	) AS ranked 
WHERE row_num <=3;

--Compare ties on the most streams 
SELECT title, streams, 
	ROW_NUMBER() OVER (ORDER BY streams DESC) AS row_num, --no need to have partition by because you are doing aggregate
	RANK() OVER (ORDER BY streams DESC) AS rank,
	DENSE_RANK() OVER (ORDER BY streams DESC) AS dense_rank
FROM spotify_charts_unclean
WHERE streams IS NOT NULL
LIMIT 20;

--Compare charts from previous day using LAG()
SELECT date, region, title, streams, 
	LAG(streams) OVER (PARTITION BY title, region ORDER BY date) as prev_streams,
	streams - LAG(streams) OVER (PARTITION BY title, region ORDER BY date) AS daily_streams
FROM spotify_charts_unclean
WHERE streams IS NOT NULL 
LIMIT 20;

--Percent of each song compared to region's total streams 
SELECT region, title, streams, 
	ROUND(100.0 * streams / SUM(streams) OVER (PARTITION BY region), 2) as pct_of_region
FROM spotify_charts_unclean
WHERE streams IS NOT NULL
LIMIT 20;


--Common Table Expressions (CTEs)
/* A CTE is a named, temporary result and used in the query right
 * after it. It is similar to a subquery, but lets you reference the table multiple times,
 * and lets you build a query in different stages.
 * 
 * Syntax: 
 	* WITH temporary_table_name AS ()   
 */

/*CTE Examples */

-- Using Multiple CTEs 
WITH region_totals AS ( 
	SELECT region, SUM(streams) as total_streams
	FROM spotify_charts_unclean
	GROUP BY region
),
global_total AS (
	SELECT SUM(total_streams) AS grand_total FROM region_totals
)
SELECT r.region, r.total_streams,
	ROUND (100 * r.total_streams / g.grand_total, 2) AS pct_of_gloabl
FROM region_totals r
CROSS JOIN global_total g
ORDER BY r.total_streams DESC;
-- Using 2 CTE's to show each regions percentage of total streams compared to the global. 
-- The reason why we have a cross join is because the global_total only returns 1 row. 
-- Cross join allows the global_total to be added to every row.


-- RECURSIVE CTE: a CTE that keeps running until everything is ran through. Using employees from Step 4
WITH RECURSIVE org_chain AS (
	SELECT emp_id, name, manager_id, 1 AS level 
	FROM employees
	WHERE manager_id IS NULL -- sets the anchor: the first one that is iterated. 
	UNION ALL -- begin the iteration below this point
	SELECT e.emp_id, e.name, e.manager_id, oc.level + 1 -- oc.level + 1 how the recursive element is run 
	FROM employees e 
	JOIN org_chain oc ON e.manager_id = oc.emp_id --in recursive cte, you can take it FROM the table
)
SELECT * FROM org_chain ORDER BY level, emp_id; -- calls the RECURSIVE CTE that was created above



--Functions
/* Functions are reusable codes that are saved in the database: they return a table or a value.
 * Benefits: reusable
 * Costs: code is native to a database, and might not transfer well across different databases. 
 */

/* Functions Example */ 
CREATE FUNCTION region_stream_total(p_region TEXT) -- describe what should be the input of the function
RETURNS NUMERIC
LANGUAGE sql
AS $$ -- this is the general syntax for the beginning of the function 
	SELECT COALESCE(SUM(streams), 0) --describe what you want the function to do 
	FROM spotify_charts_unclean
	WHERE region = p_region;
$$; -- ends the function 

SELECT region_stream_total('United States');


--Triggers 
/* A trigger automatically runs a function wen a table is modified (with INSERT, UPDATE, OR
 * DELETE), BEFORE or AFTER the change. 
 * Common uses: audit logs, timestamps, enforceing rules too complicated for constraints
 * Drawbacks: run in the background which makes bugs harder to find. 
 */

/* Trigger Syntax: 
 * 2 Parts
 	* Creating the Trigger Function 
 	* Creating the Trigger itself 
 */

/* Trigger Example*/
--Part 1 Trigger Function
CREATE FUNCTION log_balance_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$ 
BEGIN
	IF NEW.balance <> OLD.balance THEN 
		INSERT INTO account_audit (account_id, old_balance, new_balance)
		VALUES (OLD.account_id, OLD.balance, NEW.balance);
	END IF;
	RETURN NEW;
END;
$$;

--Step 2 Trigger
CREATE TRIGGER trg_balanace_audit
AFTER UPDATE ON accounts 
FOR EACH ROW 
EXECUTE FUNCTION log_balance_change();



/* Extra Step Additional Data Analyst Skills*/

--CASE WHEN: conditional logic, like python IF 
SELECT title, streams,
	CASE WHEN streams >= 10000000 THEN 'mega hit'
		WHEN streams >= 1000000 THEN 'hit'
		WHEN streams >= 100000 THEN 'aight'
		WHEN streams > 0 THEN 'mid'
		WHEN streams IS NULL THEN 'unknown'
		ELSE 'standard' END AS tier
FROM spotify_charts_unclean
LIMIT 20;

--Conditional Aggregation: applys aggregate function only if condition met 
SELECT region, 
	COUNT(*) AS entries,
	COUNT(*) FILTER (WHERE rank = 1) AS number_ones,
	COUNT(*) FILTER (WHERE chart = 'viral50') AS viral_entries
FROM spotify_charts_unclean
GROUP BY region;

--Safe division: ensuring divisor is never 0 so no error occurs when running query
SELECT region, SUM(streams) / NULLIF(COUNT(*), 0) AS streams_per_entry
FROM spotify_charts_unclean
GROUP BY region;

--Time Series: change dates to period and perform functions on it 
SELECT DATE_TRUNC('month', date) AS month, SUM(streams) AS monthly_streams -- DATE_TRUNC(only tracks month)
FROM spotify_charts_unclean 
GROUP BY DATE_TRUNC('month', date)
ORDER BY month;

--Subtotals and grand totals in one query 
SELECT region, chart, SUM(streams) AS total_streams
FROM spotify_charts_unclean
WHERE streams IS NOT NULL and region IS NOT NULL
GROUP BY ROLLUP(region, chart); -- Breaks down view 

--Median and percentiles 
/*General Syntax: 
 * PERCENTILE_CONT(percentile)
 * WITHIN GROUP (ORDER BY column name you want percentile of) 
 */
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY streams) AS median_streams,
		PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY streams) AS p90_streams
FROM spotify_charts_unclean;

--LATERAL join: allows subqueries to do joins with tables selected outside of the subquery
SELECT r.region, t.title, t.streams
FROM (SELECT DISTINCT region FROM spotify_charts_unclean) r
CROSS JOIN LATERAL ( 
	SELECT title, streams
	FROM spotify_charts_unclean s
	WHERE s.region = r.region AND s.streams IS NOT NULL
	ORDER BY s.streams DESC
	LIMIT 3
) t;

--Set operations 
/* Combines the results of two or more select statements into one result
 * Similar to JOINs but instead of horizontal joining, it is a vertical stacking
 * Both Queries must return the same number of columns, in the same order, 
 * with compatible data types. Column names are determined by the first query. 
 */
/* Set opertion types: 
 	* UNION stacks rows but removes duplicates
 	* UNION ALL stack rows but keeps duplicates (generally faster to run)
 	* INTERSECT keeps rows that appear in BOTH results
 	* EXCEPT keeps rows in the first result that are not in the second
 */

/*Set Syntax */
SELECT name FROM table1
UNION -- or UNION ALL or INTERSECT or EXCEPT 
SELECT name FROM table2


/* Data Cleaning Tooklit */ 
/* Below is  a cleaning workflow: 9 steps to ensure that data is
 * clean and ready for analysis
 * Each step has all of the possible code needed to clean the data, but it might not
 * all be applicable. 
 */


--Step 1: Find and Profile the Problems 

/* Row Count, non-null count, and distinct count per column */ 
SELECT COUNT(*) AS total_rows, 
	COUNT(title) AS title_filled, 
	COUNT(DISTINCT title) AS title_distinct,
	COUNT(*) - COUNT(artist) AS artist_nulls,
	COUNT(*) - COUNT(streams) AS stream_nulls
FROM spotify_charts_unclean;
-- Table has 164,807 distinct titles, 0 artist nulls, and 5,851,610 stream nulls.

/* Frequency table: shows inconsistent labels (repeat for necessary columns) */ 
SELECT region, COUNT(*) AS total_per_region
FROM spotify_charts_unclean
GROUP BY region 
ORDER BY total_per_region DESC;
--No inconsistent naming conventions

/* Reveal any blank strings that might be read as non-null values */
SELECT COUNT(*) AS blank_artists
FROM spotify_charts_unclean
WHERE TRIM(artist) = '';
-- 0 artists 

/* Reveal any values that don't cast to a number */
SELECT streams
FROM spotify_charts_unclean
WHERE streams:: TEXT !~ '^\d+$' --checks the regular expression (regex) of the value
LIMIT 20;
-- None

/* Check for Ranges and oddities */ 
SELECT MIN(streams::NUMERIC), MAX(streams::NUMERIC) 
FROM spotify_charts_unclean


--Step 2: Address Whitespace and Case 

/* Depending on the task, use whatever is necessary */ 

SELECT TRIM(title) AS trimmed, --trims both ends
	LTRIM(title) AS left_trimmed,
	RTRIM(title) AS right_trimmed,
	BTRIM(title, '"''') AS quotes_stripped, --strips characters that you want
	REGEXP_REPLACE(title, '[\s\u00a0]+', ' ', 'g') AS spaces_collapsed, -- cleans spaces inbetween
	LOWER(region) AS lower_case, 
	UPPER(region) AS upper_case, 
	INITCAP(artist) AS title_case -- first words are capitalized
FROM spotify_charts_unclean;


--Step 3: Replace, Remove, and Extract Text 

/* Depending on the task, use whatever is necessary */ 

SELECT REPLACE(title, '&amp', '&' AS html_fixed, --sometimes websites encode & with amp
	TRANSLATE(artist, 'áéíóú', 'aeiou') AS accents_removed,
	REGEX_REPLACE(streams::TEXT, '[^0-9]', '', 'g') AS digits_only, -- '1,000,000' becomes '1000000'
	REGEX_REPLACE(title, '\(feat\..*?\)', '', 'i') AS feat_removed, --get's rid of featured artists
	SPLIT_PART(artist, ',', 1) AS first_artist, -- only keeps first name
	STRING_TO_ARRAY(artist, ', ') AS artist_array --splits artists into list
FROM spotify_charts_unclean;


--Step 4: NULL and Blank 

/* Depending on the task, use whatever is necessary */ 

SELECT NULLIF(TRIM(artist), '') AS blank_to_null, -- blanks become NULL 
	NULLIF(UPPER(TRIM(artist)), 'N/A') AS placeholder_to_null, -- 'N/A' becomes NULL
	COALESCE(NULLIF(TRIM(artist), ''), 'Unknown') AS filled_default, --blanks or NULL becomes "Unknown"
	artist IS NOT DISTINCT FROM NULL AS null_safe_comapre --NULL can equal NULL now 
FROM spotify_charts_unclean;


--Step 5: Type Casting 

/* Depending on the task, use whatever is necessary */ 

SELECT TO_DATE(date, 'YYYY-MM-DD') AS iso_date,
	TO_DATE('03/15/2025', 'MM/DD/YYYY') AS us_format,
	TO_TIMESTAMP('2025-03-15 14:30', 'YYYY-MM-DD HH24:MI') AS full_timestamp
FROM spotify_charts_unclean;

SELECT CASE WHEN date ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(date, 'YYYY-MM-DD')
	WHEN date ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(date, 'MM/DD/YYYY')
	END AS date_clean
FROM spotify_charts_unclean;


--Step 6: Standardize Categories

/* Depending on the task, use whatever is necessary */ 

SELECT CASE WHEN LOWER(TRIM(region)) IN ('us', 'usa', 'united states') THEN 'United States'
	WHEN LOWER(TRIM(region)) IN ('uk', 'gb', 'united kingdom')  THEN 'United Kingdom'
	ELSE INITCAP(TRIM(region)) END AS region_clean
FROM spotify_charts_unclean;

--Step 7: Duplicates 

/* Depending on the task, use whatever is necessary */ 

SELECT DISTINCT ON (column_name, ...) * 
FROM spotify_charts_unclean;
ORDER BY column_name, ... DESC NULLS LAST; 

--Step 8: Validation and Outliers 

/* Depending on the task, use whatever is necessary */ 

SELECT *
FROM spotify_charts_unclean
WHERE rank::INT NOT BETWEEN 1 AND 200 -- ranks that should not be included
	OR streams::BIGINT < 0 -- negative streams
	OR TO_DATE(date, 'YYYY-MM-DD') > CURRENT_DATE; -- future dates 

/* Finding Outliers by z-score */
SELECT * 
FROM (
	SELECT title, streams::BIGINT AS streams, -- :: is another way to cast 
	(streams::BIGINT - AVG(streams::BIGINT) OVER ()) 
		/ NULLIF(STDDEV(streams::BIGINT) OVER (), 0) AS z_score
	FROM spotify_charts_unclean
) AS z
WHERE ABS(z_score) >15; -- z_score changes depending on dataset 

/*Outlier by IQR */

WITH quartiles AS (
	SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY streams::BIGINT) AS q1,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY streams::BIGINT) AS q3
	FROM spotify_charts_unclean
)
SELECT s.title, s.streams
FROM spotify_charts_unclean s, quartiles q 
WHERE s.streams IS NOT NULL
	AND (s.streams::BIGINT < q.q1 - 1.5 * (q.q3 - q.q1)
	OR s.streams::BIGINT > q.q3 + 1.5 * (q.q3 - q.q1));












