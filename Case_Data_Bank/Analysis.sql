/* --------------------
   8 Week SQL Challenge [V Kartik]
   Case Study Questions [Week 4 - Data Bank]
   --------------------*/

/* --------------------
 A. Customer Nodes Exploration
   --------------------*/

-- 1. How many unique nodes are there on the Data Bank system?

-- By Using the DISTINCT Statement

SELECT COUNT(DISTINCT node_id) AS unique_nodes_count
FROM Eight_Week_Challenge_4..customer_nodes

-- By Using the GROUP BY Clause

SELECT COUNT(temp.unique_nodes) AS unique_nodes_count
FROM 
(
SELECT node_id AS unique_nodes
FROM Eight_Week_Challenge_4..customer_nodes
GROUP BY node_id
) AS temp

-- 2. What is the number of nodes per region?

SELECT 
	region_id,
	COUNT(node_id) AS nodes_count_per_region
FROM Eight_Week_Challenge_4..customer_nodes
GROUP BY region_id

-- 3. How many customers are allocated to each region?

SELECT 
	region_id,
	COUNT(DISTINCT customer_id) AS customer_count_per_region
FROM Eight_Week_Challenge_4..customer_nodes
GROUP BY region_id

-- 4. How many days on average are customers reallocated to a different node?

SELECT 
	AVG(DATEDIFF(day, start_date, end_date)) AS average_days_for_reallocation
FROM Eight_Week_Challenge_4..customer_nodes

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

CREATE VIEW node_duration AS
SELECT 
	customer_id,
	region_id,
	DATEDIFF(day, start_date, end_date) AS difference_dates
FROM Eight_Week_Challenge_4..customer_nodes

DROP FUNCTION IF EXISTS median_calculator 
CREATE FUNCTION median_calculator(@region_id INT)
RETURNS DEC(10,2)
AS
BEGIN
	DECLARE @length INT
	DECLARE @row_number_first INT
	DECLARE @row_number_second INT
	DECLARE @median DEC(18,2)
	DECLARE @median_even_first INT
	DECLARE @median_even_second INT
	SET @length = (SELECT COUNT(*) FROM node_duration WHERE region_id = @region_id)

	IF @length %2 != 0
		BEGIN
			SET @row_number_first = ((@length + 1)/2)
			SET @median = 
			(
				SELECT
					temp.difference_dates
				FROM 
				(
					SELECT 
						customer_id,
						region_id, 
						difference_dates, 
						ROW_NUMBER() OVER(ORDER BY difference_dates ASC) AS difference_row_number
					FROM node_duration
					WHERE region_id = @region_id
				) AS temp
				WHERE temp.difference_row_number = @row_number_first
			)
		END
	ELSE
		BEGIN
			SET @row_number_first = (@length/2)
			SET @row_number_second = ((@length/2)+1)

			SET @median_even_first = 
			(
				SELECT
					temp.difference_dates
				FROM 
				(
					SELECT 
						customer_id,
						region_id, 
						difference_dates, 
						ROW_NUMBER() OVER(ORDER BY difference_dates ASC) AS difference_row_number
					FROM node_duration
					WHERE region_id = @region_id
				) AS temp
				WHERE temp.difference_row_number = @row_number_first
			)
			SET @median_even_second = 
			(
				SELECT
					temp.difference_dates
				FROM 
				(
					SELECT 
						customer_id,
						region_id, 
						difference_dates, 
						ROW_NUMBER() OVER(ORDER BY difference_dates ASC) AS difference_row_number
					FROM node_duration
					WHERE region_id = @region_id
				) AS temp
				WHERE temp.difference_row_number = @row_number_second
			)
			SET @median = (@median_even_first + @median_even_second)*1.0/2
		END
		RETURN @median
END

DROP FUNCTION IF EXISTS percentile_calculator
CREATE FUNCTION percentile_calculator(@percentile DEC(18,2), @region_id INT)
RETURNS INT
AS
BEGIN
	DECLARE @length INT
	DECLARE @value INT
	DECLARE @result INT
	SET @length = (SELECT COUNT(*) FROM node_duration WHERE region_id = @region_id)
	SET @value = @percentile*@length
	SET @result = 
	(
		SELECT 
			temp.difference_dates
		FROM
		(
		SELECT *, ROW_NUMBER() OVER(ORDER BY difference_dates ASC) AS difference_row_number
		FROM node_duration
		WHERE region_id = @region_id
		) AS temp
		WHERE temp.difference_row_number = @value
	)
	RETURN @result
END

SELECT 
	region_id, 
	CASE
		WHEN region_id IS NOT NULL 
			THEN dbo.median_calculator(region_id)
		ELSE
			NULL
	END AS median, 
	CASE
		WHEN region_id IS NOT NULL
			THEN dbo.percentile_calculator(0.80, region_id)
		ELSE 
			NULL
	END AS '80th_percentile',
	CASE
		WHEN region_id IS NOT NULL
			THEN dbo.percentile_calculator(0.95, region_id)
		ELSE 
			NULL
	END AS '95th_percentile'
FROM Eight_Week_Challenge_4..customer_nodes
GROUP BY region_id
ORDER BY region_id

/* --------------------
 B. Customer Transactions
   --------------------*/

-- 1. What is the unique count and total amount for each transaction type?
SELECT 
	txn_type, 
	COUNT(DISTINCT customer_id) AS unique_customer_count, 
	SUM(txn_amount) AS total_amount
FROM Eight_Week_Challenge_4..customer_transactions
GROUP BY txn_type

-- 2. What is the average total historical deposit counts and amounts for all customers?
SELECT 
	customer_id, 
	COUNT(customer_id) AS depsoits_count, 
	AVG(txn_amount) AS average_deposits
FROM Eight_Week_Challenge_4..customer_transactions
WHERE txn_type = 'deposit'
GROUP BY customer_id
ORDER BY customer_id

-- 3. For each month - how many Data Bank customers make more than 1 deposit and 
-- either 1 purchase or 1 withdrawal in a single month?

CREATE FUNCTION deposits_category_count(@month_number INT)
RETURNS INT
AS
BEGIN
	DECLARE @deposit_count INT;
	WITH month_transactions(customer_id, txn_type, month) AS
	(
	SELECT 
		customer_id, 
		txn_type, 
		DATEPART(month, txn_date) AS month
	FROM Eight_Week_Challenge_4..customer_transactions
	), deposits_count_month(customer_id, txn_type, month, deposit_counts_by_month) AS
	(
	SELECT 
		customer_id, 
		txn_type, 
		month, 
		COUNT(customer_id) OVER(PARTITION BY month, customer_id) AS deposit_counts_by_month
	FROM month_transactions
	WHERE txn_type = 'deposit'
	)
	SELECT @deposit_count = COUNT(DISTINCT customer_id) 
							FROM deposits_count_month
							WHERE deposit_counts_by_month >=2 AND month = @month_number
							
	RETURN @deposit_count
END

CREATE FUNCTION other_category_counts(@month_number INT)
RETURNS INT
AS
BEGIN
DECLARE @other_count INT;
WITH month_transactions(customer_id, txn_type, month) AS
	(
	SELECT 
		customer_id, 
		txn_type, 
		DATEPART(month, txn_date) AS month
	FROM Eight_Week_Challenge_4..customer_transactions
	), purchase_withdrawl_count(customer_id, txn_type, month, counts_by_month) AS
	(
	SELECT 
		customer_id, 
		txn_type, 
		month, 
		COUNT(customer_id) OVER(PARTITION BY month, customer_id) AS counts_by_month
	FROM month_transactions
	WHERE txn_type = 'purchase' OR txn_type = 'withdrawal'
	)
	SELECT @other_count = COUNT(customer_id)
						  FROM purchase_withdrawl_count
						  WHERE counts_by_month = 1 AND month = @month_number
	RETURN @other_count
END

SELECT
	temp.month_number, 
	CASE
		WHEN 
			temp.month_number IS NOT NULL
				THEN dbo.deposits_category_count(temp.month_number)
		ELSE NULL
	END AS deposits_count, 
	CASE
		WHEN 
			temp.month_number IS NOT NULL
				THEN dbo.other_category_counts(temp.month_number)
		ELSE NULL
	END AS purchase_withdrawal_count
FROM
(
SELECT 
	DATEPART(month, txn_date) AS month_number
FROM Eight_Week_Challenge_4..customer_transactions
) AS temp
GROUP BY temp.month_number
ORDER BY month_number

-- 4. What is the closing balance for each customer at the end of the month?

WITH amount_before_cal(customer_id, month_number, txn_type, txn_amount) AS
(
SELECT 
	customer_id, 
	DATEPART(month, txn_date) AS month_number, 
	txn_type, 
	CASE
		WHEN txn_type = 'deposit'
			THEN txn_amount
		ELSE
			-1*txn_amount
	END AS txn_amount
FROM Eight_Week_Challenge_4..customer_transactions
)

SELECT 
	DISTINCT customer_id, 
	month_number, 
	SUM(txn_amount) OVER(PARTITION BY month_number, customer_id) AS closing_balance
FROM amount_before_cal

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?

WITH amount_before_cal(customer_id, month_number, txn_type, txn_amount) AS
(
SELECT 
	customer_id, 
	DATEPART(month, txn_date) AS month_number, 
	txn_type, 
	CASE
		WHEN txn_type = 'deposit'
			THEN txn_amount
		ELSE
			-1*txn_amount
	END AS txn_amount
FROM Eight_Week_Challenge_4..customer_transactions
), closing_balance_month(customer_id, month_number, closing_balance) AS
(
SELECT 
	DISTINCT customer_id, 
	month_number, 
	SUM(txn_amount) OVER(PARTITION BY month_number, customer_id) AS closing_balance
FROM amount_before_cal
), last_month_balance(customer_id, month_number, last_closing_balance) AS
(
SELECT 
	DISTINCT closing_balance_month.customer_id, 
	closing_balance_month.month_number, 
	closing_balance_month.closing_balance
FROM
(
SELECT 
	customer_id, 
	month_number, 
	closing_balance, 
	MAX(month_number) OVER(PARTITION BY customer_id) AS last_month
FROM closing_balance_month
) AS temp
	INNER JOIN closing_balance_month ON closing_balance_month.customer_id = temp.customer_id AND 
			   closing_balance_month.month_number = temp.last_month 
), first_month_balance(customer_id, month_number, first_closing_balance) AS
(
SELECT 
	DISTINCT closing_balance_month.customer_id, 
	closing_balance_month.month_number, 
	closing_balance_month.closing_balance
FROM
(
SELECT 
	customer_id, 
	month_number, 
	closing_balance, 
	MIN(month_number) OVER(PARTITION BY customer_id) AS first_month
FROM closing_balance_month
) AS temp
	INNER JOIN closing_balance_month ON closing_balance_month.customer_id = temp.customer_id AND 
			   closing_balance_month.month_number = temp.first_month 
)

SELECT  
	CONCAT(CAST((SUM(CASE
		WHEN first_month_balance.first_closing_balance * 1.05 < last_month_balance.last_closing_balance
			THEN 1
		ELSE NULL
	END)*1.0 / COUNT(DISTINCT first_month_balance.customer_id))*100 AS DECIMAL(18,2)), '%') AS required_percentage
FROM first_month_balance
	INNER JOIN last_month_balance ON first_month_balance.customer_id = last_month_balance.customer_id
 

/* --------------------
 C. Data Allocation Challenge
   --------------------*/

-- 1. running customer balance column that includes the impact at each transaction

WITH amount_calc(customer_id, txn_date, txn_type, txn_amount) AS
(
SELECT 
	customer_id, 
	txn_date, 
	txn_type, 
	CASE
		WHEN txn_type = 'deposit'
			THEN txn_amount
		ELSE	
			txn_amount*-1
	END AS txn_amount
FROM Eight_Week_Challenge_4..customer_transactions
)

SELECT 
	customer_id, 
	txn_date, 
	txn_type, 
	txn_amount, 
	SUM(txn_amount) OVER(PARTITION BY customer_id ORDER BY txn_date ASC) AS running_customer_balance
FROM amount_calc

-- 2. customer balance at the end of each month

WITH month_amount_calc(customer_id, month_number, txn_type, txn_amount) AS
(
SELECT 
	customer_id, 
	DATEPART(month, txn_date) AS month_number, 
	txn_type, 
	CASE
		WHEN txn_type = 'deposit'
			THEN txn_amount
		ELSE	
			txn_amount*-1
	END AS txn_amount
FROM Eight_Week_Challenge_4..customer_transactions
)

SELECT 
	DISTINCT customer_id, 
	month_number, 
	SUM(txn_amount) OVER(PARTITION BY month_number, customer_id) AS month_end_balance
FROM month_amount_calc

-- 3. minimum, average and maximum values of the running balance for each customer

WITH amount_calc(customer_id, txn_date, txn_type, txn_amount) AS
(
SELECT 
	customer_id, 
	txn_date, 
	txn_type, 
	CASE
		WHEN txn_type = 'deposit'
			THEN txn_amount
		ELSE	
			txn_amount*-1
	END AS txn_amount
FROM Eight_Week_Challenge_4..customer_transactions
), running_balance(customer_id, txn_date, txn_type, txn_amount, running_customer_balance) AS
(
SELECT 
	customer_id, 
	txn_date, 
	txn_type, 
	txn_amount, 
	SUM(txn_amount) OVER(PARTITION BY customer_id ORDER BY txn_date ASC) AS running_customer_balance
FROM amount_calc
)

SELECT 
	DISTINCT customer_id, 
	MAX(running_customer_balance) OVER(PARTITION BY customer_id) AS max_running_balance, 
	MIN(running_customer_balance) OVER(PARTITION BY customer_id) AS min_running_balance,
	AVG(running_customer_balance) OVER(PARTITION BY customer_id) AS avg_running_balance
FROM running_balance