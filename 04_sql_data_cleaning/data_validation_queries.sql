/*
Amazon India Seller Analytics
Phase: Data Validation
Purpose: Identify data quality and business rule violations
Note: No data is modified in this phase
*/

/* =====================================================
   VALIDATION 1: SELLER GST & ACCOUNT STATUS CHECKS
   ===================================================== */

-- Sellers marked as GST registered but GST number missing
SELECT seller_id, seller_name, gst_registered, gst_number
FROM sellers
WHERE gst_registered = TRUE
  AND (gst_number IS NULL OR gst_number = '');

-- Professional sellers without GST registration
SELECT seller_id, seller_name, seller_type, gst_registered
FROM sellers
WHERE seller_type = 'Professional'
  AND gst_registered = FALSE;

-- Suspended sellers still present in system
SELECT seller_id, seller_name, account_status
FROM sellers
WHERE account_status = 'Suspended';

/* =====================================================
   VALIDATION 2: PRODUCT PRICING & CATEGORY RULES
   ===================================================== */

-- Selling price greater than MRP
SELECT product_id, product_name, mrp, selling_price
FROM products
WHERE selling_price > mrp;

-- Products with missing category
SELECT product_id, product_name
FROM products
WHERE category IS NULL OR category = '';

-- Inactive products still listed
SELECT product_id, product_name, product_status
FROM products
WHERE product_status = 'Inactive';

/* =====================================================
   VALIDATION 3: ORDERS - STATUS VS REVENUE LOGIC
   ===================================================== */

-- Cancelled orders with non-zero order value
SELECT order_id, order_status, order_value
FROM orders
WHERE order_status = 'Cancelled'
  AND order_value > 0;

-- Returned orders still carrying revenue
SELECT order_id, order_status, order_value
FROM orders
WHERE order_status = 'Returned'
  AND order_value > 0;

/* =====================================================
   VALIDATION 4: ORDER ITEMS - CORE REVENUE LOGIC
   ===================================================== */

-- Net price mismatch calculation
SELECT 
    order_item_id,
    quantity,
    item_price,
    discount,
    net_price,
    (quantity * item_price - discount) AS expected_net_price
FROM order_items
WHERE net_price <> (quantity * item_price - discount);

-- Negative discounts
SELECT order_item_id, discount
FROM order_items
WHERE discount < 0;

-- Order items linked to cancelled orders
SELECT oi.order_item_id, o.order_status
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Cancelled';

/* =====================================================
   VALIDATION 4: ORDER ITEMS - CORE REVENUE LOGIC
   ===================================================== */

-- Net price mismatch calculation
SELECT 
    order_item_id,
    quantity,
    item_price,
    discount,
    net_price,
    (quantity * item_price - discount) AS expected_net_price
FROM order_items
WHERE net_price <> (quantity * item_price - discount);

-- Negative discounts
SELECT order_item_id, discount
FROM order_items
WHERE discount < 0;

-- Order items linked to cancelled orders
SELECT oi.order_item_id, o.order_status
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Cancelled';

/* =====================================================
   VALIDATION 5: RETURNS & REFUND LEAKAGE
   ===================================================== */

-- Refund amount greater than item net price
SELECT 
    r.return_id,
    r.refund_amount,
    oi.net_price
FROM returns_refunds r
JOIN order_items oi ON r.order_item_id = oi.order_item_id
WHERE r.refund_amount > oi.net_price;

-- Refunds for cancelled orders
SELECT r.return_id, o.order_status
FROM returns_refunds r
JOIN order_items oi ON r.order_item_id = oi.order_item_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Cancelled';

/* =====================================================
   VALIDATION 6: INVENTORY HEALTH
   ===================================================== */

-- Negative inventory
SELECT inventory_id, product_id, stock_available
FROM inventory
WHERE stock_available < 0;

-- Stock below reorder level
SELECT inventory_id, product_id, stock_available, reorder_level
FROM inventory
WHERE stock_available < reorder_level;

/* =====================================================
   VALIDATION 7: SELLER RATINGS RULES
   ===================================================== */

-- Ratings outside valid range
SELECT seller_id, rating
FROM seller_ratings
WHERE rating < 0 OR rating > 5;

/* =====================================================
   VALIDATION 8: PAYMENTS & PROFIT LEAKAGE (ADVANCED)
   ===================================================== */

-- Payout given for cancelled orders
SELECT p.payment_id, o.order_status
FROM payments_fees p
JOIN order_items oi ON p.order_item_id = oi.order_item_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Cancelled';

-- Net payout greater than item revenue
SELECT p.payment_id, p.net_payout, oi.net_price
FROM payments_fees p
JOIN order_items oi ON p.order_item_id = oi.order_item_id
WHERE p.net_payout > oi.net_price;
