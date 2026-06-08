# Charity Data Warehouse Project

Target DBMS:
- Microsoft SQL Server
- Designed for SQL Server Management Studio (SSMS)

Current phase:
- Phase 1: Create and populate operational source databases.
- Phase 2: Create staging databases/tables and Program Ops source-to-staging ETL procedures.

Included SQL scripts:
1. `sql/01_source/01_create_source_program_ops_db.sql`
2. `sql/01_source/02_create_source_finance_ops_db.sql`
3. `sql/01_source/03_insert_sample_program_ops_data.sql`
4. `sql/01_source/04_insert_sample_finance_ops_data.sql`
5. `sql/02_staging/05_create_stg_program_ops_db.sql`
6. `sql/02_staging/06_create_stg_program_ops_tables.sql`
7. `sql/02_staging/07_create_stg_finance_ops_db.sql`
8. `sql/02_staging/08_create_stg_finance_ops_tables.sql`
9. `sql/04_etl/09_create_etl_program_ops_to_staging_procedures.sql`

Recommended execution order in SSMS:
1. Run `sql/01_source/01_create_source_program_ops_db.sql`
2. Run `sql/01_source/02_create_source_finance_ops_db.sql`
3. Run `sql/01_source/03_insert_sample_program_ops_data.sql`
4. Run `sql/01_source/04_insert_sample_finance_ops_data.sql`
5. Run `sql/02_staging/05_create_stg_program_ops_db.sql`
6. Run `sql/02_staging/06_create_stg_program_ops_tables.sql`
7. Run `sql/02_staging/07_create_stg_finance_ops_db.sql`
8. Run `sql/02_staging/08_create_stg_finance_ops_tables.sql`
9. Run `sql/04_etl/09_create_etl_program_ops_to_staging_procedures.sql`

To run Program Ops ETL later as a job:

```sql
USE Stg_ProgramOps_DB;
GO

EXEC etl_admin.usp_run_stg_program_ops_all
    @to_date = '2025-12-31 23:59:59';
```

ETL design:
- One procedure per Program Ops source table.
- One main procedure runs all table procedures in a safe order.
- Each table procedure accepts `@to_date`.
- Each table procedure validates rows before loading.
- Each table procedure uses `MERGE` instead of truncating/reloading.
- ETL activity is logged in `etl_admin.etl_batch` and `etl_admin.etl_load_log`.
