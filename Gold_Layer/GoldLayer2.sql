SELECT 
*
FROM gold.dim_customers;

SELECT DISTINCT
Gender
FROM gold.dim_customers;

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY Product_Info.prd_start_dt, Product_Info.prd_key) AS Product_Key,
	Product_Info.prd_id AS Product_Id,
	Product_Info.prd_key AS Product_Number,
	Product_Info.prd_nm AS Product_Name,
	Product_Info.cat_id AS Category_Id,

	CASE WHEN Product_Category.cat IS NULL THEN 'Information Not Available'
	ELSE Product_Category.cat
	END AS Product_Category,

	CASE WHEN Product_Category.subcat IS NULL THEN 'Information Not Available'
	ELSE Product_Category.subcat
	END AS Product_Sub_Category,

	CASE WHEN Product_Category.maintenance  IS NULL THEN 'Information Not Available'
	ELSE Product_Category.maintenance 
	END AS Product_Maintenance,

	Product_Info.prd_cost AS Product_Cost,
	Product_Info.prd_line AS Prduct_Line,
	Product_Info.prd_start_dt AS Shipping_Date
	
FROM silver.crm_prd_info AS Product_Info
LEFT JOIN silver.erp_px_cat_g1v2 AS Product_Category
ON Product_Info.cat_id = Product_Category.id
WHERE prd_end_dt IS NULL; -- To Filter Out All Historical Data

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
-- Use the dimension's surrogate keys instead of IDs to easily cnnect facts with dimensions

CREATE VIEW gold.fact_sales AS
SELECT

	Sales_Details.sls_ord_num AS Order_Number,
	Products.Product_Key,
	Customers.Customer_Key,
	Sales_Details.sls_order_dt AS Order_Date,
	Sales_Details.sls_ship_dt AS Shipping_Date,
	Sales_Details.sls_due_dt AS Due_Date,
	Sales_Details.sls_sales AS Sales_Amount,
	Sales_Details.sls_quantity AS Sales_Quantity,
	Sales_Details.sls_price AS Sales_Price

FROM silver.crm_sales_details AS Sales_Details
LEFT JOIN gold.dim_products AS Products
ON Sales_Details.sls_prd_key = Products.Product_Number
LEFT JOIN gold.dim_customers AS Customers
ON Sales_Details.sls_cust_id = Customers.Customer_id;
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--Foreign key Integrity (Dimensions)
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.Customer_Key = f.Customer_Key
LEFT JOIN gold.dim_products p
ON p.Product_Key = f.Product_Key
WHERE c.Customer_Key IS NULL OR p.Product_Key IS NULL;