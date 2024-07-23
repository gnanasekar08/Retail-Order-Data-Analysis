-- select * from df_orders

-- Find top 10 revenue generating products

select top 10 product_id, sum(sale_price) as revenue
from df_orders
group by product_id
order by sum(sale_price) desc

-- Find top 5 highest selling products in each region

With CTE as (select region, product_id, sum(sale_price) as sales
from df_orders
group by region,product_id)
select region, product_id, sales from 
(select *
, ROW_NUMBER() over(partition by region order by sales desc ) as rn
from CTE) A
where rn <=5


-- Find month over month comparison for 2022 and 2023 Sales eg : Jan 2022 vs Jan 2023
With CTE as (
select year(order_date) as order_year, month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date), month(order_date)
)
select order_month, 
sum(case when order_year = 2022 then sales else 0 end ) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end ) as sales_2023
from CTE
group by order_month 
order by order_month


-- For each category which month has highest sales
With CTE as (
select category, sum(sale_price) as sales, format(order_date, 'yyyyMM') as order_year_month
from df_orders
group by category, format(order_date, 'yyyyMM')
)
select category , sales, order_year_month  from (
select *,
row_number() over( partition by category order by sales desc) as rn
from CTE) A
where rn = 1



-- which subcategory had highest growth by profit in 2023 compare to 2022

With CTE as (
select sub_category, year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by year(order_date), sub_category
),
cte2 as (
select sub_category, 
sum(case when order_year = 2022 then sales else 0 end ) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end ) as sales_2023
from CTE
group by sub_category
)
select top 1 *
, (sales_2023 - sales_2022)*100 /sales_2022
from cte2
order by (sales_2023 - sales_2022)*100 /sales_2022 desc


