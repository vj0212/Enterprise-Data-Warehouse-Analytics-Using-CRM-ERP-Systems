SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_NAME = 'crm_cust_info';



EXEC sp_rename 'silver.crm_cust_info.cst_furstname', 'cst_firstname', 'COLUMN';
EXEC sp_rename 'silver.crm_cust_info.cst_material_status', 'cst_marital_status', 'COLUMN';

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'crm_cust_info';