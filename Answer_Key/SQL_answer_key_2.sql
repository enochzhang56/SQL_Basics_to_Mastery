/* SQL Practice Problems: Level 2 ANSWER SHEET 

Covers Steps 4-7: Joins, Subqueries, Constraints, Indexes and Views

Database: sqlroadmap | Main Table: spotify_charts_unclean

columns: title, rank, date, artist, url, region, chart, trend, streams

*/

/* SQL Practice Problems: Level 2 (Intermediate) 

Covers Steps 4-7: Joins, Subqueries, Constraints, Indexes and Views

Database: sqlroadmap | Main Table: spotify_charts_unclean

columns: title, rank, date, artist, url, region, chart, trend, streams

*/

/* Setup for Pracitce Problems (RUN CODE BELOW) */ 
--Table does not contain "Global" and contains two regions that are 
--not in the sample (Argentina and Atlantis)

CREATE TABLE region_info(
	region VARCHAR(50) PRIMARY KEY, 
	continent VARCHAR(30) NOT NULL
); 

INSERT INTO region_info (region, continent) VALUES 
	('United States', 'North America' ),
	('Canada', 'North America'),
	('Mexico', 'North America'),
	('Brazil', 'South America'),
	('Argentina', 'South America'),
	('Japan', 'Asia'),
	('Germany', 'Europe'),
	('United Kingdom', 'Europe'),
	('Atlantis', 'Fictional');

-- Create a table: one week 8-region slice of the top200 Chart 
CREATE TABLE spotify_sample AS 
SELECT *
FROM spotify_charts_unclean
WHERE chart = 'top200'
	AND date >= '2020-01-01' AND date < '2020-01-08'
	AND REGION IN ('United States', 'Mexico', 'Brazil', 'Japan',
					'Global', 'Germany', 'United Kingdom', 'Canada');


CREATE INDEX idx_sample_region ON spotify_sample (region);
CREATE INDEX idx_sample_artist ON spotify_sample (artist);
ANALYZE spotify_sample;

--Small Employee tables for the self join 
CREATE TABLE practice_departments (
	dept_id INT PRIMARY KEY, 
	dept_name VARCHAR(30) NOT NULL
);
CREATE TABLE practice_employees (
	emp_id INT PRIMARY KEY, 
	name VARCHAR(30) NOT NULL,
	dept_id INT, 
	manager_id INT
);
INSERT INTO practice_departments VALUES (1, 'Sales'), (2, 'Engineering'), (3, 'Marketing');
INSERT INTO practice_employees VALUES
	(1, 'Ana', 1, NULL),
	(2, 'Ben', 1, 1),
	(3, 'Cara', 2, 1),
	(4, 'Dev', 2, 3),
	(5, 'Eli', NULL, 3);

DROP TABLE practice_employees 

/* Part A: Joins */ 

-- Problem 1: INNER JOIN
-- Join spotify_sample to region_info. Return title, artist, region,
-- and continent for rank 1 entries. Show 10 rows. Which region from
-- the sample never appears in your results, and why?
 
-- YOUR ANSWER:

SELECT s.title, s.artist, s.region, r.continent
FROM spotify_sample s
INNER JOIN region_info r
	ON s.region = r.region
WHERE rank = 1 
--Gloabl never shows up because it is not a region in the region_info, and inner
--join only returns overlapped data. 


-- Problem 2: LEFT JOIN with COALESCE
-- Count the sample's chart entries per continent. Entries whose region
-- is not in region_info should appear under the label 'Not in lookup'.
-- Largest count first.
 
-- YOUR ANSWER:

SELECT COUNT(*) AS num_entries, COALESCE(r.continent, 'Not in lookup') AS continent
FROM spotify_sample s
LEFT JOIN region_info r
	ON s.region = r.region 
GROUP BY r.continent
ORDER BY COUNT(*) DESC;


-- Problem 3: Finding unmatched rows (anti-join)
-- Which regions in region_info have NO rows in spotify_sample?
-- Use a LEFT JOIN, not a subquery.
 
-- YOUR ANSWER:

SELECT * 
FROM region_info r
LEFT JOIN spotify_sample s
	ON r.region = s.region 
WHERE s.title IS NULL;
-- Japan, Argentina, and Atlantis


-- Problem 4: FULL JOIN
-- Compare the distinct regions in spotify_sample with region_info.
-- Return one row per region found in EITHER side, with two boolean
-- columns: in_sample and in_lookup. Order by region.
 
-- YOUR ANSWER:

SELECT COALESCE(s.region, r.region) AS regions,
	s.region IS NOT NULL AS in_sample, -- returns boolean value
	r.region IS NOT NULL AS in_lookup
FROM (SELECT DISTINCT(region) FROM spotify_sample) s
FULL JOIN region_info r
	ON s.region = r.region;


-- Problem 5: Self join
-- Using practice_employees, return each employee's name alongside
-- their manager's name. The top-level employee (no manager) must still
-- appear, with a NULL manager.
 
-- YOUR ANSWER:

SELECT e.name, m.name
FROM practice_employees e
LEFT JOIN practice_employees m
	ON e.manager_id = m.emp_id;

-- Problem 6: CROSS JOIN
-- Generate every combination of region (from region_info) and chart
-- ('top200', 'viral50'). Chart values are not in a table, so supply
-- them inline. Expect 18 rows.
 
-- YOUR ANSWER:

SELECT r.region, c.chart
FROM region_info r
CROSS JOIN (VALUES ('top200'), ('viral50')) AS c(chart);


/* Part B Subqueries */ 

-- Problem 7: Subquery in WHERE (single value)
-- Return title, artist, region, and streams for sample rows with
-- streams above the sample's overall average. Show the top 20 by streams.
 
-- YOUR ANSWER:

SELECT title, artist, region, streams
FROM spotify_sample
WHERE streams > (
	SELECT AVG(streams)
	FROM spotify_sample)
ORDER BY streams DESC
LIMIT 20;

-- Problem 8: Subquery in WHERE (list with IN)
-- Return up to 20 distinct (title, artist) pairs charting in the
-- 'United States' by artists who hit rank 1 in the 'Global' region.
 
-- YOUR ANSWER:

SELECT DISTINCT(title), artist
FROM spotify_charts_unclean
WHERE region = 'United States' AND 
	ARTIST IN (
	SELECT ARTIST 
	FROM spotify_charts_unclean
	WHERE region = 'Global' AND rank = 1)
LIMIT 20;

-- Problem 9: Subquery in FROM
-- Compute the total streams for each region, then return the AVERAGE of
-- those regional totals (rounded to 0 decimals).
 
-- YOUR ANSWER:

SELECT ROUND(AVG(region_sums)) AS region_average 
FROM (
	SELECT SUM(streams) AS region_sums
	FROM spotify_charts_unclean
	GROUP BY region) AS region_sums_table;

-- Problem 10: Correlated subquery
-- Return title, region, and streams for sample rows whose streams are
-- above the average for THEIR OWN region. Top 20 by streams.
 
-- YOUR ANSWER:

SELECT title, region, streams
FROM spotify_sample s
WHERE streams > 
	(SELECT AVG(streams)
	 FROM spotify_sample
	 WHERE region = s.region)
LIMIT 20;


-- Problem 11: EXISTS
-- Return up to 25 distinct artists who charted in more than one region
-- in the sample. Solve it with EXISTS, then again with GROUP BY and HAVING.
 
-- YOUR ANSWER:

SELECT DISTINCT artist
FROM spotify_sample s
WHERE EXISTS (
	SELECT 1 
	FROM spotify_sample x
	WHERE x.artist = s.artist AND
		x.region <> s.region)
LIMIT 25;

SELECT DISTINCT artist
FROM spotify_sample
GROUP BY artist 
HAVING COUNT(DISTINCT region) > 1
LIMIT 25;



/* Part C Constraints */

-- Problem 12: Build tables with constraints
-- Create practice_songs:
--   song_id: auto-incrementing primary key
--   title and artist: required text (max 100)
--   release_year: integer that must be between 1900 and 2030
--   added_on: date that defaults to today
--   the combination of title AND artist must be unique
-- Create practice_reviews:
--   review_id: auto-incrementing primary key
--   song_id: required, must reference an existing song
--   rating: required integer between 1 and 5
--   review_text: optional text
 
-- YOUR ANSWER:

CREATE TABLE practice_songs ( 
	song_id SERIAL PRIMARY KEY,
	title VARCHAR(100) UNIQUE NOT NULL, 
	artist VARCHAR(100) UNIQUE NOT NULL, 
	release_year INT CHECK (release_year BETWEEN 1900 AND 2030),
	added_on DATE DEFAULT CURRENT_DATE,
	UNIQUE (title, artist)
);



CREATE TABLE practice_reviews (
	review_id SERIAL PRIMARY KEY,
	song_id INT NOT NULL REFERENCES practice_songs (song_id),
	rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
	review_text TEXT
);


-- Problem 13: Break the rules on purpose
-- a) Insert two valid songs and one valid review.
-- b) Write one failing INSERT for each of these, with a comment naming
--    the violated constraint:
--      1. duplicate title + artist
--      2. NULL title
--      3. release_year of 1850
--      4. a review for a song_id that does not exist
--      5. a rating of 6
-- c) SELECT from practice_songs and confirm added_on filled itself in.
 
-- YOUR ANSWER:

--a) 

INSERT INTO practice_songs (title, artist, release_year) 
VALUES ('neon', 'a20', 2026),
	('mei_yo', 'me', 2025);

INSERT INTO practice_reviews (song_id, rating, review_text)
VALUES (1, 5, 'good song');

--b) 
INSERT INTO practice_songs (title, artist, release_year)
VALUES ('neon', 'a20', 2026),
	(NULL, NULL, NULL),
	('hi', 'bye', 1850);
	
INSERT INTO practice_reviews (song_id, rating, review_text)
VALUES (6, 5, 'great song'),
	(2, 6, 'great song');


-- Problem 14: Foreign key behavior
-- a) Try to delete a song that has a review. What happens?
-- b) Replace the foreign key on practice_reviews so deleting a song
--    also deletes its reviews (ON DELETE CASCADE).
-- c) Repeat the delete and confirm the review is gone too.
 
-- YOUR ANSWER:

--a
DELETE FROM practice_songs WHERE (title = 'neon')
-- cannot because it has reviews

--b) 
ALTER TABLE practice_reviews
	DROP CONSTRAINT practice_reviews_song_id_fkey;

ALTER TABLE practice_reviews
	ADD CONSTRAINT practice_reviews_song_id_fkey
	FOREIGN KEY (song_id) REFERENCES practice_songs (song_id)
	ON DELETE CASCADE;

--c 
DELETE FROM practice_songs WHERE (title = 'neon')

SELECT * FROM practice_songs

/* Part D Indexes and Views */

-- Problem 15: Measure an index
-- On the FULL table, run EXPLAIN ANALYZE for:
--   SELECT title, artist, region, streams
--   FROM spotify_charts_unclean WHERE title = 'Shape of You';
-- Note the scan type and execution time. Create an index on title,
-- rerun it, and compare.
 
-- YOUR ANSWER:

EXPLAIN ANALYZE 
SELECT title, artist, region, streams 
FROM spotify_charts_unclean 
WHERE title = 'Shape of You';
-- planning time: 4.592 ms, Execution time: 3231.592 ms

CREATE INDEX idx_spotify_titles
	ON spotify_charts_unclean (title);

--Reran. planning time: 0.705 ms, Execution time: 5022.638 ms 


-- Problem 16: Composite index and selectivity
-- Make sure an index on (region, chart) exists. Then run EXPLAIN ANALYZE
-- on a COUNT(*) for each of these filters:
--   a) region = 'Brazil' AND chart = 'top200'
--   b) chart = 'viral50' only
-- Which uses the index? Explain the results in a comment.
 
-- YOUR ANSWER:

CREATE INDEX idx_spotify_region_chart
	ON spotify_charts_unclean (region, chart);

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM spotify_charts_unclean
WHERE region = 'Brazil' AND chart = 'top200'; 
-- Planning time: 0.138ms, Execution time: 57.879 ms

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM spotify_charts_unclean
WHERE chart = 'viral50'; 
-- Planning time: 0.093 ms, Execution time: 2225.606

-- The first one uses the index, the second one uses a sequential scan. 

-- Problem 17: Views
-- a) Create a view called us_number_ones with date, title, artist, and
--    streams for rank 1 entries in the United States on 'top200'.
-- b) Query the view: top 10 artists by number of days at #1.
-- c) Replace the view so it only includes dates from 2020-01-01 onward.
 
-- YOUR ANSWER:

--a
CREATE VIEW us_number_ones AS
SELECT date, title, artist, streams
FROM spotify_charts_unclean
WHERE region = 'United States'
	AND chart = 'top200'
	AND rank = 1;

--b
SELECT COUNT(*) AS days_at_1, artist
FROM us_number_ones
GROUP BY artist 
ORDER BY days_at_1 DESC;

--c 
CREATE OR REPLACE VIEW us_number_ones AS
SELECT date, title, artist, streams
FROM spotify_charts_unclean
WHERE region = 'United States'
	AND chart = 'top200'
	AND rank = 1
	AND date >= '2020-01-01';


-- Problem 18: Materialized views
-- a) Create a materialized view sample_region_avg with each region's
--    average streams (rounded) from spotify_sample.
-- b) Insert a fake row into spotify_sample: region 'Japan', chart
--    'top200', streams 900000000, title 'fake song'.
-- c) Show that the materialized view has NOT changed, but the live
--    query has.
-- d) Refresh the materialized view and confirm it now matches.
-- e) Delete the fake row and refresh again.
 
-- YOUR ANSWER:

--a
CREATE MATERIALIZED VIEW sample_region_avg AS
SELECT region, ROUND(AVG(streams)) AS avg_streams
FROM spotify_sample
GROUP BY region;

--b
INSERT INTO spotify_sample (title, rank, date, artist, url, region, chart, trend, streams)
VALUES ('fake song', 1, '2020-01-01', 'fake artist', NULL, 'Japan', 'top200', 'NEW_ENTRY', 900000000);

--c
SELECT * FROM sample_region_avg WHERE region = 'Japan';

SELECT region, ROUND(AVG(streams)) AS avg_streams
FROM spotify_sample
WHERE region = 'Japan'
GROUP BY region;

--d
REFRESH MATERIALIZED VIEW sample_region_avg;
SELECT * FROM sample_region_avg WHERE region = 'Japan';

--e
DELETE FROM spotify_sample WHERE title = 'fake song';
REFRESH MATERIALIZED VIEW sample_region_avg;

/*Clean Up (run when finished!) */


DROP MATERIALIZED VIEW IF EXISTS sample_region_avg;
DROP VIEW IF EXISTS us_number_ones;
DROP TABLE IF EXISTS practice_reviews;
DROP TABLE IF EXISTS practice_songs;
DROP INDEX IF EXISTS idx_spotify_titles;
DROP TABLE IF EXISTS practice_employees;
DROP TABLE IF EXISTS practice_departments;
DROP TABLE IF EXISTS spotify_sample;
DROP TABLE IF EXISTS region_info;

















