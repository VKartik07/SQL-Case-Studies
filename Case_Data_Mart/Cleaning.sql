/* --------------------
   8 Week SQL Challenge [V Kartik]
   Case Study Questions [Week 4 - Data Mart]
   --------------------*/

/* --------------------
 A. Data Cleansing Steps
   --------------------*/

-- Perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales. 

-- 1. Convert the week_date to a DATE format

-- 2. Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 
-- 7th of January will be 1, 8th to 14th will be 2 etc

-- 3. Add a month_number with the calendar month for each week_date value as the 3rd column

-- 4. Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

-- 5. Add a new column called age_band after the original segment column using the following mapping 
-- on the number inside the segment value

/* --------------------
   segment       age_band
     1			Young Adults
	 2			Middle Aged
	 3 or 4     Retirees
   --------------------*/

-- 6. Add a new demographic column using the following mapping for the first letter in the segment values:

/* --------------------
   segment       demographic
     C			Couple
	 F			Families
   --------------------*/

-- 7. Ensure all null string values with an "unknown" string value in the original 
-- segment column as well as the new age_band and demographic columns

-- 8. Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places 
-- for each record
WITH date_detailed(region, 
	platform, 
	segment, 
	customer_type, 
	transactions, 
	sales, 
	day, 
	month, 
	year) AS
(
SELECT 
	region, 
	platform, 
	segment, 
	customer_type, 
	transactions, 
	sales, 
	CASE
		WHEN LEN(SUBSTRING(week_date, 1, CHARINDEX('/', week_date)-1)) = 1
			THEN CONCAT('0', SUBSTRING(week_date, 1, CHARINDEX('/', week_date)-1))
		ELSE SUBSTRING(week_date, 1, CHARINDEX('/', week_date)-1)
	END AS day, 
	CASE
		WHEN LEN(SUBSTRING(week_date, CHARINDEX('/', week_date)+1, (CHARINDEX('/', week_date, CHARINDEX('/', week_date)+1)) - (CHARINDEX('/', week_date)+1))) = 1
			THEN CONCAT('0', SUBSTRING(week_date, CHARINDEX('/', week_date)+1, (CHARINDEX('/', week_date, CHARINDEX('/', week_date)+1)) - (CHARINDEX('/', week_date)+1)))
		ELSE SUBSTRING(week_date, CHARINDEX('/', week_date)+1, (CHARINDEX('/', week_date, CHARINDEX('/', week_date)+1)) - (CHARINDEX('/', week_date)+1))
	END AS month, 
	CONCAT('20', SUBSTRING(week_date, CHARINDEX('/', week_date, CHARINDEX('/', week_date)+1)+1, LEN(week_date) - CHARINDEX('/', week_date, CHARINDEX('/', week_date)+1))) AS year
FROM Eight_Week_Challenge_5..weekly_sales
), clean_sales(week_date, week_number, month_number, calendar_year, region, platform, customer_type, age_band, demographic_band, transactions, sales, avg_transaction) AS
(
SELECT 
	CONCAT(year, '-', month, '-', day) AS week_date,
	CASE 
		WHEN day BETWEEN 1 AND 7
			THEN 1
		WHEN day BETWEEN 8 AND 14
			THEN 2
		WHEN day BETWEEN 15 AND 21
			THEN 3
		WHEN day BETWEEN 22 AND 28
			THEN 4
		WHEN day >=29
			THEN 5
	END AS week_number, 
	month AS month_number, 
	year AS calendar_year, 
	LOWER(region) AS region, 
	LOWER(platform) AS platform, 
	LOWER(customer_type) AS customer_type,
	CASE 
			WHEN SUBSTRING(segment, 2, 1) = '1'
				THEN 'Young Adults'
			WHEN SUBSTRING(segment, 2, 1) = '2'
				THEN 'Middle Aged'
			WHEN SUBSTRING(segment, 2, 1) = '3' OR SUBSTRING(segment, 2, 1) = '4'
				THEN 'Retirees'
			ELSE
				'unknown'
	END AS age_band, 
	CASE 
			WHEN SUBSTRING(segment, 1, 1) = 'C'
				THEN 'Couple'
			WHEN SUBSTRING(segment, 1, 1) = 'F'
				THEN 'Families'
			ELSE
				'unknown'
	END AS demographic_band, 
	transactions, 
	sales, 
	CAST(sales * 1.0/transactions AS DECIMAL(18,2)) AS avg_transaction
FROM date_detailed
)

SELECT *
INTO clean_weekly_sales 
FROM clean_sales
