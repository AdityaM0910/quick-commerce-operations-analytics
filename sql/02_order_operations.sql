-- DAILY ORDER VOLUME
SELECT 
	DATE(order_placed_at) as ORDER_DATE,
	COUNT(*) AS TOTAL_ORDERS
FROM orders
GROUP BY DATE(order_placed_at)
ORDER BY ORDER_DATE;

--ORDERS BY CITY
SELECT 
	c.city_name,
	count(o.order_id) as TOTAL_ORDERS
FROM orders o 
JOIN stores s
	ON o.store_id = s.store_id
JOIN cities c 
	ON s.city_id = c.city_id
GROUP BY c.city_name
ORDER BY TOTAL_ORDERS;

--ORDERS BY STORE
SELECT 
	s.store_id,
	s.store_name,
	COUNT(o.order_id) as TOTAL_ORDERS	
FROM orders o 
JOIN stores s
	ON o.store_id = s.store_id
GROUP BY s.store_id, s.store_name
ORDER BY TOTAL_ORDERS DESC;

--ORDER STATUS DISTRIBUTION
SELECT 
	order_status,
	COUNT(o.order_id) as TOTAL_ORDERS,
	 ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders o
GROUP BY order_status
ORDER BY TOTAL_ORDERS DESC;

--WEEKLY ORDER VOLUME
SELECT
    c.year,
    c.week_number,
    COUNT(o.order_id) AS total_orders,
	LAG(count(o.order_id),1) OVER (ORDER BY c.year, c.week_number) as previous_week_volume,
	ROUND(100.0 * (COUNT(o.order_id) - LAG(COUNT(o.order_id)) OVER (ORDER BY c.year, c.week_number))
        / NULLIF(LAG(COUNT(o.order_id)) OVER (ORDER BY c.year, c.week_number),0),2) AS wow_growth_pct
FROM orders o
JOIN calendar c
    ON DATE(o.order_placed_at) = c.calendar_date
GROUP BY c.year, c.week_number
ORDER BY c.year, c.week_number;
