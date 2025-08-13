# Customer Segmentation Analysis Methodology

## Brazilian E-commerce Dataset

### Executive Summary

This methodology document outlines a comprehensive analytical framework for customer segmentation analysis using Brazilian e-commerce data. The analysis combines Excel-based data preparation, SQL-driven RFM segmentation, and multi-dimensional customer behavior analysis to deliver actionable business insights across six distinct customer segments.

------

## 1. Project Objectives

### Primary Objectives

- **Customer Segmentation**: Classify customers into 6 meaningful segments using RFM analysis
- **Behavioral Analysis**: Understand customer lifecycle patterns through cohort analysis
- **Value Assessment**: Calculate Customer Lifetime Value (CLV) across segments
- **Market Intelligence**: Analyze geographic performance and product category preferences
- **Strategic Insights**: Provide data-driven recommendations for customer relationship management

### Secondary Objectives

- Demonstrate integrated use of Excel, SQL, and Power BI for business analysis
- Create automated analytical framework for ongoing customer monitoring
- Establish performance benchmarks for customer acquisition and retention strategies

------

## 2. Dataset Overview

### Data Source & Structure

- **Origin**: Brazilian E-commerce Public Dataset (Olist)

- **Analysis Period**: 2016-2018

- **Scale**: 100,000+ orders, 99,000+ customers, 32,000+ products

- **Geographic Coverage**: All Brazilian states and 4,000+ cities

  ### Core Data Tables

  

| Table                             | Records | Primary Analysis Use                          |
| --------------------------------- | ------- | --------------------------------------------- |
| customers_dataset                 | ~99k    | Geographic segmentation, demographic analysis |
| geolocation_dataset               | ~1M     | -                                             |
| order_items_dataset               | ~112k   | Product-level analysis, revenue calculation   |
| order_payments_dataset            | ~103k   | Payment behavior analysis                     |
| order_reviews_dataset             | ~99K    | Feedback and efficiency analysis              |
| orders_dataset                    | ~100K   | Transaction backbone, temporal analysis       |
| products_dataset                  | ~32k    | Category preference analysis                  |
| sellers_dataset                   | ~3K     | -                                             |
| product_category_name_translation | ~72     | -                                             |

------

## 3. Data Preparation Framework (Excel)

### 3.1 Data Import and Initial Assessment

**Data Loading Process:**

- Import CSV files using Excel's "Get Data" functionality
- Preserve original data types and formatting
- Create backup worksheets for data integrity

### 3.2 Data Cleaning Operations

**Removing Empty Spaces and Standardization:**

excel

```excel
// Text cleaning operations
=TRIM(A1)                    // Remove leading/trailing spaces
=CLEAN(A1)                   // Remove non-printable characters
=PROPER(A1)                  // Standardize city names
=UPPER(A1)                   // Standardize state codes
```

**Data Filtering Operations:**

- **Order Status Filtering**: Remove cancelled and unavailable orders
- **Date Range Filtering**: Focus on complete transaction periods
- **Geographic Filtering**: Exclude incomplete address records
- **Price Validation**: Filter out zero or negative price values

### 3.3 DateTime Format Standardization

**DateTime Conversion Process:**

excel

```excel
// Converting timestamp formats
=DATEVALUE(LEFT(A1,10)) + TIMEVALUE(MID(A1,12,8))  // ISO datetime conversion
=TEXT(A1,"yyyy-mm-dd hh:mm:ss")                     // Standardize format
=MONTH(A1)                                          // Extract month for cohort analysis
=YEAR(A1)                                           // Extract year for temporal analysis
```

**Derived Date Fields Creation:**

- Purchase Month/Year for cohort grouping
- Order-to-delivery duration calculation
- Seasonality indicators (quarters, holiday periods)

------

## 4. RFM Analysis Framework (SQL)

### 4.1 Customer Segmentation Methodology

**RFM Metric Definitions:**

- **Recency (R)**: Days since last purchase (lower is better)
- **Frequency (F)**: Total number of completed orders (higher is better)
- **Monetary (M)**: Total spending including freight (higher is better)

**SQL Implementation Framework:**

sql

```sql
-- Step 1: Base RFM Calculation
CREATE TABLE customer_metric AS
SELECT 
    customer_unique_id,
    DATEDIFF('2019-01-01', MAX(order_purchase_timestamp)) AS recency_days,
    COUNT(DISTINCT order_id) as frequency,
    SUM(total_order_value) AS monetary_value
FROM base_dataset
GROUP BY customer_unique_id;

-- Step 2: RFM Scoring (1-5 scale using quintiles)
CREATE TABLE customer_sgmt AS
WITH cust_rfm AS(
SELECT 
    customer_unique_id,
    recency_days,
    frequency,
    monetary_value,
    
    -- RFM Scores using quintiles
    NTILE(5) OVER (ORDER BY recency_days ASC) as R_score,
    NTILE(5) OVER (ORDER BY frequency DESC) as F_score,
    NTILE(5) OVER (ORDER BY monetary_value DESC) as M_score
FROM customer_metric
)
```

### 4.2 Six-Segment Classification Framework

**Segment Definition Rules:**

| Segment          | RFM Score Pattern                   | Business Characteristics                  | Count Target |
| ---------------- | ----------------------------------- | ----------------------------------------- | ------------ |
| Champion         | R:4-5, F:4-5, M:4-5                 | Best customers, high value & engagement   | 10 - 15%     |
| Loyal            | R:3-5, F:3-5, M:3-5 (not Champions) | Consistent, reliable customers            | 15 - 20%     |
| At Risk          | R:1-2, F:3-5, M:3-5                 | High value but haven't purchased recently | 10 - 15%     |
| New              | R:4-5, F:1-2, M:1-3                 | Recent customers, low frequency           | 15 - 20%     |
| Lost             | R:1-2, F:1-2, M:1-3                 | Inactive, low engagement                  | 20 - 25%     |
| Cannot Lose Them | R:1-2, F:4-5, M:4-5                 | High value customers at risk              | 5 - 10%      |

**Segmentation Logic Implementation:**

sql

```sql
CASE 
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 
         AND NOT (r_score >= 4 AND f_score >= 4 AND m_score >= 4) THEN 'Loyal'
    WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
    WHEN r_score >= 4 AND f_score <= 2 THEN 'New'
    WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 3 THEN 'Lost'
    WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4 THEN 'Cannot Lose Them'
    ELSE 'Others'
END AS customer_segment
```

### 4.3 Segment Validation Metrics

**Key Performance Indicators:**

### 4.3 Segment Validation Metrics

**Key Performance Indicators:**

- Segment size distribution (% of total customers)
- Revenue contribution per segment (% of total revenue)
- Average RFM scores per segment
- Customer migration patterns between segments

------

## 5. Product Category Analysis Framework

### 5.1 Category Penetration Analysis

**Overall Market Penetration:**

sql

```sql
-- Overall category penetration across all customers
CREATE TABLE sgmt_cat_analysis AS 
SELECT 
    cs.customer_segment,
    bd.product_category_name_english,
    COUNT(*) as purchase_count,
    COUNT(DISTINCT cs.customer_unique_id) as unique_customers,
    SUM(bd.total_order_value) as total_revenue,
    AVG(bd.total_order_value) as avg_order_value
FROM customer_sgmt cs
JOIN base_dataset bd ON cs.customer_unique_id = bd.customer_unique_id
WHERE bd.product_category_name IS NOT NULL
GROUP BY cs.customer_segment, bd.product_category_name
ORDER BY cs.customer_segment, total_revenue DESC;


WITH sgmt_totals AS(
SELECT customer_segment, COUNT(DISTINCT customer_unique_id) as total_cust_in_sgmt
FROM customer_sgmt GROUP BY customer_segment
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
```

**Segment-Specific Penetration:**

sql

```sql
-- Category penetration within each customer segment
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
```

### 5.2 Category Affinity Index Calculation

**Affinity Index Methodology:**

sql

```sql
-- Affinity Index = (Segment Penetration / Overall Penetration) * 100
WITH category_affinity AS (
    SELECT 
        customer_segment,
        product_category_name,
        segment_penetration,
        overall_penetration,
        ROUND((segment_penetration / NULLIF(overall_penetration, 0)) * 100, 2) as affinity_index
    FROM penetration_analysis
)

-- Interpretation:
-- Affinity Index > 100: Higher than average preference
-- Affinity Index = 100: Average preference  
-- Affinity Index < 100: Lower than average preference
```

**Business Applications:**

- **Index > 120**: Strong category preference, optimize inventory
- **Index 80-120**: Normal preference, maintain current strategy
- **Index < 80**: Low preference, potential for targeted campaigns

------

## 6. Cohort Analysis Framework

### 6.1 Cohort Definition and Structure

**Monthly Acquisition Cohorts:**

- **Cohort Definition**: Customers grouped by first purchase month
- **Tracking Period**: 12 months post-acquisition
- **Analysis Frequency**: Monthly retention and revenue tracking

**Core Cohort Metrics:**

sql

```sql
WITH customer_cohorts AS (
     SELECT 
        c.customer_unique_id,
        MIN(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')) as cohort_month,
        MIN(o.order_purchase_timestamp) as first_purchase_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
        AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY c.customer_unique_id;
    )
    cohort_data AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) as cohort_size,
        period_number,
        COUNT(DISTINCT active_customers) as active_customers,
        ROUND(COUNT(DISTINCT active_customers) * 100.0 / cohort_size, 2) as retention_rate,
        ROUND(SUM(revenue) / COUNT(DISTINCT active_customers), 2) as revenue_per_customer
    FROM cohort_analysis_base
    GROUP BY cohort_month, period_number
)
```

### 6.2 Cohort Analysis Components

**1. Active Customer Cohort Tracking:**

- Monthly active customer count by cohort
- Retention rate calculation for each period
- Identification of high-performing cohorts

**2. Period Number Analysis:**

- Period 0: Acquisition month
- Period 1-12: Subsequent months tracking
- Long-term retention pattern identification

**3. Revenue per Customer Analysis:**

- Monthly revenue per active customer by cohort
- Average order value trends over customer lifecycle
- Revenue retention vs customer retention comparison

### 6.3 Cohort Performance Metrics

**Key Cohort KPIs:**

- **Month 1 Retention**: Percentage returning in first month
- **Month 6 Retention**: Medium-term loyalty indicator
- **Month 12 Retention**: Long-term customer value
- **Revenue per Customer Trend**: Customer value evolution over time

------

## 7. Customer Lifetime Value (CLV) Analysis

### 7.1 CLV Calculation Methodology

**Historical CLV Approach:**

sql

```sql
WITH customer_clv_base AS (
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
    )
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
```

### 7.2 CLV Components Analysis

**Segment Size Analysis:**

- Customer count and percentage distribution across segments
- Segment growth/decline trends over time
- New customer acquisition patterns by segment

**Average CLV by Segment:**

- Mean customer lifetime value calculation
- CLV distribution analysis (median, percentiles)
- High-value customer identification within segments

**Total Segment Value:**

- Aggregate revenue contribution per segment
- Revenue concentration analysis (80/20 rule validation)
- Segment ROI potential assessment

**Repeat Buyer Analysis:**

- Percentage of customers with multiple purchases

- Average time between purchases

- Repeat purchase value progression

  ------

  ## 8. Geographic Analysis Framework

  ### 8.1 Customer Distribution Analysis

  **State-Level Customer Segmentation:**

  sql

  ```sql
  -- Customer count and segment distribution by state
  SELECT 
      customer_state,
      customer_segment,
      COUNT(*) as customer_count,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY customer_state), 2) as segment_percentage,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY customer_segment), 2) as state_percentage_in_segment
  FROM customer_geographic_analysis
  GROUP BY customer_state, customer_segment
  ORDER BY customer_state, customer_count DESC;
  ```

  **City-Level Performance Analysis:**

  ```sql
  -- Top performing cities within each state
  SELECT 
      customer_state,
      customer_city,
      COUNT(DISTINCT customer_id) as customer_count,
      ROUND(SUM(total_revenue), 2) as total_revenue,
      ROUND(AVG(avg_order_value), 2) as avg_order_value,
      ROUND(SUM(total_revenue) / COUNT(DISTINCT customer_id), 2) as revenue_per_customer
  FROM city_performance_analysis
  GROUP BY customer_state, customer_city
  HAVING COUNT(DISTINCT customer_id) >= 50  -- Minimum threshold for analysis
  ORDER BY customer_state, total_revenue DESC;
  ```

  ### 8.2 Revenue and Order Value Analysis 

  ### **State Performance Metrics:**

  - Total revenue by state and segment
  - Average order value comparison across regions
  - Customer concentration vs revenue contribution analysis
  - Market penetration opportunities by underperforming states

  **Geographic Revenue Insights:**

  sql

  ```sql
  -- State performance comprehensive view
  SELECT 
      customer_state,
      COUNT(DISTINCT customer_id) as total_customers,
      COUNT(DISTINCT order_id) as total_orders,
      ROUND(SUM(order_total), 2) as total_revenue,
      ROUND(AVG(order_total), 2) as avg_order_value,
      ROUND(SUM(order_total) / COUNT(DISTINCT customer_id), 2) as revenue_per_customer,
      ROUND(COUNT(DISTINCT order_id) * 1.0 / COUNT(DISTINCT customer_id), 2) as orders_per_customer
  FROM geographic_revenue_analysis
  GROUP BY customer_state
  ORDER BY total_revenue DESC;
  ```

  ### 8.3 Delivery Performance Analysis

  **Delivery Metrics by State:**

  sql

  ```sql
  -- Delivery performance impact analysis
  SELECT 
      customer_state,
      COUNT(*) as total_deliveries,
      ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 1) as avg_delivery_days,
      ROUND(AVG(CASE 
          WHEN order_delivered_customer_date <= order_estimated_delivery_date 
          THEN 1.0 ELSE 0.0 END) * 100, 2) as on_time_delivery_percent,
      ROUND(AVG(CASE 
          WHEN order_delivered_customer_date < order_estimated_delivery_date 
          THEN 1.0 ELSE 0.0 END) * 100, 2) as early_delivery_percent
  FROM delivery_performance_analysis
  WHERE order_delivered_customer_date IS NOT NULL 
    AND order_estimated_delivery_date IS NOT NULL
  GROUP BY customer_state
  ORDER BY on_time_delivery_percent DESC;
  ```

  **Delivery Impact on Customer Behavior:**

  - Correlation between delivery speed and customer retention
  - State-wise delivery performance vs customer satisfaction
  - Geographic logistics optimization opportunities

- Geographic logistics optimization opportunities

------

## 9. Integration and Visualization Strategy

### 9.1 Power BI Dashboard Framework

**Dashboard Structure:**

1. **Executive Summary**: Key metrics overview across all analyses
2. **Customer Segmentation**: RFM segment distribution and performance
3. **Geographic Performance**: State and city-level analysis with maps
4. **Cohort And Retention Analysis**: Retention trends and customer lifecycle visualization

### 9.2 Cross-Analysis Integration

**Integrated Insights Framework:**

- Geographic segment performance correlation

- Product category preferences by geographic region

- Cohort behavior differences across states

- CLV variations by geographic and product dimensions

  ------

  ## 10. Expected Outcomes and Success Metrics

  ### 10.1 Analytical Deliverables

  **Primary Outputs:**

  - 6-segment customer classification with business profiles
  - Interactive Power BI dashboard with drill-down capabilities
  - Geographic performance heatmaps and optimization recommendations
  - Product category affinity matrix for targeted marketing
  - Cohort retention analysis with customer lifecycle insights
  - CLV assessment with segment prioritization framework

  ### 10.2 Business Impact Metrics

  **Success Criteria:**

  - 95%+ customer classification coverage
  - Statistically significant segment differentiation
  - Actionable insights for 100% of identified segments
  - Geographic expansion opportunity identification
  - Product category cross-selling opportunity quantification
  - Customer retention improvement pathway definition

  ------

  ## 11. Implementation Timeline

  ### Phase 1: Data Preparation 

  - Excel-based data cleaning and standardization
  - DateTime format conversion and validation
  - Quality assessment and filtering operations

  ### Phase 2: RFM Analysis 

  - SQL-based RFM calculation and scoring
  - 6-segment classification implementation
  - Segment validation and profiling

  ### Phase 3: Advanced Analytics

  - Product category affinity analysis
  - Cohort analysis implementation
  - CLV calculation and segment assessment
  - Geographic performance analysis

  ### Phase 4: Integration & Visualization 

  - Power BI dashboard development
  - Cross-analysis integration
  - Interactive visualization creation
  - User acceptance testing

  ### Phase 5: Documentation & Recommendations 

  - Comprehensive insights documentation
  - Business recommendation development
  - Methodology documentation finalization

  ------

  ## 13. Conclusion

  This methodology provides a comprehensive, systematic approach to customer segmentation analysis that integrates multiple analytical perspectives. The framework combines statistical rigor with business practicality, delivering actionable insights through:

  - **Data Quality Excellence**: Rigorous Excel-based data preparation
  - **Advanced Segmentation**: Six-segment RFM classification with business relevance
  - **Multi-Dimensional Analysis**: Product, geographic, temporal, and value-based insights
  - **Integration Focus**: Cohesive analytical framework with cross-dimensional insights
  - **Business Application**: Clear pathway from analysis to strategic implementation

  The methodology demonstrates advanced analytical capabilities while maintaining focus on business value creation and strategic decision support.

  ------

  *Document Version: 1.0*
   *Analysis Framework: Excel + SQL + Power BI*
   *Geographic Scope: Brazil (All States)*
   *Temporal Scope: 2016-2018*
   *Customer Universe: 99,000+ Customers*