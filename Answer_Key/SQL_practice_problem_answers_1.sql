/* SQL Practice Problems: Level 1 ANSWER SHEET 

Covers Steps 1-3: Basics, Queries, Functions 

Database: sqlroadmap | Main Table: spotify_charts_unclean

columns: title, rank, date, artist, url, region, chart, trend, streams

*/


/* Part A: Basics */ 

--Problem 1: CRUD on a practice table 
-- a) Create a table called practice_playlist with columns:
--    title (VARCHAR 100), artist (VARCHAR 100), streams (INT).
-- b) Insert three rows:
--    ('Song A', 'Artist 1', 1000), ('Song B', 'Artist 2', 2000),
--    ('Song C', 'Artist 3', 3000)
-- c) Update Song B so its streams are 2500.
-- d) Delete Song C.
-- e) Select everything to confirm only Song A and Song B remain.
-- f) Drop the table.

-- YOUR ANSWER: 

--a)
CREATE TABLE practice_playlist (
	title VARCHAR(100),
	artist VARCHAR(100),
	streams INT
);

--b)
INSERT INTO practice_playlist VALUES 
	('Song A', 'Artist 1', 1000),
	('Song B', 'Artirst 2', 2000), 
	('Song C', 'Artist 3', 3000);

--c)
UPDATE practice_playlist
SET streams = 2500
WHERE title = 'Song B'


--d) 
DELETE FROM practice_playlist
WHERE title = 'Song C'

--e)
SELECT * 
FROM practice_playlist

--f) 
DROP TABLE IF EXISTS practice_playlist

-- Problem 2: NULL behavior
-- a) Write a query using "streams = NULL" to count rows with missing
--    streams. Note what comes back.
-- b) Fix it so it returns the correct count of rows where streams
--    is missing.
 
-- YOUR ANSWER:

--Problem 2

--a) 

SELECT COUNT(*) AS null_count
FROM spotify_charts_unclean
WHERE streams = NULL
-- 0 return

--b)
SELECT COUNT(*) AS null_count
FROM spotify_charts_unclean
WHERE streams IS NULL 
--5,851,610 



/* Part B: Queries */

-- Problem 3: Return title, artist, rank, and streams for the first
-- 10 rows of the table.
 
-- YOUR ANSWER:

SELECT title,
	artist,
	rank, 
	streams
FROM spotify_charts_unclean
LIMIT 10;

-- Problem 4: List every distinct region in alphabetical order.
 
-- YOUR ANSWER:

SELECT DISTINCT region
FROM spotify_charts_unclean
ORDER BY region;


-- Problem 5: List every distinct value in the chart column.
 
-- YOUR ANSWER:

SELECT DISTINCT(chart)
FROM spotify_charts_unclean;

-- Problem 6: Find the earliest and latest date in the table.
 
-- YOUR ANSWER:

SELECT MIN(date) as earliest_date,
	MAX(date) as latest_date
FROM spotify_charts_unclean;

-- Problem 7: Return the 10 most recent #1 songs in the United States
-- on the 'top200' chart. Show date, title, and artist, newest first.
 
-- YOUR ANSWER:

SELECT date, title, artist
FROM spotify_charts_unclean
WHERE 
	rank = 1 AND 
	chart = 'top200'AND 
	region = 'United States'
ORDER BY date DESC 
LIMIT 10;

-- Problem 8: Return title, artist, region, and streams for entries by
-- Taylor Swift OR Ed Sheeran with more than 1,000,000 streams.
-- Show the 20 highest stream counts.
 
-- YOUR ANSWER:

SELECT title, artist, region, streams
FROM spotify_charts_unclean
WHERE (artist = 'Taylor Swift' OR artist = 'Ed Sheeran') -- IN ('Taylor Swift', 'Ed Sheeran')
	AND streams > 1000000
ORDER BY streams DESC
LIMIT 20;

-- Problem 9: Return 25 distinct song titles that start with 'Love'.
-- Then rewrite the filter so capitalization doesn't matter.
 
-- YOUR ANSWER:

SELECT DISTINCT title
FROM spotify_charts_unclean
WHERE title LIKE 'Love%'
LIMIT 25;

SELECT DISTINCT title
FROM spotify_charts_unclean
WHERE LOWER(title) LIKE 'love%' -- WHERE title ILIKE 'love%' -- ILIKE ignores case
LIMIT 25;

-- Problem 10: Return title, artist, and rank for every 'top200'
-- entry in the Global region on 2020-01-01 where the rank is
-- between 1 and 5, ordered by rank.
 
-- YOUR ANSWER:

SELECT title, artist, rank
FROM spotify_charts_unclean
WHERE region = 'Global' AND date = '2020-01-01' AND rank BETWEEN 1 AND 5 -- rank <= 5
ORDER BY rank;


/* Part C: Functions */ 

-- Problem 11: In ONE query, return the total number of rows, the
-- total streams, the average streams (rounded to 0 decimals), the
-- minimum streams, and the maximum streams. Give every column an alias.
 
-- YOUR ANSWER:

SELECT COUNT(*) AS total_rows, 
	SUM(streams) AS total_streams,
	ROUND(AVG(streams), 2) AS avg_streams,
	MIN(streams) AS min_streams,
	MAX(streams) AS max_streams
FROM spotify_charts_unclean;

-- Problem 12: Count the different chart entries per region. Show the 10
-- regions with the most entries, largest first.
 
-- YOUR ANSWER:

SELECT COUNT(*) AS number_per_region, region, chart
FROM spotify_charts_unclean
GROUP BY region, chart
ORDER BY number_per_region DESC
LIMIT 20;

-- Problem 13: Find the artists with more than 1,000 chart entries.
-- Show the artist and entry count, largest first, top 15.
 
-- YOUR ANSWER:

SELECT artist, COUNT(*) AS total_entry_count
FROM spotify_charts_unclean
GROUP BY artist
HAVING COUNT(*) > 1000
ORDER BY total_entry_count DESC
LIMIT 15;

-- Problem 14: For #1 entries in the United States on the 'top200'
-- chart, return one column formatted as 'TITLE - ARTIST' in all
-- caps. Show 10 rows.
 
-- YOUR ANSWER:

SELECT UPPER(CONCAT(title, ' - ', artist)) AS title_artist
FROM spotify_charts_unclean
WHERE rank = 1 AND chart = 'top200' AND region = 'United States'
LIMIT 10;

-- Problem 15: For #1 entries in the United States on the 'top200'
-- chart, count how many #1 entries there are in each year.
-- Order by year.
 
-- YOUR ANSWER:

SELECT COUNT(*) AS number_one_entries, DATE_TRUNC('year', date) AS year_
FROM spotify_charts_unclean
WHERE region = 'United States' and chart = 'top200' and rank = 1
GROUP BY DATE_TRUNC('year', date)
ORDER BY year_;

--OR 

SELECT COUNT(*) AS number_one_entries, EXTRACT(YEAR FROM date) AS year_
FROM spotify_charts_unclean
WHERE region = 'United States' and chart = 'top200' and rank = 1
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY year_;

-- Problem 16: NULLs and averages.
-- a) Return title, artist, and a streams_clean column that shows 0
--    when streams is NULL and 'Unknown' when artist is NULL
--    (call that column artist_clean). Show 20 rows.
-- b) In one query, compare AVG(streams) with
--    AVG(COALESCE(streams, 0)). Explain in a comment why they differ.
 
-- YOUR ANSWER:

--a)

SELECT title, 
	COALESCE(artist, 'Unknown') AS artist_clean, 
	COALESCE(streams, 0) AS streams_clean
FROM spotify_charts_unclean
LIMIT 20;
	
--b)

SELECT AVG(streams) AS avg_streams_unclean, 
	AVG(COALESCE(streams, 0)) as avg_streams_clean
FROM spotify_charts_unclean;
/* Without COALESCE, NULLs are ignored, but with COALESCE 
entries are counted as 0, bringing down the avg.*/

-- Problem 17 (Challenge): Total streams for Taylor Swift in the
-- United States for each year, ignoring NULL streams. Order by year.
 
-- YOUR ANSWER:

SELECT SUM(streams), DATE_TRUNC('year', date) AS year
FROM spotify_charts_unclean
WHERE 
	region = 'United States'AND
	artist = 'Taylor Swift'
GROUP BY DATE_TRUNC('year', date);
	








