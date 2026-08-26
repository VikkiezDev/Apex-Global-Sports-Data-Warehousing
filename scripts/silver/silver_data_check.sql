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