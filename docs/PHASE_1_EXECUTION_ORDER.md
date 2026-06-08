# Phase 1 Execution Order

Run these scripts in SQL Server Management Studio:

1. `sql/01_source/01_create_source_program_ops_db.sql`
2. `sql/01_source/02_create_source_finance_ops_db.sql`
3. `sql/01_source/03_insert_sample_program_ops_data.sql`
4. `sql/01_source/04_insert_sample_finance_ops_data.sql`

Created databases:

- `Source_ProgramOps_DB`
- `Source_FinanceOps_DB`

Created schemas:

- `Source_ProgramOps_DB.program_ops`
- `Source_FinanceOps_DB.finance_ops`

Sample data scripts are designed to avoid foreign key errors by:
- inserting parent tables first
- reading generated IDs into variables
- using those variables for child tables
- wrapping each load in a transaction

Note:
- Finance sample data uses `center_id`, `child_id`, and `teacher_id` reference values that correspond conceptually to the Program Operations sample data.
- There are no cross-database foreign keys in the source layer.
