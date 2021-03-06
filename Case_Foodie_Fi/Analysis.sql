/* --------------------
   8 Week SQL Challenge [V Kartik]
   Case Study Questions [Week 3 - Foodie Fi]
   --------------------*/

/* --------------------
	A. Customer Journey
   --------------------*/

-- Based off the customers provided in the subscriptions table, 
-- write a brief description about any 8 customerís onboarding journey.

-- Try to keep it as short as possible - you may also want to run some sort of join to make your 
-- explanations a bit easier!

-- Customer ID: 11

SELECT *
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON subscriptions.plan_id = plans.plan_id
WHERE subscriptions.customer_id = 11

-- The customer took the free trial subscription for one week and once that got over, 
-- they cancelled their subscription

-- Customer ID: 1

SELECT *
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON subscriptions.plan_id = plans.plan_id
WHERE subscriptions.customer_id = 1

-- The customer took the free trial subscription for one week and once that got over,
-- they decided to start with the basic plan on a monthly basis

-- Customer ID: 2

SELECT *
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON subscriptions.plan_id = plans.plan_id
WHERE subscriptions.customer_id = 2

-- The customer took the free trial subscription for one week and once that got over,
-- they decided to start with the pro plan on a annual basis

-- Customer ID: 13

SELECT *
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON subscriptions.plan_id = plans.plan_id
WHERE subscriptions.customer_id = 13

-- The customer took the free trial subscription for one week and once that got over,
-- they decided to start with the basic plan on a monthly basis. The susbcriber sticked to this plan for 
-- 3 months and then upgraded the plan to pro on a monthly basis. 

-- Customer ID: 15

SELECT *
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON subscriptions.plan_id = plans.plan_id
WHERE subscriptions.customer_id = 15

-- The customer took the free trial subscription for one week and once that got over,
-- they decided to start with the pro plan on a monthly basis. They sticked to this plan for a 
-- month and then decided to cancel the subscription only. 

-- Customer ID: 16

SELECT *
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON subscriptions.plan_id = plans.plan_id
WHERE subscriptions.customer_id = 16

-- The customer took the free trial subscription for one week and once that got over,
-- they decided to start with the basic plan on a monthly basis. They sticked to this plan
-- for 4 months and then upgraded the plan to pro on a annual basis. 

-- Customer ID: 18

SELECT *
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON subscriptions.plan_id = plans.plan_id
WHERE subscriptions.customer_id = 18

-- The customer took the free trial subscription for one week and once that got over,
-- they decided to start with the pro plan on a monthly basis

-- Customer ID: 19

SELECT *
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON subscriptions.plan_id = plans.plan_id
WHERE subscriptions.customer_id = 19

-- The customer took the free trial subscription for one week and once that got over,
-- they decided to start with the pro plan on a monthly basis. They sticked to this plan for 2
-- months and then upgraded the plan to pro on a annual basis


/* --------------------
  B. Data Analysis Questions
   --------------------*/

-- 1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM Eight_Week_Challenge_3..subscriptions

-- 2. What is the monthly distribution of trial plan start_date values for our dataset 
-- - use the start of the month as the group by value

WITH group_dates(plan_name, first_date_month)
AS
(
SELECT
	plans.plan_name, 
	CASE 
		WHEN LEN(DATEPART(month, start_date)) = 1 
			THEN CONCAT(DATEPART(year, start_date),'-0',DATEPART(month, start_date), '-01') 
		ELSE
			CONCAT(DATEPART(year, start_date),'-',DATEPART(month, start_date), '-01') 
	END AS first_date_month

FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON plans.plan_id = subscriptions.plan_id
)

SELECT first_date_month, COUNT(plan_name) AS monthly_trial_distribution
FROM group_dates
WHERE plan_name = 'trial'
GROUP BY first_date_month

-- 3. What plan start_date values occur after the year 2020 for our dataset? 
-- Show the breakdown by count of events for each plan_name

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
	COUNT(CASE
		WHEN plans.plan_name = 'churn' 
			THEN 1 
		ELSE NULL END) AS churn_count, 
	CAST(((COUNT(CASE
		WHEN plans.plan_name = 'churn' 
			THEN 1 
		ELSE NULL END)*1.0 / COUNT(DISTINCT subscriptions.customer_id))*100) AS DECIMAL(18,1)) AS churn_percentage
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON plans.plan_id = subscriptions.plan_id

-- 5. How many customers have churned straight after their initial free trial - 
-- what percentage is this rounded to the nearest whole number?

WITH after_free_trial_plan(customer_id, plan_id, start_date, plan_after_free_trial)
AS
(
SELECT *, LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date ASC) AS plan_after_free_trial
FROM Eight_Week_Challenge_3..subscriptions
)

SELECT 
	CAST(((
	COUNT(CASE 
			WHEN plan_id = 0 AND plan_after_free_trial = 4 
				THEN 1 
			ELSE 
				NULL 
			END)*1.0/COUNT(CASE WHEN plan_id = 0 THEN 1 ELSE NULL END))*100) AS DECIMAL(18,0)) AS after_free_churn_percentage 
FROM after_free_trial_plan

-- 6. What is the number and percentage of customer plans, straight after their initial free trial?

WITH after_free_trial_plan(customer_id, plan_id, start_date, plan_after_free_trial)
AS
(
SELECT *, LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date ASC) AS plan_after_free_trial
FROM Eight_Week_Challenge_3..subscriptions
)

SELECT 'Churn' AS Plan_Type, 
	COUNT(CASE 
			WHEN plan_id = 0 AND plan_after_free_trial = 4 
				THEN 1 
			ELSE 
				NULL 
			END) AS plan_count,
	CAST(((COUNT(CASE 
			WHEN plan_id = 0 AND plan_after_free_trial = 4 
				THEN 1 
			ELSE 
				NULL 
			END)*1.0/COUNT(CASE WHEN plan_id =0 THEN 1 ELSE NULL END))*100) AS DECIMAL(18,0)) AS plan_percentage
FROM after_free_trial_plan
UNION
SELECT 'Basic - Monthly' AS Plan_Type, 
	COUNT(CASE 
			WHEN plan_id = 0 AND plan_after_free_trial = 1
				THEN 1 
			ELSE 
				NULL 
			END) AS plan_count,
	CAST(((COUNT(CASE 
			WHEN plan_id = 0 AND plan_after_free_trial = 1 
				THEN 1 
			ELSE 
				NULL 
			END)*1.0/COUNT(CASE WHEN plan_id =0 THEN 1 ELSE NULL END))*100) AS DECIMAL(18,0)) AS plan_percentage
FROM after_free_trial_plan
UNION
SELECT 'Pro - Monthly' AS Plan_Type, 
	COUNT(CASE 
			WHEN plan_id = 0 AND plan_after_free_trial = 2
				THEN 1 
			ELSE 
				NULL 
			END) AS plan_count,
	CAST(((COUNT(CASE 
			WHEN plan_id = 0 AND plan_after_free_trial = 2 
				THEN 1 
			ELSE 
				NULL 
			END)*1.0/COUNT(CASE WHEN plan_id =0 THEN 1 ELSE NULL END))*100) AS DECIMAL(18,0)) AS plan_percentage
FROM after_free_trial_plan
UNION
SELECT 'Pro - Annually' AS Plan_Type, 
	COUNT(CASE 
			WHEN plan_id = 0 AND plan_after_free_trial = 3
				THEN 1 
			ELSE 
				NULL 
			END) AS plan_count,
	CAST(((COUNT(CASE 
			WHEN plan_id = 0 AND plan_after_free_trial = 3 
				THEN 1 
			ELSE 
				NULL 
			END)*1.0/COUNT(CASE WHEN plan_id =0 THEN 1 ELSE NULL END))*100) AS DECIMAL(18,0)) AS plan_percentage
FROM after_free_trial_plan

-- 7. What is the number and percentage of customer plans after their initial free trial?

SELECT 
	'Churn' AS plan_type, 
	COUNT(CASE WHEN subscriptions.plan_id = 4 THEN 1 ELSE NULL END) AS plan_count,
	CAST(((COUNT(CASE WHEN subscriptions.plan_id = 4 THEN 1 ELSE NULL END)*1.0/
	COUNT(subscriptions.customer_id))*100) AS DECIMAL(18,2)) AS plan_percentage
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON plans.plan_id = subscriptions.plan_id
WHERE subscriptions.plan_id !=0
UNION
SELECT 
	'Basic-Monthly' AS plan_type,  
	COUNT(CASE WHEN subscriptions.plan_id = 1 THEN 1 ELSE NULL END) AS plan_count,
	CAST(((COUNT(CASE WHEN subscriptions.plan_id = 1 THEN 1 ELSE NULL END)*1.0/
	COUNT(subscriptions.customer_id))*100) AS DECIMAL(18,2)) AS plan_percentage
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON plans.plan_id = subscriptions.plan_id
WHERE subscriptions.plan_id !=0
UNION
SELECT 
	'Pro-Monthly' AS plan_type, 
	COUNT(CASE WHEN subscriptions.plan_id = 2 THEN 1 ELSE NULL END) AS plan_count,
	CAST(((COUNT(CASE WHEN subscriptions.plan_id = 2 THEN 1 ELSE NULL END)*1.0/
	COUNT(subscriptions.customer_id))*100) AS DECIMAL(18,2)) AS plan_percentage
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON plans.plan_id = subscriptions.plan_id
WHERE subscriptions.plan_id !=0
UNION
SELECT 
	'Pro-Annual' AS plan_type,  
	COUNT(CASE WHEN subscriptions.plan_id = 3 THEN 1 ELSE NULL END) AS plan_count,
	CAST(((COUNT(CASE WHEN subscriptions.plan_id = 3 THEN 1 ELSE NULL END)*1.0/
	COUNT(subscriptions.customer_id))*100) AS DECIMAL(18,2)) AS plan_percentage
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON plans.plan_id = subscriptions.plan_id
WHERE subscriptions.plan_id !=0

-- 8. How many customers have upgraded to an annual plan in 2020?

-- Using a simple count

--SELECT COUNT(CASE WHEN subscriptions.plan_id = 3 THEN 1 ELSE NULL END) AS annual_plan_upgraded_people
--FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
--	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON plans.plan_id = subscriptions.plan_id
--WHERE subscriptions.start_date > '2020-01-01' AND subscriptions.start_date < '2020-12-31'

-- Using CTE and Window Functions
WITH next_plan(customer_id, plan_id, start_date, next_plan_id)
AS
(
SELECT 
	subscriptions.customer_id, 
	subscriptions.plan_id, 
	subscriptions.start_date,
	LEAD(subscriptions.plan_id) OVER (PARTITION BY subscriptions.customer_id ORDER BY subscriptions.start_date ASC) AS next_plan_id
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON plans.plan_id = subscriptions.plan_id
WHERE subscriptions.start_date > '2020-01-01' AND subscriptions.start_date < '2020-12-31'
)

SELECT 
	COUNT(CASE WHEN plan_id = 0 AND next_plan_id = 3 THEN 1 ELSE NULL END) AS from_free_to_annual, 
	COUNT(CASE WHEN plan_id = 1 AND next_plan_id = 3 THEN 1 ELSE NULL END) AS from_basic_to_annual, 
	COUNT(CASE WHEN plan_id = 2 AND next_plan_id = 3 THEN 1 ELSE NULL END) AS from_pro_monthly_to_annual 
FROM next_plan

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH last_plan(customer_id, start_date, last_plan_id)
AS
(

SELECT 
	customer_id, 
	start_date,
	MAX(subscriptions.plan_id) OVER(PARTITION BY subscriptions.customer_id) AS last_plan_id	
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON plans.plan_id = subscriptions.plan_id
WHERE subscriptions.plan_id IN (0,1,2,3)
)

SELECT AVG(temp.day_diff) AS average_days_for_annual_upgradation
FROM
(
SELECT customer_id, DATEDIFF(day, MIN(start_date), MAX(start_date)) AS day_diff
FROM last_plan
WHERE last_plan_id = 3
GROUP BY customer_id
) AS temp

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH next_plan(customer_id, plan_id, start_date, next_plan_id)
AS
(
SELECT 
	subscriptions.customer_id, 
	subscriptions.plan_id, 
	subscriptions.start_date,
	LEAD(subscriptions.plan_id) OVER (PARTITION BY subscriptions.customer_id ORDER BY subscriptions.start_date ASC) AS next_plan_id
FROM Eight_Week_Challenge_3..subscriptions AS subscriptions
	LEFT JOIN Eight_Week_Challenge_3..plans AS plans ON plans.plan_id = subscriptions.plan_id
WHERE subscriptions.start_date > '2020-01-01' AND subscriptions.start_date < '2020-12-31'
)

SELECT COUNT(*) AS required_number
FROM next_plan
WHERE plan_id = 2 AND next_plan_id = 1