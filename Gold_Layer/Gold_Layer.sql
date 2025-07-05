CREATE VIEW gold.dim_customers AS

SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS Customer_Key,
	Cst_Info.cst_id AS Customer_id,
	Cst_Info.cst_key AS Customer_Number,
	Cst_Info.cst_firstname AS First_Name,
	Cst_Info.cst_lastname AS Last_Name,
	Cst_Attributes.bdate AS Birth_Date,
	Cst_Location.cntry AS Country,
	Cst_Info.cst_marital_status AS Marital_Status,
	CASE WHEN Cst_Info.cst_gndr != 'n/a' THEN Cst_Info.cst_gndr
	ELSE COALESCE(Cst_Attributes.gen, 'n/a')
	END AS Gender,
	Cst_Info.cst_create_date AS Create_Date

FROM silver.crm_cust_info AS Cst_Info
LEFT JOIN silver.erp_cust_az12 AS Cst_Attributes
ON Cst_Info.cst_key = Cst_Attributes.cid
LEFT JOIN silver.erp_loc_a101 Cst_Location
ON Cst_Info.cst_key = Cst_Location.cid;

--After Joining table,check if any duplicates were introduced by the join logic.

--Check Duplicates after joining :
SELECT 
cst_id,
COUNT(*) 
FROM 
(SELECT
	Cst_Info.cst_id,
	Cst_Info.cst_key,
	Cst_Info.cst_firstname,
	Cst_Info.cst_lastname,
	Cst_Info.cst_marital_status,
	Cst_Info.cst_gndr,
	Cst_Info.cst_create_date,
	Cst_Attributes.bdate,
	Cst_Attributes.gen,
	Cst_Location.cntry

FROM silver.crm_cust_info AS Cst_Info
LEFT JOIN silver.erp_cust_az12 AS Cst_Attributes
ON Cst_Info.cst_key = Cst_Attributes.cid
LEFT JOIN silver.erp_loc_a101 Cst_Location
ON Cst_Info.cst_key = Cst_Location.cid)
sub
GROUP BY cst_id
HAVING COUNT(*) > 1;

--Data Inspection and aggregation
SELECT DISTINCT
	Cst_Info.cst_gndr,
	Cst_Attributes.gen,
	CASE WHEN Cst_Info.cst_gndr != 'n/a' THEN Cst_Info.cst_gndr
	ELSE COALESCE(Cst_Attributes.gen, 'n/a')
	END AS New_Gen

FROM silver.crm_cust_info AS Cst_Info
LEFT JOIN silver.erp_cust_az12 AS Cst_Attributes
ON Cst_Info.cst_key = Cst_Attributes.cid
LEFT JOIN silver.erp_loc_a101 Cst_Location
ON Cst_Info.cst_key = Cst_Location.cid
ORDER BY 1,2;

--Look for which source is the master if case of conflicting values for same attribute arises.