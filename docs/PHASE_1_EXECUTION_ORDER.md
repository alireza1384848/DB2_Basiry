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

Created databases:

- `Source_ProgramOps_DB`
- `Source_FinanceOps_DB`
- `Stg_ProgramOps_DB`

Created schemas:

- `Source_ProgramOps_DB.program_ops`
- `Source_FinanceOps_DB.finance_ops`
- `Stg_ProgramOps_DB.stg_program_ops`
- `Stg_ProgramOps_DB.etl_admin`

Note:
- `06_create_stg_program_ops_tables.sql` creates source-copy staging tables only.
- The data-load script from source to staging will be created in the next step.
