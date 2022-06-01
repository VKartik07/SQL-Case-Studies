/* --------------------
   8 Week SQL Challenge [V Kartik]
   Case Study Questions [Week 4 - Data Mart]
   --------------------*/

/* --------------------
 A. Data Exploration
   --------------------*/

-- 1. What day of the week is used for each week_date value?

SELECT 
	DATENAME(WEEKDAY, week_date) AS week_day
FROM Eight_Week_Challenge_5..clean_weekly_sales
GROUP BY DATENAME(WEEKDAY, week_date)

-- 2. What range of week numbers are missing from the dataset?

SELECT 
	DISTINCT week_number
FROM Eight_Week_Challenge_5..clean_weekly_sales

-- 3. How many total transactions were there for each year in the dataset?

SELECT 
	calendar_year, 
	COUNT(transactions) AS total_transactions
FROM Eight_Week_Challenge_5..clean_weekly_sales
GROUP BY calendar_year

-- 4. What is the total sales for each region for each month?

SELECT 
	region, 
	month_number, 
	SUM(CAST(sales AS BIGINT)) AS total_sales
FROM Eight_Week_Challenge_5..clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number

-- 5. What is the total count of transactions for each platform

SELECT 
	platform, 
	COUNT(transactions) AS total_count_of_transactions
FROM Eight_Week_Challenge_5..clean_weekly_sales
GROUP BY platform

-- 6. What is the percentage of sales for Retail vs Shopify for each month?

SELECT 
	month_number, 
	CAST((SUM(CASE WHEN platform = 'retail' THEN 1 ELSE NULL END) * 1.0 / COUNT(*))*100 AS DECIMAL(18,2)) AS retail_sale_percentage, 
	CAST((SUM(CASE WHEN platform = 'shopify' THEN 1 ELSE NULL END) * 1.0 / COUNT(*))*100 AS DECIMAL(18,2)) AS shopify_sale_percentage
FROM Eight_Week_Challenge_5..clean_weekly_sales
GROUP BY month_number

-- 7. What is the percentage of sales by demographic for each year in the dataset?

SELECT 
	calendar_year, 
	CAST((SUM(CASE WHEN demographic_band = 'Couple' THEN 1 ELSE NULL END) * 1.0 / COUNT(*))*100 AS DECIMAL(18,2)) AS couples_sale_percentage, 
	CAST((SUM(CASE WHEN demographic_band = 'Families' THEN 1 ELSE NULL END) * 1.0 / COUNT(*))*100 AS DECIMAL(18,2)) AS families_sale_percentage, 
	CAST((SUM(CASE WHEN demographic_band = 'unknown' THEN 1 ELSE NULL END) * 1.0 / COUNT(*))*100 AS DECIMAL(18,2)) AS 'not-defined'
FROM Eight_Week_Challenge_5..clean_weekly_sales
GROUP BY calendar_year

-- 8. Which age_band and demographic values contribute the most to Retail sales?

SELECT 
	TOP 1 age_band, 
	demographic_band, 
	SUM(CAST(sales AS BIGINT)) AS total_sales
FROM Eight_Week_Challenge_5..clean_weekly_sales
WHERE platform = 'retail' AND age_band != 'unknown' AND demographic_band! = 'unknown'
GROUP BY age_band, demographic_band
ORDER BY total_sales DESC

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
-- If not - how would you calculate it instead?

SELECT 
	calendar_year, 
	CAST(AVG(CASE WHEN platform = 'retail' THEN avg_transaction ELSE NULL END) AS DECIMAL(18,2)) AS retail_average_transaction, 
	CAST(AVG(CASE WHEN platform = 'shopify' THEN avg_transaction ELSE NULL END) AS DECIMAL(18,2)) AS shopify_average_transaction
FROM Eight_Week_Challenge_5..clean_weekly_sales
GROUP BY calendar_year