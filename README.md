# SQL_Basics_to_Mastery

A 10-step SQL roadmap in **PostgreSQL 18**, taking a query from `SELECT` to window functions, CTEs, and triggers. Every concept is explained in comments and demonstrated with working code on **20M+ rows of real Spotify chart data**.

This repo is both a learning guide for new SQL users and a record of my own proficiency, including:

- **Performance tuning:** measured index speedups using `EXPLAIN ANALYZE`
- **Data cleaning:** a 9-step workflow for profiling and fixing a messy table
- **Data integrity:** constraints, normalization to 3NF, and transactions with rollbacks
- **Analytical SQL:** window functions, recursive CTEs, `ROLLUP`, percentiles

**Interview prep included:** practice problems on the Spotify dataset, organized by step and difficulty, each with a full answer key and explanation.


## The Roadmap
 
| Step | Topic | What it covers |
|------|-------|----------------|
| 1 | **Basics** | Databases, tables, data types and `NULL`, CRUD, DDL vs DML |
| 2 | **Queries** | `SELECT`, `FROM`, `WHERE`, `ORDER BY`, `GROUP BY`, `HAVING`, `LIMIT`, `DISTINCT`, and the logical order SQL actually executes them in |
| 3 | **Functions** | Aggregates, string functions, date functions, `COALESCE` for `NULL` handling |
| 4 | **Joins** | `INNER`, `LEFT`, `RIGHT`, `FULL`, `CROSS`, and self joins |
| 5 | **Subqueries** | Subqueries in `SELECT`, `FROM`, and `WHERE`; correlated subqueries; `EXISTS` |
| 6 | **Constraints** | `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `NOT NULL`, `CHECK`, `DEFAULT`, with examples of each violation |
| 7 | **Indexes and Views** | B-tree indexes, composite indexes, trade-offs, views, materialized views |
| 8 | **Normalization** | 1NF, 2NF, 3NF, update/insert/delete anomalies, when to denormalize |
| 9 | **Transactions** | `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`, ACID, isolation levels |
| 10 | **Advanced SQL** | Window functions, CTEs (including recursive), user-defined functions, triggers |
| Extra | **Analyst Toolkit** | `CASE WHEN`, conditional aggregation, safe division, time series, `ROLLUP`, percentiles, `LATERAL` joins, set operations |
| Extra | **Data Cleaning Toolkit** | A 9-step workflow for profiling and cleaning a messy table |
 
