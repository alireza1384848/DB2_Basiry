# Charity Data Warehouse Project

Target DBMS:
- Microsoft SQL Server
- Designed for SQL Server Management Studio (SSMS)

Current phase:
- Phase 1: Create and populate the operational source databases.

Included SQL scripts:
1. `sql/01_source/01_create_source_program_ops_db.sql`
2. `sql/01_source/02_create_source_finance_ops_db.sql`
3. `sql/01_source/03_insert_sample_program_ops_data.sql`
4. `sql/01_source/04_insert_sample_finance_ops_data.sql`

Important sample-data design:
- Sample scripts do not assume identity values start from 1.
- Parent records are inserted first.
- Real generated IDs are captured into variables using business values.
- Child inserts use those variables.
- Each sample script uses a transaction and rolls back if an error occurs.

Recommended execution order in SSMS:
1. Run `sql/01_source/01_create_source_program_ops_db.sql`
2. Run `sql/01_source/02_create_source_finance_ops_db.sql`
3. Run `sql/01_source/03_insert_sample_program_ops_data.sql`
4. Run `sql/01_source/04_insert_sample_finance_ops_data.sql`
