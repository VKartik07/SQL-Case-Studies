/* --------------------
   8 Week SQL Challenge [V Kartik]
   Case Study Questions [Week 2 - Pizza Runner]
   --------------------*/

/* --------------------
	 A. Pizza Metrics
   --------------------*/

-- 1. How many pizzas were ordered?

--SELECT COUNT(pizza_id) AS pizzas_ordered
--FROM Eight_Week_Challenge_2.dbo.customer_orders

-- 2. How many unique customer orders were made?

--SELECT COUNT(temp.pizza_id) AS unique_customer_orders
--FROM
--(
--SELECT DISTINCT customer_id, pizza_id
--FROM Eight_Week_Challenge_2.dbo.customer_orders
--) AS temp

-- 3. How many successful orders were delivered by each runner?

--SELECT runner_id, COUNT(order_id) AS successful_orders_delivered
--FROM Eight_Week_Challenge_2..runner_orders
--WHERE cancellation IS NULL
--GROUP BY runner_id

-- 4. How many of each type of pizza was delivered?

--SELECT 
--	CAST(pizza_names.pizza_name AS VARCHAR(10)) AS pizza_name, 
--	COUNT(runner_orders.runner_id) AS pizzas_delivered
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON customer_orders.order_id = runner_orders.order_id
--	LEFT JOIN Eight_Week_Challenge_2..pizza_names AS pizza_names ON customer_orders.pizza_id = pizza_names.pizza_id
--WHERE runner_orders.cancellation IS NULL

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
--SELECT 
--	customer_orders.customer_id, 
--	COUNT(CASE WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers' THEN 1 ELSE NULL END) AS meatlovers_count, 
--	COUNT(CASE WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian' THEN 1 ELSE NULL END) AS vegetarian_count
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..pizza_names AS pizza_names ON customer_orders.pizza_id = pizza_names.pizza_id
--GROUP BY customer_orders.customer_id

-- 6. What was the maximum number of pizzas delivered in a single order?

--SELECT TOP 1 customer_orders.order_id, COUNT(customer_orders.pizza_id) AS pizzas_delivered
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
--WHERE runner_orders.cancellation IS NULL
--GROUP BY customer_orders.order_id
--ORDER BY pizzas_delivered DESC

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

--SELECT 
--	customer_orders.customer_id,
--	COUNT(CASE WHEN exclusions IS NOT NULL THEN 1 WHEN extras IS NOT NULL THEN 1 ELSE NULL END) AS atleast_one_change, 
--	COUNT(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE NULL END) AS no_changes
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
--WHERE runner_orders.cancellation IS NULL
--GROUP BY customer_orders.customer_id

-- 8. How many pizzas were delivered that had both exclusions and extras?

--SELECT 
--	COUNT(CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE NULL END) AS both_changes_pizzas
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
--WHERE runner_orders.cancellation IS NULL

-- 9. What was the total volume of pizzas ordered for each hour of the day?

--SELECT 
--	DATEPART(year, order_time) AS year_number, 
--	DATEPART(month, order_time) AS month_number, 
--	DATEPART(day, order_time) AS day_number, 
--	DATEPART(hour, order_time) AS hour_number,
--	COUNT(pizza_id) AS total_volume_pizzas_ordered
--FROM Eight_Week_Challenge_2..customer_orders
--GROUP BY DATEPART(year, order_time), DATEPART(month, order_time), DATEPART(day, order_time), DATEPART(hour, order_time)

-- 10. What was the volume of orders for each day of the week?

--SELECT 
--	DATEPART(week, order_time) AS week_number, 
--	DATEPART(day, order_time) AS day_number, 
--	COUNT(pizza_id) AS total_volume_pizzas_delivered
--FROM Eight_Week_Challenge_2..customer_orders
--GROUP BY DATEPART(week, order_time), DATEPART(day, order_time)


/* --------------------
  B. Runner and Customer Experience
   --------------------*/

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

--SELECT 
	--DATEPART(week, registration_date) AS week_period_number, 
	--COUNT(runner_id) AS signed_up_runners
--FROM Eight_Week_Challenge_2..runners
--GROUP BY DATEPART(week, registration_date)

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

--WITH runnerTimeTaken(runner_id, time_taken)
--AS
--(
--SELECT runner_orders.runner_id, 
--	(
--	DATEPART(minute, runner_orders.pickup_time - customer_orders.order_time)*60 
--	+ (DATEPART(second, runner_orders.pickup_time) - DATEPART(second, customer_orders.order_time))
--	)*1.0/60 AS runner_time_taken
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON customer_orders.order_id = runner_orders.order_id
--WHERE runner_orders.cancellation is null
--)

--SELECT 
	--runner_id, 
	--AVG(time_taken) AS average_pickup_time
--FROM runnerTimeTaken
--GROUP BY runner_id

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

-- 4. What was the average distance travelled for each customer?

--SELECT 
--	customer_id, 
--	AVG(CAST(distance AS DEC)) AS avg_distance_travelled
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
--WHERE runner_orders.cancellation IS NULL
--GROUP BY customer_id

-- 5. What was the difference between the longest and shortest delivery times for all orders?

--WITH delivery_time(delivery_time)
--AS
--(SELECT  
--	(
--	DATEPART(minute, runner_orders.pickup_time - customer_orders.order_time)*60 
--	+ (DATEPART(second, runner_orders.pickup_time) - DATEPART(second, customer_orders.order_time))s
--	)*1.0/60
--	+duration AS delivery_time
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
--WHERE runner_orders.cancellation IS NULL
--)

--SELECT MAX(delivery_time) - MIN(delivery_time) AS required_difference
--FROM delivery_time

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

--SELECT 
	--runner_id, 
	--order_id, 
	--CAST(distance AS DEC)/(CAST(duration AS DEC)*1.0/60) AS average_speed
--FROM Eight_Week_Challenge_2..runner_orders
--WHERE cancellation IS NULL
--ORDER BY runner_id, order_id

-- Trend Observed: As each runner proceeds to the next order, the avergae speed more or less increases for the next order

-- 7. What is the successful delivery percentage for each runner?

--SELECT 
--	runner_id, 
--	CAST((COUNT(CASE WHEN cancellation IS NULL THEN 1 ELSE NULL END)*1.0/COUNT(order_id))*100 AS DECIMAL(18,2)) AS successfull_delivery_percentage
--FROM Eight_Week_Challenge_2..runner_orders
--GROUP BY runner_id

/* --------------------
  D. Pricing and Ratings
   --------------------*/

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

--SELECT 
--	SUM(CASE
--		WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers' 
--			THEN 12
--		WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian'
--			THEN 10
--	END) AS total_money_made
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..pizza_names AS pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id

-- 2. What if there was an additional $1 charge for any pizza extras? [Note: Add cheese is $1 extra]

-- To find the toppid_id of Cheese

--SELECT topping_id
--FROM Eight_Week_Challenge_2..pizza_toppings
--WHERE topping_name LIKE '%cheese%'

--SELECT
--	customer_orders.order_id,
--	pizza_names.pizza_name,
--	customer_orders.extras,
--	CASE 
--		WHEN extras IS NULL 
--			THEN 
--				CASE 
--					WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian'
--						THEN 10
--					WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers'
--						THEN 12
--				END
--			ELSE
--				CASE 
--					WHEN CHARINDEX('4', extras) > 0
--						THEN 
--							CASE 
--								WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian'
--									THEN LEN(REPLACE(REPLACE(extras, ',', ''), ' ', ''))*1 + 1 + 10
--								WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers'
--									THEN LEN(REPLACE(REPLACE(extras, ',', ''), ' ', ''))*1 + 1 + 12
--							END
--					ELSE 
--						CASE
--							WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian'
--									THEN LEN(REPLACE(REPLACE(extras, ',', ''), ' ', ''))*1 + 10
--								WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers'
--									THEN LEN(REPLACE(REPLACE(extras, ',', ''), ' ', ''))*1 + 12
--						END
--				END
--	END AS total_cost_of_pizza
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..pizza_names AS pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id


-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner,
-- how would you design an additional table for this new dataset - generate a schema for this new table and 
-- insert your own data for ratings for each successful customer order between 1 to 5.

--DROP TABLE IF EXISTS Eight_Week_Challenge_2.dbo.runner_ratings;
--CREATE TABLE Eight_Week_Challenge_2.dbo.runner_ratings (
--  "order_id" INTEGER,
--  "customer_id" INTEGER, 
--  "runner_id" INTEGER, 
--  "rating" INTEGER
--);

--INSERT INTO Eight_Week_Challenge_2.dbo.runner_ratings
--	("order_id", "customer_id", "runner_id", "rating")
--VALUES
--	(1, 101, 1, 3), 
--	(2, 101, 1, 4), 
--	(3, 102, 1, 3), 
--	(4, 103, 2, 4),
--	(5, 104, 3, 2),
--	(6, 101, 3, NULL), 
--	(7, 105, 2, 4), 
--	(8, 102, 2, 1), 
--	(9, 103, 2, NULL), 
--	(10, 104, 1, 5)

--SELECT *
--FROM Eight_Week_Challenge_2..runner_ratings


-- 4. Using your newly generated table - can you join all of the information together to form a table which has the 
-- following information for successful deliveries?
-- customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas

--WITH intial_report(
--	customer_id, 
--	order_id, 
--	runner_id, 
--	rating, 
--	order_time, 
--	pickup_time, 
--	time_between_order_pickup,
--	duration,
--	distance_covered, 
--	time_taken, 
--	total_pizzas_delivered)
--AS
--(
--SELECT 
--	customer_orders.customer_id, 
--	customer_orders.order_id, 
--	runner_orders.runner_id, 
--	runner_ratings.rating, 
--	customer_orders.order_time, 
--	runner_orders.pickup_time, 
--	CAST((DATEPART(minute, runner_orders.pickup_time - customer_orders.order_time)*60 
--	+ (DATEPART(second, runner_orders.pickup_time) - DATEPART(second, customer_orders.order_time))
--	)*1.0/60 AS DECIMAL(18,2)) AS time_between_order_pickup, 
--	runner_orders.duration,
--	SUM(CAST(runner_orders.distance AS DEC)) OVER(PARTITION BY runner_orders.runner_id) AS distance_covered, 
--	SUM(((CAST(runner_orders.duration AS DEC)*1.0)/60)) OVER(PARTITION BY runner_orders.runner_id) AS time_taken, 
--	COUNT(customer_orders.pizza_id) OVER(PARTITION BY customer_orders.customer_id) AS total_pizzas_delivered
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
--	LEFT JOIN Eight_Week_Challenge_2..runner_ratings AS runner_ratings ON runner_ratings.order_id = customer_orders.order_id 
--WHERE runner_orders.cancellation IS NULL
--)

--SELECT
--	customer_id, 
--	order_id, 
--	runner_id, 
--	rating, 
--	order_time, 
--	pickup_time, 
--	time_between_order_pickup,
--	duration,
--	CAST(distance_covered/time_taken AS DECIMAL(18,2)) AS average_speed, 
--	total_pizzas_delivered
--FROM intial_report

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - 
-- how much money does Pizza Runner have left over after these deliveries?

--SELECT 
--	SUM(CASE 
--		WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers' THEN 12 
--		WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian' THEN 10 END)
--	- SUM(0.30 * CAST(distance AS DEC)) AS money_left_after_delivery_cost
--FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
--	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
--	LEFT JOIN Eight_Week_Challenge_2..pizza_names AS pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id
