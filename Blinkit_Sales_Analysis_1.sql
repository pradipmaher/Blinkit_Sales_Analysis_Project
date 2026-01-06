create database Blinkit_Sales_Analysis;
use Blinkit_Sales_Analysis;

# checking imported tables

SELECT * FROM customers;
SELECT * FROM delivery;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM rating;
SELECT * FROM transactions;


DESCRIBE blinkit_sales_view;


# modifying Order_date,created_date column dataype to date
ALTER TABLE orders 
MODIFY order_date DATE;

ALTER TABLE customers 
MODIFY created_date DATE;


#rename the columns those are with symbols

ALTER TABLE customers RENAME COLUMN ï»¿Customer_ID TO Customer_ID;
ALTER TABLE delivery RENAME COLUMN ï»¿DP_ID TO dp_ID;
ALTER TABLE orders RENAME COLUMN ï»¿Order_ID TO order_id;
ALTER TABLE products RENAME COLUMN ï»¿Product_ID TO product_id;
ALTER TABLE rating RENAME COLUMN ï»¿Rating_ID TO rating_ID;
ALTER TABLE transactions RENAME COLUMN ï»¿Transaction_ID TO transaction_ID;


# Creating View table for Power BI

CREATE OR REPLACE VIEW blinkit_sales_view AS
SELECT
    o.Order_ID,
    o.Order_Date,
    o.Order_Time,
    o.Quantity,
    o.Coupon,
    o.Coupon_Discount,

    c.Customer_ID,
    c.Customer_Name,
    c.Gender,
    c.Age,
    c.City,
    c.State,
    c.Created_Date AS Customer_Created_Date,

    -- Region derived from State
    CASE
        WHEN c.State IN ('Delhi','Punjab','Haryana','Uttar Pradesh','Rajasthan') THEN 'North'
        WHEN c.State IN ('Maharashtra','Gujarat','Goa') THEN 'West'
        WHEN c.State IN ('Karnataka','Tamil Nadu','Kerala','Telangana','Andhra Pradesh') THEN 'South'
        WHEN c.State IN ('West Bengal','Odisha','Bihar','Jharkhand') THEN 'East'
        ELSE 'Other'
    END AS Region,

    p.Product_ID,
    p.Product_Name,
    p.Category,
    p.Brand,
    p.Price,

    t.Transaction_ID,
    t.Transaction_Mode,
    t.Rewards,

    d.DP_ID,
    d.DP_name,
    d.DP_Ratings,
    d.Percent_Cut,

    r.Product_Rating,
    r.Service_Rating

FROM Orders o
JOIN Customers c 
    ON o.Customer_ID = c.Customer_ID
JOIN Products p 
    ON o.Product_ID = p.Product_ID
JOIN Transactions t 
    ON o.Order_ID = t.Order_ID
LEFT JOIN Delivery d 
    ON o.DP_ID = d.DP_ID
LEFT JOIN Ratings r 
    ON o.Order_ID = r.Order_ID;


# KPI Cards

-- total revenue
SELECT 
    SUM((Price * Quantity) - Coupon_Discount) AS Total_Revenue
FROM blinkit_sales_view;

-- Total Orders
SELECT 
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM blinkit_sales_view;

-- total Quantity Sold
SELECT 
    SUM(Quantity) AS Total_Quantity
FROM blinkit_sales_view;

-- Average Product Rating
SELECT 
    ROUND(AVG(Product_Rating),2) AS Avg_Product_Rating
FROM blinkit_sales_view
WHERE Product_Rating IS NOT NULL;

-- Average Service Rating
SELECT 
    ROUND(AVG(Service_Rating),2) AS Avg_Service_Rating
FROM blinkit_sales_view
WHERE Service_Rating IS NOT NULL;


#Time-Base Analysis

-- Daily Revenue Trend
SELECT
    Order_Date,
    SUM((Price * Quantity) - Coupon_Discount) AS Daily_Revenue
FROM blinkit_sales_view
GROUP BY Order_Date
ORDER BY Order_Date;

-- Monthly Revenue Trend
SELECT
    DATE_FORMAT(Order_Date,'%Y-%m') AS Month,
    SUM((Price * Quantity) - Coupon_Discount) AS Monthly_Revenue
FROM blinkit_sales_view
GROUP BY Month
ORDER BY Month;


# Product and Category Analysis

-- Top Products by Revenue
SELECT
    Product_Name,
    SUM((Price * Quantity) - Coupon_Discount) AS Revenue
FROM blinkit_sales_view
GROUP BY Product_Name
ORDER BY Revenue DESC
LIMIT 10;

-- Category-wise Performance
SELECT
    Category,
    SUM((Price * Quantity) - Coupon_Discount) AS Revenue,
    SUM(Quantity) AS Quantity_Sold
FROM blinkit_sales_view
GROUP BY Category
ORDER BY Revenue DESC;


# Customer Analysis

-- Orders by Gender
SELECT
    Gender,
    COUNT(DISTINCT Order_ID) AS Orders
FROM blinkit_sales_view
GROUP BY Gender;

-- Age Group Analysis
SELECT
    CASE
        WHEN Age < 25 THEN 'Under 25'
        WHEN Age BETWEEN 25 AND 35 THEN '25-35'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END AS Age_Group,
    SUM((Price * Quantity) - Coupon_Discount) AS Revenue
FROM blinkit_sales_view
GROUP BY Age_Group;


# Location Analysis

-- City-wise Analysis
SELECT
    City,
    SUM((Price * Quantity) - Coupon_Discount) AS Revenue
FROM blinkit_sales_view
GROUP BY City
ORDER BY Revenue DESC;

-- State-Wise Analysis
SELECT
    State,
    SUM((Price * Quantity) - Coupon_Discount) AS Revenue
FROM blinkit_sales_view
GROUP BY State
ORDER BY Revenue DESC;


-- Delievry-Partner Analysis

-- Orders Handled by Each Partner
SELECT
    DP_name,
    COUNT(DISTINCT Order_ID) AS Orders_Delivered
FROM blinkit_sales_view
GROUP BY DP_name;

-- Delivery Partner Earnings
SELECT
    DP_name,
    SUM((Price * Quantity) * Percent_Cut / 100) AS Partner_Earnings
FROM blinkit_sales_view
GROUP BY DP_name
ORDER BY Partner_Earnings DESC;

# Transaction Analysis

-- Payment Mode Usage
SELECT
    Transaction_Mode,
    COUNT(DISTINCT Order_ID) AS Orders
FROM blinkit_sales_view
GROUP BY Transaction_Mode;

-- Rewards Impact
SELECT
    Rewards,
    COUNT(DISTINCT Order_ID) AS Orders
FROM blinkit_sales_view
GROUP BY Rewards;



