/* SQL Practice Problems: Level 1 (Foundations) 

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



-- Problem 2: NULL behavior
-- a) Write a query using "streams = NULL" to count rows with missing
--    streams. Note what comes back.
-- b) Fix it so it returns the correct count of rows where streams
--    is missing.
 
-- YOUR ANSWER:


/* Part B: Queries */

-- Problem 3: Return title, artist, rank, and streams for the first
-- 10 rows of the table.
 
-- YOUR ANSWER:


-- Problem 4: List every distinct region in alphabetical order.
 
-- YOUR ANSWER:


-- Problem 5: List every distinct value in the chart column.
 
-- YOUR ANSWER:


-- Problem 6: Find the earliest and latest date in the table.
 
-- YOUR ANSWER:


-- Problem 7: Return the 10 most recent #1 songs in the United States
-- on the 'top200' chart. Show date, title, and artist, newest first.
 
-- YOUR ANSWER:


-- Problem 8: Return title, artist, region, and streams for entries by
-- Taylor Swift OR Ed Sheeran with more than 1,000,000 streams.
-- Show the 20 highest stream counts.
 
-- YOUR ANSWER:


-- Problem 9: Return 25 distinct song titles that start with 'Love'.
-- Then rewrite the filter so capitalization doesn't matter.
 
-- YOUR ANSWER:


-- Problem 10: Return title, artist, and rank for every 'top200'
-- entry in the Global region on 2020-01-01 where the rank is
-- between 1 and 5, ordered by rank.
 
-- YOUR ANSWER:


/* Part C: Functions */ 

-- Problem 11: In ONE query, return the total number of rows, the
-- total streams, the average streams (rounded to 0 decimals), the
-- minimum streams, and the maximum streams. Give every column an alias.
 
-- YOUR ANSWER:


-- Problem 12: Count the different chart entries per region. Show the 10
-- regions with the most entries, largest first.
 
-- YOUR ANSWER:


-- Problem 13: Find the artists with more than 1,000 chart entries.
-- Show the artist and entry count, largest first, top 15.
 
-- YOUR ANSWER:


-- Problem 14: For #1 entries in the United States on the 'top200'
-- chart, return one column formatted as 'TITLE - ARTIST' in all
-- caps. Show 10 rows.
 
-- YOUR ANSWER:


-- Problem 15: For #1 entries in the United States on the 'top200'
-- chart, count how many #1 entries there are in each year.
-- Order by year.
 
-- YOUR ANSWER:


-- Problem 16: NULLs and averages.
-- a) Return title, artist, and a streams_clean column that shows 0
--    when streams is NULL and 'Unknown' when artist is NULL
--    (call that column artist_clean). Show 20 rows.
-- b) In one query, compare AVG(streams) with
--    AVG(COALESCE(streams, 0)). Explain in a comment why they differ.
 
-- YOUR ANSWER:


-- Problem 17 (Challenge): Total streams for Taylor Swift in the
-- United States for each year, ignoring NULL streams. Order by year.
 
-- YOUR ANSWER:

	





