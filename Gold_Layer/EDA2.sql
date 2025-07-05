SELECT
    Country AS Attributes,
    COUNT(Customer_Number) AS Total_Customers
FROM gold.dim_customers
WHERE Country != 'Detail Not Available'
GROUP BY Country

UNION ALL

SELECT
    Gender ,
    COUNT(Customer_Number) 
FROM gold.dim_customers
WHERE Gender != 'n/a' AND Gender IS NOT NULL
GROUP BY Gender

ORDER BY Total_Customers DESC;

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

SELECT
Product_Category,
COUNT(Product_Number) Total_Products
FROM gold.dim_products
GROUP BY Product_Category
ORDER BY Total_Products DESC;

SELECT
    Product_Category,
    '$' + FORMAT(AVG(Product_Cost), 'N2') AS Avg_Cost
FROM gold.dim_products
GROUP BY Product_Category
ORDER BY AVG(Product_Cost) DESC;

SELECT
    p.Product_Category,
    '$' + FORMAT(SUM(f.Sales_Amount), 'N2') AS Total_Revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.Product_Key = f.Product_Key
GROUP BY p.Product_Category
ORDER BY SUM(f.Sales_Amount) DESC;

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

SELECT TOP 300
    c.Customer_id,
    c.First_Name,
    c.Last_Name,
    '$' + FORMAT(SUM(f.Sales_Amount), 'N2') AS Total_Revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.Customer_Key = f.Customer_Key
GROUP BY 
c.Customer_id,
c.First_Name,
c.Last_Name
ORDER BY SUM(f.Sales_Amount) DESC;

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

WITH CountrySales AS (
    SELECT
        c.Country,
        SUM(f.Sales_Amount) AS Country_Total_Sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.Customer_Key = f.Customer_Key
    WHERE c.Country IS NOT NULL
    GROUP BY c.Country
),
TotalSales AS (
    SELECT SUM(Sales_Amount) AS Global_Total_Sales
    FROM gold.fact_sales
)

SELECT
    cs.Country,
    '$' + FORMAT(cs.Country_Total_Sales, 'N2') AS Country_Sales,
    FORMAT((cs.Country_Total_Sales * 100.0) / ts.Global_Total_Sales, 'N2') + '%' AS Sales_Percentage
FROM CountrySales cs
CROSS JOIN TotalSales ts
ORDER BY cs.Country_Total_Sales DESC;

--**--**--**--**--**--**--**--**--**--**--**--**--**--*--**--**--**--**--**--**--**--**--**--**--**--**--**--*--**--**--**--**--**--**--**--**--**--**--**--**--**--*

SELECT 
*
FROM 
(
SELECT
    p.Product_Name,
    '$' + FORMAT(SUM(f.Sales_Amount), 'N2') AS Total_Revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(f.Sales_Amount) DESC) AS Products_Ranking
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.Product_Key = f.Product_Key
GROUP BY p.Product_Name
) sub
WHERE Products_Ranking < =10;