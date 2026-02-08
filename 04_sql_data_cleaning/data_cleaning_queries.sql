/*
Amazon India Seller Analytics
Phase: Data Cleaning
Purpose: Correct data quality issues identified during validation
Approach:
- Apply business rules
- Preserve analytical consistency
- Prepare clean views for BI consumption
*/

/* =====================================================
   CLEANING 1: SELLER GST & STATUS FIXES
   ===================================================== */

-- Mark missing GST numbers explicitly
UPDATE sellers
SET gst_number = 'PENDING_GST'
WHERE gst_registered = TRUE
  AND (gst_number IS NULL OR gst_number = '');

-- Force Professional sellers to GST registered
UPDATE sellers
SET gst_registered = TRUE
WHERE seller_type = 'Professional'
  AND gst_registered = FALSE;


/* =====================================================
   CLEANING 2: PRODUCT PRICING & CATEGORY
   ===================================================== */

-- Fix selling price greater than MRP
UPDATE products
SET selling_price = mrp
WHERE selling_price > mrp;

-- Fill missing category
UPDATE products
SET category = 'Unknown'
WHERE category IS NULL OR category = '';


/* =====================================================
   CLEANING 3: ORDER STATUS & REVENUE
   ===================================================== */

UPDATE orders
SET order_value = 0
WHERE order_status IN ('Cancelled', 'Returned');


/* =====================================================
   CLEANING 4: ORDER ITEMS REVENUE LOGIC
   ===================================================== */

-- Fix negative discounts
UPDATE order_items
SET discount = 0
WHERE discount < 0;

-- Recalculate net price correctly
UPDATE order_items
SET net_price = (quantity * item_price) - discount;

-- Zero out items for cancelled orders
UPDATE order_items oi
JOIN orders o ON oi.order_id = o.order_id
SET oi.net_price = 0
WHERE o.order_status = 'Cancelled';


/* =====================================================
   CLEANING 5: RETURNS & REFUNDS
   ===================================================== */

-- Cap refund amount at net price
UPDATE returns_refunds r
JOIN order_items oi ON r.order_item_id = oi.order_item_id
SET r.refund_amount = oi.net_price
WHERE r.refund_amount > oi.net_price;


/* =====================================================
   CLEANING 6: INVENTORY CORRECTIONS
   ===================================================== */

UPDATE inventory
SET stock_available = 0
WHERE stock_available < 0;


/* =====================================================
   CLEANING 7: SELLER RATINGS
   ===================================================== */

UPDATE seller_ratings
SET rating = 5
WHERE rating > 5;


/* =====================================================
   CLEANING 8: PAYMENTS & FEES
   ===================================================== */

-- Zero payout for cancelled orders
UPDATE payments_fees p
JOIN order_items oi ON p.order_item_id = oi.order_item_id
JOIN orders o ON oi.order_id = o.order_id
SET p.net_payout = 0
WHERE o.order_status = 'Cancelled';

-- Cap payout at net price
UPDATE payments_fees p
JOIN order_items oi ON p.order_item_id = oi.order_item_id
SET p.net_payout = oi.net_price
WHERE p.net_payout > oi.net_price;
