-- Quality Check

SELECT
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()
ORDER BY bdate;

SELECT
cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
     ELSE cid
END AS Cleaned_cid,
bdate,
CASE WHEN bdate < '1924-01-01' OR bdate > GETDATE() THEN NULL
     ELSE bdate
END AS Cleaned_bdate,
gen,
CASE WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male'
     WHEN UPPER(TRIM(gen))  = 'F' THEN 'Female'
     WHEN UPPER(TRIM(gen))  IS NULL THEN 'Unknown'
     WHEN UPPER(TRIM(gen))  = '' THEN 'n/a'
     ELSE gen
END AS Cleaned_gen
FROM bronze.erp_cust_az12;

--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*
TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12( cid, bdate, gen)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
     ELSE cid
END AS cid,
CASE WHEN bdate < '1924-01-01' OR bdate > GETDATE() THEN NULL
     ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male'
     WHEN UPPER(TRIM(gen))  = 'F' THEN 'Female'
     WHEN UPPER(TRIM(gen))  IS NULL THEN 'Unknown'
     WHEN UPPER(TRIM(gen))  = '' THEN 'n/a'
     ELSE gen
END AS gen
FROM bronze.erp_cust_az12;

SELECT
*
FROM silver.erp_cust_az12;

--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*
--Data Quality and Format check

SELECT
*
FROM bronze.erp_loc_a101;

SELECT 
cst_key 
FROM silver.crm_cust_info;
--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
SELECT
REPLACE(cid,'-','') AS cid,
cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid,'-','') NOT IN
(SELECT 
cst_key 
FROM silver.crm_cust_info);
--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

SELECT 
  CASE 
    WHEN cntry IS NULL OR cntry = '' THEN 'Detail Not Available'
    ELSE cntry
  END AS cntry_cleaned,
  COUNT(*) AS count_rows
FROM bronze.erp_loc_a101
GROUP BY 
  CASE 
    WHEN cntry IS NULL OR cntry = '' THEN 'Detail Not Available'
    ELSE cntry
  END
ORDER BY cntry_cleaned;
--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

SELECT 
  cntry,
  COUNT(*) AS cnt
FROM bronze.erp_loc_a101
GROUP BY cntry
ORDER BY cntry;
--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101(
cid,
cntry)
SELECT
REPLACE(cid,'-','') AS cid,
CASE 
    WHEN TRIM(cntry) IS NULL OR cntry = '' THEN 'Detail Not Available'
    WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
    WHEN TRIM(cntry) = 'DE' THEN 'Germany'
    ELSE TRIM(cntry)
  END AS cntry
FROM bronze.erp_loc_a101;

SELECT DISTINCT
cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

SELECT 
*
FROM silver.erp_loc_a101;