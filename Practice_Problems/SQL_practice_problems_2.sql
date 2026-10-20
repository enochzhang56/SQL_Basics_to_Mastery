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


-- Problem 2: LEFT JOIN with COALESCE
-- Count the sample's chart entries per continent. Entries whose region
-- is not in region_info should appear under the label 'Not in lookup'.
-- Largest count first.
 
-- YOUR ANSWER:


-- Problem 3: Finding unmatched rows (anti-join)
-- Which regions in region_info have NO rows in spotify_sample?
-- Use a LEFT JOIN, not a subquery.
 
-- YOUR ANSWER:


-- Problem 4: FULL JOIN
-- Compare the distinct regions in spotify_sample with region_info.
-- Return one row per region found in EITHER side, with two boolean
-- columns: in_sample and in_lookup. Order by region.
 
-- YOUR ANSWER:


-- Problem 5: Self join
-- Using practice_employees, return each employee's name alongside
-- their manager's name. The top-level employee (no manager) must still
-- appear, with a NULL manager.
 
-- YOUR ANSWER:


-- Problem 6: CROSS JOIN
-- Generate every combination of region (from region_info) and chart
-- ('top200', 'viral50'). Chart values are not in a table, so supply
-- them inline. Expect 18 rows.
 
-- YOUR ANSWER:


/* Part B Subqueries */ 

-- Problem 7: Subquery in WHERE (single value)
-- Return title, artist, region, and streams for sample rows with
-- streams above the sample's overall average. Show the top 20 by streams.
 
-- YOUR ANSWER:


-- Problem 8: Subquery in WHERE (list with IN)
-- Return up to 20 distinct (title, artist) pairs charting in the
-- 'United States' by artists who hit rank 1 in the 'Global' region.
 
-- YOUR ANSWER:


-- Problem 9: Subquery in FROM
-- Compute the total streams for each region, then return the AVERAGE of
-- those regional totals (rounded to 0 decimals).
 
-- YOUR ANSWER:


-- Problem 10: Correlated subquery
-- Return title, region, and streams for sample rows whose streams are
-- above the average for THEIR OWN region. Top 20 by streams.
 
-- YOUR ANSWER:


-- Problem 11: EXISTS
-- Return up to 25 distinct artists who charted in more than one region
-- in the sample. Solve it with EXISTS, then again with GROUP BY and HAVING.
 
-- YOUR ANSWER:


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


-- Problem 14: Foreign key behavior
-- a) Try to delete a song that has a review. What happens?
-- b) Replace the foreign key on practice_reviews so deleting a song
--    also deletes its reviews (ON DELETE CASCADE).
-- c) Repeat the delete and confirm the review is gone too.
 
-- YOUR ANSWER:


/* Part D Indexes and Views */

-- Problem 15: Measure an index
-- On the FULL table, run EXPLAIN ANALYZE for:
--   SELECT title, artist, region, streams
--   FROM spotify_charts_unclean WHERE title = 'Shape of You';
-- Note the scan type and execution time. Create an index on title,
-- rerun it, and compare.
 
-- YOUR ANSWER:


-- Problem 16: Composite index and selectivity
-- Make sure an index on (region, chart) exists. Then run EXPLAIN ANALYZE
-- on a COUNT(*) for each of these filters:
--   a) region = 'Brazil' AND chart = 'top200'
--   b) chart = 'viral50' only
-- Which uses the index? Explain the results in a comment.
 
-- YOUR ANSWER:


-- Problem 17: Views
-- a) Create a view called us_number_ones with date, title, artist, and
--    streams for rank 1 entries in the United States on 'top200'.
-- b) Query the view: top 10 artists by number of days at #1.
-- c) Replace the view so it only includes dates from 2020-01-01 onward.
 
-- YOUR ANSWER:


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


