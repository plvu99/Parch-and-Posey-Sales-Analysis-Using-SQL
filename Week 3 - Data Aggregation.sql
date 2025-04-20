-- 1. Determine the number of times a particular channel was used in the web_events table for each sales rep. 
-- Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. 
-- Order your table with the highest number of occurrences first.
SELECT sr.name, we.channel, COUNT(we.channel) AS no_of_occurrences
FROM sales_reps sr 
INNER JOIN accounts a
ON sr.id = a.sales_rep_id
INNER JOIN web_events we
ON a.id = we.account_id 
GROUP BY we.channel, sr.name 
ORDER BY no_of_occurrences DESC

-- 2. How many of the sales reps have more than 5 accounts that they manage?
SELECT COUNT(*)
FROM (SELECT sales_rep_id, COUNT(id) AS account_id
      FROM accounts 
      GROUP BY sales_rep_id
      HAVING COUNT(id) > 5) AS a 
	  
-- 3. How many accounts have more than 20 orders?
SELECT COUNT(*)
FROM (SELECT account_id, COUNT(id) AS total_orders
      FROM orders 
      GROUP BY account_id 
      HAVING COUNT(id) > 20) AS o 

-- 4. Which account has the most orders?
SELECT a.name, COUNT(o.id) AS total_orders
FROM orders o 
INNER JOIN accounts a 
ON o.account_id = a.id 
GROUP BY a.name 
ORDER BY COUNT(id) DESC
LIMIT 1

-- 5. How many accounts spent more than $30,000 total with Parch and Posey throughout the years?
SELECT COUNT(*)
FROM (SELECT account_id, SUM(total_amt_usd) AS total_spent
      FROM orders 
      GROUP BY account_id
      HAVING total_spent > 30000) AS o

-- 6. Which account has spent the most with us?
SELECT a.name, SUM(total_amt_usd) AS total_spent
FROM orders o 
INNER JOIN accounts a 
ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_spent DESC
LIMIT 1

-- 7. Which account used facebook most as a channel?
SELECT a.name, we.channel, COUNT(we.channel) AS facebook_channel
FROM web_events we
INNER JOIN accounts a 
ON we.account_id = a.id
WHERE we.channel = 'facebook'
GROUP BY a.name
ORDER BY facebook_channel DESC 
LIMIT 1

-- 8. Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.name, we.channel, COUNT(channel) AS facebook_channel
FROM web_events we
INNER JOIN accounts a 
ON we.account_id = a.id
WHERE channel = 'facebook'
GROUP BY a.name
HAVING facebook_channel > 6

-- 9. Which channel was the most frequently used by different accounts?
WITH all_channels AS (SELECT a.name, we.channel, COUNT(we.channel) AS total_uses
	  	      FROM accounts a 
	  	      INNER JOIN web_events we 
	  	      ON a.id = we.account_id 
      		      GROUP BY a.name, we.channel 
       		      ORDER BY a.name), 
     frequent_channels AS (SELECT name, MAX(total_uses) AS frequent_uses
	 		   FROM all_channels 
	 		   GROUP BY name)
     SELECT all_channels.name AS account_name, all_channels.channel, frequent_channels.frequent_uses
     FROM all_channels
     INNER JOIN frequent_channels
     ON all_channels.name = frequent_channels.name AND all_channels.total_uses = frequent_channels.frequent_uses 

-- 10. Find the sales ($) for all orders in each year, ordered from largest to smallest. 
SELECT YEAR(occurred_at) AS 'year', SUM(total_amt_usd) AS total_sales 
FROM orders o 
GROUP BY YEAR(occurred_at)
ORDER BY total_sales DESC 

-- 11. Which month did Parch & Posey have the largest sales ($)?
SELECT YEAR(occurred_at) AS 'year', MONTH(occurred_at) AS 'month', SUM(total_amt_usd) AS total_sales 
FROM orders o 
GROUP BY YEAR(occurred_at), MONTH(occurred_at) 
ORDER BY total_sales DESC
LIMIT 1

-- 12. In which year and month did Walmart spend($) the most on gloss paper?
SELECT a.name, YEAR(o.occurred_at) AS 'year', MONTH(o.occurred_at) AS 'month', SUM(o.gloss_amt_usd) AS total_gloss_sales 
FROM orders o 
INNER JOIN accounts a
ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY YEAR(o.occurred_at), MONTH(o.occurred_at) 
ORDER BY total_gloss_sales DESC
LIMIT 1

-- 13. We would like to understand 3 different branches of customers based on the amount associated with their purchases. 
-- The top branch includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. 
-- The second branch is between 200,000 and 100,000 usd. The lowest branch is anyone under 100,000 usd. 
-- Provide a table that includes the level associated with each account. 
-- You should provide the account name, the total sales of all orders for the customer, and the level. 
-- Order with the top spending customers listed first.
SELECT a.name, SUM(o.total_amt_usd) AS total_sales,
       CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Top'
	    WHEN SUM(o.total_amt_usd) > 100000 THEN 'Second'
	    ELSE 'Lowest'
       END AS 'level'
FROM orders o 
INNER JOIN accounts a 
ON o.account_id = a.id 
GROUP BY a.name 
ORDER BY total_sales DESC

-- 14. Restrict the results of the preivous question to the orders occurred only in 2016 and 2017.
SELECT a.name, SUM(o.total_amt_usd) AS total_sales,
       CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Top'
	    WHEN SUM(o.total_amt_usd) > 100000 THEN 'Second'
	    ELSE 'Lowest'
       END AS 'level'
FROM orders o 
INNER JOIN accounts a 
ON o.account_id = a.id 
WHERE YEAR(o.occurred_at) IN (2016, 2017)
GROUP BY a.name 
ORDER BY total_sales DESC

-- 15. We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders. 
-- Create a table with the sales rep name, the total number of orders, and a column with top or not depending on 
-- if they have more than 200 orders. Place the top sales people first in your final table.
SELECT sr.name AS sales_rep_name, COUNT(o.id) AS total_orders,
       CASE WHEN COUNT(o.id) > 200 THEN 'Top'
	    ELSE 'Not Top'
       END AS 'Top or Not'
FROM orders o 
INNER JOIN accounts a 
ON o.account_id = a.id 
INNER JOIN sales_reps sr
ON a.sales_rep_id = sr.id 
GROUP BY sr.name
ORDER BY total_orders DESC

-- 16. The previous question didn’t account for the middle, nor the dollar amount associated with the sales. 
-- Management decides they want to see these characteristics represented as well. 
-- We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders 
-- or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales. 
-- Create a table with the sales rep name, the total number of orders, total sales across all orders, 
-- and a column with top, middle, or low depending on this criteria. 
-- Place the top sales people based on dollar amount of sales first in your final table. 
SELECT sr.name AS sales_rep_name, COUNT(o.id) AS total_orders, SUM(o.total_amt_usd) AS total_sales,
       CASE WHEN COUNT(o.id) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'Top'
	    WHEN COUNT(o.id) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'Middle'
	    ELSE 'Low'
       END AS 'performance_level'	    
FROM orders o 
INNER JOIN accounts a 
ON o.account_id = a.id 
INNER JOIN sales_reps sr
ON a.sales_rep_id = sr.id 
GROUP BY sr.name
ORDER BY total_sales DESC
