/* SQL Practice Problems: Level 3 ANSWER SHEET

Covers Steps 8-10 plus the Analyst Toolkit and Data Cleaning

Database: sqlroadmap | Main Table: spotify_charts_unclean

columns: title, rank, date, artist, url, region, chart, trend, streams

QUICK TIPS: 
- Run Setup before starting Problem 1
- Most problems will use spotify_sample, which is a one-month slice of the data. 
Window functions and CTEs run a lot faster than the entire dataset. 

*/

/* Setup for Pracitce Problems (RUN CODE BELOW) */ 

DROP TABLE IF EXISTS spotify_sample;
CREATE TABLE spotify_sample AS
SELECT *
FROM spotify_charts_unclean
WHERE chart = 'top200'
  AND date >= '2020-01-01' AND date < '2020-02-01'
  AND region IN ('United States', 'Mexico', 'Brazil', 'Japan',
                 'Global', 'Germany', 'United Kingdom', 'Canada');
ANALYZE spotify_sample;
 
-- Flat orders table for the normalization problems
DROP TABLE IF EXISTS orders_flat;
CREATE TABLE orders_flat (
	order_id INT,
	order_date DATE,
	customer_name VARCHAR(50),
	customer_email VARCHAR(100),
	customer_city VARCHAR(50),
	product_id INT,
	product_name VARCHAR(50),
	unit_price NUMERIC(8,2),
	quantity INT,
	PRIMARY KEY (order_id, product_id)
);
INSERT INTO orders_flat VALUES
	(1, '2025-01-05', 'Ana',  'ana@example.com',  'Austin',  101, 'Notebook', 4.50, 2),
	(1, '2025-01-05', 'Ana',  'ana@example.com',  'Austin',  102, 'Pen',      1.25, 10),
	(2, '2025-01-06', 'Ben',  'ben@example.com',  'Boston',  101, 'Notebook', 4.50, 1),
	(3, '2025-01-07', 'Ana',  'ana@example.com',  'Austin',  103, 'Stapler',  9.99, 1),
	(3, '2025-01-07', 'Ana',  'ana@example.com',  'Austin',  102, 'Pen',      1.25, 5),
	(4, '2025-01-09', 'Cara', 'cara@example.com', 'Chicago', 103, 'Stapler',  9.99, 2);
 
-- Accounts for the transaction and trigger problems
DROP TABLE IF EXISTS practice_accounts;
CREATE TABLE practice_accounts (
	account_id INT PRIMARY KEY,
	owner VARCHAR(30) NOT NULL,
	balance NUMERIC(10,2) NOT NULL CHECK (balance >= 0)
);
INSERT INTO practice_accounts VALUES (1, 'Ana', 500.00), (2, 'Ben', 200.00);
 
-- Employees for the recursive CTE
DROP TABLE IF EXISTS l3_employees;
CREATE TABLE l3_employees (
	emp_id INT PRIMARY KEY,
	name VARCHAR(30) NOT NULL,
	manager_id INT
);
INSERT INTO l3_employees VALUES
	(1, 'Ana', NULL), (2, 'Ben', 1), (3, 'Cara', 1), (4, 'Dev', 3), (5, 'Eli', 3);
 
-- Deliberately dirty data for the cleaning problems
DROP TABLE IF EXISTS messy_songs;
CREATE TABLE messy_songs (
	row_id SERIAL PRIMARY KEY,
	title TEXT,
	artist TEXT,
	region TEXT,
	streams_text TEXT,
	chart_date_text TEXT
);
INSERT INTO messy_songs (title, artist, region, streams_text, chart_date_text) VALUES
	('  Blinding Lights ', 'the weeknd',    'US',             '1,200,000',      '2020-01-02'),
	('Blinding Lights',    'The Weeknd',    'usa',            '1200000',        '2020-01-02'),
	('Levitating',         'DUA LIPA',      'United States',  '950,000',        '01/03/2020'),
	('Levitating',         'Dua Lipa',      ' us ',           '950000',         '2020-01-03'),
	('Roxanne',            'Arizona Zervas','UK',             'N/A',            '2020-01-04'),
	('Roxanne',            'Arizona Zervas','gb',             '',               '01/05/2020'),
	('Dance Monkey',       'Tones and I',   'United Kingdom', '-5',             '2020-01-05'),
	('Memories',           'Maroon 5',      'uk',             '15,000,000,000', '2020-01-06'),
	('Memories',           'Maroon 5',      'UK',             '880,000',        '2020-01-07'),
	('Circles',            'Post Malone',   'US',             '1,050,000',      '2099-01-01'),
	('Circles',            'N/A',           'US',             '1,000,000',      '2020-01-07'),
	('Someone You Loved',  'Lewis Capaldi', 'UK',             '700,000',        '2020-01-07'),
	('Someone You Loved',  'Lewis Capaldi', 'United Kingdom', '710,000',        '01/08/2020'),
	('Señorita',           'Shawn Mendes',  'US',             '1,100,000',      '2020-01-08'),
	('Sunflower',          'Post Malone',   'US',             '2,300,000',      '2020-01-08');
 

/* Part A: Normalization */ 

-- Problem 1: Watch an update anomaly happen
-- a) In orders_flat, change Ana's city to 'Dallas' on ONE row only
--    (order 1, product 101).
-- b) Query the distinct (customer_name, customer_city) pairs for Ana.
--    What do you see, and how many rows would a correct update need?
-- c) Restore the city to 'Austin' on that row. (Do this before
--    Problem 3, or the migration will fail.)
 
-- YOUR ANSWER:

--a
UPDATE orders_flat
SET customer_city = 'Dallas'
WHERE order_id = 1 AND product_id = 101;

--b
SELECT DISTINCT customer_name, customer_city
FROM orders_flat
WHERE customer_name = 'Ana';
-- Ana's name comes up twice, but in 2 different cities. In order to update her city corrected,
-- only 1 row can return for it to be in 1NF

--c
UPDATE orders_flat
SET customer_city = 'Austin'
WHERE order_id = 1 AND product_id = 101;

SELECT DISTINCT customer_name, customer_city
FROM orders_flat
WHERE customer_name = 'Ana';
--This solves it. We are back to 1 row. 


-- Problem 2: Diagnose the design (written answer, in comments)
-- orders_flat is in 1NF. Name:
--   a) the columns that violate 2NF, and what part of the key they
--      depend on
--   b) the dependency that violates 3NF
--   c) one insert anomaly and one delete anomaly this design allows
 
-- YOUR ANSWER:

--a
--There is a violation of the partial key dependency, as the order_id determines the date,
--name, email, city, and quantity while the product_id determines the product_name and price. 
--2NF requires that there are no partial dependencies of the key. 

--b
--3NF is violated by the customer_name, customer_city, and customer_email all depend on
--on the customer. Also, the product_id, product_name, and unit_price are also dependent. 

--c
--Insert anomoly: a product doesn't exist until it is bought. 
--Delte anomaly: customer disappears when the order is deleted. 


-- Problem 3: Normalize to 3NF
-- Create four tables with proper keys and constraints:
--   norm_customers, norm_products, norm_orders, norm_order_items
-- Then populate them from orders_flat using INSERT ... SELECT, in the
-- right order so foreign keys are satisfied.
 
-- YOUR ANSWER:

CREATE TABLE norm_customers (
	customer_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	email VARCHAR(100) UNIQUE NOT NULL,
	city VARCHAR(50)
);

CREATE TABLE norm_products (
	product_id INT PRIMARY KEY,
	product_name VARCHAR(50) NOT NULL,
	unit_price NUMERIC(8,2) NOT NULL CHECK (unit_price > 0)
);

CREATE TABLE norm_orders (
	order_id INT PRIMARY KEY,
	order_date DATE NOT NULL,
	customer_id INT NOT NULL REFERENCES norm_customers (customer_id)
);

CREATE TABLE norm_order_items (
	order_id INT REFERENCES norm_orders (order_id),
	product_id INT REFERENCES norm_products (product_id),
	quantity INT NOT NULL CHECK (quantity > 0),
	PRIMARY KEY (order_id, product_id)
);
-- Breaks apart all of the dependencies. 


/* Part B: Advanced SQL */ 

-- Problem 4: ROW_NUMBER over an aggregate
-- For each region, find the single date with the highest total streams
-- and that day's total. One row per region.
 
-- YOUR ANSWER:

WITH ranked AS (
	SELECT region, date, SUM(streams) AS total_streams,
	ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(streams) DESC) AS highest_total
	FROM spotify_sample	
	GROUP BY region, date
)
SELECT *
FROM ranked
WHERE highest_total = 1;

--OR

SELECT region, date AS peak_date, day_total
FROM (
	SELECT region, date,
	       SUM(streams) AS day_total,
	       ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(streams) DESC) AS rn
	FROM spotify_sample
	GROUP BY region, date
) t
WHERE rn = 1
ORDER BY region;

-- Problem 5: ROW_NUMBER vs RANK vs DENSE_RANK
-- For the United States, count chart entries per artist and show all
-- three ranking functions side by side, ordered by entries (ties are
-- likely). Show 25 rows. Explain the difference in a comment.
 
-- YOUR ANSWER:

SELECT artist, COUNT(*) AS chart_entries, 
	ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS row_numbers, --NOTE: you are collapsing artists, so you don't need
	RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking,           -- to partition by. Partition by doesn't collapse completely.        
	DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS dense_ranking
FROM spotify_sample
WHERE region = 'United States'
GROUP BY artist
ORDER BY chart_entries DESC
LIMIT 25;
--They are all the same, but if there were two artists with the same chart_entires: 
--Row_number would not care, and just rank them differently 
--Rank would count it like 1, 2, 2, 4, and skip 3 because the 2nd place is tied 
--Dense_rank count it like 1, 2, 2, 3 and include the 3. 


-- Problem 6: Multiple CTEs
-- Find songs that reached #1 in the United States AND spent at least
-- 15 distinct days in the US top 10. Build it with two CTEs and a final
-- join. Show title, artist, and days in the top 10, most days first.
 
-- YOUR ANSWER:

WITH us_ranking AS( 
	SELECT title
	FROM spotify_sample
	WHERE rank = 1 AND region = 'United States'
),
fifteen_days AS (
	SELECT
    	title,
    	artist,
    	COUNT(DISTINCT date) AS days_in_top_ten
	FROM spotify_sample
	WHERE rank <= 10
		AND region = 'United States'
	GROUP BY title, artist
	HAVING COUNT(DISTINCT date) >= 15
)
SELECT f.title, f.artist, f.days_in_top_ten
FROM fifteen_days f 
INNER JOIN us_ranking u
	ON u.title = f.title
ORDER BY days_in_top_ten DESC;



-- Problem 7: Recursive CTEs
-- a) Generate a calendar of every date in January 2020 with a
--    recursive CTE, LEFT JOIN it to US chart rows, and return each date
--    with its US entry count (31 rows).
 
-- YOUR ANSWER:

WITH RECURSIVE cal AS (
	SELECT DATE '2020-01-01' AS d
	UNION ALL
	SELECT d + 1 FROM cal WHERE d < DATE '2020-01-31'
	)
SELECT c.d AS calendar_date, COUNT(s.title) AS us_entries
FROM cal c
LEFT JOIN spotify_sample s
	ON s.date = c.d AND s.region = 'United States'
GROUP BY c.d
ORDER BY c.d;


-- Problem 8: User-defined function
-- Create a function region_avg_streams(p_region TEXT) that returns the
-- average streams for a region from spotify_sample, rounded to 0
-- decimals. Call it for 'United States', then use it in a query that
-- lists every region with its average, highest first.

CREATE FUNCTION region_avg_streams(p_region TEXT)
RETURNS NUMERIC
LANGUAGE sql
AS $$
	SELECT ROUND(AVG(streams), 0)
	FROM spotify_sample
	WHERE region = p_region;
$$;

-- Problem 9: CASE WHEN and conditional aggregation
-- a) Label each entry's streams as 'million+' (>= 1,000,000), 'mid'
--    (100,000 to 999,999), or 'low' (below 100,000), and count entries
--    per label.
-- b) Per region, in ONE query with no subqueries, return: total
--    entries, entries in each of the three tiers (use FILTER), and the
--    percent of entries that are 'million+'. Highest percent first.
-- c) Reproduce one of the tier counts using SUM(CASE WHEN ...).
 
-- YOUR ANSWER:


--a 
SELECT region, SUM(streams), 
	CASE WHEN SUM(streams) >= 1000000 THEN 'million+'
		WHEN SUM(streams) >= 100000 THEN 'mid'
		ELSE 'low' END AS tier, COUNT(title)
FROM spotify_sample
GROUP BY region;

--b
SELECT region, 
	COUNT(*) as entries, 
	COUNT(*) FILTER (WHERE streams >= 1000000) AS million, 
	COUNT(*) FILTER (WHERE streams >= 100000 AND streams < 1000000) AS mid,
	COUNT(*) FILTER (WHERE streams < 100000) AS low,
	ROUND(100.0 * COUNT(*) FILTER (WHERE streams >= 1000000) / COUNT(*), 2) AS percentage
FROM spotify_sample
GROUP BY region
ORDER BY percentage DESC;

--c
SELECT region,
       SUM(CASE WHEN streams >= 1000000 THEN 1 ELSE 0 END) AS million_plus
FROM spotify_sample
GROUP BY region;


-- Problem 10: Safe division
-- a) Per region, compute SUM(streams) divided by the number of entries
--    with at least 100,000,000 streams. Run it and note the result.
-- b) Fix it so it returns NULL instead of an error.
 
-- YOUR ANSWER:

--a
SELECT region, SUM(streams) / 
	COUNT(*) FILTER (WHERE streams >= 100000000) AS problem_10
FROM spotify_sample
GROUP BY region;
-- Error: divison by zero 

--b
SELECT region, SUM(streams) / 
	NULLIF(COUNT(*) FILTER (WHERE streams >= 100000000),0) AS problem_10
FROM spotify_sample
GROUP BY region;


-- Problem 11: Median and percentiles
-- Per region, return average streams, median streams, and the 90th
-- percentile. Which is larger, the mean or the median, and what does
-- that tell you?
 
-- YOUR ANSWER:

SELECT region, 
	ROUND(AVG(streams)) AS mean_streams,
	ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY streams))) AS median_streams, 
	ROUND((PERCENTILE_CONT(.9) WITHIN GROUP (ORDER BY streams))) AS p90_streams
FROM spotify_sample
WHERE streams IS NOT NULL
GROUP BY region
ORDER BY mean_streams DESC;
--The data is right skewed, the mean is larger! 


-- Problem 12: LATERAL join
-- For each region, return the 3 most recent dates it had a #1 song,
-- with the title. Use CROSS JOIN LATERAL.

SELECT r.region, t.date, t.title
FROM (SELECT DISTINCT region FROM spotify_sample) r
CROSS JOIN LATERAL ( 
	SELECT s.date, s.title
	FROM spotify_sample s
	WHERE s.region = r.region AND s.rank = 1
	ORDER BY s.date DESC
	LIMIT 3
) t
ORDER BY r.region, t.date DESC;


-- Problem 13: Set operations
-- a) Artists in the US top 20 AND the Germany top 20 (INTERSECT).
-- b) Artists in the US top 20 who never appear in the Japan data (EXCEPT).
-- c) Compare the row counts of UNION vs UNION ALL when stacking all
--    artist rows from the United States and Germany. Why do they differ?
 
-- YOUR ANSWER:

--a
SELECT artist FROM spotify_sample WHERE region = 'United States' AND rank <= 20
INTERSECT
SELECT artist FROM spotify_sample WHERE region = 'Germany' AND rank <= 20;

--b
SELECT artist FROM spotify_sample WHERE region = 'United States' AND rank <= 20
EXCEPT
SELECT artist FROM spotify_sample WHERE region = 'Japan';

--c
SELECT COUNT(*) AS union_rows FROM (
	SELECT artist FROM spotify_sample WHERE region = 'United States'
	UNION
	SELECT artist FROM spotify_sample WHERE region = 'Germany'
) u;

SELECT COUNT(*) AS union_all_rows FROM (
	SELECT artist FROM spotify_sample WHERE region = 'United States'
	UNION ALL
	SELECT artist FROM spotify_sample WHERE region = 'Germany'
) u;

/* Data Cleaning */


-- Problem 14: Profile before you clean
-- In one query, return: total rows, distinct titles as stored, distinct
-- titles after trimming, rows with a missing artist (blank or 'N/A'),
-- and rows with missing streams (blank or 'N/A').
-- Then run a frequency table on region. What do you notice?
 
-- YOUR ANSWER:
 
SELECT COUNT(*) AS total_rows,
	COUNT(DISTINCT title) AS distinct_titles_raw,
	COUNT(DISTINCT TRIM(title)) AS distinct_titles_trimmed,
	COUNT(*) FILTER (WHERE TRIM(artist) = '' OR UPPER(TRIM(artist)) = 'N/A') AS missing_artist,
	COUNT(*) FILTER (WHERE TRIM(streams_text) = '' OR UPPER(TRIM(streams_text)) = 'N/A') AS missing_streams
FROM messy_songs;

SELECT region, COUNT(*) AS rows_per_value
FROM messy_songs
GROUP BY region
ORDER BY rows_per_value DESC;

-- Problem 15: Clean text and standardize categories
-- Return row_id plus three cleaned columns:
--   title_clean: trimmed, with repeated inner spaces collapsed
--   artist_clean: trimmed, proper case, with blank/'N/A' becoming NULL
--   region_clean: 'United States' for us/usa/united states,
--                 'United Kingdom' for uk/gb/united kingdom
--                 (case and whitespace should not matter)
 
-- YOUR ANSWER:
 
SELECT row_id,
	REGEXP_REPLACE(TRIM(title), '\s+', ' ', 'g') AS title_clean,
		CASE WHEN UPPER(TRIM(artist)) IN ('', 'N/A') THEN NULL
			ELSE INITCAP(TRIM(artist)) END AS artist_clean,
		CASE WHEN LOWER(TRIM(region)) IN ('us', 'usa', 'united states') THEN 'United States'
			WHEN LOWER(TRIM(region)) IN ('uk', 'gb', 'united kingdom') THEN 'United Kingdom'
			ELSE INITCAP(TRIM(region)) END AS region_clean
FROM messy_songs
ORDER BY row_id;
 
 
-- Problem 16: Type casting
-- Return row_id, streams_text, and:
--   streams_clean: a BIGINT with commas removed, blanks and 'N/A' as NULL
--   chart_date_clean: a DATE, handling both 'YYYY-MM-DD' and 'MM/DD/YYYY'
 
-- YOUR ANSWER:
 
 SELECT row_id,
	streams_text,
		NULLIF(REGEXP_REPLACE(streams_text, '[^0-9-]', '', 'g'), '')::BIGINT AS streams_clean,
		CASE WHEN TRIM(chart_date_text) ~ '^\d{4}-\d{2}-\d{2}$'
				THEN TO_DATE(TRIM(chart_date_text), 'YYYY-MM-DD')
			WHEN TRIM(chart_date_text) ~ '^\d{2}/\d{2}/\d{4}$'
				THEN TO_DATE(TRIM(chart_date_text), 'MM/DD/YYYY')
		END AS chart_date_clean
FROM messy_songs
ORDER BY row_id;
 
-- Problem 17: Build the clean table
-- Using CTEs, create messy_songs_clean from all of the above, then:
--   - remove duplicates (same cleaned title, artist, region, and date),
--     keeping the lowest row_id
--   - add boolean flags invalid_streams (negative) and future_date
--   Then, on rows that are NOT flagged and have streams, find outliers
--   with the IQR rule (below Q1 - 1.5*IQR or above Q3 + 1.5*IQR).
--   Which rows get flagged? Is each one actually an error?
 
-- YOUR ANSWER:
 
CREATE TABLE messy_songs_clean AS
WITH cleaned AS (
	SELECT row_id,
	       REGEXP_REPLACE(TRIM(title), '\s+', ' ', 'g') AS title,
	       CASE WHEN UPPER(TRIM(artist)) IN ('', 'N/A') THEN NULL
	            ELSE INITCAP(TRIM(artist)) END AS artist,
	       CASE WHEN LOWER(TRIM(region)) IN ('us', 'usa', 'united states') THEN 'United States'
	            WHEN LOWER(TRIM(region)) IN ('uk', 'gb', 'united kingdom') THEN 'United Kingdom'
	            ELSE INITCAP(TRIM(region)) END AS region,
	       NULLIF(REGEXP_REPLACE(streams_text, '[^0-9-]', '', 'g'), '')::BIGINT AS streams,
	       CASE WHEN TRIM(chart_date_text) ~ '^\d{4}-\d{2}-\d{2}$'
	                 THEN TO_DATE(TRIM(chart_date_text), 'YYYY-MM-DD')
	            WHEN TRIM(chart_date_text) ~ '^\d{2}/\d{2}/\d{4}$'
	                 THEN TO_DATE(TRIM(chart_date_text), 'MM/DD/YYYY')
	       END AS chart_date
	FROM messy_songs
),
deduped AS (
	SELECT *,
	       ROW_NUMBER() OVER (
	           PARTITION BY LOWER(title), LOWER(artist), region, chart_date
	           ORDER BY row_id) AS rn
	FROM cleaned
)
SELECT row_id, title, artist, region, streams, chart_date,
       COALESCE(streams < 0, FALSE) AS invalid_streams,
       COALESCE(chart_date > CURRENT_DATE, FALSE) AS future_date
FROM deduped
WHERE rn = 1;

SELECT * FROM messy_songs_clean ORDER BY row_id;


WITH valid AS (
	SELECT *
	FROM messy_songs_clean
	WHERE streams IS NOT NULL
	  AND NOT invalid_streams
	  AND NOT future_date
),
q AS (
	SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY streams) AS q1,
	       PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY streams) AS q3
	FROM valid
)
SELECT v.row_id, v.title, v.artist, v.streams
FROM valid v, q
WHERE v.streams < q.q1 - 1.5 * (q.q3 - q.q1)
   OR v.streams > q.q3 + 1.5 * (q.q3 - q.q1);


 
