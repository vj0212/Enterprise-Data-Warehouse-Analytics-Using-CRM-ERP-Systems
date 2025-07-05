CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @duration INT, @row_count INT;
    DECLARE @step NVARCHAR(100);

    BEGIN TRY
        PRINT ' Loading Silver Layer';
        PRINT '-------------------------------------------';

        PRINT ' Loading FROM CRM';
        PRINT '-------------------------------------------';
        SET @step = 'silver.crm_cust_info';
        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_cust_info;

        INSERT INTO silver.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'n/a'
            END,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) sub
        WHERE flag_last = 1;

        SET @end_time = GETDATE();
        SELECT @row_count = COUNT(*) FROM silver.crm_cust_info;
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        PRINT @step + ' - Load Duration: ' + CAST(@duration AS NVARCHAR) + ' seconds, Rows: ' + CAST(@row_count AS NVARCHAR);


        SET @step = 'silver.crm_prd_info';
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_prd_info;
        INSERT INTO silver.crm_prd_info (
            prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LEN(prd_key)),
            prd_nm,
            ISNULL(prd_cost, 0),
            CASE 
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE)
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        SELECT @row_count = COUNT(*) FROM silver.crm_prd_info;
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        PRINT @step + ' - Load Duration: ' + CAST(@duration AS NVARCHAR) + ' seconds, Rows: ' + CAST(@row_count AS NVARCHAR);
       

        SET @step = 'silver.crm_sales_details';
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_sales_details;
        INSERT INTO silver.crm_sales_details (
            sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt,
            sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END,
            CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END,
            CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END,
            CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
                 ELSE sls_sales
            END,
            sls_quantity,
            CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0) ELSE sls_price END
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        SELECT @row_count = COUNT(*) FROM silver.crm_sales_details;
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        PRINT @step + ' - Load Duration: ' + CAST(@duration AS NVARCHAR) + ' seconds, Rows: ' + CAST(@row_count AS NVARCHAR);

        PRINT '-------------------------------------------';
        PRINT ' Loading FROM ERP';
        PRINT '-------------------------------------------';
        SET @step = 'silver.erp_cust_az12';

        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_cust_az12;
        INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
        SELECT
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END,
            CASE WHEN bdate < '1924-01-01' OR bdate > GETDATE() THEN NULL ELSE bdate END,
            CASE 
                WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(gen)) = 'F' THEN 'Female'
                WHEN gen IS NULL OR TRIM(gen) = '' THEN 'n/a'
                ELSE gen
            END
        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        SELECT @row_count = COUNT(*) FROM silver.erp_cust_az12;
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        PRINT @step + ' - Load Duration: ' + CAST(@duration AS NVARCHAR) + ' seconds, Rows: ' + CAST(@row_count AS NVARCHAR);


        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_loc_a101;
        INSERT INTO silver.erp_loc_a101 (cid, cntry)
        SELECT
            REPLACE(cid, '-', ''),
            CASE 
                WHEN TRIM(cntry) IS NULL OR cntry = '' THEN 'Detail Not Available'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                ELSE TRIM(cntry)
            END
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        SELECT @row_count = COUNT(*) FROM silver.erp_loc_a101;
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        PRINT @step + ' - Load Duration: ' + CAST(@duration AS NVARCHAR) + ' seconds, Rows: ' + CAST(@row_count AS NVARCHAR);


        SET @step = 'silver.erp_px_cat_g1v2';
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT id, cat, subcat, maintenance FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        SELECT @row_count = COUNT(*) FROM silver.erp_px_cat_g1v2;
        SET @duration = DATEDIFF(SECOND, @start_time, @end_time);
        PRINT @step + ' - Load Duration: ' + CAST(@duration AS NVARCHAR) + ' seconds, Rows: ' + CAST(@row_count AS NVARCHAR);

    END TRY
    BEGIN CATCH
        PRINT '-------------------------------------------';
        PRINT 'ERROR in Silver Layer Load!';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
    END CATCH
END
