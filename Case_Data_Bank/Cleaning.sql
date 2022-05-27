-- The following query tells that there are issues in the data as there is 9999 in the year.
-- All the end dates have the same value. 
-- Hence, all these rows should be removed for better analysis of the given data

SELECT 
	end_date, DATEDIFF(day, start_date, end_date) AS node_duration
FROM Eight_Week_Challenge_4..customer_nodes
WHERE end_date LIKE '9999%'

-- In order to remove the above mentioned rows, we will execute the following query
DELETE FROM Eight_Week_Challenge_4..customer_nodes
WHERE end_date LIKE '9999%'