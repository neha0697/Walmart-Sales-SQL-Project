--Create Database

CREATE DATABASE WalmartSalesData;

--Create Table

DROP TABLE IF EXISTS Sales;
CREATE TABLE Sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
	branch VARCHAR(5) NOT NULL,
	city VARCHAR(30) NOT NULL,
	customer_type VARCHAR(30) NOT NULL,
	Gender VARCHAR(10) NOT NULL,
	Product_line VARCHAR(100) NOT NULL,
	Unit_price DECIMAL(10,2) NOT NULL,
	Quantity INT NOT NULL,
	VAT FLOAT NOT NULL,
	Total DECIMAL(10,2) NOT NULL,
	Date DATE NOT NULL,
	Time TIME NOT NULL,
	Payment_method VARCHAR(15) NOT NULL,
	cogs DECIMAL(10,2) NOT NULL,
	gross_margin_percentage FLOAT NOT NULL,
	gross_income DECIMAL(12,4) NOT NULL,
	Rating FLOAT NOT NULL
);

SELECT * FROM Sales;


------------------------------------------------------------------------------------------------
---------------------------------- Feature Engineering ---------------------------------------------


-- time_of_day

select 
	time,
	case 
	when extract(hour from time) <12 then 'Morning'
	when extract(hour from time) between 12 and 16 then 'Afternoon'
	else 'Evening'
	end as time_of_day
from Sales;	

ALTER TABLE Sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE Sales
SET time_of_day =(
	CASE 
	WHEN extract(hour from time) <12 THEN 'Morning'
	WHEN extract(hour from time) between 12 and 16 THEN 'Afternoon'
	ELSE 'Evening'
	END 
	);


-- Day_name

SELECT date, to_char(date,'Day') AS day_name
FROM Sales;

ALTER TABLE Sales ADD COLUMN day_name VARCHAR(15);

UPDATE Sales
SET day_name = to_char(date,'Day');


-- Month_name

SELECT date, to_char(date, 'Mon') AS month_name
FROM Sales;

ALTER TABLE Sales ADD COLUMN month_name VARCHAR(3);

UPDATE Sales
SET month_name = to_char(date, 'Mon');


------------------------------------------------------------------------------------------------
-------------------------------------- Generic -------------------------------------------------

-- Q1. How many unique cities does data have?

SELECT DISTINCT city FROM Sales;

-- Q2. In which city is each branch?

SELECT 
	DISTINCT city,
	branch
FROM Sales;



------------------------------------------------------------------------------------------------
---------------------------------------- PRODUCT -----------------------------------------------

-- Q1. How many unique product lines does the data have?

SELECT COUNT(DISTINCT product_line)
FROM Sales;

-- Q2. What is the common payment method?

SELECT payment_method, COUNT(payment_method) AS no_of_payments
FROM Sales
GROUP BY Payment_method
ORDER BY 2 DESC
LIMIT 1;

-- Q3. What is the most selling product line?

SELECT product_line, COUNT(product_line) AS cnt
FROM Sales
GROUP BY product_line
ORDER BY 2 DESC
LIMIT 1;

-- Q4. What is the total revenue by month?

SELECT month_name, SUM(total) AS total_revenue
FROM Sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- Q5. Which month had the highest cogs?

SELECT month_name, SUM(cogs) AS total_cogs
FROM Sales
GROUP BY month_name
ORDER BY total_cogs DESC;

-- Q6. Which product line had the highest revenue?

SELECT product_line, SUM(total) AS total_revenue
FROM Sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- Q7. What is the city with highest revenue?

SELECT city, branch, SUM(total) AS total_revenue
FROM Sales
GROUP BY city, branch
ORDER BY total_revenue DESC
LIMIT 1;

-- Q8. Which product line had the largest VAT?

SELECT product_line, ROUND(AVG(vat)::numeric,2) as avg_vat
FROM Sales
GROUP BY product_line
ORDER BY avg_vat DESC
LIMIT 1;

-- Q9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales.

SELECT product_line,
	CASE
	WHEN AVG(total) > (SELECT AVG(TOTAL) FROM Sales) THEN 'Good'
	ELSE 'Bad'
	END AS Status
FROM Sales
GROUP BY product_line;
	
		
--Q10. Which branch sold more products than average product sold?

SELECT branch, ROUND(AVG(quantity)::numeric,2) AS avg_sales
FROM Sales
GROUP BY branch
HAVING AVG(quantity) > (SELECT AVG(quantity) FROM Sales);
	

-- Q11. What is the most common product line by gender?

SELECT product_line, gender, count(gender) as total_cnt
FROM Sales
GROUP BY product_line, gender
ORDER BY total_cnt DESC;

-- Q12. What is the average rating of each product line?

SELECT product_line, ROUND(AVG(rating)::numeric,2) AS avg_rating
FROM Sales
GROUP BY product_line
ORDER BY avg_rating DESC;



-----------------------------------------------------------------------------------------------
------------------------------------ SALES ----------------------------------------------------

-- Q1. Number of sales made in each time of the day per weekday?

SELECT day_name, time_of_day, COUNT(*) AS no_of_sales
FROM Sales	
GROUP BY day_name, time_of_day
HAVING TRIM(day_name) NOT IN ('Saturday', 'Sunday')	
ORDER BY day_name, time_of_day;

-- Q2. Which of the customer types brings the most revenue?

SELECT customer_type, SUM(total) AS total_revenue
FROM Sales
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;

-- Q3. Which city has the largest tax percentage/VAT?

SELECT city, ROUND(AVG(VAT)::numeric,2) as VAT
FROM Sales
GROUP BY city
ORDER BY VAT DESC
LIMIT 1;

-- Q4. Which customer type pays the most in VAT?

SELECT customer_type, SUM(VAT) AS total_tax_paid
FROM Sales
GROUP BY customer_type
ORDER BY total_tax_paid DESC
LIMIT 1;



-----------------------------------------------------------------------------------------------
-------------------------------------- CUSTOMERS ----------------------------------------------


-- Q1. How many unique customer type dodes the data have?

SELECT COUNT(DISTINCT customer_type) 
FROM Sales;


-- Q2. How many unique payment methods does the data have?

SELECT COUNT(DISTINCT payment_method)
FROM Sales;


-- Q3. What is the most common customer type?

SELECT customer_type, COUNT(*) AS cust_count
FROM Sales
GROUP BY customer_type
ORDER BY cust_count DESC
LIMIT 1;


-- Q4. Which customer type buys the most?

ELECT customer_type, COUNT(*) AS cust_count
FROM Sales
GROUP BY customer_type
ORDER BY cust_count DESC
LIMIT 1;


-- Q5. What is the gender of the most of the customers?

SELECT gender, COUNT(*) AS cnt
FROM Sales
GROUP BY gender
ORDER BY cnt DESC	
LIMIT 1;

-- Q6. What is the gender distribution per branch?

SELECT branch, gender, COUNT(*) AS cnt
FROM Sales
GROUP BY branch, gender
ORDER BY branch, gender;

-- Q7. Which time of the day do customers give most ratings?

SELECT time_of_day, ROUND(AVG(rating)::numeric,2) as avg_rating
FROM Sales
GROUP BY time_of_day
ORDER BY avg_rating DESC
LIMIT 1;

-- Q8. Which time of the day do customers give most ratings per branch?

SELECT branch, time_of_day, avg_rating
	FROM(
SELECT branch, time_of_day, ROUND(AVG(rating)::numeric,2) as avg_rating,
RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
FROM Sales
GROUP BY branch, time_of_day
ORDER BY branch, avg_rating DESC
	)
WHERE rnk = 1;

-- Q9. Which day of the week has the best avg ratings?

SELECT day_name, ROUND(AVG(rating)::numeric,2) AS avg_rating
FROM Sales
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 1;

-- Q10. Which day of the week has the best avg ratings per branch?

SELECT branch, day_name, avg_rating
	FROM(
SELECT branch, day_name, ROUND(AVG(rating)::numeric,2) as avg_rating,
RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
FROM Sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC
	)
WHERE rnk = 1; 


-----------------------------------------------------------------------------------------------