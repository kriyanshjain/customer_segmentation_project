-- Create customer cohorts based on first purchase month
CREATE TABLE customer_cohorts AS 
    SELECT 
        c.customer_unique_id,
        MIN(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')) as cohort_month,
        MIN(o.order_purchase_timestamp) as first_purchase_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
        AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY c.customer_unique_id;

SELECT cohort_month, COUNT(*) as customers 
FROM customer_cohorts 
GROUP BY cohort_month 
ORDER BY cohort_month;
/*
 SELECT 
    cohort_month,
    COUNT(DISTINCT customer_unique_id) as cohort_size
FROM customer_cohorts
GROUP BY cohort_month
ORDER BY cohort_month;
*/

CREATE TABLE monthly_purcahses AS      -- cust activit
SELECT
	c.customer_unique_id,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
    -- o.order_purchase_timestamp,
    COUNT( DISTINCT o.order_id) AS orders_count,
    SUM(oi.price + oi.freight_value) AS monthly_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= '2017-01-01'  -- Limit date range
    AND o.order_purchase_timestamp < '2019-01-01'
    GROUP BY c.customer_unique_id, DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m');
	
SELECT COUNT(*) FROM monthly_purcahses;

SELECT 
    cc.customer_unique_id,
    cc.cohort_month,
    mp.purchase_month,
    mp.orders_count,
    mp.monthly_revenue
FROM customer_cohorts cc
JOIN monthly_purcahses mp ON cc.customer_unique_id = mp.customer_unique_id
ORDER BY cc.cohort_month, cc.customer_unique_id, mp.purchase_month;

-- period number
WITH cohort_data AS (
    SELECT 
        cc.cohort_month,
        mp.purchase_month,
        -- Calculate period number (months since first purchase)
        PERIOD_DIFF(
            CAST(REPLACE(mp.purchase_month, '-', '') AS UNSIGNED),
            CAST(REPLACE(cc.cohort_month, '-', '') AS UNSIGNED)
        ) as period_number,
        COUNT(DISTINCT cc.customer_unique_id) as active_customers,
        SUM(mp.monthly_revenue) as total_revenue
    FROM customer_cohorts cc
JOIN monthly_purcahses mp ON cc.customer_unique_id = mp.customer_unique_id
    GROUP BY cc.cohort_month, mp.purchase_month,
    PERIOD_DIFF(
            CAST(REPLACE(mp.purchase_month, '-', '') AS UNSIGNED),
            CAST(REPLACE(cc.cohort_month, '-', '') AS UNSIGNED)
        )
),


-- retention analysis

cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_unique_id) as cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
),
cohort_retention AS (
    SELECT 
        cd.cohort_month,
        cd.period_number,
        cd.active_customers,
        cs.cohort_size,
        ROUND(
            (cd.active_customers * 100.0 / cs.cohort_size), 2
        ) as retention_rate,
        cd.total_revenue
    FROM cohort_data cd
    JOIN cohort_sizes cs ON cd.cohort_month = cs.cohort_month
    
),

critical_metric AS (
SELECT
AVG(CASE WHEN period_number = 1 THEN retention_rate END) AS Month_1_Retention,
        -- Month 3 Retention
        AVG(CASE WHEN period_number = 3 THEN retention_rate END) AS Month_3_Retention,
        -- Month 6 Retention   
        AVG(CASE WHEN period_number = 6 THEN retention_rate END) AS Month_6_Retention,
        -- Month 12 Retention
        AVG(CASE WHEN period_number = 12 THEN retention_rate END) AS Month_12_Retention
    FROM cohort_retention
),
churn_rate AS (
-- Calculate churn rates by period
SELECT 
    period_number,
    AVG(retention_rate) as retention_rate,
    (100 - AVG(retention_rate)) as churn_rate,
    LAG(AVG(retention_rate)) OVER (ORDER BY period_number) as prev_retention,
    (LAG(AVG(retention_rate)) OVER (ORDER BY period_number) - AVG(retention_rate)) as period_churn
FROM cohort_retention
WHERE period_number <= 12
GROUP BY period_number
ORDER BY period_number
)

SELECT period_number,
CASE 
        WHEN period_number = 0 THEN 'Acquisition'
        WHEN period_number = 1 THEN 'Month 0-1'
        WHEN period_number = 2 THEN 'Month 1-2'
        WHEN period_number = 3 THEN 'Month 2-3'
        WHEN period_number = 4 THEN 'Month 3-4'
        WHEN period_number = 5 THEN 'Month 4-5'
        WHEN period_number = 6 THEN 'Month 5-6'
        WHEN period_number = 7 THEN 'Month 6-7'
        WHEN period_number = 8 THEN 'Month 7-8'
        WHEN period_number = 9 THEN 'Month 8-9'
        WHEN period_number = 10 THEN 'Month 9-10'
        WHEN period_number = 11 THEN 'Month 10-11'
        WHEN period_number = 12 THEN 'Month 11-12'
        ELSE CONCAT('Month ', period_number-1, '-', period_number)
    END as period_label, 
retention_rate, churn_rate, prev_retention,
period_churn FROM churn_rate;
/*
SELECT Month_1_Retention, Month_3_Retention, Month_6_Retention, Month_12_Retention
FROM critical_metric;

 SELECT 
    cohort_month,
    cohort_size,
    period_number,
    active_customers,
    retention_rate,
    ROUND(total_revenue / cohort_size, 2) as revenue_per_customer
FROM cohort_retention
ORDER BY cohort_month, period_number;
*/