-- 1. What is the number of company names that start with a vowel and consonant letters?
SELECT COUNT(*)
FROM (SELECT LEFT(name, 1) AS first_letter 
      FROM accounts) AS a
WHERE first_letter NOT IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')

-- 2. We would also like to create an initial password, which they will change after their first log in. 
-- The password will be a combination of:
-- the first letter of the primary_poc’s first name (lowercase),
-- the last letter of their first name (lowercase),
-- the first letter of their last name (uppercase),
-- the last letter of their last name (uppercase),
-- the number of letters in their first name,
-- the number of letters in their last name, and
-- the name of the company they are working with, no spaces
-- the forth and fifth digit of their sales rep id
WITH table1 AS (SELECT sales_rep_id, first_name, last_name, company_name, 
	   	       CONCAT(LOWER(first_name), '.', LOWER(last_name), '@', LOWER(company_name), '.com') AS email
		FROM (SELECT sales_rep_id, primary_poc, REPLACE(name,' ','') AS company_name, 
		     	     LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) AS first_name,
	         	     RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last_name	              
	  	      FROM accounts) AS a)
	    SELECT email, CONCAT(LOWER(LEFT(first_name, 1)), LOWER(RIGHT(first_name, 1)), UPPER(LEFT(last_name, 1)), 
		   UPPER(RIGHT(last_name, 1)), LENGTH(first_name), LENGTH(last_name),
		   company_name, RIGHT(sales_rep_id, 2)) AS initial_password
	    FROM table1

-- 3. For the orders table, create a new column which shows the total number of transactions for all accounts.
SELECT *, COUNT(*) OVER() AS total_transactions
FROM orders

-- 4. Update the previous query to create two new column: (1) over_all_total_by_account_id, 
-- and (2) overall_count_by_account_id (without using Group By).
SELECT *, SUM(total_amt_usd) OVER(PARTITION BY account_id) AS over_all_total_by_account_id,  
       COUNT(*) OVER(PARTITION BY account_id) AS overall_count_by_account_id
FROM orders

-- 5. Create a running total of standard_amt_usd (in the orders table) over order time.
SELECT occurred_at, SUM(standard_amt_usd) OVER(PARTITION BY occurred_at) AS total_standard_amt_used
FROM orders

-- 6. Create a running total of standard_amt_usd (in the orders table) over order time for each month.
SELECT DISTINCT *
FROM (SELECT MONTH(occurred_at) AS month, 
       	     SUM(standard_amt_usd) OVER(PARTITION BY MONTH(occurred_at)) AS monthly_standard_amt_usd
      FROM orders) AS o

-- 7. Create a running total of standard_qty (in the orders table) over order time for each year.
SELECT DISTINCT *
FROM (SELECT YEAR(occurred_at) AS year, 
       	     SUM(standard_qty) OVER(PARTITION BY YEAR(occurred_at)) AS yearly_standard_qty
      FROM orders) AS o
	  
-- 8. For account with id 1001, use the row_number(), rank() and dense_rank() 
-- to rank the transactions by the number of standard paper purchased.
SELECT account_id, standard_qty,  
       ROW_NUMBER() OVER(ORDER BY standard_qty) AS ranking
FROM orders 
WHERE account_id = 1001

SELECT account_id, standard_qty,  
       RANK() OVER(ORDER BY standard_qty) AS ranking
FROM orders 
WHERE account_id = 1001

SELECT account_id, standard_qty,  
       DENSE_RANK() OVER(ORDER BY standard_qty) AS ranking
FROM orders 
WHERE account_id = 1001

-- 9. For each account, use the row_number(), rank() and dense_rank() 
-- to rank the transactions by the number of standard paper purchased.
SELECT account_id, standard_qty,  
       ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY standard_qty) AS ranking
FROM orders 

SELECT account_id, standard_qty,  
       RANK() OVER(PARTITION BY account_id ORDER BY standard_qty) AS ranking
FROM orders 

SELECT account_id, standard_qty,  
       DENSE_RANK() OVER(PARTITION BY account_id ORDER BY standard_qty) AS ranking
FROM orders

-- 10. Select the id, account_id, and standard_qty variable from the orders table, 
-- then create a column called dense_rank that ranks this standard_qty amount of paper for each account. 
-- In addition, create a sum_std_qty which gives you the running total for account. 
-- Repeat the last task to get the avg, min, and max.
SELECT id, account_id, standard_qty,
       DENSE_RANK() OVER(PARTITION BY account_id ORDER BY standard_qty) AS ranking,
       SUM(standard_qty) OVER(PARTITION BY account_id ORDER BY standard_qty) AS sum_std_qty 
FROM orders 

SELECT id, account_id, standard_qty,
       DENSE_RANK() OVER(PARTITION BY account_id ORDER BY standard_qty) AS ranking,
       AVG(standard_qty) OVER(PARTITION BY account_id ORDER BY standard_qty) AS avg_std_qty 
FROM orders 

SELECT id, account_id, standard_qty,
       DENSE_RANK() OVER(PARTITION BY account_id ORDER BY standard_qty) AS ranking,
       MIN(standard_qty) OVER(PARTITION BY account_id ORDER BY standard_qty) AS min_std_qty 
FROM orders 

SELECT id, account_id, standard_qty,
       DENSE_RANK() OVER(PARTITION BY account_id ORDER BY standard_qty) AS ranking,
       MAX(standard_qty) OVER(PARTITION BY account_id ORDER BY standard_qty) AS max_std_qty 
FROM orders

-- 11. Give an allias for the window function in the previous question, and call it account_window.
SELECT id, account_id, standard_qty,
       DENSE_RANK() OVER account_window AS ranking,
       SUM(standard_qty) OVER account_window AS sum_std_qty,
       AVG(standard_qty) OVER account_window AS avg_std_qty,
       MIN(standard_qty) OVER account_window AS min_std_qty,
       MAX(standard_qty) OVER account_window AS max_std_qty
FROM orders 
WINDOW account_window AS (PARTITION BY account_id ORDER BY standard_qty)

-- 12. Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders. 
-- Your resulting table should have the account_id, the occurred_at time for each order, 
-- the total amount of standard_qty paper purchased, and one of four levels in a standard_quartile column.
SELECT account_id, occurred_at, standard_qty,
       NTILE(4) OVER(PARTITION BY account_id ORDER BY standard_qty) AS standard_qty_quartile
FROM orders

-- 13. Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders. 
-- Your resulting table should have the account_id, the occurred_at time for each order, 
-- the total amount of gloss_qty paper purchased, and one of two levels in a gloss_half column.
SELECT account_id, occurred_at, gloss_qty,
       NTILE(2) OVER(PARTITION BY account_id ORDER BY gloss_qty) AS gloss_qty_half
FROM orders
