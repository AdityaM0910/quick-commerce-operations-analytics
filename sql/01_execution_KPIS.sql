select * 
from orders;

-- TOTAL ORDERS
SELECT COUNT(*) as total_orders
FROM orders;

-- TOTAL COMPLETED ORDERS
SELECT COUNT(*) AS TOTAL_COMPLETED_ORDERS
FROM orders 
WHERE order_status = 'Delivered';

-- TOTAL CANCELLED ORDERS
SELECT COUNT(*) AS TOTAL_CANCELLED_ORDERS
FROM orders
WHERE order_status = 'Cancelled';

--COMPLETION RATE 
SELECT 
	count(*) FILTER (WHERE order_status = 'Delivered') * 100 / NULLIF(count(*),0) as Completion_rate
FROM orders;

-- CANCELLATION RATE
SELECT 
	COUNT(*) FILTER (WHERE order_status = 'Cancelled')*100 / NULLIF(count(*),0) as Cancelation_rate
FROM orders;

-- TOTAL REVENUE
SELECT 
	ROUND(SUM(total_amount),2) AS TOTAL_REVENUE
FROM orders
WHERE order_status = 'Delivered';

-- AVERAGE ORDER VALUE 
SELECT 
	ROUND(AVG(total_amount),2) as AVERAGE_ORDER_VALUE
FROM orders
WHERE order_status = 'Delivered';
	
