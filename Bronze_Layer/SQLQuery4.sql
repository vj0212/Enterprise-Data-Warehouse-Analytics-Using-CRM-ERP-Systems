-- Metadata_Columns : Extra columns added by data engineers that don't originate from the source data.
/* examples :
create_date : The record's load timestamp.
update_date : The record's last update timestamp.
source_system : The origin system of the record.
file_location : The file source of the record.
*/
USE DataWarehouse;

CREATE TABLE silver.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_furstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_material_status NVARCHAR(10),
	cst_gndr NVARCHAR(10),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
/*🔍 Explanation
Component	                                Meaning
dwh_create_date	                    This is the column name. Likely used to store the "create date" of a row in a data warehouse (dwh).
DATETIME2	                  This is the data type. It's a more precise and modern version of DATETIME that allows for specifying fractional seconds precision (up to 7 digits).
DEFAULT GETDATE()	                             This defines a default constraint, meaning: if no value is supplied during an INSERT, 
                                     the column will be automatically populated with the current system date and time from GETDATE() (which returns a DATETIME value).*/

CREATE TABLE silver.crm_prd_info (
	prd_id INT,
	prd_key NVARCHAR(20),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.erp_loc_a101 (
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.erp_px_cat_g1v2 (
	id NVARCHAR (50),
	cat NVARCHAR (50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR (50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);