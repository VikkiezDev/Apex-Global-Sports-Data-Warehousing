-- DATA QUALITY CHECKS FOR silver.crm_cust_info

-- Checks for nulls or duplicates in the primary key column

select cst_id, count(*) as no_of_records
from silver.crm_cust_info
group by cst_id
having count(*) > 1;

-- Check for leading and trailing spaces

select
	sum(case when cst_key != trim(cst_key) then 1 else 0 end) as keys_with_spaces,
	sum(case when cst_firstname != trim(cst_firstname) then 1 else 0 end) as firstname_with_spaces,
	sum(case when cst_lastname != trim(cst_lastname) then 1 else 0 end) as lastname_with_spaces,
	sum(case when cst_marital_status != trim(cst_marital_status) then 1 else 0 end) as marital_status_with_spaces,
	sum(case when cst_gndr != trim(cst_gndr) then 1 else 0 end) as gender_with_spaces
from
	silver.crm_cust_info

-- Data Standardization & Consistency (of columns with low cardinality)

select distinct
	cst_marital_status
from
	silver.crm_cust_info;

select distinct
	cst_gndr
from
	silver.crm_cust_info;

-- Preview

select * from silver.crm_cust_info;

-- DATA QUALITY CHECKS FOR silver.crm_prd_info

-- Checks for nulls or duplicates in the primary key column
-- No duplicates

select
	prd_id,
	count(*) as no_of_record
from
	silver.crm_prd_info
group by
	prd_id
having
	count(*) > 1 or prd_id is null;

-- Checks for leading and trailing spaces
-- No spaces

select
	sum(case when prd_key != trim(prd_key) then 1 else 0 end) as prd_key_with_space,
	sum(case when prd_nm != trim(prd_nm) then 1 else 0 end) as prd_nm_with_space,
	sum(case when prd_line != trim(prd_line) then 1 else 0 end) as prd_line_with_space
from
	silver.crm_prd_info

-- Check for nulls and negative numbers
-- Found nulls

select
	prd_cost
from
	silver.crm_prd_info
where
	prd_cost < 0 or prd_cost is null;

-- Data standardization and consistency

select distinct
	prd_line
from
	silver.crm_prd_info;

-- Check for invaid dates

select 
	*
from
	silver.crm_prd_info
where
	prd_end_dt < prd_start_dt

select * from silver.crm_prd_info;

-- DATA QUALITY CHECKS FOR bronze.crm_sales_details

-- Checks for nulls or duplicates in the primary key column
-- No idea why duplicates were not checked for this table

select
	sls_cust_id,
	count(*) as no_of_record
from
	bronze.crm_sales_details
group by
	sls_cust_id
having
	count(*) > 1 or sls_cust_id is null;

-- Checks for leading and trailing spaces
-- No spaces

select
	sum(case when sls_ord_num != trim(sls_ord_num) then 1 else 0 end) as sls_ord_num_with_space,
	sum(case when sls_prd_key != trim(sls_prd_key) then 1 else 0 end) as sls_prd_key_with_space
from
	bronze.crm_sales_details;

-- Check for invalid dates

select
	nullif(sls_order_dt, 0) as sls_order_dt
from
	bronze.crm_sales_details
where
	sls_order_dt <= 0
	or len(sls_order_dt) != 8
	or sls_order_dt > 20500101
	or sls_order_dt < 19000101;

-- Check for invalid date orders

select
	*
from
	bronze.crm_sales_details
where
	sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;

-- Check Data consistency
-- > sale = quantity * price
-- > sale, quantity and price cannot be null, zero or negative

select distinct
	sls_sales,
	sls_quantity,
	sls_price
from
	bronze.crm_sales_details
where
	sls_sales != sls_quantity * sls_price
	or sls_sales is null or sls_quantity is null or sls_price is null
	or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
order by
	sls_sales,
	sls_quantity,
	sls_price;

-- Checking 'silver.erp_cust_az12'

-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
select distinct
    bdate 
from bronze.erp_cust_az12
where bdate < '1924-01-01' 
   or bdate > getdate();

-- Data Standardization & Consistency
select distinct
    gen 
from bronze.erp_cust_az12;

-- Checking 'silver.erp_loc_a101'
-- Data Standardization & Consistency
select distinct
    cntry 
from silver.erp_loc_a101
order by cntry;

-- Checking 'silver.erp_px_cat_g1v2'

-- Check for Unwanted Spaces
-- Expectation: No Results
select 
    * 
from silver.erp_px_cat_g1v2
where cat != trim(cat) 
   or subcat != trim(subcat) 
   or maintenance != trim(maintenance);

-- Data Standardization & Consistency
select distinct
    subcat 
from bronze.erp_px_cat_g1v2;