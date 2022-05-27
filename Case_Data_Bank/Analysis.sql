/* --------------------
   8 Week SQL Challenge [V Kartik]
   Case Study Questions [Week 4 - Data Bank]
   --------------------*/

/* --------------------
 A. Customer Nodes Exploration
   --------------------*/

-- 1. How many unique nodes are there on the Data Bank system?

-- By Using the DISTINCT Statement

--SELECT COUNT(DISTINCT node_id) AS unique_nodes_count
--FROM Eight_Week_Challenge_4..customer_nodes

-- By Using the GROUP BY Clause

--SELECT COUNT(temp.unique_nodes) AS unique_nodes_count
--FROM 
--(
--SELECT node_id AS unique_nodes
--FROM Eight_Week_Challenge_4..customer_nodes
--GROUP BY node_id
--) AS temp

-- 2. What is the number of nodes per region?

--SELECT 
--	region_id,
--	COUNT(node_id) AS nodes_count_per_region
--FROM Eight_Week_Challenge_4..customer_nodes
--GROUP BY region_id

-- 3. How many customers are allocated to each region?

--SELECT 
--	region_id,
--	COUNT(DISTINCT customer_id) AS customer_count_per_region
--FROM Eight_Week_Challenge_4..customer_nodes
--GROUP BY region_id

-- 4. How many days on average are customers reallocated to a different node?

--SELECT 
--	AVG(DATEDIFF(day, start_date, end_date)) AS average_days_for_reallocation
--FROM Eight_Week_Challenge_4..customer_nodes

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

--CREATE VIEW node_duration AS
--SELECT 
--	customer_id,
--	region_id,
--	DATEDIFF(day, start_date, end_date) AS difference_dates
--FROM Eight_Week_Challenge_4..customer_nodes

--DROP FUNCTION IF EXISTS median_calculator 

--CREATE FUNCTION median_calculator(@region_id INT)
--RETURNS DEC(10,2)
--AS
--BEGIN
--	DECLARE @length INT
--	DECLARE @row_number_first INT
--	DECLARE @row_number_second INT
--	DECLARE @median DEC(18,2)
--	DECLARE @median_even_first INT
--	DECLARE @median_even_second INT
--	SET @length = (SELECT COUNT(*) FROM node_duration WHERE region_id = @region_id)

--	IF @length %2 != 0
--		BEGIN
--			SET @row_number_first = ((@length + 1)/2)
--			SET @median = 
--			(
--				SELECT
--					temp.difference_dates
--				FROM 
--				(
--					SELECT 
--						customer_id,
--						region_id, 
--						difference_dates, 
--						ROW_NUMBER() OVER(ORDER BY difference_dates ASC) AS difference_row_number
--					FROM node_duration
--					WHERE region_id = @region_id
--				) AS temp
--				WHERE temp.difference_row_number = @row_number_first
--			)
--		END
--	ELSE
--		BEGIN
--			SET @row_number_first = (@length/2)
--			SET @row_number_second = ((@length/2)+1)

--			SET @median_even_first = 
--			(
--				SELECT
--					temp.difference_dates
--				FROM 
--				(
--					SELECT 
--						customer_id,
--						region_id, 
--						difference_dates, 
--						ROW_NUMBER() OVER(ORDER BY difference_dates ASC) AS difference_row_number
--					FROM node_duration
--					WHERE region_id = @region_id
--				) AS temp
--				WHERE temp.difference_row_number = @row_number_first
--			)
--			SET @median_even_second = 
--			(
--				SELECT
--					temp.difference_dates
--				FROM 
--				(
--					SELECT 
--						customer_id,
--						region_id, 
--						difference_dates, 
--						ROW_NUMBER() OVER(ORDER BY difference_dates ASC) AS difference_row_number
--					FROM node_duration
--					WHERE region_id = @region_id
--				) AS temp
--				WHERE temp.difference_row_number = @row_number_second
--			)
--			SET @median = (@median_even_first + @median_even_second)*1.0/2
--		END
--		RETURN @median
--END

--DROP FUNCTION IF EXISTS percentile_calculator
--CREATE FUNCTION percentile_calculator(@percentile DEC(18,2), @region_id INT)
--RETURNS INT
--AS
--BEGIN
--	DECLARE @length INT
--	DECLARE @value INT
--	DECLARE @result INT
--	SET @length = (SELECT COUNT(*) FROM node_duration WHERE region_id = @region_id)
--	SET @value = @percentile*@length
--	SET @result = 
--	(
--		SELECT 
--			temp.difference_dates
--		FROM
--		(
--		SELECT *, ROW_NUMBER() OVER(ORDER BY difference_dates ASC) AS difference_row_number
--		FROM node_duration
--		WHERE region_id = @region_id
--		) AS temp
--		WHERE temp.difference_row_number = @value
--	)
--	RETURN @result
--END

--SELECT 
--	region_id, 
--	CASE
--		WHEN region_id IS NOT NULL 
--			THEN dbo.median_calculator(region_id)
--		ELSE
--			NULL
--	END AS median, 
--	CASE
--		WHEN region_id IS NOT NULL
--			THEN dbo.percentile_calculator(0.80, region_id)
--		ELSE 
--			NULL
--	END AS '80th_percentile',
--	CASE
--		WHEN region_id IS NOT NULL
--			THEN dbo.percentile_calculator(0.95, region_id)
--		ELSE 
--			NULL
--	END AS '95th_percentile'
--FROM Eight_Week_Challenge_4..customer_nodes
--GROUP BY region_id
--ORDER BY region_id



