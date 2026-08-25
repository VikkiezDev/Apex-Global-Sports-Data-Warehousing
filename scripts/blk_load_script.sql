-- Bulk loading crm & erp data, printing durations and making it as a stored procedure
exec bronze.load_bronze;
go

create or alter procedure bronze.load_bronze as
begin
	declare @start_time datetime, @end_time datetime, @start_load datetime, @end_load datetime
	begin try
		print '======================================'
		print 'Loading bronze layer'
		print '======================================'

		-- Bulk loading crm & data
		print '--------------------------------------'
		print 'Loading CRM Tables'
		print '--------------------------------------'
		
		set @start_load = getdate();
		set @start_time = getdate();
		truncate table bronze.crm_cust_info;

		bulk insert bronze.crm_cust_info
		from 'C:\Users\Admin\source\repos\sql-datawarehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock -- freezes the entire table so no other user or script can alter the data
		);
		set @end_time = getdate();
		print '>> Load duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' secs.'
		
		set @start_time = getdate();
		truncate table bronze.crm_prd_info;

		bulk insert bronze.crm_prd_info
		from 'C:\Users\Admin\source\repos\sql-datawarehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print '>> Load duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' secs.'

		set @start_time = getdate();
		truncate table bronze.crm_sales_details;

		bulk insert bronze.crm_sales_details
		from 'C:\Users\Admin\source\repos\sql-datawarehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print '>> Load duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' secs.'

		-- Bulk loading erp data
		print '--------------------------------------'
		print 'Loading CRM Tables'
		print '--------------------------------------'

		set @start_time = getdate();
		truncate table bronze.erp_cust_az12;

		bulk insert bronze.erp_cust_az12
		from 'C:\Users\Admin\source\repos\sql-datawarehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print '>> Load duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' secs.'

		set @start_time = getdate();
		truncate table bronze.erp_loc_a101;

		bulk insert bronze.erp_loc_a101
		from 'C:\Users\Admin\source\repos\sql-datawarehouse-project\datasets\source_erp\LOC_A101.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print '>> Load duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' secs.'

		set @start_time = getdate();
		truncate table bronze.erp_px_cat_g1v2;

		bulk insert bronze.erp_px_cat_g1v2
		from 'C:\Users\Admin\source\repos\sql-datawarehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		set @end_load = getdate();
		print '>> Load duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' secs.'
		print '==================================='
		print '>> Total load duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' secs.'
		print '==================================='

	end try
	begin catch
		print '==================================='
		print 'ERROR OCCURED WHILE LOADING BRONZE LAYER'
		print 'ERROR MESSAGE: ' + error_message();
		print 'ERROR MESSAGE: ' + cast(error_number() as nvarchar);
		print '==================================='
	end catch
end