-- Data Exploration and Cleansing
SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

--If the original value is not equal to the trimmed value, that means there are spaces.
SELECT
cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname ! = TRIM(cst_lastname);


INSERT INTO silver.crm_cust_info(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_First_Name,
TRIM(cst_lastname) AS cst_Last_Name,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
     WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
     ELSE 'n/a'
END cst_material_status,

CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
     WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
     ELSE 'n/a'
END cst_gndr,
cst_create_date
FROM (
SELECT 
*,
ROW_NUMBER() OVER ( PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
) sub
WHERE flag_last = 1;

--Quality Check

SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

SELECT
cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname ! = TRIM(cst_lastname);

SELECT * FROM silver.crm_cust_info;

SELECT 
DISTINCT cst_gndr
FROM silver.crm_cust_info;