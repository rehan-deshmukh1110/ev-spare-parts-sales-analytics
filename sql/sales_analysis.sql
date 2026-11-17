-- EV Spare Parts Sales Analysis (Jun - Sep 2026)
-- Tables: orders, order_items, customers, cities, parts (loaded from the CSV files in data/)
-- net_amount = sale value of one order line after discount


-- 1. Total sales, number of orders and average order value
SELECT
    ROUND(SUM(oi.net_amount))                                 AS total_sales,
    COUNT(DISTINCT o.order_id)                                AS total_orders,
    ROUND(SUM(oi.net_amount) / COUNT(DISTINCT o.order_id))    AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;


-- 2. Sales by month
SELECT
    SUBSTR(o.order_date, 1, 7)    AS month,
    COUNT(DISTINCT o.order_id)    AS orders,
    ROUND(SUM(oi.net_amount))     AS sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY SUBSTR(o.order_date, 1, 7)
ORDER BY month;


-- 3. Sales by state
SELECT
    ci.state,
    ROUND(SUM(oi.net_amount))     AS sales
FROM order_items oi
JOIN orders o     ON oi.order_id = o.order_id
JOIN customers cu ON o.customer_id = cu.customer_id
JOIN cities ci    ON cu.city_id = ci.city_id
GROUP BY ci.state
ORDER BY sales DESC;


-- 4. Top 10 cities by sales
SELECT
    ci.city,
    ci.state,
    ROUND(SUM(oi.net_amount))     AS sales
FROM order_items oi
JOIN orders o     ON oi.order_id = o.order_id
JOIN customers cu ON o.customer_id = cu.customer_id
JOIN cities ci    ON cu.city_id = ci.city_id
GROUP BY ci.city, ci.state
ORDER BY sales DESC
LIMIT 10;


-- 5. Top 10 parts by sales
SELECT
    p.part_type,
    SUM(oi.quantity)              AS units_sold,
    ROUND(SUM(oi.net_amount))     AS sales
FROM order_items oi
JOIN parts p ON oi.part_id = p.part_id
GROUP BY p.part_type
ORDER BY sales DESC
LIMIT 10;


-- 6. Battery sales: 30Ah / 35Ah / 45Ah, LFP vs NMC
SELECT
    p.part_type                   AS battery,
    p.variant                     AS chemistry,
    SUM(oi.quantity)              AS units_sold,
    ROUND(SUM(oi.net_amount))     AS sales
FROM order_items oi
JOIN parts p ON oi.part_id = p.part_id
WHERE p.category = 'Battery'
GROUP BY p.part_type, p.variant
ORDER BY p.part_type, units_sold DESC;


-- 7. Orders by channel each month (WhatsApp Business vs Direct Call)
SELECT
    SUBSTR(order_date, 1, 7)      AS month,
    channel,
    COUNT(*)                      AS orders
FROM orders
GROUP BY SUBSTR(order_date, 1, 7), channel
ORDER BY month, channel;


-- 8. Sales by repair shop size (A = large, B = medium, C = small)
SELECT
    cu.tier,
    COUNT(DISTINCT cu.customer_id)   AS shops,
    ROUND(SUM(oi.net_amount))        AS sales
FROM order_items oi
JOIN orders o     ON oi.order_id = o.order_id
JOIN customers cu ON o.customer_id = cu.customer_id
GROUP BY cu.tier
ORDER BY cu.tier;


-- 9. Repair shops with no order in the last 30 days (last order before 1 Sep 2026)
SELECT
    cu.shop_name,
    ci.city,
    MAX(o.order_date)             AS last_order_date
FROM customers cu
JOIN cities ci ON cu.city_id = ci.city_id
JOIN orders o  ON cu.customer_id = o.customer_id
GROUP BY cu.shop_name, ci.city
HAVING MAX(o.order_date) < '2026-09-01'
ORDER BY last_order_date;
