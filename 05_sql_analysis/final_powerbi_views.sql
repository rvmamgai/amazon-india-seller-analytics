/*
===========================================================
Project: Amazon India – Seller & Operations Analytics
Phase  : Final Analytical Layer
Purpose: Business-ready SQL Views for Power BI
Author : Ravi
Notes  :
- Uses cleaned & validated data
- No raw tables exposed to BI
- One view = one analytical purpose
===========================================================
*/

USE amazon_india_analytics;

-----------------------------------------------------------
-- VIEW 1: ORDER FACT VIEW (CORE FACT TABLE FOR POWER BI)
-- Purpose:
--   - Central transactional table
--   - Base for most KPIs (Revenue, Orders, AOV, Trends)
-----------------------------------------------------------

CREATE OR REPLACE VIEW vw_order_fact AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.payment_method,
    o.order_value,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.quantity,
    oi.item_price,
    oi.discount,
    oi.net_price
FROM orders o
JOIN order_items oi
  ON o.order_id = oi.order_id;


-----------------------------------------------------------
-- VIEW 2: SELLER PERFORMANCE VIEW
-- Purpose:
--   - Seller-level revenue & profitability
--   - Used for Top/Bottom seller analysis
-----------------------------------------------------------

CREATE OR REPLACE VIEW vw_seller_performance AS
SELECT
    s.seller_id,
    s.seller_name,
    s.seller_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.net_price) AS total_revenue,
    SUM(pf.net_payout) AS seller_payout,
    SUM(oi.net_price) - SUM(pf.net_payout) AS amazon_margin
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
JOIN payments_fees pf ON oi.order_item_id = pf.order_item_id
WHERE o.order_status = 'Delivered'
GROUP BY
    s.seller_id,
    s.seller_name,
    s.seller_state;


-----------------------------------------------------------
-- VIEW 3: CATEGORY PERFORMANCE VIEW
-- Purpose:
--   - Category-wise revenue & fee contribution
--   - Helps identify high-margin categories
-----------------------------------------------------------

CREATE OR REPLACE VIEW vw_category_performance AS
SELECT
    p.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.net_price) AS total_revenue,
    SUM(pf.amazon_commission) AS total_commission,
    SUM(pf.net_payout) AS seller_payout
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
JOIN payments_fees pf ON oi.order_item_id = pf.order_item_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category;


-----------------------------------------------------------
-- VIEW 4: RETURNS ANALYSIS VIEW
-- Purpose:
--   - Return rate & refund impact by category
--   - Quality and operational risk analysis
-----------------------------------------------------------

CREATE OR REPLACE VIEW vw_returns_analysis AS
SELECT
    p.category,
    COUNT(r.return_id) AS total_returns,
    SUM(r.refund_amount) AS total_refund_amount,
    COUNT(DISTINCT oi.order_item_id) AS items_sold,
    ROUND(
        COUNT(r.return_id) * 100.0 /
        COUNT(DISTINCT oi.order_item_id),
        2
    ) AS return_rate_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN returns_refunds r ON oi.order_item_id = r.order_item_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category;


-----------------------------------------------------------
-- VIEW 5: INVENTORY RISK VIEW
-- Purpose:
--   - Stock health monitoring
--   - Identifies low stock & out-of-stock products
-----------------------------------------------------------

CREATE OR REPLACE VIEW vw_inventory_risk AS
SELECT
    i.product_id,
    p.product_name,
    i.seller_id,
    i.stock_available,
    i.reorder_level,
    CASE
        WHEN i.stock_available <= 0 THEN 'Out of Stock'
        WHEN i.stock_available < i.reorder_level THEN 'Low Stock'
        ELSE 'Healthy'
    END AS inventory_status
FROM inventory i
JOIN products p ON i.product_id = p.product_id;


-----------------------------------------------------------
-- VIEW 6: DAILY TIME-SERIES METRICS
-- Purpose:
--   - Revenue & order trends over time
--   - Used for line charts in Power BI
-----------------------------------------------------------

CREATE OR REPLACE VIEW vw_daily_metrics AS
SELECT
    o.order_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.net_price) AS daily_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY o.order_date;


-----------------------------------------------------------
-- FINAL CHECK: LIST ALL CREATED VIEWS
-----------------------------------------------------------

-- Run this to verify all views exist
-- SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';
