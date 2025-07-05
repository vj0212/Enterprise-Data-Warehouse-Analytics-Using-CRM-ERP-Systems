SELECT 
FORMAT(Order_Date, 'yyyy-MMMM') AS Commercial_Period,
'$' + FORMAT(SUM(Sales_Amount), 'N2') AS Total_Sales,
COUNT(DISTINCT(Customer_Key)) AS Total_Customers,
COUNT(Sales_Quantity) AS Total_Quantity
FROM gold.fact_sales
WHERE Order_Date IS NOT NULL
GROUP BY FORMAT(Order_Date, 'yyyy-MMMM')
ORDER BY FORMAT(Order_Date, 'yyyy-MMMM');

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
SELECT
		Commercial_Period,
		'$' + FORMAT(Total_Sales , 'N2') AS Total_Sales,
'$' + FORMAT(SUM( Total_Sales) OVER ( ORDER BY Commercial_Period), 'N2') AS Cumulative_Total_Sales,
'$' + FORMAT(AVG( Average_Price) OVER ( ORDER BY Commercial_Period), 'N2') AS Cumulative_Average_Sales
FROM 
(
SELECT
DATETRUNC(year,Order_Date) AS Commercial_Period,
SUM(Sales_Amount) AS Total_Sales,
AVG(Sales_Price) as Average_Price
FROM gold.fact_sales
WHERE Order_Date IS NOT NULL
GROUP BY DATETRUNC (year, Order_Date)
) sub;

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

WITH Yearly_Product_Sales AS 
(
SELECT
YEAR(f.Order_Date) AS Order_Year,
p.Product_Name,
SUM(f.Sales_Amount) AS Current_Sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.Product_Key = p.Product_Key
WHERE f.Order_Date IS NOT NULL
GROUP BY
YEAR(f.Order_Date) ,
p.Product_Name
)
SELECT
		Order_Year,
		Product_Name,
		Current_Sales,
		AVG(Current_Sales) OVER (PARTITION BY Product_Name) AS Average_Sales,
	  CASE
      WHEN Current_Sales - AVG(Current_Sales) OVER (PARTITION BY Product_Name) > 10000 THEN 'Very Good'
      WHEN Current_Sales - AVG(Current_Sales) OVER (PARTITION BY Product_Name) > 1000 THEN 'Good'
      WHEN Current_Sales - AVG(Current_Sales) OVER (PARTITION BY Product_Name) BETWEEN -1000 AND 1000 THEN 'Average'
      WHEN Current_Sales - AVG(Current_Sales) OVER (PARTITION BY Product_Name) > -10000 THEN 'Bad'
      ELSE 'Very Bad'
      END AS Sales_Performance,
      Current_Sales - AVG(Current_Sales) OVER (PARTITION BY Product_Name)  AS Product_Performance_Value,
	  LAG(Current_Sales) OVER (PARTITION BY Product_Name ORDER BY Order_Year) AS Past_Yearl_Performance,
	  Current_Sales - LAG(Current_Sales) OVER (PARTITION BY Product_Name ORDER BY Order_Year)  AS Yearly_Performance_Change     
FROM Yearly_Product_Sales
ORDER BY Product_Name, Order_Year;

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--****--**--**--**--**--**--**--****--**--**--**--**--**--**--**
WITH Category_Sales AS (
SELECT
	Product_Category,
	SUM(Sales_Amount) Total_Sales

FROM gold.fact_sales AS Fact
LEFT JOIN gold.dim_products AS Dimension
ON Dimension.Product_Key = Fact.Product_Key
GROUP BY Product_Category
)
SELECT
	Product_Category,
	Total_Sales,
	SUM(Total_Sales) OVER() AS Overall_Sales,
	CONCAT(ROUND((CAST(Total_Sales AS FLOAT) / SUM(Total_Sales) OVER() )*100,2), '%') AS Category_Sales_Distribution
FROM Category_Sales
ORDER BY Category_Sales_Distribution DESC;

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--****--**--**--**--**--**--**--****--**--**--**--**--**--**--**
WITH Product_Segments AS (
SELECT
Product_Key,
Product_Name,
Product_Cost,
CASE WHEN Product_Cost < 100 THEN 'Below 100'
     WHEN Product_Cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN Product_Cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END AS Cost_Range
FROM gold.dim_products
)
SELECT
Cost_Range,
COUNT(Product_Key) AS Total_Customers
FROM Product_Segments
GROUP BY Cost_Range 
ORDER BY Total_Customers DESC;

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--****--**--**--**--**--**--**--****--**--**--**--**--**--**--**
WITH Customer_Expenditure AS (
SELECT
	Customer_Dimension.Customer_Key,
	SUM(Fact.Sales_Amount) AS Total_Spending,
	MIN(Order_Date) AS First_Order,
	MAX(Order_Date) AS Last_Order,
	DATEDIFF(month,MIN(Order_Date),MAX(Order_Date)) AS Lifespan_In_Months

FROM gold.fact_sales AS Fact
LEFT JOIN gold.dim_customers Customer_Dimension
ON Fact.Customer_Key = Customer_Dimension.Customer_Key
GROUP BY Customer_Dimension.Customer_Key
)
SELECT 
	Customer_Segment,
	COUNT(Customer_Key) AS Total_Customers_Per_Segment
FROM(
SELECT
	Customer_Key,
	Total_Spending,
	Lifespan_In_Months,
	CASE WHEN Lifespan_In_Months >= 12 AND Total_Spending > 5000 THEN 'VIP'
		 WHEN Lifespan_In_Months >= 12 AND Total_Spending <= 5000 THEN 'Regular'
		 ELSE 'New'
	END AS Customer_Segment
FROM Customer_Expenditure) sub
GROUP BY Customer_Segment
ORDER BY Total_Customers_Per_Segment DESC;