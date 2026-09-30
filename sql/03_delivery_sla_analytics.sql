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
FROM orders oAAC

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

--new overall sla 
SELECT
    COUNT(*) AS total_deliveries,
    SUM(CASE WHEN is_late THEN 1 ELSE 0 END) AS late_deliveries,
    ROUND(
        100.0 * SUM(CASE WHEN NOT is_late THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS sla_compliance_pct
FROM deliveries;

--sla by city 
SELECT
    c.city_name,
    COUNT(d.order_id) AS deliveries,
    ROUND(
        100.0 * SUM(CASE WHEN NOT d.is_late THEN 1 ELSE 0 END)
        / COUNT(d.order_id),
        2
    ) AS sla_compliance_pct
FROM deliveries d
JOIN orders o
    ON d.order_id = o.order_id
JOIN customers cu
    ON o.customer_id = cu.customer_id
JOIN cities c
    ON cu.city_id = c.city_id
GROUP BY c.city_name
ORDER BY sla_compliance_pct;

--new period comparison 
SELECT
    o.order_placed_at::date AS order_date,
    COUNT(d.order_id) AS deliveries,
    ROUND(
        100.0 * SUM(CASE WHEN NOT d.is_late THEN 1 ELSE 0 END)
        / COUNT(d.order_id),
        2
    ) AS sla_compliance_pct
FROM deliveries d
JOIN orders o
    ON d.order_id = o.order_id
WHERE o.order_placed_at::date >= DATE '2026-01-31'
  AND o.order_placed_at::date <= DATE '2026-02-06'
GROUP BY o.order_placed_at::date
ORDER BY o.order_placed_at::date;

--sla new one 31 jan to 6 feb 
SELECT
    c.city_name,
    COUNT(d.order_id) AS deliveries,
    ROUND(
        100.0 * SUM(CASE WHEN NOT d.is_late THEN 1 ELSE 0 END)
        / COUNT(d.order_id),
        2
    ) AS sla_compliance_pct,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (o.delivered_at - o.out_for_delivery_at)) / 60),
        2
    ) AS avg_delivery_minutes
FROM deliveries d
JOIN orders o
    ON d.order_id = o.order_id
JOIN customers cu
    ON o.customer_id = cu.customer_id
JOIN cities c
    ON cu.city_id = c.city_id
WHERE o.order_placed_at::date >= DATE '2026-01-31'
  AND o.order_placed_at::date <= DATE '2026-02-06'
GROUP BY c.city_name
ORDER BY sla_compliance_pct;

--peak vs non peak 
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM o.order_placed_at) BETWEEN 18 AND 21
            THEN 'Peak'
        ELSE 'Non-Peak'
    END AS period,
    COUNT(d.order_id) AS deliveries,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (o.delivered_at - o.out_for_delivery_at)) / 60),
        2
    ) AS avg_delivery_minutes,
    ROUND(
        100.0 * SUM(CASE WHEN NOT d.is_late THEN 1 ELSE 0 END)
        / COUNT(d.order_id),
        2
    ) AS sla_compliance_pct
FROM deliveries d
JOIN orders o
    ON d.order_id = o.order_id
WHERE o.order_placed_at::date >= DATE '2026-01-31'
  AND o.order_placed_at::date <= DATE '2026-02-06'
GROUP BY 1
ORDER BY 1;

SELECT
    MIN(order_placed_at::date) AS first_order_date,
    MAX(order_placed_at::date) AS last_order_date,
    COUNT(*) AS total_orders
FROM orders;

SELECT
    order_placed_at::date AS order_date,
    COUNT(*) AS total_orders
FROM orders
WHERE order_placed_at::date >= DATE '2026-02-07'
  AND order_placed_at::date <= DATE '2026-02-28'
GROUP BY order_placed_at::date
ORDER BY order_date;

--latest sla of 59 days 
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN NOT is_late THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS sla_compliance_pct,
    COUNT(*) AS total_deliveries,
    SUM(CASE WHEN is_late THEN 1 ELSE 0 END) AS late_deliveries
FROM deliveries d
JOIN orders o ON d.order_id = o.order_id
WHERE o.order_placed_at::date >= DATE '2026-01-31'
  AND o.order_placed_at::date <= DATE '2026-02-28';