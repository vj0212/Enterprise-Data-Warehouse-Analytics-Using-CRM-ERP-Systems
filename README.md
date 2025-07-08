# Enterprise-Data-Warehouse-Analytics-Using-CRM-ERP-Systems

# 📊 Data Warehouse & Power BI Project: End-to-End Analytics Pipeline (Bronze → Gold)

---

## 🧾 Description:
This project implements a full-scale data warehouse solution by integrating raw data from **CRM** and **ERP** systems, transforming it through a multi-layered architecture (**Bronze → Silver → Gold**) in Microsoft SQL Server, and ultimately visualizing the curated Gold Layer in **Power BI** for business insights. It follows a **Star Schema** modeling approach and delivers powerful KPIs and analytics on customer behavior, product performance, and sales trends.

## Key Responsibilities
- Designed and implemented a three-layer data warehouse architecture (Bronze, Silver, Gold).
- Conducted requirement analysis to understand business needs.
- Developed data ingestion, cleansing, and transformation processes.
- Created a star schema for the Gold layer to optimize analytics.
- Documented data flows, architecture, and star schema design.
- Built Power BI dashboards for business intelligence and visualization.

## Technical Skills
- Data Warehouse Architecture
- ETL Processes
- Data Modeling (Star Schema)
- Data Cleansing and Transformation
- Batch Processing
- Power BI Desktop
- DAX (Data Analysis Expressions)
- SQL Server
- Documentation (Draw.io, Notion)

## Planning in Notion
![Steps for making the Warehouse](https://raw.githubusercontent.com/vj0212/Enterprise-Data-Warehouse-Analytics-Using-CRM-ERP-Systems/59deae75b5050c0762230a724f6343bfa1fdbd94/Planning/Screenshot%202025-07-05%20171912.png)
![Data Warehouse Project Planning in Notion](https://raw.githubusercontent.com/vj0212/Enterprise-Data-Warehouse-Analytics-Using-CRM-ERP-Systems/b7e083bfd7c2dee09e4602684ad57432aba1165c/Planning/Screenshot%202025-07-05%20171948.png)


## Project Workflow

The attached project management board outlines the workflow in Notion, with tasks grouped into epics , as shown in above images:
---

## Data Architecture and Flow

The attached diagrams provide visual context:
- **High-Level Architecture (Image 3)**: Data flows from CRM and ERP `.csv` files to:
  - **Bronze Layer**: Raw data tables, batch-loaded with no transformation.
  - **Silver Layer**: Cleansed tables with transformations (e.g., standardization, deduplication).
  - **Gold Layer**: Views forming a star schema, integrating and aggregating data for BI, reporting, SQL queries, and machine learning.
- **Star Schema (Image 2)**: Defines Gold layer tables:
  - `gold.dim_customers`: Customer dimension with `Customer_Key`.
  - `gold.dim_products`: Product dimension with `Product_Key`.
  - `gold.fact_sales`: Sales fact table linked via `Customer_Key` and `Product_Key`.
- **Data Flow Diagram (Image 4)**: Maps specific tables from CRM and ERP to Bronze, Silver, and Gold layers.

---

## Detailed Breakdown of SQL Scripts

The SQL scripts are executed in the following order to implement the ETL process:

### 1. Bronze Layer Setup and Data Ingestion
Raw data is ingested into the Bronze layer from CRM and ERP sources.

- **SQLQuery1.sql**
  - **Purpose**: Creates Bronze layer tables.
  - **Actions**:
    - Creates the `bronze` schema.
    - Defines six tables: `crm_cust_info`, `crm_prd_info`, `crm_sales_details`, `erp_loc_a101`, `erp_cust_az12`, `erp_px_cat_g1v2`.
  - **Diagram Reference**: Matches Bronze layer tables in the data flow diagram.

- **SQLQuery2.sql**
  - **Purpose**: Defines the `bronze.load_bronze` stored procedure to load raw data.
  - **Actions**:
    - Uses `BULK INSERT` to load `.csv` files into Bronze tables.
    - Truncates tables before loading.
    - Skips headers (`FIRSTROW = 2`), uses `FIELDTERMINATOR = ','`, and applies `TABLOCK`.
    - Logs process with `PRINT` statements and checks row counts with `SELECT COUNT(*)`.
    - Includes `TRY...CATCH` error handling.
  - **Diagram Reference**: Represents the Sources → Bronze flow.

- **SQLQuery3.sql**
  - **Purpose**: Executes the `bronze.load_bronze` procedure.
  - **Actions**: Triggers data loading into Bronze tables.

### 2. Silver Layer Setup and Transformation
Data is cleansed and transformed from Bronze to Silver.

- **SQLQuery4.sql**
  - **Purpose**: Creates Silver layer tables.
  - **Actions**:
    - Creates the `silver` schema.
    - Defines six tables mirroring Bronze, adding `dwh_create_date` (`DATETIME2`, default `GETDATE()`).
  - **Diagram Reference**: Matches Silver layer tables in the data flow diagram.

- **Silver_Layer.sql**
  - **Purpose**: Creates `silver.crm_prd_info`.
  - **Actions**: Defines columns (`prd_id`, `prd_key`, etc.) with `dwh_create_date`.

- **Silver_Layer2.sql**
  - **Purpose**: Creates `silver.crm_sales_details`.
  - **Actions**: Defines columns (`sls_ord_num`, `sls_prd_key`, etc.) with `dwh_create_date`.

- **Silver_Layer3.sql**
  - **Purpose**: Creates `silver.erp_loc_a101`.
  - **Actions**: Defines columns (`cid`, `cntry`, `dwh_create_date`).

- **Silver_Layer4.sql**
  - **Purpose**: Creates `silver.erp_cust_az12` and `silver.erp_px_cat_g1v2`.
  - **Actions**:
    - `erp_cust_az12`: Columns (`cid`, `bdate`, `gen`, `dwh_create_date`).
    - `erp_px_cat_g1v2`: Columns (`id`, `cat`, `subcat`, `maintenance`, `dwh_create_date`).

- **Check&Fix.sql**
  - **Purpose**: Corrects column names in `silver.crm_cust_info`.
  - **Actions**:
    - Inspects `bronze.crm_cust_info` columns.
    - Renames `cst_furstname` to `cst_firstname`, `cst_material_status` to `cst_marital_status`.
    - Verifies changes.

- **Data_Cleansing.sql**
  - **Purpose**: Cleanses `crm_cust_info` data and loads it into Silver.
  - **Actions**:
    - Checks duplicates and NULLs in `bronze.crm_cust_info`.
    - Trims `cst_firstname` and `cst_lastname`.
    - Maps `cst_marital_status` (M/S → Married/Single) and `cst_gndr` (F/M → Female/Male).
    - Deduplicates using `ROW_NUMBER()` by `cst_create_date`.
    - Verifies cleansing in `silver.crm_cust_info`.
  - **Diagram Reference**: Bronze → Silver transformation for `crm_cust_info`.

- **Silver_Level_Stored_Procedure.sql**
  - **Purpose**: Defines `silver.load_silver` to transform and load data.
  - **Actions**:
    - Truncates and loads data into Silver tables:
      - `crm_prd_info`: Converts dates to `DATETIME`.
      - `crm_sales_details`: Converts dates to `DATE`.
      - `erp_loc_a101`: Standardizes `cntry` (e.g., US → United States).
      - `erp_cust_az12`: Standardizes `gen`, deduplicates by `bdate`.
      - `erp_px_cat_g1v2`: Trims strings, deduplicates by `maintenance`.
    - Includes logging and `TRY...CATCH`.
  - **Diagram Reference**: Bronze → Silver transformation for all tables.

- **Running_StoredProcedure.sql**
  - **Purpose**: Executes `silver.load_silver`.
  - **Actions**: Triggers Bronze-to-Silver transformation.

### 3. Gold Layer Setup and Dimensional Modeling
Data is modeled into a star schema for analytics.

- **Data_Analytics.sql**
  - **Purpose**: Sets up the Gold layer database and tables.
  - **Actions**:
    - Creates `DataWarehouseAnalytics` database and `gold` schema.
    - Defines tables: `dim_customers`, `dim_products`, `fact_sales`.
    - Loads data via `BULK INSERT` from `.csv` files (optional/alternative approach).
  - **Diagram Reference**: Initializes Gold layer tables.

- **Gold_Layer.sql**
  - **Purpose**: Creates the `gold.dim_customers` view.
  - **Actions**:
    - Integrates `silver.crm_cust_info`, `erp_cust_az12`, `erp_loc_a101`.
    - Generates `Customer_Key` with `ROW_NUMBER()`.
    - Maps gender and handles NULLs.
  - **Diagram Reference**: Silver → Gold flow to `dim_customers`.

- **GoldLayer2.sql**
  - **Purpose**: Creates `gold.dim_products` and `gold.fact_sales` views.
  - **Actions**:
    - `dim_products`: Integrates `silver.crm_prd_info` and `erp_px_cat_g1v2`, filters active products.
    - `fact_sales`: Links `silver.crm_sales_details` with dimensions via keys.
  - **Diagram Reference**: Silver → Gold flow to `dim_products` and `fact_sales`.

### 4. Data Analysis and Reporting
Analytical queries are performed on the Gold layer.

- **Complex_Query.sql**
  - **Purpose**: Creates `gold.Customers_Report` view.
  - **Actions**:
    - Calculates `Customer_Age`, `Total_Sales`, `Lifespan_As_Customers_In_Months`.
    - Segments customers by age and sales.

- **EDA.sql**
  - **Purpose**: Performs exploratory data analysis.
  - **Actions**:
    - Analyzes `Country`, product categories, sales time spans, and aggregates.

- **EDA2.sql**
  - **Purpose**: Continues EDA.
  - **Actions**:
    - Aggregates customers by `Country`/`Gender`, products by category, top customers, sales by country.

- **Advanced_Data_Analysis.sql**
  - **Purpose**: Conducts advanced analytics.
  - **Actions**:
    - Analyzes sales by period, cumulative metrics, product cost ranges, customer expenditure.

---

## Conclusion

The **Data Warehouse Project** implements a robust ETL pipeline, transforming raw CRM and ERP data into a star schema for actionable insights. The process—ingestion (Bronze), cleansing/transformation (Silver), modeling (Gold), and analysis—aligns with the attached diagrams, ensuring data quality and analytical efficiency. All tasks are completed (100% progress), as shown in the project management board.

## 📊 Power BI Dashboard - Analytics from Gold Layer

### 🧰 Tools & Technologies Used
- **Power BI Desktop**
- **SQL Server** (source of Gold Layer views)
- **DAX (Data Analysis Expressions)**
- **Star Schema** with Dimension & Fact tables

### 🧱 Data Model
- **Star schema**: `dim_customers`, `dim_products`, `fact_sales`
- **Snowflake extension**: `Customers_Report` view adds segmentation and behavior insights
- **Relationships**: Based on surrogate keys (`Customer_Key`, `Product_Key`)

### 📌 Key Metrics 
```DAX
--(KPI Cards)--

Total Revenue:
Value: ₹29.356M (29.356 million)
Metric: Sum of Sales Amount
Insight: This represents the total revenue generated, indicating a significant sales volume.

Total Customers:
Value: 18,484K (18.484 million)
Metric: Count of Customer Key
Insight: A large customer base, suggesting widespread market reach.

Returning Customers:
Value: 7K (7,000) (updated based on DAX: CALCULATE(DISTINCTCOUNT('gold Customers_Report'[Customer_Key]), 'gold Customers_Report'[Lifespan_As_Customers_In_Months] > 1))
Metric: Repeat Customers (defined as customers with a lifespan > 1 month)
Insight: The 7,000 returning customers (0.0378% of 18.484M) reflect those who have stayed with the business for more than one month, indicating a low retention rate or a large influx of one-time buyers.

Average Price of an Order:
Value: ₹486.05
Metric: Average Value of Order
Insight: The average order value is moderate, suggesting a mix of low and high-value transactions.

## Dashboard Data Analysis
Customer Segmentation (Donut Chart):
Segments:
New: 14,637 (79.15%)
Regular: 2,215 (11.99%)
VIP: 1,665 (8.94%)
Insight: The majority of customers are new (over 79%), with a smaller proportion of regular and VIP customers. This aligns with the low returning customer rate, as the DAX definition of returning customers (lifespan > 1 month) may overlap with Regular and VIP segments.

Revenue by Customer Segment (Bar Chart):
Segments and Revenue:
New: ₹11.09M
VIP: ₹10.76M
Regular: ₹7.50M
Insight: Despite fewer VIP and Regular customers, they contribute significantly to revenue, with New customers still leading overall. This suggests higher average spending by non-new segments, potentially including the returning customers.

Total Monthly Sales by Year and Month (Line Chart):
Data Points (in ₹):
Jan 2011: 3.4K
Jul 2011: 103K
Jan 2012: 6.8K
Jul 2012: 2.7K
Jan 2013: 38.9K
Jul 2013: 46.1K
Jan 2014: 66.8K
Jul 2014: 146.8K
Jan 2015: 2.75M
Jul 2015: 7.796M
Insight: Sales show a general upward trend over time, with significant growth from 2014 onwards, peaking in mid-2015. This indicates a period of rapid business expansion or seasonal sales spikes.

Products by Revenue (Bar Chart):
Top Products by Revenue (in ₹):
Mountain-200 Black-46: 1.373M
Mountain-200 Black-42: 1.363M
Mountain-200 Silver-38: 1.339M
Mountain-200 Silver-46: 1.301M
Mountain-200 Black-38: 1.294M
Mountain-200 Silver-42: 1.257M
Road-150 Red-48: 1.205M
Road-150 Red-62: 1.202M
Road-150 Red-52: 1.080M
Road-150 Red-56: 1.055M
Lower Revenue Products (examples):
Road-250 Red-48: 397K
Road-250 Red-42: 381K
Touring-1000 Blue-54: 376K
Insight: Mountain-200 series products dominate revenue, particularly in Black and Silver variants across different sizes. Road-150 series also performs well, while Touring and Road-250 series contribute less.

🚀 Future Enhancements
Add churn %, rolling average
Enable scheduled refreshes
Apply bookmarks and page navigation

This architecture is designed for:

Business Intelligence: Generate reports and dashboards using data from the Gold layer.
SQL Queries: Query the Gold layer views for analytical insights.
Machine Learning: Use Gold layer data for training and inference in ML models.
