-- 1. Generate a list of all the names of the sales representatives and their IDs that Parch and Posey havs in their database.
SELECT name, id
FROM sales_reps

-- 2. Write your own query to select only the id, account_id, and occurred_at columns for all orders in the orders table.
SELECT id, account_id, occurred_at
FROM orders

-- 3. Show just the first 10 observations of the sales_reps table with all of the columns.
SELECT * 
FROM sales_reps
LIMIT 10

-- 4. Write a SQL query to look up the most 10 recent orders.
SELECT * 
FROM orders
ORDER BY occurred_at DESC
LIMIT 10

-- 5. Write a query to return the 10 earliest orders in the orders table. 
-- Include the id, occurred_at, and total_amt_usd.
SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY occurred_at ASC 
LIMIT 10

-- 6. Write a query to return the date of the 5 most expensive orders of papers. 
-- Make sure to include the order id, and the total dollar amount.
SELECT id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5

-- 7. Write a query that that returns all accounts sorted by account id. 
-- For each account, list the orders sorted by total dollar amount in descending order.
SELECT * 
FROM orders
ORDER BY account_id, total_amt_usd DESC

-- 8. Write a query that returns the top 5 rows with the highest total number of orders. 
-- If two rows have the same number of total orders, then use the total dollar amount (highest to lowest) to break the tie. 
-- (Return the ID, the total number of orders, and the total dollar amount)
SELECT id, total, total_amt_usd
FROM orders 
ORDER BY total DESC, total_amt_usd DESC 
LIMIT 5

-- 9. Write a query to show only orders from our customer with an account ID 4251.
SELECT *
FROM orders
WHERE account_id = 4251

-- 10. Write a query to pull the first 5 rows and all columns from the orders table 
-- that have spent a total amount less than or equal to $500.
SELECT * 
FROM orders
WHERE total_amt_usd <= 500
LIMIT 5

-- 11. For the account Exxon Mobil, return the the company name, website, and the primary point of contact (primary_poc).
SELECT name, website, primary_poc
FROM accounts
WHERE name = 'Exxon Mobil'

-- 12. For each order, return the quantity of non-standard papers (poster and gloss). 
-- Include the account_id and date.
SELECT account_id, occurred_at, gloss_qty + poster_qty AS non_standard_quantity
FROM orders

-- 13. Find the percentatge of standard papers ordered for each order. 
-- Limit the results to the first 5 orders, and include the id and account_id fields.
SELECT id, account_id, CONCAT((standard_qty / total * 100), '%') AS percentage_of_standard_papers
FROM orders
LIMIT 5

-- 14. Find the website for the Whole Foods account.
SELECT website
FROM accounts
WHERE name = 'Whole Foods Market'

-- 15. Find all companies whose names contain the string ‘one’ somewhere in the name.
SELECT name
FROM accounts
WHERE name LIKE '%one%'

-- 16. Use the accounts table to find all the companies whose names start with ‘C’.
SELECT name
FROM accounts
WHERE name LIKE 'C%'

-- 17. Use the accounts table to find all companies whose names end with ‘s’.
SELECT name
FROM accounts
WHERE name LIKE '%s'

-- 18. Find the account ID for both Apple and Walmart.
SELECT id, name
FROM accounts
WHERE name = 'Apple' OR name = 'Walmart' 

-- 19. Get all account IDs for those companies who were contacted via ads displayed on twitter or via google adwords.
SELECT DISTINCT account_id
FROM web_events
WHERE channel IN ('twitter', 'adwords')

-- 20. Find the account name, primary poc, and sales rep id for all stores except Walmart, Target, and Nordstrom.
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom')

-- 21. Find all company account ids who were contacted via any method except using twitter or adwords methods.
SELECT account_id
FROM web_events
WHERE channel NOT IN ('twitter', 'adwords')

-- 22. Find all the companies whose names do not start with ‘C’.
SELECT name
FROM accounts
WHERE name NOT LIKE 'C%'

-- 23. Pull all orders that occurred between April 1, 2016 and September 1, 2016.
SELECT id
FROM orders
WHERE occurred_at BETWEEN '2016-04-01%' AND '2016-09-01%'

-- 24. Write a query that returns all the orders where the standard_qty is over 1000, 
-- the poster_qty is 0, and the gloss_qty is 0.
SELECT id
FROM orders
WHERE standard_qty > 1000 AND poster_qty IS NULL AND gloss_qty IS NULL

-- 25. Which companies who were contacted via twitter or adwords channel and 
-- started their account at any point in 2016 sorted from newest to oldest.
SELECT we.account_id, a.name, we.channel, we.occurred_at 
FROM web_events we 
LEFT JOIN accounts a 
ON we.account_id = a.id
WHERE we.channel IN ('twitter', 'adwords') AND we.occurred_at LIKE '2016%'
ORDER BY we.occurred_at DESC 

-- 26. Find all customers whose orders did not have at least one type of paper.
SELECT DISTINCT account_id
FROM orders
WHERE standard_qty IS NULL OR gloss_qty IS NULL OR poster_qty IS NULL

-- 27. Find all customers whose orders did not have at least one type of paper and 
-- the order occurred after September 1, 2016. Sort the result from older transactions to the newest.
SELECT DISTINCT account_id, occurred_at
FROM orders
WHERE (standard_qty IS NULL OR gloss_qty IS NULL OR poster_qty IS NULL)
	   AND occurred_at BETWEEN '2016-09-02%' AND '2017-01-02%'
ORDER BY occurred_at ASC

-- 28. Find list of orders ids where either gloss_qty or poster_qty is greater than 4000. 
-- Only include the id field in the resulting table.
SELECT id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000

-- 29. Write a query that returns a list of orders where the standard_qty is zero and 
-- either the gloss_qty or poster_qty is over 1000.
SELECT id
FROM orders
WHERE standard_qty IS NULL AND (gloss_qty > 1000 OR poster_qty > 1000)
