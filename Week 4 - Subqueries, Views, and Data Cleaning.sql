# 1. What is the lifetime average amount spent in USD for the top 10 total spending accounts?
# Find the top 10 total spending accounts > Find average top 10 
WITH table1 AS (SELECT a.name, SUM(o.total_amt_usd) AS total_spending
				FROM accounts a 
				JOIN orders o
				ON a.id = o.account_id 
				GROUP BY a.name 
				ORDER BY total_spending DESC 
				LIMIT 10)
			SELECT AVG(total_spending) AS lifetime_average_amount_spent
			FROM table1

# 2. For the customer/account that spent the most (in total over their lifetime as a customer) total_amt_usd, 
# how many web_events did they have for each channel?
# Find the customer/account name with the highest total_amt_usd > Link to web_events, count channel    
WITH table1 AS (SELECT a.name, a.id, SUM(o.total_amt_usd) AS total_spending
				FROM orders o 
				JOIN accounts a
				ON o.account_id = a.id 
				GROUP BY a.name, a.id  
				ORDER BY SUM(total_amt_usd) DESC
				LIMIT 1)
			SELECT table1.name, we.channel, COUNT(*) AS channel_count 
			FROM web_events we
			JOIN table1
			ON we.account_id = table1.id
			GROUP BY table1.name, we.channel
 
# 3. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
# Find largest total_amt_usd > account name > sales_rep_id > sales_rep_name > region_id > region_name
# Find max sales according to region_name > Match sales_rep_name, region_name, max sales = total_sales 
WITH table1 AS (SELECT sr.name AS sales_rep_name, r.name AS region_name, SUM(total_amt_usd) AS total_sales
				FROM orders o
				JOIN accounts a 
				ON o.account_id = a.id 
				JOIN sales_reps sr 
				ON a.sales_rep_id = sr.id
				JOIN region r 
				ON sr.region_id = r.id
				GROUP BY sr.name, r.name), 
	 table2 AS (SELECT region_name, MAX(total_sales) AS max_sales
				FROM table1
				GROUP BY region_name)
	        SELECT table1.sales_rep_name, table1.region_name, table2.max_sales
	        FROM table1
	        JOIN table2
	        ON table1.region_name = table2.region_name AND table1.total_sales = table2.max_sales
	        
# 4. In the accounts table, there is a column holding the website for each company. 
# The last three digits specify what type of web address they are using. 
# Pull these extensions and provide how many of each website type exist in the accounts table.
SELECT website_type, COUNT(*) AS website_type_count
FROM (SELECT RIGHT(website, 4) AS website_type
	  FROM accounts) AS a
GROUP BY website_type

# 5. There is much debate about how much the name (or even the first letter of a company name) matters. 
# Use the accounts table to pull the first letter of each company name 
# to see the distribution of company names that begin with each letter (or number).
SELECT first_letter, COUNT(*) AS first_letter_distribution 
FROM (SELECT LEFT(name, 1) AS first_letter 
	  FROM accounts) AS a
GROUP BY 1 
ORDER BY 2 DESC
	  
# 6. Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number 
# and a second group of those company names that start with a letter. What proportion of company names start with a letter?
SELECT first_letter_group, COUNT(*) AS count_group 
FROM (SELECT LEFT(name, 1) AS first_letter, 
	   		 CASE WHEN LEFT(name, 1) > 0 THEN 'Number' 
			      ELSE 'Letter'
	   		 END AS 'first_letter_group'
	  FROM accounts) AS a 
GROUP BY 1
# There are 350 companies whose name starts with a letter, so the proportion is 350/351 ~99.7%.

# 7. Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.
SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) AS first_name,
	   RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last_name
FROM accounts

# 8. Each company in the accounts table wants to create an email address for each primary_poc. 
# The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
SELECT primary_poc, company_name, 
	   CONCAT(first_name, '.', last_name, '@', company_name, '.com') AS email
FROM (SELECT primary_poc, name AS company_name, 
		     LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) AS first_name,
	         RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last_name	              
	  FROM accounts) AS a
	  
# 9. You may have noticed that in the previous solution some of the company names include spaces, which will certainly 
# not work in an email address. See if you can create an email address that will work by removing all of the spaces 
# in the account name, but otherwise your solution should be just as in the previous question. (Hint: lookup replace)
SELECT primary_poc, company_name, 
	   CONCAT(first_name, '.', last_name, '@', company_name, '.com') AS email
FROM (SELECT primary_poc, REPLACE(name,' ','') AS company_name, 
		     LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) AS first_name,
	         RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last_name	              
	  FROM accounts) AS a
	  
# 10. We would also like to create an initial password, which they will change after their first log in. 
# The first password will be the first letter of the primary_poc’s first name (lowercase), 
# then the last letter of their first name (lowercase), the first letter of their last name (lowercase), 
# the last letter of their last name (lowercase), the number of letters in their first name, 
# and then the name of the company they are working with, all capitalized with no spaces.
WITH table1 AS (SELECT first_name, last_name, company_name, 
	   				   CONCAT(LOWER(first_name), '.', LOWER(last_name), '@', LOWER(company_name), '.com') AS email
				FROM (SELECT primary_poc, REPLACE(name,' ','') AS company_name, 
		     				 LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) AS first_name,
	         				 RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last_name	              
	  				  FROM accounts) AS a)
			SELECT email, CONCAT(LOWER(LEFT(first_name, 1)), LOWER(RIGHT(first_name, 1)), LOWER(LEFT(last_name, 1)), 
				   LOWER(RIGHT(last_name, 1)), LENGTH(first_name), UPPER(company_name)) AS initial_password
		    FROM table1	 		