# Execution Order

Run these scripts in SQL Server Management Studio:

## Source layer

1. `sql/01_source/01_create_source_program_ops_db.sql`
2. `sql/01_source/02_create_source_finance_ops_db.sql`
3. `sql/01_source/03_insert_sample_program_ops_data.sql`
4. `sql/01_source/04_insert_sample_finance_ops_data.sql`

## Staging layer

5. `sql/02_staging/05_create_stg_program_ops_db.sql`
6. `sql/02_staging/06_create_stg_program_ops_tables.sql`
7. `sql/02_staging/07_create_stg_finance_ops_db.sql`
8. `sql/02_staging/08_create_stg_finance_ops_tables.sql`

## ETL layer

9. `sql/04_etl/09_create_etl_program_ops_to_staging_procedures.sql`

## Run Program Ops ETL later

```sql
USE Stg_ProgramOps_DB;
GO

EXEC etl_admin.usp_run_stg_program_ops_all
    @to_date = '2025-12-31 23:59:59';
```

Created databases:

- `Source_ProgramOps_DB`
- `Source_FinanceOps_DB`
- `Stg_ProgramOps_DB`
- `Stg_FinanceOps_DB`
