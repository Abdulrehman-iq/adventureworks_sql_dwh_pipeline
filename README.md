# adventureworks_sql_dwh_pipeline

Overview
--------
This repository contains SQL scripts and stored procedures that implement a complete SQL-based ETL pipeline which loads data from the AdventureWorks OLTP source into an AdventureWorks data warehouse (DWH). The project focuses on:

- loading and upserting dimension tables
- loading and upserting fact tables
- centralized logging, restartability, and operational tracking

The pipeline uses set-based `MERGE` statements and stored procedures to ensure idempotent, restartable loads and to record detailed ETL activity for auditing and troubleshooting.

Repository structure
-------------------

- `dimensions/` — Scripts to build and populate dimension tables (DimAccount, DimCustomer, DimDate, etc.). Each file contains the SQL logic and stored procedures used to transform and merge source data into the DWH dimensions.
- `facts/` — Scripts to build and populate fact tables (FactInternetSales, FactResellerSales, FactProductInventory, etc.). These scripts apply business logic and perform MERGE upserts into the DWH fact tables.
- `Logging/` — Logging and control scripts for the ETL pipeline. This includes job definitions, batch control scripts, and the ETL log table(s).

Key features
------------

- Dimension & Fact Loading: Scripts in `dimensions/` and `facts/` implement transformations and upserts from source tables into the data warehouse using `MERGE` statements for safe upserts.
- Stored Procedures: Loading logic is encapsulated in stored procedures to allow parameterized runs, batching, and easier scheduling from job agents.
- Logging & Audit: All ETL activity is recorded to log tables. The `Logging/` scripts include procedures to record job start/end times, row counts, errors, and other operational metadata.
- Restartability & Idempotence: Loads are designed to be restartable — the stored procedures and MERGE logic avoid duplicate inserts and support resuming after failures.
- Operational Scripts: The `Logging/All_ETL_Jobs.sql`, `Logging/CustomerBatch.sql`, and `Logging/ETL_Log.sql` scripts provide the control and auditing foundation used by the pipeline.

How it works (high level)
-------------------------

1. Initialize logging and control objects (create log tables and job records).
2. Run dimension load stored procedures (scripts in `dimensions/`). Each dimension script:
	- extracts and transforms source rows
	- uses `MERGE` to insert/update dimension rows
	- writes counts and status to the ETL log
3. Run fact load stored procedures (scripts in `facts/`) using the transformed dimension keys. Fact loads similarly use `MERGE` and log progress.
4. On completion, the logging procedures update job records with success/failure, row counts, and timing metrics.

Execution notes
---------------

- This project assumes a Microsoft SQL Server environment (T-SQL) and that you run the scripts using SQL Server Management Studio (SSMS), sqlcmd, or an automation/orchestration tool that can execute stored procedures and .sql files.
- Run `Logging/ETL_Log.sql` first to ensure the logging schema and table are present.
- Load dimensions before facts to ensure referential keys exist for fact foreign keys.
- Stored procedures accept parameters for batch sizes and date ranges — review each procedure header for options.

Files of interest
-----------------

- `dimensions/` — dimension scripts (e.g., `DimCustomer.sql`, `DimProduct.sql`, `DimDate.sql`)
- `facts/` — fact scripts (e.g., `FactInternetSales.sql`, `FactResellerSales.sql`)
- `Logging/ETL_Log.sql` — ETL log table definition and maintenance
- `Logging/All_ETL_Jobs.sql` — orchestration script to run all ETL jobs
- `Logging/CustomerBatch.sql` — example batch control for customer-related loads

Best practices and tips
-----------------------

- Test on a copy of the source and target databases before running in production.
- Use transactions appropriately inside stored procedures to guarantee consistency, but avoid holding long-running transactions during large MERGE operations if possible.
- Monitor the `ETL_Log` table for failures and performance bottlenecks.
- When tuning, examine indexes on target tables (especially on MERGE join keys) and consider batching large loads.

Contributing
------------

If you'd like to contribute: open an issue describing the change, submit SQL following the existing folder patterns, and include any test or run instructions for your script.

License
-------
This repository does not contain an explicit license. Add a license file if you intend to publish or share this work publicly.

Flow diagram
------------
Below is a high-level flow diagram of the ETL pipeline. The first block is a Mermaid diagram (supported by many renderers). A simple ASCII diagram is provided as a fallback.

```mermaid
flowchart LR
	A[Source: AdventureWorks OLTP] --> B[Extract]
	B --> C[Transform]
	C --> D{Load Dimensions}
	D -->|Upsert (MERGE)| E[Dimension Tables]
	C --> F{Load Facts}
	F -->|Upsert (MERGE)| G[Fact Tables]
	E --> H[Logging / ETL_Log]
	G --> H
	H --> I[Job Status & Audit]
	I --> J[Complete]
	J --> K[Restartability / Retry]
	K --> B
```

ASCII fallback:

Source -> Extract -> Transform
								 |
								 +-> Load Dimensions (MERGE) -> Dimension Tables
								 |
								 +-> Load Facts (MERGE) -> Fact Tables
								 |
								 +-> Logging / ETL_Log -> Job Status -> Complete
								 |
								 +-> Restartability (retry/resume on failure)

