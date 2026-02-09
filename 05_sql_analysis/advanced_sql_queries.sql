/*
Amazon India Seller Analytics
Phase: Advanced SQL Analysis
Focus: CTEs, Window Functions, Ranking, Trend Analysis
Audience: Interviewers, Senior Analysts, BI Teams
*/


/* =====================================================
   Q1: TOP 3 SELLERS BY REVENUE
   ===================================================== */

WITH seller_revenue AS (
    SELECT
        s.seller_id,
        s.seller_name,
        SUM(oi.net_price) AS total_revenue
    FROM sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY s.seller_id, s.seller_name
)
SELECT *,
       RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM seller_revenue
WHERE RANK() OVER (ORDER BY total_revenue DESC) <= 3;


/* =====================================================
   Q2: SELLER CONTRIBUTION PERCENTAGE
   ===================================================== */

WITH total_revenue AS (
    SELECT SUM(oi.net_price) AS overall_revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
)
SELECT
    s.seller_name,
    SUM(oi.net_price) AS seller_revenue,
    ROUND(
        SUM(oi.net_price) * 100.0 / (SELECT overall_revenue FROM total_revenue),
        2
    ) AS contribution_percentage
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY s.seller_name;


/* =====================================================
   Q3: SELLER RETURN RATE
   ===================================================== */

WITH seller_orders AS (
    SELECT
        seller_id,
        COUNT(DISTINCT order_item_id) AS total_items
    FROM order_items
    GROUP BY seller_id
),
seller_returns AS (
    SELECT
        oi.seller_id,
        COUNT(r.return_id) AS returned_items
    FROM order_items oi
    JOIN returns_refunds r ON oi.order_item_id = r.order_item_id
    GROUP BY oi.seller_id
)
SELECT
    s.seller_name,
    so.total_items,
    COALESCE(sr.returned_items, 0) AS returned_items,
    ROUND(
        COALESCE(sr.returned_items, 0) * 100.0 / so.total_items,
        2
    ) AS return_rate_percentage
FROM seller_orders so
JOIN sellers s ON so.seller_id = s.seller_id
LEFT JOIN seller_returns sr ON so.seller_id = sr.seller_id;


/* =====================================================
   Q4: MONTH-OVER-MONTH REVENUE TREND
   ===================================================== */

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        SUM(oi.net_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS mom_change
FROM monthly_revenue;


/* =====================================================
   Q5: FBA VS FBM PERFORMANCE
   ===================================================== */

SELECT
    p.fulfillment_type,
    COUNT(DISTINCT oi.order_item_id) AS items_sold,
    SUM(oi.net_price) AS total_revenue,
    ROUND(AVG(oi.net_price), 2) AS avg_item_value
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.fulfillment_type;


/* =====================================================
   Q6: LOW RATING – HIGH REVENUE SELLERS
   ===================================================== */

SELECT
    s.seller_name,
    sr.rating,
    SUM(oi.net_price) AS total_revenue
FROM sellers s
JOIN seller_ratings sr ON s.seller_id = sr.seller_id
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY s.seller_name, sr.rating
HAVING sr.rating < 3.5
ORDER BY total_revenue DESC;
