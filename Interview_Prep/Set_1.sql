/* Set 1:

1) Who were our top 5 customers by revenue in 1997, net of discounts?
2) Show monthly revenue and the percentage change from the prior month. The finance team wants this for a dashboard.
3) For each product category, find the top 3 products by revenue. Explain how your query handles ties.
4) Marketing wants to know which customers ordered in 1996 but not in 1997. Produce that list.
5) For each customer with at least two orders, calculate the number of days between their first and second order. 
   Then report the average of that gap across all customers.

State your assumptions as comments at the top of each query.
*/ 


-- ANSWERS 

-- 1. 

/* First get familiar with data */ 
SELECT * FROM customers LIMIT 10;

SELECT * FROM orders LIMIT 10;

SELECT * FROM order_details od LIMIT 10;

/* First iteration of answer */ 
WITH customer_orders AS ( 
	SELECT c.customer_id, o.order_id
	FROM customers c
	INNER JOIN orders o 
		ON c.customer_id = o.customer_id 
	WHERE EXTRACT(YEAR FROM o.order_date) = 1997
),
revenue AS (
	SELECT co.customer_id, co.order_id, od.quantity, od.unit_price, od.discount
	FROM customer_orders co 
	INNER JOIN order_details od 
		ON co.order_id = od.order_id
)
SELECT customer_id, 
	   SUM(CASE WHEN discount <> 0 THEN (quantity * unit_price) - (quantity * unit_price * discount)
	   	 	ELSE quantity * unit_price END) AS total_revenue
FROM revenue 
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 5;

/* Claude Grading: 
1) Over-built. Two CTEs and a join to customers that contributes nothing, since orders already has customer_id. 
   In an interview, verbose reads as unsure.
2) The CASE is redundant. quantity * unit_price * (1 - discount) handles discount = 0 on its own.
   EXTRACT(YEAR FROM order_date) = 1997 is non-sargable. Wrapping the column in a function stops 
   Postgres from using an index on order_date. Use a half-open range: >= '1997-01-01' AND < '1998-01-01'. 
   This is the most common probe on date filters.
3) You returned an ID, not a “who.” The question asked who the customers were, so show the name.
4) LIMIT 5 cuts ties arbitrarily. If #5 and #6 tie, you silently drop one. 
   FETCH FIRST 5 ROWS WITH TIES or DENSE_RANK() handles it. You also had no stated assumptions, which I asked for.
5) No rounding. If unit_price and discount are real, you’ll get float noise like 12345.6000001. 
   Postgres has no round(real, int), so cast to numeric first.
*/ 

/* Second iteration */ 

-- Assumes revenue = unit_price * quantity * (1 - discount); ties at #5 are included

SELECT c.company_name, 
	   ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue
FROM orders o
JOIN order_details od ON od.order_id = o.order_id 
JOIN customers c ON c.customer_id = o.customer_id  
WHERE o.order_date >= DATE '1997-01-01'
  AND o.order_date < DATE '1998-01-01'
GROUP BY c.customer_id, c.company_name 
ORDER BY revenue DESC 
FETCH FIRST 5 ROWS WITH TIES;


-- 2.

-- Get familiar with data

SELECT * FROM order_details LIMIT 10;

SELECT * FROM orders ORDER BY shipped_date DESC;

/* failed attempt 

SELECT EXTRACT(YEAR FROM o.order_date) AS year, EXTRACT(MONTH FROM o.order_date) AS month, 
	ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue, 
	LAG(revenue) OVER (ORDER BY year, month)/revenue AS pct_change
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY year, month;

ROUND((LAG(ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2)) OVER (PARTITION BY EXTRACT(YEAR FROM o.order_date),  
	EXTRACT(MONTH FROM o.order_date) ORDER BY EXTRACT(YEAR FROM o.order_date),  
	EXTRACT(MONTH FROM o.order_date)))/ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2), 2) */

/* First Iteration */
--assumes price * quantity * 1- discount gives revenue. 
WITH rev_values AS(
	SELECT EXTRACT(YEAR FROM o.order_date) AS year, EXTRACT(MONTH FROM o.order_date) AS month, 
	ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue 
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY year, month
)
SELECT year, month, revenue, 
	ROUND((LAG(revenue) OVER (ORDER BY year, month))/revenue, 2) AS pct_change
FROM rev_values 

/* Claude Grading: 
1) The formula is wrong. LAG(revenue) / revenue gives prior ÷ current, not percent change. 
   It should be (current - prior) / prior, times 100. With revenue going 100 → 150, yours returns 0.67 when the answer is +50%. 
   This is the main thing that fails the question.
2) No NULLIF on the denominator. If a prior month has zero revenue, the query errors with division by zero. Wrap the divisor in NULLIF(..., 0).
3) Splitting year and month is clumsy. DATE_TRUNC('month', order_date) gives one real date column. It’s easier to sort, and 
   it’s what a dashboard wants. -- I disagree, I would want to keep year! 
4) There’s no final ORDER BY. The ORDER BY inside OVER only orders the window calculation. It does not guarantee the output order.
5) You round before computing. Round only for display, after the math.
 */

/* Second Iteration */ 
WITH rev_values AS(
	SELECT EXTRACT(YEAR FROM o.order_date) AS year, EXTRACT(MONTH FROM o.order_date) AS month, 
	ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue 
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY year, month
)
SELECT year, month, revenue, 
	ROUND((revenue - (LAG(revenue) OVER (ORDER BY year, month)))/NULLIF(revenue, 0) * 100, 2) AS pct_change
FROM rev_values 
ORDER BY year, month;


-- 3. 3) For each product category, find the top 3 products by revenue. Explain how your query handles ties.

SELECT * FROM products LIMIT 10;
SELECT * FROM order_details LIMIT 10;
SELECT * FROM categories LIMIT 10;
SELECT COUNT(DISTINCT(category_id)) FROM products;

/* MISREAD THE QUESTION 
-- Assuming price * quantity - 1 * discount is revenue. Deals with ties with FETCH FIRST WITH TIES 
SELECT p.category_id, SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue
FROM order_details od
JOIN products p ON p.product_id = od.product_id
GROUP BY p.category_id
ORDER BY total_revenue DESC
FETCH FIRST 3 ROWS WITH TIES;
*/

/* First Iteration */ 

-- Assuming price * quantity - 1 * discount is revenue. Deals with ties by including both. 
WITH product_revenue AS (
	SELECT p.product_id, p.product_name, p.category_id,
		   SUM(od.unit_price * od.quantity * (1 - od.discount)) AS revenue 
	FROM products p
	JOIN order_details od ON p.product_id = od.product_id
	JOIN categories c ON p.category_id = c.category_id
	GROUP BY p.product_id, p.product_name, p.category_id
), 
ranked AS (
	SELECT *, DENSE_RANK() OVER (PARTITION BY category_id ORDER BY revenue DESC) as rank
	FROM product_revenue 
)
SELECT *
FROM ranked 
WHERE rank <= 3;

/* Claude Grading 
1) DENSE_RANK plus “including both” is vague. DENSE_RANK doesn’t just keep tied rows. It also keeps ranks 2 and 3 after a tie, 
   so a tie for first returns 4 products. That’s a valid reading (“top 3 revenue levels”), but say so in the comment. Most interviewers 
   expect RANK, which returns 3 products after a 1,1,3 tie.
2) The tie debate is mostly academic here. unit_price and discount are floats, so exact revenue ties are very unlikely. Saying that 
   shows you checked the data. If you use ROW_NUMBER, add a deterministic tiebreaker like product_id to the ORDER BY.
3) SELECT * returns IDs, not names. Join categories to get category_name.
4) No final ORDER BY. A window-function filter doesn’t guarantee output order.
5) Raw float output. Cast to numeric and round.
6) The comment’s formula is still garbled. Write it as unit_price * quantity * (1 - discount). A reader should be able to trust your comments.
 */

/* Second Iteration */ 
WITH product_revenue AS (
	SELECT p.product_id, p.product_name, p.category_id, c.category_name,
		   ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue 
	FROM products p
	JOIN order_details od ON p.product_id = od.product_id
	JOIN categories c ON p.category_id = c.category_id
	GROUP BY p.product_id, p.product_name, p.category_id, c.category_name
), 
ranked AS (
	SELECT *, DENSE_RANK() OVER (PARTITION BY category_id ORDER BY revenue DESC) as rank
	FROM product_revenue 
)
SELECT *
FROM ranked 
WHERE rank <= 3
ORDER BY category_id;


-- 4. Marketing wants to know which customers ordered in 1996 but not in 1997. Produce that list.

SELECT * FROM customers LIMIT 10; 
SELECT * FROM customer_demographics LIMIT 10;
SELECT * FROM orders LIMIT 10; 
SELECT * FROM order_details LIMIT 10;

WITH order_year_96 AS (
	SELECT customer_id, EXTRACT(YEAR FROM order_date) as year
	FROM orders 
	WHERE EXTRACT(YEAR FROM order_date) = 1996
),
order_year_97 AS (
	SELECT customer_id, EXTRACT(YEAR FROM order_date) as year
	FROM orders 
	WHERE EXTRACT(YEAR FROM order_date) = 1997
)
SELECT * 
FROM order_year_96 l
LEFT OUTER JOIN order_year_97 r 
  ON l.customer_id = r.customer_id
WHERE r.customer_id IS NULL

/* Claude Grading
1. Duplicate rows. Your CTEs return one row per order, not per customer. A customer with 5 orders in 1996 and 
   none in 1997 appears 5 times. Marketing asked for a list of customers, so the list must be unique. This is 
   the main error, and it’s the classic anti-join trap.
2. SELECT * returns junk. You get customer_id, year, and then two NULL columns from the right side. You also have 
   no customer name.
3. Non-sargable year filter again. EXTRACT(YEAR FROM order_date) = 1996 blocks index use. I flagged this on 
   Question 1, so expect an interviewer to notice if it repeats. Use a half-open date range.
4. The year column is pointless. It’s a constant inside each CTE.
5. No assumption comment. For example: “ordered” means placed any order, regardless of ship status.
 */

/* Second Iteration */ 
SELECT c.customer_id, c.company_name 
FROM customers c 
WHERE EXISTS (
	SELECT 1
	FROM orders o 
	WHERE o.customer_id = c.customer_id AND
	EXTRACT(YEAR FROM o.order_date) = 1996)
	AND NOT EXISTS (
	SELECT 1
	FROM orders o 
	WHERE o.customer_id = c.customer_id AND 
	EXTRACT(YEAR FROM o.order_date) = 1997)
ORDER BY c.company_name;


-- 5. For each customer with at least two orders, calculate the number of days between their first and second order.  
-- Then report the average of that gap across all customers.

/* First Iteration */ 

WITH partitioned AS(
	SELECT customer_id, order_date, 
	ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_counter
	FROM orders
),
days_joined AS (
	SELECT o.customer_id, o.order_date AS second_date, m.order_date AS first_date 
	FROM partitioned o 
	JOIN partitioned m ON o.customer_id = m.customer_id
	WHERE o.order_counter = 2 AND m.order_counter = 1
)
SELECT customer_id, (second_date - first_date) AS time_inbetween
FROM days_joined

SELECT AVG(second_date - first_date) as AVERAGE 
FROM days_joined 
-- 101 days average. 
