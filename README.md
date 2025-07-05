# Enterprise-Data-Warehouse-Analytics-Using-CRM-ERP-Systems

# 📊 Data Warehouse & Power BI Project: End-to-End Analytics Pipeline (Bronze → Gold)

---

## 🧾 Description:
This project implements a full-scale data warehouse solution by integrating raw data from **CRM** and **ERP** systems, transforming it through a multi-layered architecture (**Bronze → Silver → Gold**), and ultimately visualizing the curated Gold Layer in **Power BI** for business insights. It follows a **Star Schema** modeling approach and delivers powerful KPIs and analytics on customer behavior, product performance, and sales trends.

## Project Overview
This project outlines the development of a data warehouse architecture using a medallion architecture (Bronze, Silver, Gold layers) to process and transform data from CRM and ERP sources into a business-ready format. The architecture supports batch processing of CSV files, with transformations for cleansing, standardization, and modeling for analytics, reporting, and machine learning.

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

## 🏗 Architecture

### 1. **Bronze Layer – Raw Data Ingestion**
- **Database:** `DataWarehouseRaw`
- **Schema:** `bronze`
- **Purpose:** Load and store raw CSV files as-is with minimal formatting.
- **Key Actions:**
  - Tables mirror source files with generic data types (e.g., `VARCHAR(MAX)`).
  - Loaded using `BULK INSERT` with header skipping (`FIRSTROW = 2`).
- **Scripts:**
  - `1_Create_Bronze_Tables.sql`
  - `2_Load_Bronze_Data.sql`

### 2. **Silver Layer – Data Cleansing & Transformation**
- **Database:** `DataWarehouseCleaned`
- **Schema:** `silver`
- **Purpose:** Clean, deduplicate, and standardize Bronze data.
- **Key Actions:**
  - Normalize data types and formats.
  - Remove duplicates, standardize values.
  - Join across ERP and CRM tables for enrichment.
- **Scripts:**
  - `1_Create_Silver_Tables.sql`
  - `2_Transform_Cleanse_Data.sql`
  - `3_Enrich_Join_And_Validate.sql`

### 3. **Gold Layer – Curated Data Models for Analytics**
- **Database:** `DataWarehouseAnalytics`
- **Schema:** `gold`
- **Purpose:** Host fact and dimension tables for Power BI dashboards.
- **Key Views:**
  - `gold.dim_customers`
  - `gold.dim_products`
  - `gold.fact_sales`
  - `gold.Customers_Report`
- **Scripts:**
  - `Data_Analytics.sql`
  - `Gold_Layer.sql`
  - `GoldLayer2.sql`

## Architecture Details
### Architecture Overview
The data warehouse architecture is structured into three layers: **Bronze**, **Silver**, and **Gold**. Data flows from source systems (CRM and ERP) through these layers to the consumption layer for analytics.

- **Sources**: 
  - CRM and ERP systems provide raw data in CSV format.
  - Data is ingested via batch processing with a full load (truncate and insert) approach.
  
- **Bronze Layer**:
  - Stores raw data as CSV files without transformations.
  - Data model: None.
  - Contains tables such as `crm_sales_details`, `crm_cust_info`, `crm_prd_info`, `erp_cust_az12`, `erp_loc_a101`, and `erp_px_cat_g1v2`.

- **Silver Layer**:
  - Stores cleansed and standardized data in tables.
  - Transformations include data cleansing, standardization, normalization, derived columns, and enrichment.
  - Data model: None.
  - Contains the same table names as the Bronze layer but with processed data.

- **Gold Layer**:
  - Stores business-ready data in views, optimized for analytics.
  - Transformations include data integration, aggregations, and business logic.
  - Data model: Star Schema.
  - Contains tables: `dim_customers`, `dim_products`, and `fact_sales`.

- **Consumption Layer**:
  - Supports BI and reporting, SQL queries, and machine learning applications.
  - Data is consumed from the Gold layer for actionable insights.

### Data Flow
The flow of data from sources to the Gold layer:

1. **Source to Bronze**:
   - Data from CRM and ERP systems is ingested into the Bronze layer.
   - CRM data maps to `crm_sales_details`, `crm_cust_info`, and `crm_prd_info`.
   - ERP data maps to `erp_cust_az12`, `erp_loc_a101`, and `erp_px_cat_g1v2`.

2. **Bronze to Silver**:
   - Data is transformed (cleansed, standardized, normalized) and moved to the Silver layer.
   - Each Bronze layer table corresponds to a Silver layer table with the same name.

3. **Silver to Gold**:
   - Data is integrated and aggregated into the Gold layer.
   - `crm_sales_details` maps to `fact_sales`.
   - `crm_cust_info` and `erp_cust_az12` map to `dim_customers`.
   - `crm_prd_info`, `erp_loc_a101`, and `erp_px_cat_g1v2` map to `dim_products`.

### Star Schema in Gold Layer
- **Dimension Tables**:
  - **`gold.dim_customers`**:
    - **Primary Key**: `Customer_Key`
    - **Attributes**: `customer_Id`, `Customer_Number`, `First_Name`, `Last_Name`, `Country`, `Marital_Status`, `Gender`, `Birth_Date`, `Create_Date`
  - **`gold.dim_products`**:
    - **Primary Key**: `Product_Key`
    - **Attributes**: `Product_Id`, `Product_Number`, `Customer_Id`, `Category`, `Sub_Category`, `Maintenance`, `Cost`, `Product_Line`, `Start_Date`

- **Fact Table**:
  - **`gold.fact_sales`**:
    - **Primary Key**: `Order_Number`
    - **Foreign Keys**: `Product_Key`, `Customer_Key`
    - **Attributes**: `Order_Date`, `Shipping_Date`, `Due_Date`, `Sales_Amount`, `Quantity`, `Price`
    - **Derived Metric**: `Total Sales Amount = Quantity * Price`

- **Relationships**:
  - `dim_customers.Customer_Key` is linked to `fact_sales.Customer_Key` (one-to-many).
  - `dim_products.Product_Key` is linked to `fact_sales.Product_Key` (one-to-many).

## 🔍 Exploratory Data Analysis (EDA)
### 📊 `EDA.sql` & `EDA2.sql`
- Lists schema metadata and explores data relationships.
- Generates insights on customer demographics, product mix, sales volume.
- KPIs: revenue, avg order value, product performance, customer engagement.

## 🧠 Advanced Analytics
### 📈 `Advanced_Data_Analysis.sql`
- Monthly/Yearly performance with window functions.
- Segments customers by loyalty and spend.
- Categorizes products by revenue and pricing bands.
- Revenue breakdown by product category and geography.

### 📘 `Complex_Query.sql`
- `gold.Customers_Report` View:
  - Combines demographic, behavioral, and transactional data.
  - Includes KPIs: `Avg_Order_Value`, `Segment`, `Years_Since_Last_Order`, etc.

## 📊 Power BI Dashboard - Hotel Analytics from Gold Layer
### 📁 Project Title:
**Hotel Data Warehouse Analytics Dashboard**

### 🧾 Description:
This Power BI report is built on the **Gold Layer** of a star-schema data warehouse for visualizing the report made in the gold layer. It connects to cleaned and enriched data (`dim_customers`, `dim_products`, `fact_sales`, `Customers_Report`), and provides executive-level KPIs, visual trends, segmentation insights, and actionable intelligence for business stakeholders.

### 🧰 Tools & Technologies Used
- **Power BI Desktop**
- **SQL Server** (source of Gold Layer views)
- **DAX (Data Analysis Expressions)**
- **Star Schema** with Dimension & Fact tables

### 🧱 Data Model
- **Star schema**: `dim_customers`, `dim_products`, `fact_sales`
- **Snowflake extension**: `Customers_Report` view adds segmentation and behavior insights
- **Relationships**: Based on surrogate keys (`Customer_Key`, `Product_Key`)

### 📌 Key Metrics (KPI Cards)
```DAX
Total Revenue = SUM(gold.fact_sales[Sales_Amount])
Total Orders = COUNTROWS(gold.fact_sales)
Total Customers = DISTINCTCOUNT(gold.fact_sales[Customer_Key])
Average Order Value = DIVIDE([Total Revenue], [Total Orders])

🚀 Future Enhancements
Add YoY metrics, churn %, rolling average
Build multiple dashboard views (Product, Region, Customer)
Enable scheduled refreshes
Apply bookmarks and page navigation
Key Features
Batch Processing: Data is loaded using a truncate-and-insert method.
Transformations:
Bronze: No transformations.
Silver: Data cleansing, standardization, normalization, derived columns, and enrichment.
Gold: Data integration, aggregations, and business logic for analytics.
Data Models:
Bronze and Silver: None.
Gold: Star Schema for optimized querying.
Consumption: Supports BI tools, SQL queries, and machine learning workflows.
Usage
This architecture is designed for:

Business Intelligence: Generate reports and dashboards using data from the Gold layer.
SQL Queries: Query the Gold layer views for analytical insights.
Machine Learning: Use Gold layer data for training and inference in ML models.
