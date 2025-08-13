CREATE VIEW geographic_base AS
SELECT 
    c.customer_id,
    c.customer_unique_id,
    c.customer_state,
    c.customer_city,
    c.customer_zip_code_prefix,
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    o.order_approved_at,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    op.payment_value,
    op.payment_type,
    s.seller_state,
    s.seller_city,
    s.seller_zip_code_prefix as seller_zip,
    pt.product_category_name_english,
    -- Calculate delivery metrics
    DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) as delivery_days,
    DATEDIFF(o.order_estimated_delivery_date, o.order_purchase_timestamp) as estimated_days,
    CASE 
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On Time'
        ELSE 'Delayed'
    END as delivery_status,
    -- Same state shipping flag
    CASE 
        WHEN c.customer_state = s.seller_state THEN 'Same State'
        ELSE 'Cross State'
    END as shipping_type
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN order_payment op ON o.order_id = op.order_id
JOIN seller_data s ON oi.seller_id = s.seller_id
LEFT JOIN product p ON oi.product_id = p.product_id
LEFT JOIN name_translation pt ON p.product_category_name = pt.product_category_name 
WHERE o.order_status = 'delivered';


-- state performance summary
SELECT 
    customer_state,
    COUNT(DISTINCT customer_id) as total_customers,
    COUNT(DISTINCT order_id) as total_orders,
    ROUND(SUM(payment_value), 2) as total_revenue,
    ROUND(AVG(payment_value), 2) as avg_order_value,
    ROUND(AVG(freight_value), 2) as avg_shipping_cost,
    ROUND(COUNT(order_id) * 1.0 / COUNT(DISTINCT customer_id), 2) as orders_per_customer,
    ROUND(AVG(delivery_days), 1) as avg_delivery_days,
    ROUND(AVG(estimated_days), 1) as avg_estimated_days,
    ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as on_time_delivery_pct,
    ROUND(SUM(CASE WHEN shipping_type = 'Same State' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as same_state_orders_pct
FROM geographic_base
GROUP BY customer_state
ORDER BY total_revenue DESC;

-- 2.2 State Market Share Analysis
WITH state_totals AS (
    SELECT 
        customer_state,
        SUM(payment_value) as state_revenue,
        COUNT(DISTINCT customer_id) as state_customers
    FROM geographic_base
    GROUP BY customer_state
),
overall_totals AS (
    SELECT 
        SUM(payment_value) as total_revenue,
        COUNT(DISTINCT customer_id) as total_customers
    FROM geographic_base
)
SELECT 
    st.customer_state,
    st.state_revenue,
    st.state_customers,
    ROUND(st.state_revenue * 100.0 / ot.total_revenue, 2) as revenue_share_pct,
    ROUND(st.state_customers * 100.0 / ot.total_customers, 2) as customer_share_pct,
    ROUND(st.state_revenue / st.state_customers, 2) as revenue_per_customer
FROM state_totals st
CROSS JOIN overall_totals ot
ORDER BY revenue_share_pct DESC;

-- city lvl analysis
SELECT 
    customer_state,
    customer_city,
    COUNT(DISTINCT customer_id) as customers,
    COUNT(DISTINCT order_id) as orders,
    ROUND(SUM(payment_value), 2) as revenue,
    ROUND(AVG(payment_value), 2) as avg_order_value,
    ROUND(AVG(freight_value), 2) as avg_shipping_cost,
    ROUND(AVG(delivery_days), 1) as avg_delivery_days,
    ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as on_time_pct
FROM geographic_base
GROUP BY customer_state, customer_city
HAVING COUNT(DISTINCT order_id) >= 10  -- Filter for cities with meaningful order volume
ORDER BY revenue DESC
LIMIT 30;


-- 5. SELLER GEOGRAPHIC DISTRIBUTION
-- =====================================================

-- 5.1 Seller Performance by State
SELECT 
    seller_state,
    COUNT(DISTINCT seller_id) as seller_count,
    COUNT(DISTINCT order_id) as total_orders,
    ROUND(SUM(payment_value), 2) as total_revenue,
    ROUND(AVG(payment_value), 2) as avg_order_value,
    ROUND(SUM(payment_value) / COUNT(DISTINCT seller_id), 2) as revenue_per_seller,
    ROUND(COUNT(order_id) * 1.0 / COUNT(DISTINCT seller_id), 2) as orders_per_seller
FROM geographic_base
GROUP BY seller_state
ORDER BY total_revenue DESC;

-- 5.2 Cross-State vs Local Sales by Seller State
SELECT 
    seller_state,
    SUM(CASE WHEN shipping_type = 'Same State' THEN payment_value ELSE 0 END) as local_sales,
    SUM(CASE WHEN shipping_type = 'Cross State' THEN payment_value ELSE 0 END) as cross_state_sales,
    ROUND(SUM(CASE WHEN shipping_type = 'Same State' THEN payment_value ELSE 0 END) * 100.0 / 
          SUM(payment_value), 1) as local_sales_pct,
    COUNT(DISTINCT customer_state) as states_served
FROM geographic_base
GROUP BY seller_state
HAVING SUM(payment_value) >= 10000  -- Focus on significant seller states
ORDER BY (local_sales + cross_state_sales) DESC;
-- PRODUCT CATEGORY PREFERENCES BY GEOGRAPHY
-- =====================================================

-- 8.1 Top Product Categories by State
WITH state_category_sales AS (
    SELECT 
        customer_state,
        product_category_name_english,
        COUNT(*) as orders,
        SUM(payment_value) as revenue,
        ROW_NUMBER() OVER (PARTITION BY customer_state ORDER BY SUM(payment_value) DESC) as category_rank
    FROM geographic_base
    WHERE product_category_name_english IS NOT NULL
    GROUP BY customer_state, product_category_name_english
)
SELECT 
    customer_state,
    product_category_name_english,
    orders,
    ROUND(revenue, 2) as revenue,
    category_rank
FROM state_category_sales
WHERE category_rank <= 5  -- Top 5 categories per state
ORDER BY customer_state, category_rank;

-- 10. POWER BI READY SUMMARY TABLES
-- =====================================================

-- 10.1 Geographic Summary for Dashboard
CREATE VIEW geographic_summary_dashboard AS
SELECT 
    customer_state,
    customer_city,
    COUNT(DISTINCT customer_id) as customers,
    COUNT(DISTINCT order_id) as orders,
    ROUND(SUM(payment_value), 2) as revenue,
    ROUND(AVG(payment_value), 2) as avg_order_value,
    ROUND(AVG(freight_value), 2) as avg_shipping_cost,
    ROUND(COUNT(order_id) * 1.0 / COUNT(DISTINCT customer_id), 2) as orders_per_customer,
    ROUND(AVG(delivery_days), 1) as avg_delivery_days,
    ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as on_time_delivery_pct,
    ROUND(AVG(CASE WHEN shipping_type = 'Same State' THEN 1 ELSE 0 END) * 100.0, 1) as local_shipping_pct
FROM geographic_base
GROUP BY customer_state, customer_city;

-- 10.2 Monthly Geographic Trends for Time Series Analysis
CREATE VIEW monthly_geographic_trends AS
SELECT 
    customer_state,
    YEAR(order_purchase_timestamp) as year,
    MONTH(order_purchase_timestamp) as month,
    COUNT(DISTINCT customer_id) as customers,
    COUNT(DISTINCT order_id) as orders,
    ROUND(SUM(payment_value), 2) as revenue,
    ROUND(AVG(payment_value), 2) as avg_order_value
FROM geographic_base
GROUP BY customer_state, YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
HAVING orders >= 10  -- Filter for meaningful monthly data
ORDER BY customer_state, year, month;

SELECT 
    bg.customer_state,
    cs.customer_segment,
    COUNT(*) as segment_count 
FROM geographic_base bg 
LEFT JOIN customer_sgmt_correct cs ON bg.customer_unique_id = cs.customer_unique_id
WHERE cs.customer_segment IS NOT NULL
GROUP BY bg.customer_state, cs.customer_segment
ORDER BY bg.customer_state, segment_count DESC;

