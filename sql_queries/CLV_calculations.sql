/* SELECT 
    c.customer_unique_id,
    MIN(o.order_purchase_timestamp) as first_purchase_date,
    MAX(o.order_purchase_timestamp) as last_purchase_date,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(oi.price + oi.freight_value) as total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
LIMIT 10;
*/

-- Step 1B: Complete Historical CLV calculation
WITH customer_clv AS (
    SELECT 
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) as first_purchase_date,
        MAX(o.order_purchase_timestamp) as last_purchase_date,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(oi.price + oi.freight_value) as total_revenue,
        AVG(oi.price + oi.freight_value) as avg_order_value,
        DATEDIFF(MAX(o.order_purchase_timestamp), MIN(o.order_purchase_timestamp)) as customer_lifespan_days
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
/*
SELECT 
    customer_unique_id,
    first_purchase_date,
    last_purchase_date,
    total_orders,
    ROUND(total_revenue, 2) as historical_clv,
    ROUND(avg_order_value, 2) as avg_order_value,
    customer_lifespan_days,
    CASE 
        WHEN customer_lifespan_days > 0 
        THEN ROUND(total_revenue / (customer_lifespan_days/30.0), 2) 
        ELSE total_revenue 
    END as monthly_revenue_rate,
    CASE 
        WHEN total_revenue >= 1000 THEN 'High Value'
        WHEN total_revenue >= 500 THEN 'Medium-High Value'
        WHEN total_revenue >= 200 THEN 'Medium Value'
        WHEN total_revenue >= 50 THEN 'Low-Medium Value'
        ELSE 'Low Value'
    END as clv_category
FROM customer_clv
ORDER BY historical_clv DESC; 
*/

/* summary statistics
SELECT 
    COUNT(*) as total_customers,
    ROUND(AVG(total_revenue), 2) as avg_clv,
    ROUND(MIN(total_revenue), 2) as min_clv,
    ROUND(MAX(total_revenue), 2) as max_clv,
    ROUND(STDDEV(total_revenue), 2) as clv_std_dev,
    -- Order distribution
    ROUND(AVG(total_orders), 1) as avg_orders_per_customer,
    COUNT(CASE WHEN total_orders = 1 THEN 1 END) as one_time_buyers,
    COUNT(CASE WHEN total_orders > 1 THEN 1 END) as repeat_buyers,
    ROUND(COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0 / COUNT(*), 2) as repeat_buyer_rate
FROM customer_clv;
*/

clv_buckets AS (
    SELECT 
        CASE 
            WHEN total_revenue >= 1000 THEN 'High Value (1000+)'
            WHEN total_revenue >= 500 THEN 'Medium-High Value (500-999)'
            WHEN total_revenue >= 200 THEN 'Medium Value (200-499)'
            WHEN total_revenue >= 50 THEN 'Low-Medium Value (50-199)'
            ELSE 'Low Value (0-49)'
        END as clv_category,
        total_revenue
    FROM customer_clv
)
SELECT 
    clv_category,
    COUNT(*) as customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM clv_buckets), 2) as percentage,
    ROUND(AVG(total_revenue), 2) as avg_clv_in_category,
    ROUND(SUM(total_revenue), 2) as total_revenue_contribution,
    ROUND(SUM(total_revenue) * 100.0 / (SELECT SUM(total_revenue) FROM clv_buckets), 2) as revenue_percentage
FROM clv_buckets
GROUP BY clv_category
ORDER BY avg_clv_in_category DESC;

-- repeat customers

WITH repeat_customers AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(oi.price + oi.freight_value) as total_clv,
        AVG(oi.price + oi.freight_value) as avg_order_value,
        MIN(o.order_purchase_timestamp) as first_purchase,
        MAX(o.order_purchase_timestamp) as last_purchase,
        DATEDIFF(MAX(o.order_purchase_timestamp), MIN(o.order_purchase_timestamp)) as lifespan_days
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1  -- Only repeat buyers
)

SELECT 
    COUNT(*) as repeat_customers,
    ROUND(AVG(total_orders), 1) as avg_orders,
    ROUND(AVG(total_clv), 2) as avg_clv_repeat_customers,
    ROUND(MAX(total_clv), 2) as max_clv_repeat_customer,
    ROUND(AVG(avg_order_value), 2) as avg_order_value,
    ROUND(AVG(lifespan_days), 0) as avg_lifespan_days,
    ROUND(SUM(total_clv), 2) as total_revenue_from_repeat_customers,
    ROUND(SUM(total_clv) / (SELECT SUM(oi.price + oi.freight_value) FROM customers c JOIN orders o ON c.customer_id = o.customer_id JOIN order_items oi ON o.order_id = oi.order_id WHERE o.order_status = 'delivered') * 100, 2) as repeat_customer_revenue_share
FROM repeat_customers;


WITH customer_rfm_clv AS (
    SELECT 
        cs.customer_segment,
        cs.customer_unique_id,
        SUM(oi.price + oi.freight_value) as total_clv,
        COUNT(DISTINCT o.order_id) as total_orders
    FROM customer_sgmt_correct cs  -- Your RFM results table
    JOIN customers c ON cs.customer_unique_id = c.customer_unique_id
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY cs.customer_segment, cs.customer_unique_id
)

SELECT 
    customer_segment,
    COUNT(*) as segment_size,
    ROUND(AVG(total_clv), 2) as avg_clv,
    ROUND(SUM(total_clv), 2) as total_segment_value,
    ROUND(AVG(total_orders), 1) as avg_orders,
    COUNT(CASE WHEN total_orders > 1 THEN 1 END) as repeat_buyers_in_segment,
    ROUND(COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0 / COUNT(*), 2) as repeat_rate_in_segment
FROM customer_rfm_clv
GROUP BY customer_segment
ORDER BY avg_clv DESC;