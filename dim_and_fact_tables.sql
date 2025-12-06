use warehouse ecommerce_wh;
use database db_ecommerce;

-- create dim customers 
create or replace table analytics_schema.dim_customers as 
select
id,
concat(first_name, ' ', last_name) as customer_name,
email,
phone,
city,
country,
gender,
signup_date,
datediff('days', signup_date, current_date()) as days_as_customer,
case 
    when datediff('days', signup_date, current_date()) >= 730 then 'Super Loyal'
    when datediff('days', signup_date, current_date()) >= 365 then 'Loyal'
    when datediff('days', signup_date, current_date()) >= 180 then 'Champion'
    when datediff('days', signup_date, current_date()) >= 90 then 'Regular'
    when datediff('days', signup_date, current_date()) >= 45 then 'New'
    else 'Very New'
end as customer_segment
from 
raw_schema.customers;

-- create dim products 
create or replace table analytics_schema.dim_products as 
select
c.id as category_id,
c.category_name as category_name,
p.id as product_id,
p.product_name as product_name,
p.sale_price,
p.cost_price,
p.sale_price - p.cost_price as profit_margin,
round((p.sale_price - p.cost_price) * 100.0 / nullif(p.sale_price, 0), 2) as profit_percent,
p.stock_quantity,
case 
    when p.stock_quantity >= 100 then 'High Stock'
    when p.stock_quantity >= 50 then 'Moderate'
    when p.stock_quantity >= 25 then 'Medium'
    when p.stock_quantity >= 10 then 'Low'
    when p.stock_quantity >= 1 then 'Very Low'
    when p.stock_quantity = 0 then 'Out of Stock'
end as stock_status,
case 
    when p.sale_price >= 1000 then 'Luxuray'
    when p.sale_price >= 800 then 'Premium'
    when p.sale_price >= 500 then 'High'
    when p.sale_price >= 250 then 'In Budget'
    when p.sale_price >= 100 then 'Economy'
    else 'Low Price'
end as price_segment,
case 
    when (p.sale_price - p.cost_price) * 100.0 / nullif(p.sale_price, 0) > 75 then 'Very High'
    when (p.sale_price - p.cost_price) * 100.0 / nullif(p.sale_price, 0) > 50 then 'High Margin'
    when (p.sale_price - p.cost_price) * 100.0 / nullif(p.sale_price, 0) > 25 then 'Moderate'
    when (p.sale_price - p.cost_price) * 100.0 / nullif(p.sale_price, 0) > 10 then 'Medium'
    else 'Low Margin'
end as margin_category
from 
raw_schema.category c join raw_schema.products p on 
c.id = p.category_id;

-- dim date table
CREATE OR REPLACE TABLE analytics_schema.dim_date AS
WITH 
order_dates_cte AS (
    SELECT DISTINCT order_date
    FROM raw_schema.orders
),
date_range_cte AS (
    SELECT 
        MIN(order_date) as start_date,
        MAX(order_date) as end_date
    FROM order_dates_cte
),
all_dates_cte AS (
    SELECT 
        DATEADD('day', SEQ4(), (SELECT start_date FROM date_range_cte)) as full_date
    FROM TABLE(GENERATOR(ROWCOUNT => 10000))
    WHERE full_date <= (SELECT end_date FROM date_range_cte)
),
final_cte AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY full_date) as date_key,
        full_date as order_date,
        YEAR(full_date) as year,
        MONTH(full_date) as month_num,
        MONTHNAME(full_date) as month,
        QUARTER(full_date) as quarter_num,
        'Q' || QUARTER(full_date) as quarter,
        DAYOFWEEK(full_date) as day_of_week,
        CASE 
            WHEN DAYOFWEEK(full_date) = 1 THEN 'Monday'
            WHEN DAYOFWEEK(full_date) = 2 THEN 'Tuesday'
            WHEN DAYOFWEEK(full_date) = 3 THEN 'Wednesday'
            WHEN DAYOFWEEK(full_date) = 4 THEN 'Thursday'
            WHEN DAYOFWEEK(full_date) = 5 THEN 'Friday'
            WHEN DAYOFWEEK(full_date) = 6 THEN 'Saturday'
            WHEN DAYOFWEEK(full_date) = 7 THEN 'Sunday'
        END as week_name,
        CASE 
            WHEN MONTH(full_date) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(full_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(full_date) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Fall'
        END as season,
        CASE 
            WHEN DAYOFWEEK(full_date) IN (6, 7) THEN 'Weekend'
            ELSE 'Weekday'
        END as day_category,
        CASE 
            WHEN MONTH(full_date) = 1 AND DAY(full_date) = 1 THEN 'New Year'
            WHEN MONTH(full_date) = 12 AND DAY(full_date) = 25 THEN 'Christmas'
            ELSE NULL 
        END as holiday_name
    FROM all_dates_cte
)
SELECT * FROM final_cte
ORDER BY order_date;

-- face sales
create or replace table analytics_schema.fact_sales as 
select
o.id as order_id,
o.customer_id,
o.order_date,
o.order_status,
oi.id as order_item_id,
oi.product_id,
oi.quantity,
oi.unit_price,
oi.discounts,
case 
    when oi.discounts > 0 then 'Discounted'
    else 'Full Price'
end as discount_flag,
oi.quantity * oi.unit_price as gross_amount,
(oi.quantity * oi.unit_price) - oi.discounts as net_amount,
oi.quantity * dp.cost_price as total_cost,
net_amount - total_cost as net_profit_amount,
case 
    when oi.quantity >= 10 then 'Bulk Order'
    when oi.quantity >= 5 then 'Mid Size'
    when oi.quantity >= 2 then 'Small Order'
    else 'Single Order'
end as order_size
from 
raw_schema.orders o join raw_schema.order_items oi on 
o.id = oi.order_id join analytics_schema.dim_products dp on 
dp.product_id = oi.product_id;


