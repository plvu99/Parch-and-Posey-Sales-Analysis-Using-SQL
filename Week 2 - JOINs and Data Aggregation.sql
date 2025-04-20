-- 1. Write a query to return all orders by Walmart. 
-- Return the order id, account name, as well as the total paper quantity for each order.
SELECT o.id AS order_id, a.name, o.total 
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id 
WHERE a.name = 'Walmart' 

-- 2. Create a table that has the different channels used by account id 1001. 
-- Your final table should have only 2 columns: account name and the different channels.
SELECT a.name AS 'account name', we.channel AS 'different channels'
FROM accounts a 
LEFT JOIN web_events we
ON a.id = we.account_id 
WHERE a.id = 1001

-- 3. Create a table that has the orders that occurred in 2015 (sorted by date). 
-- Your final table should have 4 columns: occurred_at, account name, order total, and order total_amt_usd.
SELECT a.name, o.occurred_at, o.total, o.total_amt_usd
FROM orders o 
LEFT JOIN accounts a
ON o.account_id = a.id
WHERE o.occurred_at LIKE '2015%' 

-- 4. Create a table that has the region for each sales_rep along with their associated accounts. 
-- Your final table should include three columns: the region name, the sales rep name, and the account name.
SELECT r.name, sr.name, a.id 
FROM accounts a 
LEFT JOIN sales_reps sr
ON a.sales_rep_id = sr.id 
LEFT JOIN region r
ON sr.region_id = r.id

-- 5. Create a table that provides the region for each sales_rep along with their associated accounts. 
-- This time only for the Midwest region. 
-- Your final table should include three columns: the region name, the sales rep name, and the account name. 
SELECT r.name, sr.name, a.id 
FROM accounts a 
LEFT JOIN sales_reps sr
ON a.sales_rep_id = sr.id 
LEFT JOIN region r
ON sr.region_id = r.id
WHERE r.name = 'Midwest' 

-- 6. Who was the primary contact associated with the earliest web_event?
SELECT a.name, we.occurred_at
FROM web_events we 
LEFT JOIN accounts a 
ON we.account_id = a.id 
ORDER BY we.occurred_at ASC 
LIMIT 1

-- 7. Create a table that has the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. 
-- Your final table should have 3 columns: region name, account name, and unit price. 
-- A few accounts have 0 for total, so you might have to divide by (total + 0.0001) to assure not dividing by zero.
SELECT r.name AS region_name, a.name AS account_name, o.total_amt_usd/(o.total + 0.0001) AS unit_price
FROM orders o 
LEFT JOIN accounts a 
ON o.account_id = a.id
LEFT JOIN sales_reps sr 
ON a.sales_rep_id = sr.id
LEFT JOIN region r
ON sr.region_id = r.id 

-- 8. Count the number of rows in the accounts table.
SELECT COUNT(*)
FROM accounts

-- 9. Find the total amount of poster_qty paper ordered in the orders table.
SELECT SUM(poster_qty)
FROM orders 

-- 10. What is the min and max order quantity for each poster papers in the database?
SELECT MIN(poster_qty), MAX(poster_qty)
FROM orders 

-- 11. When was the earliest order ever placed?
SELECT MIN(occurred_at)
FROM orders

-- 12. Find the mean (AVERAGE) amount spent per order on each paper type.
SELECT AVG(standard_amt_usd), AVG(gloss_amt_usd), AVG(poster_amt_usd) 
FROM orders

-- 13. What is the MEDIAN total_usd spent on all orders?
SELECT AVG(total_amt_usd) 
FROM orders
WHERE id = 3456 OR id = 3457

-- 14. Find the total sales in usd for each account. You should include two columns: 
-- the total sales for each company’s orders in usd and the company name.
SELECT a.name AS company_name, SUM(o.total_amt_usd) AS total_sales
FROM orders o
INNER JOIN accounts a 
ON o.account_id = a.id 
GROUP BY a.name

-- 15. Find the total number of times each type of channel from the web_events was used. 
-- Your final table should have two columns - the channel and the number of times the channel was used.
SELECT channel, COUNT(channel)
FROM web_events
GROUP BY channel 

-- 16. What was the smallest order total value in USD placed by each account. 
-- Provide only two columns - the account name and the total usd. 
-- Order from smallest dollar amounts to largest.
SELECT a.name AS company_name, SUM(o.total_amt_usd) AS total_value  
FROM orders o
INNER JOIN accounts a 
ON o.account_id = a.id 
GROUP BY a.name
ORDER BY total_value ASC
LIMIT 1

-- 17. Find the number of sales reps in each region. 
-- Your final table should have two columns - the region and the number of sales_reps. 
-- Order from fewest reps to most reps.
SELECT r.name AS region_name, COUNT(sr.id) AS sales_reps_num
FROM region r
INNER JOIN sales_reps sr 
ON r.id = sr.region_id
GROUP BY r.name
ORDER BY sales_reps_num ASC

-- 18. For each account, determine the average amount of each type of paper they purchased across their orders. 
-- Your result should have four columns: one for the account name and one for the average spent on each of the paper types.
SELECT a.name, AVG(standard_amt_usd) AS standard_spent, 
       AVG(gloss_amt_usd) AS gloss_spent, AVG(poster_amt_usd) AS poster_spent
FROM accounts a
INNER JOIN orders o
ON a.id = o.account_id
GROUP BY a.name 
