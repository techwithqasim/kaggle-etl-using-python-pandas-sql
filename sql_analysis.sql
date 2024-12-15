CREATE DATABASE EDA;
GO;

USE EDA;
GO;

SELECT * FROM df_orders;

-- DROP TABLE AS ALL VALUES HAVE MAX VALUE INPUT

DROP TABLE df_orders;

-- CREATE SAME TABLE WITH CUSTOMS INPUT VALUES OF COLUMNS

CREATE TABLE df_orders (
		order_id INT PRIMARY KEY,
		order_date DATE,
		ship_mode VARCHAR(20),
		segment VARCHAR(20),
		country VARCHAR(20),
		city VARCHAR(20),
		state VARCHAR(20),
		postal_code VARCHAR(20),
		region VARCHAR(20),
		category VARCHAR(20),
		sub_category VARCHAR(20),
		product_id VARCHAR(50),
		quantity INT,
		discount DECIMAL(7,2),
		sale_price DECIMAL(7,2),
		profit DECIMAL(7,2));

-- NOW GO BACK AND APPEND ALL DATA FROM PANDAS AGAIN

SELECT * FROM df_orders;



-- Find TOP 10 Highest Revenue Generating Products

SELECT TOP 10 product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC;


-- Find TOP 5 Highest Selling Products in Each Region

WITH CTE AS (
SELECT region, product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY region,product_id)
SELECT * FROM (
SELECT *
, ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
FROM CTE) A
WHERE rn <= 5;


-- Find Month over Month Growth comparison for 2022 and 2023 sales eg: Jan 2022 vs Jan 2023

WITH CTE AS (
SELECT YEAR(order_date) AS order_year,
MONTH(order_date) AS order_month,
sum(sale_price) AS sales
FROM df_orders
GROUP BY YEAR(order_date),MONTH(order_date)
--order by YEAR(order_date),MONTH(order_date)
	)
SELECT order_month,
SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM CTE
GROUP BY order_month
ORDER BY order_month;


-- For Each Category Which Month Had Highest Sales 
WITH CTE AS (
SELECT category,FORMAT(order_date,'yyyyMM') AS order_year_month,
SUM(sale_price) AS sales 
FROM df_orders
GROUP BY category,FORMAT(order_date,'yyyyMM')
--order by category,format(order_date,'yyyyMM')
)
SELECT * FROM (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
from CTE
) A
WHERE rn=1;


-- Which Sub Category Had Highest Growth By Profit in 2023 compared to 2022

WITH CTE AS (
SELECT sub_category,YEAR(order_date) AS order_year,
SUM(sale_price) AS sales
FROM df_orders
GROUP BY sub_category,YEAR(order_date)
--order by YEAR(order_date),month(order_date)
	)
, CTE2 AS (
SELECT sub_category,
SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM CTE 
GROUP BY sub_category
)
SELECT TOP 1 *,
(sales_2023-sales_2022) AS profit_growth_difference
FROM  CTE2
ORDER BY (sales_2023-sales_2022) DESC;