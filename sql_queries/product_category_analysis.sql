USE customer_segmentation;
CREATE TABLE sgmt_cat_analysis AS 
SELECT 
    cs.customer_segment,
    bd.product_category_name_english,
    COUNT(*) as purchase_count,
    COUNT(DISTINCT cs.customer_unique_id) as unique_customers,
    SUM(bd.total_order_value) as total_revenue,
    AVG(bd.total_order_value) as avg_order_value
FROM customer_sgmt_correct cs
JOIN base_dataset bd ON cs.customer_unique_id = bd.customer_unique_id
WHERE bd.product_category_name IS NOT NULL
GROUP BY cs.customer_segment, bd.product_category_name
ORDER BY cs.customer_segment, total_revenue DESC;


WITH sgmt_totals AS(
SELECT customer_segment, COUNT(DISTINCT customer_unique_id) as total_cust_in_sgmt
FROM customer_sgmt_correct GROUP BY customer_segment
)

SELECT
sca.customer_segment,
sca.product_category_name_english,
sca.unique_customers,
st.total_cust_in_sgmt,
ROUND((sca.unique_customers*100.0/st.total_cust_in_sgmt),2) AS  penetration_rate,
sca.total_revenue,
sca.avg_order_value
FROM sgmt_cat_analysis sca JOIN sgmt_totals st ON sca.customer_segment = st.customer_segment
ORDER BY sca.customer_segment, penetration_rate DESC;

-- TOP CATEGORIES BY SEGMENT


WITH category_rankings AS (
    SELECT 
        customer_segment,
        product_category_name_english,
        total_revenue,
        unique_customers,
        avg_order_value,
        ROW_NUMBER() OVER (PARTITION BY customer_segment ORDER BY total_revenue DESC) as revenue_rank,
        ROW_NUMBER() OVER (PARTITION BY customer_segment ORDER BY unique_customers DESC) as customer_rank
    FROM sgmt_cat_analysis
)

SELECT 
    customer_segment,
    product_category_name_english,
    total_revenue,
    unique_customers,
    avg_order_value,
    revenue_rank,
    customer_rank
FROM category_rankings
WHERE revenue_rank <= 5  -- Top 5 by revenue
ORDER BY customer_segment, revenue_rank;


-- category affinity analysis

WITH overall_category_distribution AS (
SELECT
	product_category_name_english,
    COUNT(DISTINCT bd.customer_unique_id ) AS total_customer_buying_category,
    (SELECT COUNT(DISTINCT customer_unique_id ) FROM customer_sgmt_correct) AS total_customers
    FROM base_dataset AS bd JOIN customer_sgmt  AS cs 
    ON bd.customer_unique_id = cs.customer_unique_id
    WHERE product_category_name_english IS NOT NULL 
    GROUP BY product_category_name_english
),

segment_category_distribution AS (
SELECT 
	cs.customer_segment,
    bd.product_category_name_english,
    COUNT(DISTINCT cs.customer_unique_id) as customers_in_segment_buying_category,
        (SELECT COUNT(DISTINCT customer_unique_id) 
         FROM customer_sgmt_correct cs2 
         WHERE cs2.customer_segment = cs.customer_segment) as total_customers_in_segment
    FROM customer_sgmt_correct cs
    JOIN base_dataset bd ON cs.customer_unique_id = bd.customer_unique_id
    WHERE bd.product_category_name IS NOT NULL
    GROUP BY cs.customer_segment, bd.product_category_name
)

SELECT 
    scd.customer_segment,
    scd.product_category_name_english,
    ROUND((scd.customers_in_segment_buying_category * 100.0 / scd.total_customers_in_segment), 2) as segment_penetration,
    ROUND((ocd.total_customer_buying_category * 100.0 / ocd.total_customers), 2) as overall_penetration,
    ROUND(
        (scd.customers_in_segment_buying_category * 100.0 / scd.total_customers_in_segment) - 
        (ocd.total_customer_buying_category * 100.0 / ocd.total_customers), 2
    ) as affinity_index
FROM segment_category_distribution scd
JOIN overall_category_distribution ocd ON scd.product_category_name_english = ocd.product_category_name_english
ORDER BY scd.customer_segment, affinity_index DESC;

--  ........................................

-- Pre-calculate totals to avoid repeated subqueries
WITH customer_totals AS (
    SELECT 
        customer_segment,
        COUNT(DISTINCT customer_unique_id) as total_customers_in_segment
    FROM customer_sgmt_correct 
    GROUP BY customer_segment
),
overall_total AS (
    SELECT COUNT(DISTINCT customer_unique_id) as total_customers 
    FROM customer_sgmt_correct
),
overall_category_distribution AS (
    SELECT 
        bd.product_category_name_english,
        COUNT(DISTINCT bd.customer_unique_id) AS total_customers_buying_category
    FROM base_dataset bd 
    INNER JOIN customer_sgmt_correct cs ON bd.customer_unique_id = cs.customer_unique_id
    WHERE bd.product_category_name_english IS NOT NULL
    GROUP BY bd.product_category_name_english
), 
segment_category_distribution AS (
    SELECT 
        cs.customer_segment,
        bd.product_category_name_english,
        COUNT(DISTINCT cs.customer_unique_id) as customers_in_segment_buying_category
    FROM customer_sgmt_correct cs
    INNER JOIN base_dataset bd ON cs.customer_unique_id = bd.customer_unique_id
    WHERE bd.product_category_name_english IS NOT NULL
    GROUP BY cs.customer_segment, bd.product_category_name_english
)
SELECT
    scd.customer_segment,
    scd.product_category_name_english,
    ROUND((scd.customers_in_segment_buying_category * 100.0 / ct.total_customers_in_segment), 2) as segment_penetration,
    ROUND((ocd.total_customers_buying_category * 100.0 / ot.total_customers), 2) as overall_penetration,
    ROUND(
        (scd.customers_in_segment_buying_category * 100.0 / ct.total_customers_in_segment) -
        (ocd.total_customers_buying_category * 100.0 / ot.total_customers), 2
    ) as affinity_index
FROM segment_category_distribution scd
INNER JOIN overall_category_distribution ocd 
    ON scd.product_category_name_english = ocd.product_category_name_english
INNER JOIN customer_totals ct 
    ON scd.customer_segment = ct.customer_segment
CROSS JOIN overall_total ot
ORDER BY scd.customer_segment, affinity_index DESC;