# Customer Segmentation Analysis - Key Insights Summary

## Brazilian E-commerce Dataset Analysis Results

### Executive Summary

This document presents the key findings from comprehensive customer segmentation analysis of Brazilian e-commerce data spanning 2016-2018. The analysis reveals significant opportunities for revenue optimization through targeted customer strategies, with Champions and Loyal segments representing 6.25% of total revenue, being 16.1% of the customer base.

**Key Headlines:**

- **Revenue Concentration**:  61% of customers (At Risk + Others) generate 62.5% of total revenue
- **Geographic Opportunity**: São Paulo and Rio de Janeiro represent 28% of customers but show expansion potential in secondary markets
- **Retention Challenge**: 95% of customers are one-time purchasers, indicating significant retention improvement opportunity
- **Category Insights**: Health Beauty dominates Champions segment (11% affinity), while Furniture Decor  show highest repeat purchase rates

------

## 1. Customer Segmentation Results (RFM Analysis)

### 1.1 Segment Distribution and Performance

| Segment             | Customer Count | % of Total | Revenue (BRL) | % of Revenue | Avg CLV (BRL) | Avg Orders |
| ------------------- | -------------- | ---------- | ------------- | ------------ | ------------- | ---------- |
| **Champion**        | 2.2k           | 2.3%       | 120k          | 0.75%        | 55            | 1          |
| **Loyal**           | 12k            | 12.9%      | 947k          | 5.9%         | 76.63         | 1          |
| **New**             | 18k            | 19.35%     | 3M            | 18.75%       | 175.26        | 1.1        |
| **At Risk**         | 32k            | 34.4%      | 5M            | 31.25%       | 163           | 1          |
| **Cannot** **Lose** | 2.8k           | 3%         | 214k          | 1.3%         | 75.71         | 1.1        |
| **Lost**            | 2.2k           | 2.3%       | 698k          | 4.3%         | 304           | 1.4        |
| **Others**          | 24k            | 25.8%      | 5M            | 31.25%       | 213           | 1          |

### 1.2 Critical Insights

**Revenue Concentration Pattern:**

- **Pareto Principle Confirmed**: 60% of customers (At Risk + Others) generate 62% of revenue
- **High-Risk Revenue**: 37.63% of total revenue comes from At Risk + Cannot Lose segments requiring immediate attention
- **Lost Customer Impact**: 2.3% of customers contribute 4.3% of revenue, indicating successful churn identification

**Customer Behavior Patterns:**

- **Champions**: 1 average orders with 55 BRL CLV significantly underperforms other segments
- **New Customer Potential**: 19.35% of customer base with 175 BRL CLV shows conversion opportunity
- **At Risk Alert**: 34.4% of customers with declining engagement but historical value of 163 BRL CLV

### 1.3 Segment-Specific Behavioral Insights

**Champions (2.3% of customers, 0.75% of revenue):**

- 1 orders per customer (highest frequency)
- 55 BRL average spending (lowest monetary value)
- **Key Insight**: Show inconsistent engagement with 41% making repeat purchases within 90 days

**At Risk (34% of customers, 31% of revenue):**

- Average 245 days since last purchase (high recency concern)
- 1 historical orders (decent engagement history)
- 163 BRL CLV (High historical value)
- **Key Insight**: Previously valuable customers showing churn signals, requiring immediate intervention

------

## 2. Product Category Analysis Results

------

### 2.1 Category Penetration Analysis

**Overall Market Penetration (Top 10 Categories):**

| Category             | Total Orders | Overall Penetration | Revenue Share |
| -------------------- | ------------ | ------------------- | ------------- |
| Health & beauty      | 8647         | 9.1%                | 8.4%          |
| Watches & gifts      | 5495         | 5.81%               | 8%            |
| Bed Bath Table       | 9272         | 9.65%               | 7.1%          |
| Sports Leisure       | 7530         | 7.86%               | 6.6%          |
| Computer accessories | 6530         | 6.86%               | 6.1%          |
| Furniture Decor      | 6307         | 6.62%               | 4.9%          |
| Houseware            | 5743         | 6.09%               | 4.3%          |
| Cool Stuff           | 3559         | 3.8%                | 4.2%          |
| Auto                 | 3810         | 4.04%               | 4%            |
| Garden Tools         | 3448         | 3.66%               | 3.2%          |

### 2.2 Segment-Specific Category Affinity

**Champions Segment Category Preferences:**

| Category             | Affinity Index | Segment Penetration | Business implication                   |
| -------------------- | -------------- | ------------------- | -------------------------------------- |
| Health beauty        | 1.89           | 10.99               | Good preference - premium  focus       |
| Bath Bed Table       | -0.63          | 9.02                | Slight preference - lifestyle products |
| Housewares           | 3.85           | 9.94                | Above average - high-value home items  |
| Sports Leisure       | -0.9           | 6.96                | Slight preference - lifestyle products |
| Computer Accessories | -0.18          | 6.68                | Average preference                     |

**Key Category Insights:**

- **Health & beauty Dominance**: Champions show  higher preference for Health & beauty
- **Cross-Category Opportunity**: 30% of Champions purchase from 3+ categories, indicating cross-selling potential
- **Premium Positioning**: High-affinity categories correlate with higher average order values

### 2.3 Category Performance by Segment

**Cross-Selling Analysis:**

- **Multi-Category Champions**: 33% purchase from 3+ categories vs 70% for other segments
- **Category Loyalty**: Furniture Decor shows highest repeat purchase rate (73%) across most of the segments

------

## 3. Cohort Analysis Results

### 3.1 Customer Retention Patterns

**Overall Retention Performance:**

| Period             | Month 1 | Month 3 | Month 6 | Month 12 |
| ------------------ | ------- | ------- | ------- | -------- |
| **Retention Rate** | 5.45    | 0.25    | 0.27    | 0.21     |

### 3.2 High-Performing Cohorts

**Best Performing Acquisition Cohorts:**

| Cohort Month  | Cohort Size | Month 6 Retention | Month 12 Retention | Avg Revenue/Customer |
| ------------- | ----------- | ----------------- | ------------------ | -------------------- |
| December 2017 | 5338        | 0.17              | -                  | 154 BRL              |
| August 2017   | 4057        | 0.30              | 0.12               | 156 BRL              |
| May 2018      | 6506        | 0.41              | 0.23               | 169 BRL              |
| April 2018    | 6582        | 0.35              | 0.04               | 168 BRL              |

**Cohort Performance Insights:**

- **Seasonal Impact**: Holiday season cohorts (Nov-Dec) show higher initial revenue but similar long-term retention
- **Retention Stability**: Month 6 retention cannot predicts Month 12 retention 
- **Revenue Growth**: Retained customers shows uneven revenue change from Month 1 to Month 12

### 3.3 Critical Retention Insights

**Customer Lifecycle Patterns:**

- **Critical Period**: 94% of churn occurs within first month

- **Retention Cliff**: Sharp drop from 5% (Month 1) to 0.37% (Month 2)

- **Stabilization Point**: Retention rates stabilize after Month 2, indicating long-term customer identification

  ------

  

## 4. Geographic Analysis Results

### 4.1 State-Level Performance Analysis

**Top Performing States by Customer Count:**

| State                  | Customer Count | Revenue (BRL)      | Avg Order Value |
| ---------------------- | -------------- | ------------------ | --------------- |
| Sao Paulo (SP)         | 40,485 (43%)   | 7,400,000 (46%)    | 153             |
| Rio de Janeiro (RJ)    | 12,342 (13%)   | 2,687,442 (16%)    | 181             |
| Minas Gerais (MG)      | 11,348 (12%)   | 2,277,679 (13.75%) | 169             |
| Rio Grande do Sul (RS) | 5344 (5.7%)    | 1,110,782 (6.8%)   | 174             |
| Paraná (PR)            | 4922 (5.3%)    | 1,030,757 (6.2%)   | 175             |

### 4.2 Geographic Performance Insights

**Market Concentration:**

- **Dominance of Southeast**: SP + RJ represent 56% of customers and 62% of revenue
- **Underserved Markets**: Northern states represent <3% of customers despite 8.7% of Brazilian population
- **Revenue Efficiency**: São Paulo shows highest revenue per customer and market penetration

**City-Level Performance (Top 5):**

| City           | State | Customers | Revenue   | Champions |
| -------------- | ----- | --------- | --------- | --------- |
| Sao Paulo      | SP    | 12,340    | 1,950,000 | 15.8%     |
| Rio de Janeiro | RJ    | 9,680     | 1,470,000 | 14.2%     |
| Belo Horizonte | MG    | 3,450     | 490,000   | 13.1%     |
| Brasilia       | DF    | 2,890     | 420,000   | 16.4%     |
| Salvador       | BA    | 2,650     | 350,000   | 11.9%     |

### 4.3 Delivery Performance Impact

**Delivery Performance by State:**

| State          | Avg Delivery Days | On-Time Delivery | Customer Satisfaction Impact |
| -------------- | ----------------- | ---------------- | ---------------------------- |
| Sao Paulo      | 2.40              | 94%              | High retention correlation   |
| Rio de Janeiro | 15.20             | 87%              | Above average satisfaction   |
| Minas Gerais   | 11                | 94%              | High retention correlation   |
| Alabama        | 24                | 75%              | Average performance          |

**Delivery Impact Analysis:**

- **Performance Correlation**: States with <10 days average delivery show 34% higher customer retention
- **On-Time Impact**: >75% on-time delivery correlates with 28% higher Champions segment percentage
- **Geographic Challenge**: Southern states show delivery delays affecting customer satisfaction and segment progression

------

## 5. Cross-Dimensional Insights

### 5.1 Geographic-Segment Correlation

**Champions Distribution by Region:**

- **Southeast Dominance**: 70% of Champions customers located in SP/RJ
- **Capital City Effect**: State capitals show 2.3x higher Champions concentration
- **Delivery Correlation**: States with better delivery performance show 31% higher Champions percentage

### 5.2 Temporal-Behavioral Patterns

**Seasonal Segment Behavior:**

- **Holiday Surge**: Champions segment shows revenue increase during November-December
- **Summer Patterns**: Watches & Gifts categories peak correlate with New customer acquisition
- **Retention Seasonality**: Customers acquired during holidays show better 6-month retention

------

## 6. Critical Business Challenges Identified

### 6.1 Customer Retention Crisis

**Challenge Magnitude:**

- **94% One-Time Purchasers**: Majority of customers never return
- **Rapid Churn**: 5% of customers retained after 1 month drops to 0.37% after 2 months
- **Revenue Impact**: Lost segment represents 2.3% of customers but only 4.2% of revenue

**Root Cause Analysis:**

- Insufficient onboarding for new customers
- Lack of engagement between purchases
- Generic marketing approach not addressing segment-specific needs

### 6.2 Geographic Market Penetration Gap

**Opportunity Analysis:**

- **Northern Brazil Underrepresentation**: <3% customer base vs 8.7% population
- **Delivery Performance Gap**: 12+ day average delivery in 40% of states
- **Urban-Rural Divide**: 78% of customers concentrated in 15 major cities

### 6.3 Category Cross-Selling Underutilization

**Missed Opportunities:**

- **Cross-Selling Gap**: Average 1.8 categories per customer vs 3.2 for Champions
- **Category Affinity Underexploited**: High-affinity categories not systematically promoted to relevant segments

------

## 7. Revenue Impact Quantification

### 7.1 Immediate Revenue Opportunities

**Short-Term Revenue Potential (6 months):**

| Initiative                     | Target Segment     | Estimated Impact         | Revenue Potential |
| ------------------------------ | ------------------ | ------------------------ | ----------------- |
| At Risk Retention Campaign     | At Risk (32,230)   | 30% retention            | 1,605,000 BRL     |
| New Customer Onboarding        | New (18,000)       | 10% repeat rate increase | 679,000 BRL       |
| Champions Loyalty Program      | Champions (2184)   | 5% AOV increase          | 121,540 BRL       |
| Geographic Expansion           | Underserved States | 5,000 new customers      | 725,000 BRL       |
| **Total Short term Potential** |                    |                          | 3,130,540 BRL     |

### 7.2 Long-Term Value Creation

**12-Month Revenue Projections:**

- **Customer Lifecycle Optimization**: 1,890,000 BRL potential through improved retention
- **Geographic Market Expansion**: 1,250,000 BRL from northern region development
- **Category Cross-Selling Program**: 890,000 BRL from multi-category engagement
- **Premium Segment Development**: 670,000 BRL from New-to-Loyal conversion

**Total Long-Term Revenue Opportunity: 4,700,000 BRL **

------

*Analysis Period: 2016-2018*
 *Customer Universe: 90,000+ Active Customers*
 *Revenue Analyzed: 16M BRL*
 *Geographic Coverage: All Brazilian States*
 *Categories Analyzed: 100+ Product Categories*