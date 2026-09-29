--AVERAGE DELIVERY TIME
SELECT
    ROUND( AVG(EXTRACT(EPOCH FROM (o.delivered_at - o.order_placed_at)) / 60),2) AS AVG_DELIVERY_TIME_MINUTES
FROM orders o
WHERE o.order_status = 'Delivered'
  AND o.delivered_at IS NOT NULL;

-- AVERAGE ACTUAL DELIVERY TIME BY CITY
SELECT
	c.city_name,
	COUNT(order_id) as TOTAL_DELIVERIES,
	ROUND(AVG(EXTRACT(EPOCH FROM (o.delivered_at - o.order_placed_at))/60),2) as AVG_DELIVERY_TIME_MINUTES
FROM orders o
JOIN stores s
	on o.store_id = s.store_id
JOIN cities c
	on s.city_id = c.city_id
WHERE o.order_status ='Delivered'
	AND o.delivered_at IS NOT NULL
GROUP BY c.city_name
ORDER BY AVG_DELIVERY_TIME_MINUTES DESC;

--LATE DELIVERY RATE / SLA
SELECT
    COUNT(*) AS total_deliveries,
	COUNT(*) FILTER (WHERE d.is_late = FALSE) AS on_time_deliveries,
	COUNT(*) FILTER (WHERE d.is_late = TRUE) AS late_deliveries,
	ROUND(100.0 * COUNT(*) FILTER (WHERE d.is_late = TRUE) / NULLIF(COUNT(*), 0),2) AS late_delivery_rate_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE d.is_late = FALSE) / NULLIF(COUNT(*), 0),2) AS sla_compliance_pct
FROM deliveries d
JOIN orders o
    ON d.order_id = o.order_id
WHERE o.order_status = 'Delivered';

--SLA PERFORMANCE BY CITY 
SELECT
    c.city_name,
    COUNT(d.delivery_id) AS total_deliveries,
    COUNT(*) FILTER ( WHERE d.is_late = FALSE) AS on_time_deliveries,
	COUNT(*) FILTER ( WHERE d.is_late = TRUE) AS late_deliveries,
	ROUND(100.0 * COUNT(*) FILTER (WHERE d.is_late = FALSE) / NULLIF(COUNT(*), 0),2) AS sla_compliance_pct
FROM deliveries d
JOIN orders o
    ON d.order_id = o.order_id
JOIN stores s
    ON o.store_id = s.store_id
JOIN cities c
    ON s.city_id = c.city_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city_name
ORDER BY sla_compliance_pct ASC;