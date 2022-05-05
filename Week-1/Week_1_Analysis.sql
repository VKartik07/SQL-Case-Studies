/* --------------------
   8 Week SQL Challenge [V Kartik]
   Case Study Questions [Week 1 - Danny's Diner]
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

CREATE VIEW AmountSpentByEachCustomer AS 
SELECT sales.customer_id, SUM(menu.price) AS total_amount
FROM Eight_Week_Challenge_1.dbo.sales AS sales
	LEFT JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id

-- 2. How many days has each customer visited the restaurant?

CREATE VIEW DaysVisitedByEachCustomer AS
SELECT sales.customer_id, COUNT(DISTINCT sales.order_date) AS days_visited
FROM Eight_Week_Challenge_1.dbo.sales AS sales
GROUP BY sales.customer_id

-- 3. What was the first item from the menu purchased by each customer?

-- Solution using First_Value

CREATE VIEW FirstItemPurchasedByEachCustomer_1 AS 
SELECT DISTINCT(sales.customer_id), FIRST_VALUE(menu.product_name) OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date ASC) AS first_item
FROM Eight_Week_Challenge_1.dbo.sales AS sales
	LEFT JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON sales.product_id = menu.product_id

-- Solution using Dense_Rank AND CTE

CREATE VIEW FirstItemPurchasedByEachCustomer_2 AS

WITH date_rank_table(customer_id, product_name, date_rank, row_rank)
AS 
(
	SELECT 
		sales.customer_id, 
		menu.product_name,
		DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date ASC) AS date_rank, 
		ROW_NUMBER() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date ASC) AS row_rank
	FROM Eight_Week_Challenge_1.dbo.sales AS sales
	LEFT JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON sales.product_id = menu.product_id
)

SELECT customer_id, product_name
FROM date_rank_table
WHERE date_rank = 1 AND row_rank = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

CREATE VIEW PopularItems AS
SELECT TOP 1 menu.product_name, COUNT(sales.product_id) AS times_purchased
FROM Eight_Week_Challenge_1.dbo.sales AS sales
	LEFT JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON sales.product_id = menu.product_id
GROUP BY menu.product_name

-- 5. Which item was the most popular for each customer?

CREATE VIEW PopularItemForEachCustomer AS
WITH product_count(customer_id, product_identification, count_of_products)
AS 
(
SELECT 
	sales.customer_id, 
	sales.product_id, 
	COUNT(sales.product_id) OVER(PARTITION BY sales.customer_id, sales.product_id) AS count_of_products 
FROM Eight_Week_Challenge_1.dbo.sales AS sales
)

SELECT temp.customer_id, temp.product_name
FROM 
(
SELECT  
	customer_id,  
	product_identification, 
	count_of_products,
	product_name, 
	DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY count_of_products DESC) AS count_product_rank, 
	ROW_NUMBER() OVER (PARTITION BY customer_id, product_identification ORDER BY count_of_products) AS row_numb 
FROM product_count 
	JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON menu.product_id = product_count.product_identification
) AS temp
WHERE temp.count_product_rank = 1 AND temp.row_numb = 1

-- 6. Which item was purchased first by the customer after they became a member?

CREATE VIEW FirstItemPurchasedAfterMember AS 
WITH after_member_date(customer_id, order_date, product_id)
AS
(
SELECT 
	sales.customer_id, 
	sales.order_date, 
	sales.product_id
FROM Eight_Week_Challenge_1.dbo.sales AS sales
	LEFT JOIN Eight_Week_Challenge_1.dbo.members AS members ON sales.customer_id = members.customer_id
WHERE sales.order_date > members.join_date
)

SELECT customer_id, product_name
FROM
(
SELECT *, DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date ASC) AS product_order
FROM after_member_date
) AS temp
	LEFT JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON menu.product_id = temp.product_id
WHERE temp.product_order = 1

-- 7. Which item was purchased just before the customer became a member?

CREATE VIEW ItemPurchasedJustBeforeMmeber AS
WITH before_member_date(customer_id, order_date, product_id)
AS
(
SELECT 
	sales.customer_id, 
	sales.order_date, 
	sales.product_id
FROM Eight_Week_Challenge_1.dbo.sales AS sales
	LEFT JOIN Eight_Week_Challenge_1.dbo.members AS members ON sales.customer_id = members.customer_id
WHERE sales.order_date < members.join_date
)

SELECT customer_id, product_name
FROM
(
SELECT *, DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS order_rank
FROM before_member_date
) AS temp
	LEFT JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON temp.product_id = menu.product_id
WHERE temp.order_rank = 1

-- 8. What is the total items and amount spent for each member before they became a member?

CREATE VIEW AfterMemberItemsPurchased AS
WITH before_member_date(customer_id, product_id)
AS
(
SELECT 
	sales.customer_id,  
	sales.product_id
FROM Eight_Week_Challenge_1.dbo.sales AS sales
	LEFT JOIN Eight_Week_Challenge_1.dbo.members AS members ON sales.customer_id = members.customer_id
WHERE sales.order_date < members.join_date
)

SELECT before_member_date.customer_id, COUNT(before_member_date.product_id) AS total_items, SUM(menu.price) AS amount_spent
FROM before_member_date
	LEFT JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON menu.product_id = before_member_date.product_id
GROUP BY before_member_date.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

CREATE VIEW PointsRecievedWithSushiPreference AS
WITH points(customer_id, points)
AS
(
SELECT customer_id, 
	CASE
		WHEN menu.product_name = 'sushi' THEN 2*10*menu.price
		ELSE 10*menu.price END AS points
FROM Eight_Week_Challenge_1.dbo.sales AS sales
	LEFT JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON sales.product_id = menu.product_id
)

SELECT customer_id, SUM(points) AS points
FROM points
GROUP BY customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? 

CREATE VIEW PointsRecievedForAllItemsTillJanuary AS
WITH points(customer_id, points)
AS 
(
SELECT sales.customer_id,  
	CASE 
		WHEN sales.order_date >= members.join_date AND sales.order_date <= DATEADD(WEEK, 1, members.join_date)
			THEN 2*10*price
		ELSE 10*price
	END AS points
FROM Eight_Week_Challenge_1.dbo.sales AS sales
	LEFT JOIN Eight_Week_Challenge_1.dbo.members AS members ON members.customer_id =  sales.customer_id
	LEFT JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON menu.product_id = sales.product_id
WHERE sales.order_date <= '2021-01-31' AND members.join_date IS NOT NULL
) 

SELECT customer_id, SUM(points) AS points
FROM points
GROUP BY customer_id

-- 11. Bonus Question - 1

CREATE VIEW MemberStatusForEachTransaction AS 
SELECT 
	sales.customer_id, 
	sales.order_date, 
	menu.product_name, 
	menu.price, 
	CASE 
		WHEN
			members.join_date IS NULL
				THEN 'N'
		ELSE 
			CASE
				WHEN sales.order_date < members.join_date 
					THEN 'N'
				ELSE 'Y'
			END
	END AS member
FROM Eight_Week_Challenge_1.dbo.sales AS sales
	LEFT JOIN Eight_Week_Challenge_1.dbo.members AS members ON sales.customer_id = members.customer_id
	LEFT JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON menu.product_id = sales.product_id

-- Bonus Question - 2

CREATE VIEW ProductRankingForMembers AS
WITH member_report(customer_id, order_date, product_name, price, member)
AS
(
SELECT 
	sales.customer_id, 
	sales.order_date, 
	menu.product_name, 
	menu.price, 
	CASE 
		WHEN
			members.join_date IS NULL
				THEN 'N'
		ELSE 
			CASE
				WHEN sales.order_date < members.join_date 
					THEN 'N'
				ELSE 'Y'
			END
	END AS member
FROM Eight_Week_Challenge_1.dbo.sales AS sales
	LEFT JOIN Eight_Week_Challenge_1.dbo.members AS members ON sales.customer_id = members.customer_id
	LEFT JOIN Eight_Week_Challenge_1.dbo.menu AS menu ON menu.product_id = sales.product_id
)

SELECT 
	*,
	CASE 
		WHEN member = 'N'
			THEN NULL
		ELSE
			DENSE_RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date ASC)
	END AS ranking
FROM member_report