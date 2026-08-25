/*
Created a new database named 'DataWarehouse',
with 3 schemas namely bronze, silver and gold.

Note: For now, if there is a need to re-run the this init script,
always drop/truncate the database.
*/

create database DataWarehouse;
go

use DataWarehouse;
go

create schema bronze;
go

create schema silver;
go

create schema gold;