-- Exploring All Objects in the Database

SELECT * FROM INFORMATION_SCHEMA.TABLES ;
SELECT * FROM INFORMATION_SCHEMA.COLUMNS ;

SELECT DISTINCT Country
FROM gold.dim_customers
WHERE country NOT IN ('n/a', 'Detail Not Available');

SELECT DISTINCT 
Product_Category,
Product_Sub_Category,
Product_Name
FROM gold.dim_products
ORDER BY 1,2,3 ;
--**--**--**---**--**--**--**--**--**---**--**--**--**--**--**---**--**--**--**--**--**---**--**--**--**--**--**---**--**--**

SELECT 
MIN(Order_Date) AS Earliest_Order_Date,
MAX(Order_Date) AS Latest_Order_Date,
DATEDIFF(year, MIN(Order_Date), MAX(Order_Date)) AS Time_Span_Of_Sales_Orders_In_Years,
DATEDIFF(month, MIN(Order_Date), MAX(Order_Date)) AS Time_Span_Of_Sales_Orders_In_Months,
DATEDIFF(day, MIN(Order_Date), MAX(Order_Date)) AS Time_Span_Of_Sales_Orders_In_Days
FROM gold.fact_sales ;
--**--**--**---**--**--**--**--**--**---**--**--**--**--**--**---**--**--**--**--**--**---**--**--**--**--**--**---**--**--**

SELECT
MIN(Birth_Date) AS Oldest_Customer_BirthDate,
DATEDIFF(year, MIN(Birth_Date) , GETDATE()) AS Oldest_Customer_Age,
MAX(Birth_Date) AS Youngest_Customer_BirthDate,
DATEDIFF(year, MAX(Birth_Date) , GETDATE()) AS Youngest_Customer_Age
FROM gold.dim_customers;

--**--**--**---**--**--**--**--**--**---**--**--**--**--**--**---**--**--**--**--**--**---**--**--**--**--**--**---**--**--**
SELECT 
SUM(Sales_Amount) AS Total_Sales
FROM gold.fact_sales;

SELECT 
AVG(Sales_Price) AS Avg_Sales
FROM gold.fact_sales;

SELECT 
COUNT(DISTINCT Order_Number) AS Total_Orders
FROM gold.fact_sales;

SELECT 
COUNT (Product_Key)
FROM gold.dim_products;

SELECT
COUNT(Customer_Key) AS Total_Customers
FROM gold.dim_customers;

SELECT
COUNT(Customer_Key) AS Total_Customers
FROM gold.fact_sales;

SELECT
COUNT(DISTINCT Customer_Key) AS Total_Customers
FROM gold.fact_sales;

--**--**--**---**--**--**--**--**--**--**--**---**--**--**--**--**--**--**--**---**--**--**--**--**--**--**--**---**--**--**--**--**
SELECT 'Total Sales' AS Measure_Name,
       '$ ' + FORMAT(SUM(Sales_Amount), 'N2') AS Measure_Value
FROM gold.fact_sales

UNION ALL

SELECT 'Total Quantity',
       FORMAT(SUM(Sales_Quantity), 'N0')
FROM gold.fact_sales

UNION ALL

SELECT 'Average Price',
       '$ ' + FORMAT(AVG(Sales_Price), 'N2')
FROM gold.fact_sales

UNION ALL

SELECT 'Total Number Of Orders',
       FORMAT(COUNT(DISTINCT Order_Number), 'N0')
FROM gold.fact_sales

UNION ALL

SELECT 'Total Number Of Products',
       FORMAT(COUNT(Product_Key), 'N0')
FROM gold.dim_products

UNION ALL

SELECT 'Total Number Of Customers',
       FORMAT(COUNT(Customer_Key), 'N0')
FROM gold.dim_customers;

