-- NULL Handling [Customer Orders Table]

--Replace null values (strings) with empty strings

UPDATE Eight_Week_Challenge_2.dbo.customer_orders
	SET 
		exclusions = REPLACE(exclusions, 'null', ''), 
		extras = REPLACE(extras, 'null', ''); 

--Replace empty strings with NULL

UPDATE Eight_Week_Challenge_2.dbo.customer_orders
	SET
		exclusions = NULLIF(exclusions, ''),
		extras = NULLIF(extras, '');

-- NULL Handling [Runner Orders Table]

-- Replace null values (strings) with empty strings

UPDATE Eight_Week_Challenge_2.dbo.runner_orders
	SET 
		cancellation = REPLACE(cancellation, 'null', ''), 
		distance = REPLACE(distance, 'null', ''),
		duration = REPLACE(duration, 'null', '');
		pickup_time = REPLACE(pickup_time, 'null', '')
		
-- Replace empty strings with NULL

UPDATE Eight_Week_Challenge_2.dbo.runner_orders
	SET
		distance = NULLIF(distance, ''),
		duration = NULLIF(duration, ''), 
		cancellation = NULLIF(cancellation, ''); 
		pickup_time = NULLIF(pickup_time, '');

-- Values Inconsistency Handling

UPDATE Eight_Week_Challenge_2.dbo.runner_orders
SET 
	distance = 
		CASE 
			WHEN CHARINDEX('k', distance) > 0
				THEN 
					REPLACE(distance, SUBSTRING(distance, CHARINDEX('k', distance), (LEN(distance) - CHARINDEX('k', distance))+1), '')
			ELSE
				distance
		END 	

UPDATE Eight_Week_Challenge_2.dbo.runner_orders
SET 
	duration = 
		CASE 
			WHEN CHARINDEX('m', duration) > 0
				THEN 
					REPLACE(duration, SUBSTRING(duration, CHARINDEX('m', duration), (LEN(duration) - CHARINDEX('m', duration))+1), '')
			ELSE
				duration
		END 