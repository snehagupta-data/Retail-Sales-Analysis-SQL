/* =========================================================
   📊 Retail Sales Analysis - SQL Portfolio Project
   Database: PostgreSQL
   Tool: pgAdmin 4
   Author: Sneha Gupta
   ========================================================= */


/* =========================================================
   1️⃣ DATABASE SETUP
   ========================================================= */

-- Run this once
CREATE DATABASE p1_retail_db;

-- After creating database:
-- 1. Refresh in pgAdmin
-- 2. Right click p1_retail_db → Connect
-- 3. Open Query Tool again


/* =========================================================
   2️⃣ TABLE CREATION
   ========================================================= */

DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales
(
    transaction_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);


/* =========================================================
   3️⃣ DATA EXPLORATION
   ========================================================= */

-- Total transactions
SELECT COUNT(*) AS total_transactions
FROM retail_sales;

-- Unique customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM retail_sales;

-- Available categories
SELECT DISTINCT category
FROM retail_sales;


/* =========================================================
   4️⃣ DATA CLEANING
   ========================================================= */

-- Check for NULL values
SELECT *
FROM retail_sales
WHERE 
    transaction_id IS NULL OR
    sale_date IS NULL OR
    sale_time IS NULL OR
    customer_id IS NULL OR
    gender IS NULL OR
    age IS NULL OR
    category IS NULL OR
    quantity IS NULL OR
    price_per_unit IS NULL OR
    cogs IS NULL OR
    total_sale IS NULL;

-- Remove incomplete records
DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL OR
    sale_date IS NULL OR
    sale_time IS NULL OR
    customer_id IS NULL OR
    gender IS NULL OR
    age IS NULL OR
    category IS NULL OR
    quantity IS NULL OR
    price_per_unit IS NULL OR
    cogs IS NULL OR
    total_sale IS NULL;


/* =========================================================
   5️⃣ CORE BUSINESS ANALYSIS
   ========================================================= */

-- Q1: Sales on specific date
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- Q2: Clothing transactions (Nov 2022) with quantity >= 4
SELECT *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND sale_date BETWEEN '2022-11-01' AND '2022-11-30'
    AND quantity >= 4;


-- Q3: Total Revenue by Category
SELECT 
    category,
    SUM(total_sale) AS total_revenue,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;


-- Q4: Average Age (Beauty category)
SELECT 
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';


-- Q5: High Value Transactions (> 1000)
SELECT *
FROM retail_sales
WHERE total_sale > 1000;


-- Q6: Transactions by Gender & Category
SELECT 
    category,
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;


-- Q7: Best Performing Month Per Year (Window Function)
SELECT 
    year,
    month,
    avg_sale
FROM 
(
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER(
            PARTITION BY EXTRACT(YEAR FROM sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rank
    FROM retail_sales
    GROUP BY 1,2
) AS ranked_data
WHERE rank = 1;


-- Q8: Top 5 Customers by Total Spending
SELECT 
    customer_id,
    SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;


-- Q9: Unique Customers per Category
SELECT 
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;


-- Q10: Sales by Shift (Morning / Afternoon / Evening)
WITH shift_data AS (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) AS total_orders
FROM shift_data
GROUP BY shift
ORDER BY total_orders DESC;


/* =========================================================
   🔥 6️⃣ ADVANCED ANALYSIS SECTION
   ========================================================= */


-- Advanced 1: Revenue Contribution Percentage by Category
SELECT 
    category,
    SUM(total_sale) AS total_revenue,
    ROUND(
        SUM(total_sale) * 100.0 
        / SUM(SUM(total_sale)) OVER(),
        2
    ) AS revenue_percentage
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;


-- Advanced 2: Customer Segmentation (High / Medium / Low)
WITH customer_spending AS (
    SELECT 
        customer_id,
        SUM(total_sale) AS total_spent
    FROM retail_sales
    GROUP BY customer_id
)
SELECT 
    customer_id,
    total_spent,
    CASE 
        WHEN total_spent >= 5000 THEN 'High Value'
        WHEN total_spent BETWEEN 2000 AND 4999 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_spending
ORDER BY total_spent DESC;


-- Advanced 3: Profit & Profit Margin by Category
SELECT 
    category,
    SUM(total_sale) AS total_revenue,
    SUM(cogs) AS total_cost,
    SUM(total_sale - cogs) AS total_profit,
    ROUND(
        (SUM(total_sale - cogs) * 100.0 / SUM(total_sale)),
        2
    ) AS profit_margin_percent
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;


/* =========================================================
   ✅ END OF PROJECT
   ========================================================= */