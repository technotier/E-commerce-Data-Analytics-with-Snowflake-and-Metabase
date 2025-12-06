# E-commerce-Data-Analytics-with-Snowflake-and-Metabase
A production-ready data warehouse solution built with Snowflake for e-commerce business intelligence. This project implements modern data engineering practices to transform raw transactional data into actionable business insights.

# 🏗️ Architecture Overview
1. Dimension Tables (Master Data)
Purpose: Store descriptive attributes for business entities

dim_customers - Customer master with segmentation (RFM, value tiers, activity status)
dim_products - Product catalog with pricing, margins, and stock classification
dim_date - Complete calendar with business days, seasons, and holidays

2. Fact Tables (Transactional Data)
Purpose: Capture business events with quantitative metrics

fact_sales - Core sales transactions with financial calculations

>> Net amount, profit margins, discount analysis
>> Order size classification and status tracking
>> Foreign keys to all dimension tables

3. Internal Staging Layer
Purpose: Raw data transformation and standardization

>> stg_customers - Clean customer data from source systems
>> stg_products - Standardized product information
>> stg_orders - Order data validation and enrichment
>> stg_order_items - Line-item standardization
>> stg_categories - Product category hierarchy

4. Analytical Views
Purpose: Business-ready datasets for different teams

# Customer Analytics View
RFM segmentation (Recency, Frequency, Monetary)
Customer lifetime value calculations
Activity status and purchase patterns
Actionable retention strategies

# Executive View
Monthly KPI tracking with MoM growth
Profitability metrics and trend analysis
Performance scorecards with emoji indicators
Priority alerts for business issues

# Product Performance View
ABC analysis (Pareto principle)
Inventory turnover and stock health
Margin performance and discount impact
Strategic recommendations for product management

# 📈 18 Key Business Insights

# Customer Insights (6)

1. RFM Segmentation - Identify Champions vs At-Risk customers
2. Customer Lifetime Value - Predict future revenue from customer segments
3. Churn Prediction - Detect customers likely to leave based on activity patterns
4. Discount Sensitivity - Measure how price promotions affect buying behavior
5. Geographic Performance - Analyze sales by region/country
6. Customer Acquisition Cost - Track marketing efficiency by segment

# Product Insights (6)

1. ABC Analysis - Classify products by revenue contribution (80/20 rule)
2. Inventory Turnover - Identify fast vs slow-moving products
3. Margin Analysis - Track profitability across product categories
4. Seasonality Patterns - Detect seasonal demand fluctuations
5. Cross-Sell Opportunities - Find products frequently bought together
6. Stock Optimization - Smart reorder points based on sales velocity

# Sales & Financial Insights (6)

1. Monthly Growth Trends - Track MoM revenue and order growth
2. Average Order Value - Monitor customer spending patterns
3. Fulfillment Efficiency - Measure order success vs cancellation rates
4. Discount Impact - Analyze promotional effectiveness on margins
5. Peak Performance Periods - Identify best performing days/weeks
6. Customer Cohort Analysis - Track retention across signup periods



