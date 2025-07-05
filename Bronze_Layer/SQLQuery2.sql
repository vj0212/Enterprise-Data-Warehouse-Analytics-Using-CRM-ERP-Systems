/*✅ SQL Server: BULK INSERT
BULK INSERT is a T-SQL command used to efficiently load a large volume of data from a file into a SQL Server table.
Syntax:

BULK INSERT table_name
FROM 'C:\path\to\file.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

Key Features:
High-speed data import.
Supports various file formats.
Can be used with flat files (CSV, TXT).
Supports options like FORMATFILE, ERRORFILE, etc.

Alternative methods in SQL Server:
bcp utility (Bulk Copy Program).
OPENROWSET(BULK...).
SSIS (SQL Server Integration Services) for ETL.

✅ MySQL: Alternative to BULK INSERT
MySQL doesn’t have a BULK INSERT keyword. Instead, it uses:
🔸 LOAD DATA INFILE
Equivalent functionality to BULK INSERT in SQL Server.
Syntax:

LOAD DATA INFILE '/path/to/file.csv'
INTO TABLE table_name
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Key Features:
Very fast for importing large datasets.
Works with CSV or TSV.
Can specify column mappings, escape characters, etc.
Use LOCAL keyword if the file is on the client machine.

Example:

LOAD DATA LOCAL INFILE 'data.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

⚠️ Permissions: FILE privilege is required. In some setups, secure_file_priv must point to an allowed directory.

Comparison Summary
Feature	                             SQL Server (BULK INSERT)	            MySQL (LOAD DATA INFILE)
Command                                	BULK INSERT	                          LOAD DATA INFILE 
File Source	                          Local or network path	                 Local or client-side (LOCAL)
Speed	                                   Very fast	                           Very fast
Additional Tools	                  bcp, SSIS, OPENROWSET	                     mysqlimport CLI
Privilege Needed	                   Access to file system	                  FILE privilege
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
 DECLARE @start_time DATETIME, @end_time DATETIME ;
 BEGIN TRY
    PRINT ' Loading Bronze Layer';
    PRINT '-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-';
    PRINT ' Loading Data From CRM files ';

    SET @start_time = GETDATE();
    TRUNCATE TABLE bronze.crm_cust_info;
    BULK INSERT bronze.crm_cust_info
    FROM 'D:\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
    WITH (
        FIRSTROW = 2, --Since First row would be names of columns
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    -- Quality_Check : Check that the data has not shifted and is in the correct columns
    SELECT COUNT(*) AS Total_Rows_crm_cust FROM bronze.crm_cust_info;
    SET @end_time = GETDATE();
    PRINT '#Load_Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
    PRINT'-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-';

    SET @start_time = GETDATE();
    TRUNCATE TABLE bronze.crm_prd_info;
    BULK INSERT bronze.crm_prd_info
    FROM 'D:\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SELECT COUNT(*) AS Total_Rows_crm_prd_info FROM bronze.crm_prd_info;
    SET @end_time = GETDATE();
    PRINT '#Load_Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
    PRINT'-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-';

    SET @start_time = GETDATE();
    TRUNCATE TABLE bronze.crm_sales_details;
    BULK INSERT bronze.crm_sales_details
    FROM 'D:\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SELECT COUNT(*) AS Total_Rows_crm_sales_details FROM bronze.crm_sales_details;
    SET @end_time = GETDATE();
    PRINT '#Load_Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
    PRINT'-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-';

    SET @start_time = GETDATE();
    PRINT ' Loading Data From ERP files ';
    TRUNCATE TABLE bronze.erp_loc_a101;
    BULK INSERT bronze.erp_loc_a101
    FROM 'D:\SQL\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SELECT COUNT(*) AS Total_Rows_erp_loc_a101 FROM bronze.erp_loc_a101;
    SET @end_time = GETDATE();
    PRINT '#Load_Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
    PRINT'-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-';

    SET @start_time = GETDATE();
    TRUNCATE TABLE bronze.erp_cust_az12;
    BULK INSERT bronze.erp_cust_az12
    FROM 'D:\SQL\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SELECT COUNT(*) AS Total_Rows_erp_cust_az12 FROM bronze.erp_cust_az12;
    SET @end_time = GETDATE();
    PRINT '#Load_Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
    PRINT'-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-';

    SET @start_time = GETDATE();
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    BULK INSERT bronze.erp_px_cat_g1v2
    FROM 'D:\SQL\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SELECT COUNT(*) AS Total_Rows_erp_px_cat_g1v2 FROM bronze.erp_px_cat_g1v2;
    SET @end_time = GETDATE();
    PRINT '#Load_Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
    PRINT'-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-';
 END TRY
 BEGIN CATCH
 PRINT '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*';
 PRINT 'ERROR OCCURED DURING LOADING THE BRONZE LAYER';
 PRINT 'Error Message' + ERROR_MESSAGE();
 PRINT 'Error Message' + CAST(ERROR_NUMBER () AS NVARCHAR);
 PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
 END CATCH
END
--Save frequently used SQL code in stored procedures in database.