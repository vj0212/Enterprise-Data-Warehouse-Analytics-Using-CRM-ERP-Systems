CREATE VIEW gold.Customers_Report AS 

WITH Customers_Details AS (
SELECT
	Fact.Order_Number,
	Fact.Product_Key,
	Fact.Order_Date,
	Fact.Sales_Amount,
	Fact.Sales_Quantity,
	Customers_Dimension.Customer_Key,
	Customers_Dimension.Customer_Number,
	CONCAT(Customers_Dimension.First_Name, ' ',Customers_Dimension.Last_Name) AS Customer_Name,
	DATEDIFF(year,Customers_Dimension.Birth_Date, GETDATE()) AS Customer_Age
	
FROM gold.fact_sales AS Fact
LEFT JOIN gold.dim_customers AS Customers_Dimension
ON Customers_Dimension.Customer_Key = Fact.Customer_Key
WHERE Fact.Order_Date IS NOT NULL
)
, Customers_Details_Aggregation AS (
SELECT
	Customer_Key,
	Customer_Number,
	Customer_Name,
	Customer_Age,
	COUNT(DISTINCT Order_Number) AS Total_Orders,
	SUM(Sales_Amount) AS Total_Sales,
	SUM(Sales_Quantity) AS Total_Quantity,
	COUNT(DISTINCT Product_Key) AS Total_Products,
	MAX(Order_Date) AS Last_Order_Date,
	DATEDIFF(month,MIN(Order_Date),MAX(Order_Date)) AS Lifespan_As_Customers_In_Months
FROM Customers_Details
GROUP BY
    Customer_Key,
	Customer_Number,
	Customer_Name,
	Customer_Age
)
SELECT
    Customer_Key,
	Customer_Number,
	Customer_Name,
	Customer_Age,
	CASE WHEN Customer_Age BETWEEN 10 AND 40 THEN 'Young Age'
	     WHEN Customer_Age BETWEEN 40 AND 60 THEN 'Mid Age'
		 WHEN Customer_Age > 60 THEN 'Old Age'
	END AS Age_Group,
	CASE WHEN Lifespan_As_Customers_In_Months >= 12 AND Total_Sales > 5000 THEN 'VIP'
		 WHEN Lifespan_As_Customers_In_Months >= 12 AND Total_Sales <= 5000 THEN 'Regular'
		 ELSE 'New'
	END AS Customer_Segment,
	Total_Orders,
	Total_Sales,

	CASE WHEN Total_Sales = 0 THEN 0
	     ELSE Total_Sales / Total_Orders
	END AS Avg_Order_Value,

	Total_Quantity,
	Total_Products,
	Last_Order_Date,

	CASE WHEN Lifespan_As_Customers_In_Months = 0 THEN Total_Sales
	     ELSE Total_Sales / Lifespan_As_Customers_In_Months
	END AS Avg_Monthly_Expenditure,

	DATEDIFF(year,Last_Order_Date,GETDATE()) AS Years_Since_Last_Order,
	Lifespan_As_Customers_In_Months

FROM Customers_Details_Aggregation