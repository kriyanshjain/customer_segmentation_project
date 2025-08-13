USE customer_segmentation;

 -- query to join products_category_name in product table to there english counterpart --
SELECT p.product_id, p.product_category_name, pro.product_category_name_english,row_number()
over(order by product_category_name) as rn FROM product p JOIN name_translation pro ON 
 p.product_category_name = pro.product_category_name;
 
 SELECT COUNT(p.product_id), pt.product_category_name_english  FROM product P 
 JOIN name_translation pt ON p.product_category_name = pt.product_category_name 
 GROUP BY pt.product_category_name_english ORDER BY COUNT(p.product_id) DESC ;
 
 
 
 -- Create the base dataset
CREATE VIEW base_dataset AS
SELECT 
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_id,
    o.order_purchase_timestamp,
    o.order_status,
    o.order_delivered_customer_date,
    oi.order_item_id,
    oi.product_id,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_order_value,
    op.payment_type,
    op.payment_value,
    p.product_category_name,
    pt.product_category_name_english
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN order_payment op ON o.order_id = op.order_id
LEFT JOIN product p ON oi.product_id = p.product_id
LEFT JOIN name_translation pt ON p.product_category_name = pt.product_category_name 
WHERE o.order_status = 'delivered'  -- Only completed orders
    AND o.order_purchase_timestamp IS NOT NULL;
    

    
CREATE TABLE customer_metric AS
SELECT 
    customer_unique_id,
    DATEDIFF('2019-01-01', MAX(order_purchase_timestamp)) AS recency_days,
    COUNT(DISTINCT order_id) as frequency,
    SUM(total_order_value) AS monetary_value
FROM base_dataset
GROUP BY customer_unique_id;

CREATE TABLE customer_sgmt_correct AS
WITH cust_rfm AS(
SELECT 
    customer_unique_id,
    recency_days,
    frequency,
    monetary_value,
    
    -- RFM Scores using quintiles
    6 - NTILE(5) OVER (ORDER BY recency_days ASC) as R_score,
    NTILE(5) OVER (ORDER BY frequency DESC) as F_score,
    NTILE(5) OVER (ORDER BY monetary_value DESC) as M_score
FROM customer_metric
)
SELECT *,
    CONCAT(R_score, F_score, M_score) as RFM_score,
    CASE 
        WHEN R_score >= 4 AND F_score >= 4 AND M_score >= 4 THEN 'Champions'
        WHEN R_score >= 3 AND F_score >= 3 AND M_score >= 3 THEN 'Loyal Customers'
        WHEN R_score >= 4 AND F_score <= 2 THEN 'New Customers'
        WHEN R_score <= 2 AND F_score >= 3 THEN 'At Risk'
        WHEN R_score <= 2 AND F_score <= 2 AND M_score >= 3 THEN 'Cannot Lose Them'
        WHEN R_score <= 2 AND F_score <= 2 AND M_score <= 2 THEN 'Lost Customers'
        ELSE 'Others'
    END as customer_segment
FROM cust_rfm;

SELECT *, ROW_NUMBER() over (ORDER BY RFM_score DESC) as  rn from customer_sgmt_correct; 

SELECT distinct customer_segment, count(*) from customer_sgmt_correct 
group by customer_segment order by count(*) desc;


