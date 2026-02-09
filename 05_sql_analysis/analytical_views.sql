/*
Amazon India Seller Analytics
Phase: Analytical Views
Purpose: Create reusable business-ready SQL views
Consumers: Power BI, Business Analysts, Stakeholders
*/


/* =====================================================
   VIEW 1: SELLER REVENUE PERFORMANCE
   ===================================================== */

CREATE VIEW vw_seller_revenue AS
SELECT
    s.seller_id,
    s.seller_name,
    s.seller_type,
    s.seller_city,
    s.seller_state,
    SUM(oi.net_price) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY
    s.seller_id,
    s.seller_name,
    s.seller_type,
    s.seller_city,
    s.seller_state;


/* =====================================================
   VIEW 2: CATEGORY SALES PERFORMANCE
   ===================================================== */

CREATE VIEW vw_category_sales AS
SELECT
    p.category,
    COUNT(DISTINCT oi.order_item_id) AS items_sold,
    SUM(oi.net_price) AS category_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category;

/* =====================================================
   VIEW 3: SELLER RETURN ANALYSIS
   ===================================================== */

CREATE VIEW vw_seller_returns AS
SELECT
    s.seller_id,
    s.seller_name,
    COUNT(r.return_id) AS total_returns,
    SUM(r.refund_amount) AS total_refund_amount
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN returns_refunds r ON oi.order_item_id = r.order_item_id
GROUP BY
    s.seller_id,
    s.seller_name;

/* =====================================================
   VIEW 4: INVENTORY RISK
   ===================================================== */

CREATE VIEW vw_inventory_risk AS
SELECT
    i.product_id,
    p.product_name,
    i.seller_id,
    i.stock_available,
    i.reorder_level,
    CASE
        WHEN i.stock_available = 0 THEN 'OUT_OF_STOCK'
        WHEN i.stock_available < i.reorder_level THEN 'LOW_STOCK'
        ELSE 'HEALTHY'
    END AS inventory_status
FROM inventory i
JOIN products p ON i.product_id = p.product_id;


/* =====================================================
   VIEW 5: SELLER RATING VS REVENUE
   ===================================================== */

CREATE VIEW vw_seller_rating_revenue AS
SELECT
    s.seller_id,
    s.seller_name,
    sr.rating,
    sr.total_reviews,
    SUM(oi.net_price) AS total_revenue
FROM sellers s
JOIN seller_ratings sr ON s.seller_id = sr.seller_id
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY
    s.seller_id,
    s.seller_name,
    sr.rating,
    sr.total_reviews;


/* =====================================================
   VIEW 6: SELLER PROFITABILITY
   ===================================================== */

CREATE VIEW vw_seller_profitability AS
SELECT
    s.seller_id,
    s.seller_name,
    SUM(pf.amazon_commission + pf.shipping_fee) AS total_fees_collected,
    SUM(oi.net_price) AS gross_revenue,
    SUM(oi.net_price) - SUM(pf.amazon_commission + pf.shipping_fee) AS net_margin
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN payments_fees pf ON oi.order_item_id = pf.order_item_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY
    s.seller_id,
    s.seller_name;





