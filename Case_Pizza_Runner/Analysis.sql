--/* --------------------
--   8 Week SQL Challenge [V Kartik]
--   Case Study Questions [Week 2 - Pizza Runner]
--   --------------------*/

--/* --------------------
--	 A. Pizza Metrics
--   --------------------*/

---- 1. How many pizzas were ordered?

SELECT COUNT(pizza_id) AS pizzas_ordered
FROM Eight_Week_Challenge_2.dbo.customer_orders

---- 2. How many unique customer orders were made?

SELECT COUNT(temp.pizza_id) AS unique_customer_orders
FROM
(
SELECT DISTINCT customer_id, pizza_id
FROM Eight_Week_Challenge_2.dbo.customer_orders
) AS temp

---- 3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(order_id) AS successful_orders_delivered
FROM Eight_Week_Challenge_2..runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id

---- 4. How many of each type of pizza was delivered?

SELECT 
	CAST(pizza_names.pizza_name AS VARCHAR(10)) AS pizza_name, 
	COUNT(runner_orders.runner_id) AS pizzas_delivered
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON customer_orders.order_id = runner_orders.order_id
	LEFT JOIN Eight_Week_Challenge_2..pizza_names AS pizza_names ON customer_orders.pizza_id = pizza_names.pizza_id
WHERE runner_orders.cancellation IS NULL

---- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
	customer_orders.customer_id, 
	COUNT(CASE WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers' THEN 1 ELSE NULL END) AS meatlovers_count, 
	COUNT(CASE WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian' THEN 1 ELSE NULL END) AS vegetarian_count
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..pizza_names AS pizza_names ON customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY customer_orders.customer_id

---- 6. What was the maximum number of pizzas delivered in a single order?

SELECT TOP 1 customer_orders.order_id, COUNT(customer_orders.pizza_id) AS pizzas_delivered
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY customer_orders.order_id
ORDER BY pizzas_delivered DESC

---- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
	customer_orders.customer_id,
	COUNT(CASE WHEN exclusions IS NOT NULL THEN 1 WHEN extras IS NOT NULL THEN 1 ELSE NULL END) AS atleast_one_change, 
	COUNT(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE NULL END) AS no_changes
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY customer_orders.customer_id

---- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT 
	COUNT(CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE NULL END) AS both_changes_pizzas
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
WHERE runner_orders.cancellation IS NULL

---- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT 
	DATEPART(year, order_time) AS year_number, 
	DATEPART(month, order_time) AS month_number, 
	DATEPART(day, order_time) AS day_number, 
	DATEPART(hour, order_time) AS hour_number,
	COUNT(pizza_id) AS total_volume_pizzas_ordered
FROM Eight_Week_Challenge_2..customer_orders
GROUP BY DATEPART(year, order_time), DATEPART(month, order_time), DATEPART(day, order_time), DATEPART(hour, order_time)

---- 10. What was the volume of orders for each day of the week?

SELECT 
	DATEPART(week, order_time) AS week_number, 
	DATEPART(day, order_time) AS day_number, 
	COUNT(pizza_id) AS total_volume_pizzas_delivered
FROM Eight_Week_Challenge_2..customer_orders
GROUP BY DATEPART(week, order_time), DATEPART(day, order_time)

--/* --------------------
--  B. Runner and Customer Experience
--   --------------------*/

---- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
	DATEPART(week, registration_date) AS week_period_number, 
	COUNT(runner_id) AS signed_up_runners
FROM Eight_Week_Challenge_2..runners
GROUP BY DATEPART(week, registration_date)

---- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH runnerTimeTaken(runner_id, time_taken)
AS
(
SELECT runner_orders.runner_id, 
	(
	DATEPART(minute, runner_orders.pickup_time - customer_orders.order_time)*60 
	+ (DATEPART(second, runner_orders.pickup_time) - DATEPART(second, customer_orders.order_time))
	)*1.0/60 AS runner_time_taken
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation is null
)

SELECT 
	runner_id, 
	AVG(time_taken) AS average_pickup_time
FROM runnerTimeTaken
GROUP BY runner_id

---- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

---- 4. What was the average distance travelled for each customer?

SELECT 
	customer_id, 
	AVG(CAST(distance AS DEC)) AS avg_distance_travelled
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY customer_id

---- 5. What was the difference between the longest and shortest delivery times for all orders?

WITH delivery_time(delivery_time)
AS
(SELECT  
	(
	DATEPART(minute, runner_orders.pickup_time - customer_orders.order_time)*60 
	+ (DATEPART(second, runner_orders.pickup_time) - DATEPART(second, customer_orders.order_time))s
	)*1.0/60
	+duration AS delivery_time
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
WHERE runner_orders.cancellation IS NULL
)

SELECT MAX(delivery_time) - MIN(delivery_time) AS required_difference
FROM delivery_time

---- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
	runner_id, 
	order_id, 
	CAST(distance AS DEC)/(CAST(duration AS DEC)*1.0/60) AS average_speed
FROM Eight_Week_Challenge_2..runner_orders
WHERE cancellation IS NULL
ORDER BY runner_id, order_id

---- Trend Observed: As each runner proceeds to the next order, the avergae speed more or less increases for the next order

---- 7. What is the successful delivery percentage for each runner?

SELECT 
	runner_id, 
	CAST((COUNT(CASE WHEN cancellation IS NULL THEN 1 ELSE NULL END)*1.0/COUNT(order_id))*100 AS DECIMAL(18,2)) AS successfull_delivery_percentage
FROM Eight_Week_Challenge_2..runner_orders
GROUP BY runner_id

--/* --------------------
--  C. Ingredient Optimisation
--   --------------------*/

---- 1. What are the standard ingredients for each pizza?

CREATE VIEW toppings 
AS
SELECT pizza_id, value AS topping_id
FROM Eight_Week_Challenge_2..pizza_recipes
	CROSS APPLY STRING_SPLIT(REPLACE(CAST(toppings AS VARCHAR), ' ', ''), ',')

SELECT CAST(toppings_names.topping_name AS VARCHAR) AS standard_ingredients
FROM toppings
	INNER JOIN Eight_Week_Challenge_2..pizza_toppings AS toppings_names ON toppings_names.topping_id = toppings.topping_id
WHERE toppings_names.topping_id IN 
(
SELECT topping_id
FROM toppings
WHERE pizza_id = 1

INTERSECT

SELECT topping_id
FROM toppings
WHERE pizza_id = 2
)
GROUP BY CAST(toppings_names.topping_name AS VARCHAR)

---- 2. What was the most commonly added extra?

SELECT topping_name
FROM Eight_Week_Challenge_2..pizza_toppings
WHERE topping_id IN 
(
	SELECT temp.topping_id
	FROM
	(
		SELECT TOP 1 value AS topping_id, COUNT(value) AS count_of_ingredients 
		FROM Eight_Week_Challenge_2..customer_orders
		CROSS APPLY STRING_SPLIT(REPLACE(CAST(extras AS VARCHAR), ' ', ''), ',')
		GROUP BY value
		ORDER BY count_of_ingredients DESC
	) AS temp
)

---- 3. What was the most common exclusion?

SELECT topping_name
FROM Eight_Week_Challenge_2..pizza_toppings
WHERE topping_id IN 
(
	SELECT temp.topping_id
	FROM
	(
		SELECT TOP 1 value AS topping_id, COUNT(value) AS count_of_ingredients 
		FROM Eight_Week_Challenge_2..customer_orders
		CROSS APPLY STRING_SPLIT(REPLACE(CAST(exclusions AS VARCHAR), ' ', ''), ',')
		GROUP BY value
		ORDER BY count_of_ingredients DESC
	) AS temp
)

---- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

--DROP FUNCTION IF EXISTS toppings_generator
CREATE FUNCTION toppings_generator(@topping_id NVARCHAR(10))
RETURNS VARCHAR(20) AS
BEGIN
	DECLARE @topping_names AS VARCHAR(20); 
	SET @topping_names = 
	(
		SELECT STRING_AGG(CAST(topping_name AS VARCHAR), ', ') AS topping_names
		FROM Eight_Week_Challenge_2..pizza_toppings
		WHERE topping_id IN 
		(
			SELECT value 
			FROM STRING_SPLIT(REPLACE(CAST(@topping_id AS VARCHAR), ' ', ''), ',')
		)
	)
	RETURN @topping_names
END;

SELECT 
	names.pizza_name, 
	orders.exclusions, 
	orders.extras, 
	CASE 
		WHEN orders.exclusions IS NULL AND orders.extras IS NULL
			THEN
				CASE 
					WHEN CAST(pizza_name AS VARCHAR) = 'Meatlovers'
						THEN 'Meat Lovers'
					ELSE
						'Vegetarian Lovers'
				END
		WHEN orders.exclusions IS NOT NULL AND orders.extras IS NOT NULL
			THEN 
				CASE 
					WHEN CAST(pizza_name AS VARCHAR) = 'Meatlovers'
						THEN 
						'Meat Lovers - Exclude '+dbo.toppings_generator(orders.exclusions)+' - Extra '+dbo.toppings_generator(orders.extras)
					ELSE
						'Vegetarian Lovers - Exclude '+dbo.toppings_generator(orders.exclusions)+' - Extra '+dbo.toppings_generator(orders.extras)
				END
		WHEN orders.exclusions IS NOT NULL AND orders.extras IS NULL
			THEN 
			CASE 
				WHEN CAST(pizza_name AS VARCHAR) = 'Meatlovers'
					THEN 
					'Meat Lovers - Exclude '+dbo.toppings_generator(orders.exclusions)
				ELSE
					'Vegetarian Lovers - Exclude '+dbo.toppings_generator(orders.exclusions)
			END
		WHEN orders.exclusions IS NULL AND orders.extras IS NOT NULL
			THEN 
			CASE 
				WHEN CAST(pizza_name AS VARCHAR) = 'Meatlovers'
					THEN 
					'Meat Lovers - Extra '+dbo.toppings_generator(orders.extras)
				ELSE
					'Vegetarian Lovers - Extra '+dbo.toppings_generator(orders.extras)
			END
		ELSE
			NULL
	END AS 'generated_format'
FROM Eight_Week_Challenge_2..customer_orders AS orders
	LEFT JOIN Eight_Week_Challenge_2..pizza_names AS names ON names.pizza_id = orders.pizza_id

---- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders
-- table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

--DROP FUNCTION IF EXISTS toppings_generator
CREATE FUNCTION toppings_count_generator(@pizza_id INT, @exclusions VARCHAR(10), @extras VARCHAR(10))
RETURNS VARCHAR(100) AS
BEGIN
	DECLARE @count_topping_names AS VARCHAR(100); 	
	WITH topping_exclusion(topping_id, topping_count) AS
	(
	SELECT temp.topping_id, COUNT(*) AS topping_count
	FROM
	(
		SELECT topping_id
		FROM toppings
		WHERE pizza_id = @pizza_id
		UNION ALL
		SELECT value 
		FROM STRING_SPLIT(REPLACE(CAST(@exclusions AS VARCHAR), ' ', ''), ',')
	) AS temp
	GROUP BY temp.topping_id
	HAVING COUNT(*) = 1
	), final_toppings AS
	(
	SELECT 
		temp.topping_id, COUNT(*) AS topping_count
	FROM
	(
	SELECT topping_id
	FROM topping_exclusion
	UNION ALL
	SELECT value 
	FROM STRING_SPLIT(REPLACE(CAST(@extras AS VARCHAR), ' ', ''), ',')
	) AS temp
	GROUP BY temp.topping_id
	), count_final_toppings(topping_name, generated_list) AS
	(
	SELECT names.topping_name, 
		CASE WHEN final_toppings.topping_count >=2 
				THEN CONCAT(final_toppings.topping_count, 'x', names.topping_name)
			ELSE
				names.topping_name
		END AS generated_list
	FROM final_toppings
		LEFT JOIN Eight_Week_Challenge_2..pizza_toppings AS names ON final_toppings.topping_id = names.topping_id
	)
	
	SELECT @count_topping_names = 
	(
		SELECT STRING_AGG(CAST(generated_list AS VARCHAR),', ')  WITHIN GROUP ( ORDER BY CAST(topping_name AS VARCHAR) ASC) 
		FROM count_final_toppings
	)
	
	RETURN @count_topping_names
END;

SELECT 
	pizza_id, 
	exclusions, 
	extras, 
	CASE
		WHEN pizza_id = 1
			THEN 'Meat Lovers: '+dbo.toppings_count_generator(pizza_id, exclusions, extras)
		ELSE
			'Vegetarian Lovers: '+dbo.toppings_count_generator(pizza_id, exclusions, extras)
	END AS generated_column
FROM Eight_Week_Challenge_2..customer_orders

---- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

CREATE VIEW delivered_pizzas AS
SELECT customer_orders.pizza_id, customer_orders.exclusions, customer_orders.extras
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
WHERE runner_orders.cancellation IS NULL

CREATE VIEW all_ingredients_id AS
SELECT topping_id
FROM toppings
WHERE pizza_id = 1
UNION
SELECT topping_id
FROM toppings
WHERE pizza_id = 2

DECLARE @pizza_1_count INT
DECLARE @pizza_2_count INT
SET @pizza_1_count = (SELECT COUNT(*) FROM delivered_pizzas WHERE pizza_id = 1 GROUP BY pizza_id)
SET @pizza_2_count = (SELECT COUNT(*) FROM delivered_pizzas WHERE pizza_id = 2 GROUP BY pizza_id);

WITH count_topping(pizza_id, topping_id, topping_count) AS
(
SELECT pizza_id,
	topping_id,
	COUNT(topping_id) OVER(PARTITION BY topping_id) AS topping_count
FROM toppings
), initial_count(pizza_id, topping_id, initial_topping_count, overall_topping_count) AS
(
SELECT  
	pizza_id,
	topping_id, 
	topping_count, 
	CASE 
		WHEN topping_count = 2 
			THEN @pizza_1_count + @pizza_2_count
		ELSE 
			CASE
				WHEN pizza_id = 1
					THEN @pizza_1_count
				ELSE
					@pizza_2_count
			END
	END AS overall_topping_count
FROM count_topping
), excluded_toppings_count(topping_id, excluded_count) AS
(
	SELECT value, COUNT(value) AS excluded_count
	FROM delivered_pizzas
	CROSS APPLY STRING_SPLIT(exclusions, ',')
	GROUP BY value
), extra_toppings_count(topping_id, extra_count) AS
(
	SELECT value, COUNT(value) AS extra_count
	FROM delivered_pizzas
	CROSS APPLY STRING_SPLIT(extras, ',')
	GROUP BY value
), final_extra_count(topping_id, extra_count) AS
(
	SELECT 
		DISTINCT toppings.topping_id, 
		CASE
			WHEN extra_count IS NULL 
				THEN 0
			ELSE
				extra_count
		END AS extra_count
	FROM toppings
		LEFT JOIN extra_toppings_count ON CAST(extra_toppings_count.topping_id AS INT) = CAST(toppings.topping_id AS INT)
), final_excluded_count(topping_id, exclusion_count) AS
(
SELECT 
	DISTINCT toppings.topping_id, 
	CASE
		WHEN excluded_count IS NULL 
			THEN 0
		ELSE
			excluded_count
	END AS exclusions_count
FROM toppings
	LEFT JOIN excluded_toppings_count ON CAST(excluded_toppings_count.topping_id AS INT) = CAST(toppings.topping_id AS INT)
)

SELECT 
	DISTINCT CAST(names.topping_name AS VARCHAR) AS topping_name, 
	initial_count.overall_topping_count + final_extra_count.extra_count - final_excluded_count.exclusion_count AS total_quantity_consumed
FROM initial_count
	INNER JOIN final_extra_count ON final_extra_count.topping_id  = initial_count.topping_id
	INNER JOIN final_excluded_count ON final_excluded_count.topping_id = initial_count.topping_id
	INNER JOIN Eight_Week_Challenge_2..pizza_toppings AS names ON names.topping_id = initial_count.topping_id
ORDER BY total_quantity_consumed DESC

--/* --------------------
--  D. Pricing and Ratings
--   --------------------*/

---- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT 
	SUM(CASE
		WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers' 
			THEN 12
		WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian'
			THEN 10
	END) AS total_money_made
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..pizza_names AS pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id

---- 2. What if there was an additional $1 charge for any pizza extras? [Note: Add cheese is $1 extra]

---- To find the toppid_id of Cheese

SELECT topping_id
FROM Eight_Week_Challenge_2..pizza_toppings
WHERE topping_name LIKE '%cheese%'

SELECT
	customer_orders.order_id,
	pizza_names.pizza_name,
	customer_orders.extras,
	CASE 
		WHEN extras IS NULL 
			THEN 
				CASE 
					WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian'
						THEN 10
					WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers'
						THEN 12
				END
			ELSE
				CASE 
					WHEN CHARINDEX('4', extras) > 0
						THEN 
							CASE 
								WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian'
									THEN LEN(REPLACE(REPLACE(extras, ',', ''), ' ', ''))*1 + 1 + 10
								WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers'
									THEN LEN(REPLACE(REPLACE(extras, ',', ''), ' ', ''))*1 + 1 + 12
							END
					ELSE 
						CASE
							WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian'
									THEN LEN(REPLACE(REPLACE(extras, ',', ''), ' ', ''))*1 + 10
								WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers'
									THEN LEN(REPLACE(REPLACE(extras, ',', ''), ' ', ''))*1 + 12
						END
				END
	END AS total_cost_of_pizza
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..pizza_names AS pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id


---- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner,
---- how would you design an additional table for this new dataset - generate a schema for this new table and 
---- insert your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS Eight_Week_Challenge_2.dbo.runner_ratings;
CREATE TABLE Eight_Week_Challenge_2.dbo.runner_ratings (
 "order_id" INTEGER,
 "customer_id" INTEGER, 
 "runner_id" INTEGER, 
 "rating" INTEGER
);

INSERT INTO Eight_Week_Challenge_2.dbo.runner_ratings
	("order_id", "customer_id", "runner_id", "rating")
VALUES
	(1, 101, 1, 3), 
	(2, 101, 1, 4), 
	(3, 102, 1, 3), 
	(4, 103, 2, 4),
	(5, 104, 3, 2),
	(6, 101, 3, NULL), 
	(7, 105, 2, 4), 
	(8, 102, 2, 1), 
	(9, 103, 2, NULL), 
	(10, 104, 1, 5)

SELECT *
FROM Eight_Week_Challenge_2..runner_ratings

---- 4. Using your newly generated table - can you join all of the information together to form a table which has the 
---- following information for successful deliveries?
---- customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas

WITH intial_report(
	customer_id, 
	order_id, 
	runner_id, 
	rating, 
	order_time, 
	pickup_time, 
	time_between_order_pickup,
	duration,
	distance_covered, 
	time_taken, 
	total_pizzas_delivered)
AS
(
SELECT 
	customer_orders.customer_id, 
	customer_orders.order_id, 
	runner_orders.runner_id, 
	runner_ratings.rating, 
	customer_orders.order_time, 
	runner_orders.pickup_time, 
	CAST((DATEPART(minute, runner_orders.pickup_time - customer_orders.order_time)*60 
	+ (DATEPART(second, runner_orders.pickup_time) - DATEPART(second, customer_orders.order_time))
	)*1.0/60 AS DECIMAL(18,2)) AS time_between_order_pickup, 
	runner_orders.duration,
	SUM(CAST(runner_orders.distance AS DEC)) OVER(PARTITION BY runner_orders.runner_id) AS distance_covered, 
	SUM(((CAST(runner_orders.duration AS DEC)*1.0)/60)) OVER(PARTITION BY runner_orders.runner_id) AS time_taken, 
	COUNT(customer_orders.pizza_id) OVER(PARTITION BY customer_orders.customer_id) AS total_pizzas_delivered
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
	LEFT JOIN Eight_Week_Challenge_2..runner_ratings AS runner_ratings ON runner_ratings.order_id = customer_orders.order_id 
WHERE runner_orders.cancellation IS NULL
)

SELECT
	customer_id, 
	order_id, 
	runner_id, 
	rating, 
	order_time, 
	pickup_time, 
	time_between_order_pickup,
	duration,
	CAST(distance_covered/time_taken AS DECIMAL(18,2)) AS average_speed, 
	total_pizzas_delivered
FROM intial_report

---- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - 
---- how much money does Pizza Runner have left over after these deliveries?

SELECT 
	SUM(CASE 
		WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Meatlovers' THEN 12 
		WHEN CAST(pizza_names.pizza_name AS VARCHAR(10)) = 'Vegetarian' THEN 10 END)
	- SUM(0.30 * CAST(distance AS DEC)) AS money_left_after_delivery_cost
FROM Eight_Week_Challenge_2..customer_orders AS customer_orders
	LEFT JOIN Eight_Week_Challenge_2..runner_orders AS runner_orders ON runner_orders.order_id = customer_orders.order_id
	LEFT JOIN Eight_Week_Challenge_2..pizza_names AS pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id

--/* --------------------
--    E. Bonus Questions
--   --------------------*/

---- If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
---- Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added 
---- to the Pizza Runner menu?

---- If we want to add a supreme pizza with all the toppings then, we need to do the following in order
---- for the database to remain consistent:
---- 1) Add the pizza into the pizza_names table with pizza_id as 3 and pizza_name as supreme
---- 2) Now we need to add the toppings information in the pizza_recipes table with pizza_id as 3 and toppings as
---- 1,2,3,4,5,6,7,8,9,10,11,12

INSERT INTO pizza_names
	("pizza_id", "pizza_name")
VALUES(3, 'Supreme');

INSERT INTO pizza_recipes
	("pizza_id", "toppings")
VALUES(3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');