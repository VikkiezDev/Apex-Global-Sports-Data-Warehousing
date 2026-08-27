exec silver.load_silver;

create or alter procedure silver.load_silver as
begin

	-- Transformed and loaded crm_cust_info into silver schema
	-- Removed duplicates keeping only the latest records
	truncate table silver.crm_cust_info;
	insert into silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)

	select
		cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname,
		trim(cst_lastname) as cst_lastname,
		case when upper(trim(cst_marital_status)) = 'S' then 'Single' 
			 when upper(trim(cst_marital_status)) = 'M' then 'Married'
			 else 'Unknown'
		end cst_marital_status,
		case when upper(trim(cst_gndr)) = 'F' then 'Female' 
			 when upper(trim(cst_gndr)) = 'M' then 'Male'
			 else 'Unknown'
		end cst_gndr,
		cst_create_date
	from
		(select
		 *,
		 row_number() over(partition by cst_id order by cst_create_date desc) as flag_latest
		 from
			 bronze.crm_cust_info
		 where
			 cst_id is not null) as latest
	where
		flag_latest = 1;

	-- Transformed and loaded crm_prd_info into silver schema
	truncate table silver.crm_prd_info;
	insert into silver.crm_prd_info (
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	select
		prd_id,
		-- prd_key, (dervied cat_id and prd_key to be able to join with category and sales tables)
		replace(substring(prd_key, 1, 5), '-', '_') as cat_id,
		substring(prd_key, 7, len(prd_key)) as prd_key,
		prd_nm,
		coalesce(prd_cost, 0) as prd_cost,
		case when upper(trim(prd_line)) = 'M' then 'Mountain'
			 when upper(trim(prd_line)) = 'R' then 'Road'
			 when upper(trim(prd_line)) = 'S' then 'Other Sales'
			 when upper(trim(prd_line)) = 'T' then 'Touring'
			 else 'Unknown'
		end as prd_line,
		cast(prd_start_dt as date),
		cast(dateadd(day, -1, lead(prd_start_dt) over(partition by substring(prd_key, 7, len(prd_key)) order by prd_start_dt)) as date) as prd_end_dt
	from
		bronze.crm_prd_info;

	-- Transformed and loaded crm_sales_details into silver schema
	truncate table silver.crm_sales_details;
	insert into silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	select
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null
			 else cast(cast(sls_order_dt as varchar) as date)
		end as sls_order_dt,
		case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null
			 else cast(cast(sls_ship_dt as varchar) as date)
		end as sls_ship_dt,
		case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null
			 else cast(cast(sls_due_dt as varchar) as date)
		end as sls_due_dt,
		case 
			when sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
				then sls_quantity * abs(sls_price)
			else sls_sales
		end as sls_sales, -- Recalculate sales if original value is missing or incorrect
		sls_quantity,
		case 
			when sls_price IS NULL OR sls_price <= 0 
				then sls_sales / NULLIF(sls_quantity, 0)
			else sls_price  -- Derive price if original value is invalid
		end as sls_price
	from
		bronze.crm_sales_details;

	-- Transformed and loaded crm_sales_details into silver schema
	truncate table silver.erp_cust_az12;
	insert into silver.erp_cust_az12 (
		cid,
		bdate,
		gen
	)
	select
		case
			when cid like 'NAS%' then substring(cid, 4, len(cid)) -- Remove 'NAS' prefix if present
			else cid
		end as cid, 
		case
			when bdate > getdate() then null
			else bdate
		end as bdate, -- Set future birthdates to NULL
		case
			when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
			when upper(trim(gen)) in ('M', 'MALE') then 'Male'
			else 'Unknown'
		end as gen -- Normalize gender values and handle unknown cases
	FROM bronze.erp_cust_az12;

	-- Loading erp_loc_a101
	truncate table silver.erp_loc_a101;
	insert into silver.erp_loc_a101 (
		cid,
		cntry
	)
	select
		replace(cid, '-', '') AS cid, 
		case
			when trim(cntry) = 'DE' then 'Germany'
			when trim(cntry) in ('US', 'USA') then 'United States'
			when trim(cntry) = '' or cntry is null then 'Unknown'
			else trim(cntry)
		end as cntry -- Normalize and Handle missing or blank country codes
	from bronze.erp_loc_a101;

	-- Loading erp_px_cat_g1v2

	truncate table silver.erp_px_cat_g1v2;
	insert into silver.erp_px_cat_g1v2 (
		id,
		cat,
		subcat,
		maintenance
	)
	select
		id,
		cat,
		subcat,
		maintenance
	from bronze.erp_px_cat_g1v2;
end