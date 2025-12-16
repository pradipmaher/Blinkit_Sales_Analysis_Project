use blinkit_analysis;
select * from delivery;
select * from orders;
select * from products;
select * from rating;
select * from transcations;

select * from customers_clean;
alter table customers_clean rename to customers;


/* BASIC ANALYSIS */
/* A. Customer Analysis */
-- 1.	How are customers buying by gender across states, and what is the ratio of male to female customers?
select * from customers;


with count_gender as(
select 
	state,
    sum(case when gender="female" then 1 else 0 end) as female_count,
    sum(case when gender="male" then 1 else 0 end) as male_count
from customers 
group by state 
having female_count >0
and male_count>0)
 select * , round((male_count/female_count),2) as gender_ratio from count_gender
 group by state;


-- 2.	What are the youngest and oldest customers (based on Age Group) in each city, and how many customers are there per city, along with average spending?
select * from customers;

select
	city,
    case 
		when age between 0 and 18 then '0-18'
        when age between 19 and 30 then '19-30'
        when age between 31 and 45 then '31-45'
        when age between 46 and 60 then '46-60'
        else '60+'
	end as age_group,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city, age_group
ORDER BY city, age_group;

-- 3.	Which cities have the most and fewest young customers (all young customers under 25) and divide it by gender,statewise ?
select * from customers;

with young_customers as (
	select 
		state,
        city,
        sum(case when gender = "male" then 1 else 0 end) as male_count,
        sum(case when gender ="female" then 1 else 0 end) as female_count,
        count(*) as total_young
	from customers
    where age< 25
    group by state,city
)
select * from young_customers;

-- 4.	Which states have the highest number of customers, also divide by quarter by quarter (top 15)?
select * from customers;

select state, count(*) as total_customers
from customers
group by state
order by  total_customers desc;

-- 5.	How does the percentage of all gender based customers change monthly compared to the previous month?
select  * from customers;

select sum(case when gender="male" then 1 else 0 end) as male_count,
sum(case when gender="female" then 1 else 0 end) as female_count 
from customers;


-- 6.	Which state has customers with the widest  average spending for
-- 7.   Divide the customer into different age group and count their based on each city and identify top 20
select  * from customers;

select 
	city,
    count(c_id) as total_customers,
    case 
    when age between 0 and 18 then "0-18"
    when age between 19 and 30 then "19-30"
    when age between 31 and 45 then "31-45"
    when age between 46 and 60 then "46-60"
    else "60+"
    end as age_group
   
from customers
group by city,age_group
order by total_customers desc limit 20;
	
-- 8.	Group customers into age brackets (e.g., 18–25, 26–35) and count how many fall into each bracket by brand, along with average spending.
select * from customers;
select * from products;
select * from orders;


select p.brand,
	round(avg(p.price),2) as avg_price,
    case
		when c.age between 0 and 17 then "0-17"
        when c.age between 18 and 25 then "18-25"
        when c.age between 26 and 45 then "26-45"
        when c.age between 46 and 59 then "46-59"
        else "60+"
        end as age_group
from customers c 
join orders o
on c.C_ID=o.C_ID
join products p
on p.P_ID=o.P_ID
group by brand,age_group
order by avg_price;

-- 9.	Who are the top 50 customers with the most favourite brand, orders and average spending,based on spending ?
select * from customers;
select * from products;
select * from orders;


select
	c.CName,
	p.brand,
    count(or_id) as total_orders,
    round(avg(p.price),2) as avg_spending
from customers c
join orders o
on c.C_ID=o.C_ID
join products p
on p.P_ID=o.P_ID
group by brand,CName
order by avg_spending desc limit 50;
    

/* Advanced Analysis */
-- 1.	Which product has the most orders and which one is least ,highest quantity sold, best rating, highest sales, categorywise, in different region ?

-- 1 Product with Most Orders & Least Orders
select * from products;
select * from orders;

select p.pname,
       count(o.order_id) astotal_orders
from orders o
join products p on o.product_id = p.product_id
group by p.pname
order by total_orders desc;

-- 2 Product with Highest Quantity Sold
select * from orders;
select * from products;
select * from rating;

select p.pname,
       sum(o.quantity) as total_quantity
from rating r
join orders o
on o.order_id=r.order_id
join products p 
on o.product_id = p.product_id
group by p.pname
order by total_quantity desc;
 
 -- 3 Product with Best Rating
 select * from orders;
select * from products;
select * from rating;

 select p.product_name,
       round(avg(r.prod_rating),2) as avg_rating
from rating r
join orders o
on o.order_id=r.order_id
join products p 
on o.product_id = p.product_id
group by p.product_name
order by avg_rating desc;

-- 4️ Product with Highest Sales
select * from products;
select * from orders;

select p.product_name,
       sum(o.sales_amount) as total_sales
from orders o
join products p on o.product_id = p.product_id
group by p.product_name
order by  total_sales desc;

-- 5️ Category-wise Best Product (by Sales)
select * from products;
select * from customers;
select * from orders;
alter table products rename column pname to product_name;


with cte as (
  select p.category,
         p.product_name,
         sum(p.price) as total_sales,
         Rank() over (partition by p.category order by sum(p.price) desc) as rnk
  from orders o
  join products p on  o.product_id = p.product_id
  group by p.category, p.product_name
)
select category, product_name, total_sales
from cte
Where rnk = 1;

-- 2.	How do delivery partners perform in orders,quantity ,revenue, ratings , find top 5 states for each partner  ?
-- 1️ Delivery Partner Performance
select * from orders;
select * from rating;
select * from transcations;
select * from delivery;
select * from products;
select * from rating;

select dp.partner_name,
       count(o.order_id) as total_orders,
       sum(o.quantity) as total_quantity,
       sum(o.quantity*p.price) as total_revenue,
       round(avg(r.partner_rating), 2) as avg_rating
from products p
join orders o
	on p.product_id=o.product_id
join delivery dp
     on o.partner_id = dp.partner_id
join rating r
	on o.order_id=r.order_id
group by dp.partner_name
order by total_revenue desc;

-- 3.	How do order and revenue patterns along with its percentage in different company , Monthwise, in different region ? 
SELECT c.company_name,
       DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       COUNT(o.order_id) AS total_orders,
       SUM(o.revenue)    AS total_revenue
FROM orders o
JOIN companies c
     ON o.company_id = c.company_id
GROUP BY c.company_name, month
ORDER BY month, total_revenue DESC;

-- 4.	How does revenue vary by month for each delivery partner ?
SELECT dp.partner_name,
       DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       SUM(o.revenue) AS total_revenue
FROM orders o
JOIN delivery_partners dp
     ON o.partner_id = dp.partner_id
GROUP BY dp.partner_name, month
ORDER BY dp.partner_name, month;

-- 5.	Which months were most and least profitable for delivery partners, region by region?
WITH monthly_rev AS (
  SELECT dp.partner_name,
         o.region,
         DATE_FORMAT(o.order_date, '%Y-%m') AS month,
         SUM(o.revenue) AS total_revenue
  FROM orders o
  JOIN delivery_partners dp
       ON o.partner_id = dp.partner_id
  GROUP BY dp.partner_name, o.region, month
)
SELECT * FROM monthly_rev;


WITH monthly_rev AS (
  SELECT dp.partner_name,
         o.region,
         DATE_FORMAT(o.order_date, '%Y-%m') AS month,
         SUM(o.revenue) AS revenue
  FROM orders o
  JOIN delivery_partners dp
       ON o.partner_id = dp.partner_id
  GROUP BY dp.partner_name, o.region, month
),
ranked AS (
  SELECT *,
         RANK() OVER (
           PARTITION BY partner_name, region
           ORDER BY revenue DESC
         ) AS high_rank,
         RANK() OVER (
           PARTITION BY partner_name, region
           ORDER BY revenue ASC
         ) AS low_rank
  FROM monthly_rev
)
SELECT partner_name,
       region,
       month,
       revenue,
       CASE
         WHEN high_rank = 1 THEN 'Most Profitable'
         WHEN low_rank = 1  THEN 'Least Profitable'
       END AS performance
FROM ranked
WHERE high_rank = 1 OR low_rank = 1
ORDER BY partner_name, region;



WITH region_month_rev AS (
  SELECT o.region,
         DATE_FORMAT(o.order_date, '%Y-%m') AS month,
         SUM(o.revenue) AS revenue
  FROM orders o
  GROUP BY o.region, month
),
ranked AS (
  SELECT *,
         RANK() OVER (
           PARTITION BY region ORDER BY revenue DESC
         ) AS high_rnk,
         RANK() OVER (
           PARTITION BY region ORDER BY revenue ASC
         ) AS low_rnk
  FROM region_month_rev
)
SELECT region,
       month,
       revenue,
       CASE
         WHEN high_rnk = 1 THEN 'Most Profitable'
         WHEN low_rnk = 1  THEN 'Least Profitable'
       END AS performance
FROM ranked
WHERE high_rnk = 1 OR low_rnk = 1;

-- 6.	Which company sell best and worst in each state, quarter by quarter, based on order , also finding its quantity, rating and revenue?
WITH base AS (
  SELECT c.company_name,
         o.state,
         CONCAT(YEAR(o.order_date), '-Q', QUARTER(o.order_date)) AS quarter,
         COUNT(o.order_id) AS total_orders,
         SUM(o.quantity)   AS total_quantity,
         SUM(o.revenue)    AS total_revenue,
         ROUND(AVG(o.rating), 2) AS avg_rating
  FROM orders o
  JOIN companies c
       ON o.company_id = c.company_id
  GROUP BY c.company_name, o.state, quarter
)
SELECT * FROM base;


WITH base AS (
  SELECT c.company_name,
         o.state,
         CONCAT(YEAR(o.order_date), '-Q', QUARTER(o.order_date)) AS quarter,
         COUNT(o.order_id) AS orders,
         SUM(o.quantity)   AS quantity,
         SUM(o.revenue)    AS revenue,
         ROUND(AVG(o.rating), 2) AS rating
  FROM orders o
  JOIN companies c
       ON o.company_id = c.company_id
  GROUP BY c.company_name, o.state, quarter
),
ranked AS (
  SELECT *,
         RANK() OVER (
           PARTITION BY state, quarter
           ORDER BY orders DESC
         ) AS best_rank,
         RANK() OVER (
           PARTITION BY state, quarter
           ORDER BY orders ASC
         ) AS worst_rank
  FROM base
)
SELECT company_name,
       state,
       quarter,
       orders,
       quantity,
       revenue,
       rating,
       CASE
         WHEN best_rank = 1 THEN 'Best Seller'
         WHEN worst_rank = 1 THEN 'Worst Seller'
       END AS performance
FROM ranked
WHERE best_rank = 1 OR worst_rank = 1
ORDER BY state, quarter;


RANK() OVER (
  PARTITION BY state, quarter
  ORDER BY revenue DESC
) AS revenue_rank

-- 7.	Which companies dominate sales in which city, and which struggle, in different region 
WITH city_sales AS (
  SELECT c.company_name,
         o.city,
         o.region,
         SUM(o.revenue) AS total_revenue
  FROM orders o
  JOIN companies c
       ON o.company_id = c.company_id
  GROUP BY c.company_name, o.city, o.region
)
SELECT * FROM city_sales;


WITH city_sales AS (
  SELECT c.company_name,
         o.city,
         o.region,
         SUM(o.revenue) AS revenue
  FROM orders o
  JOIN companies c
       ON o.company_id = c.company_id
  GROUP BY c.company_name, o.city, o.region
),
ranked AS (
  SELECT *,
         RANK() OVER (
           PARTITION BY city, region
           ORDER BY revenue DESC
         ) AS top_rank,
         RANK() OVER (
           PARTITION BY city, region
           ORDER BY revenue ASC
         ) AS low_rank
  FROM city_sales
)
SELECT company_name,
       city,
       region,
       revenue,
       CASE
         WHEN top_rank = 1 THEN 'Dominates Sales'
         WHEN low_rank = 1 THEN 'Struggles'
       END AS performance
FROM ranked
WHERE top_rank = 1 OR low_rank = 1
ORDER BY region, city;


COUNT(o.order_id) AS total_orders


ORDER BY total_orders DESC

-- 8.	How do monthly trends (MOM) in orders, quantities, sales, compare tier over tier

WITH monthly_data AS (
  SELECT tier,
         DATE_FORMAT(order_date, '%Y-%m') AS month,
         COUNT(order_id) AS orders,
         SUM(quantity)   AS quantity,
         SUM(revenue)    AS sales
  FROM orders
  GROUP BY tier, month
)
SELECT *
FROM monthly_data
ORDER BY tier, month;



WITH monthly_data AS (
  SELECT tier,
         DATE_FORMAT(order_date, '%Y-%m') AS month,
         COUNT(order_id) AS orders,
         SUM(quantity)   AS quantity,
         SUM(revenue)    AS sales
  FROM orders
  GROUP BY tier, month
)
SELECT tier,
       month,
       orders,
       orders - LAG(orders)
         OVER (PARTITION BY tier ORDER BY month) AS mom_orders_change,
       quantity,
       quantity - LAG(quantity)
         OVER (PARTITION BY tier ORDER BY month) AS mom_quantity_change,
       sales,
       sales - LAG(sales)
         OVER (PARTITION BY tier ORDER BY month) AS mom_sales_change
FROM monthly_data
ORDER BY tier, month;



WITH monthly_data AS (
  SELECT tier,
         DATE_FORMAT(order_date, '%Y-%m') AS month,
         COUNT(order_id) AS orders,
         SUM(quantity)   AS quantity,
         SUM(revenue)    AS sales
  FROM orders
  GROUP BY tier, month
)
SELECT tier,
       month,
       ROUND(
         (orders - LAG(orders) OVER (PARTITION BY tier ORDER BY month))
         * 100.0 / LAG(orders) OVER (PARTITION BY tier ORDER BY month), 2
       ) AS orders_mom_pct,
       ROUND(
         (quantity - LAG(quantity) OVER (PARTITION BY tier ORDER BY month))
         * 100.0 / LAG(quantity) OVER (PARTITION BY tier ORDER BY month), 2
       ) AS quantity_mom_pct,
       ROUND(
         (sales - LAG(sales) OVER (PARTITION BY tier ORDER BY month))
         * 100.0 / LAG(sales) OVER (PARTITION BY tier ORDER BY month), 2
       ) AS sales_mom_pct
FROM monthly_data
ORDER BY tier, month;



WITH monthly_data AS (
  SELECT tier,
         DATE_FORMAT(order_date, '%Y-%m') AS month,
         COUNT(order_id) AS orders,
         SUM(revenue) AS sales
  FROM orders
  GROUP BY tier, month
)
SELECT month,
       tier,
       orders,
       sales,
       ROUND(
         sales * 100.0 /
         SUM(sales) OVER (PARTITION BY month), 2
       ) AS sales_share_pct
FROM monthly_data
ORDER BY month, tier;

-- 9.	How do delivery partner earnings vary by month (MOM) ?

SELECT dp.partner_name,
       DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       SUM(o.partner_earning) AS total_earning
FROM orders o
JOIN delivery_partners dp
     ON o.partner_id = dp.partner_id
GROUP BY dp.partner_name, month
ORDER BY dp.partner_name, month;


WITH monthly_earnings AS (
  SELECT dp.partner_name,
         DATE_FORMAT(o.order_date, '%Y-%m') AS month,
         SUM(o.partner_earning) AS earnings
  FROM orders o
  JOIN delivery_partners dp
       ON o.partner_id = dp.partner_id
  GROUP BY dp.partner_name, month
)
SELECT partner_name,
       month,
       earnings,
       earnings - LAG(earnings)
         OVER (PARTITION BY partner_name ORDER BY month) AS mom_change
FROM monthly_earnings
ORDER BY partner_name, month;


WITH monthly_earnings AS (
  SELECT dp.partner_name,
         DATE_FORMAT(o.order_date, '%Y-%m') AS month,
         SUM(o.partner_earning) AS earnings
  FROM orders o
  JOIN delivery_partners dp
       ON o.partner_id = dp.partner_id
  GROUP BY dp.partner_name, month
)
SELECT partner_name,
       month,
       earnings,
       ROUND(
         (earnings - LAG(earnings)
           OVER (PARTITION BY partner_name ORDER BY month))
         * 100.0 /
         LAG(earnings)
           OVER (PARTITION BY partner_name ORDER BY month),
       2) AS mom_growth_pct
FROM monthly_earnings
ORDER BY partner_name, month;


WITH monthly_earnings AS (
  SELECT dp.partner_name,
         DATE_FORMAT(o.order_date, '%Y-%m') AS month,
         SUM(o.partner_earning) AS earnings
  FROM orders o
  JOIN delivery_partners dp
       ON o.partner_id = dp.partner_id
  GROUP BY dp.partner_name, month
),
ranked AS (
  SELECT *,
         RANK() OVER (
           PARTITION BY partner_name ORDER BY earnings DESC
         ) AS high_rank,
         RANK() OVER (
           PARTITION BY partner_name ORDER BY earnings ASC
         ) AS low_rank
  FROM monthly_earnings
)
SELECT partner_name,
       month,
       earnings,
       CASE
         WHEN high_rank = 1 THEN 'Highest Earning Month'
         WHEN low_rank = 1  THEN 'Lowest Earning Month'
       END AS performance
FROM ranked
WHERE high_rank = 1 OR low_rank = 1
ORDER BY partner_name;
