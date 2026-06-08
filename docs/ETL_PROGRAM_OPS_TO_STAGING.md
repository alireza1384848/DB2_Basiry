# Program Operations Source-to-Staging ETL

## Script

`sql/04_etl/09_create_etl_program_ops_to_staging_procedures.sql`

## Source

`Source_ProgramOps_DB.program_ops`

## Target

`Stg_ProgramOps_DB.stg_program_ops`

## Main procedure

```sql
EXEC etl_admin.usp_run_stg_program_ops_all
    @to_date = '2025-12-31 23:59:59';
```

## Per-table procedure pattern

Each source table has its own procedure:

```sql
etl_admin.usp_load_stg_program_ops_<table_name>
```

Examples:

```sql
etl_admin.usp_load_stg_program_ops_centers
etl_admin.usp_load_stg_program_ops_children
etl_admin.usp_load_stg_program_ops_task_assessments
```

## Requirements covered

### 1. Logging

Each table procedure logs to:

- `etl_admin.etl_batch`
- `etl_admin.etl_load_log`

Logged fields include:

- source database/schema/table
- target database/schema/table
- status
- rows read
- rows written
- rows rejected
- start and end timestamps
- error message if failed

### 2. Insert and update behavior

Each procedure uses `MERGE`:

- new source rows are inserted into staging
- existing staging rows are updated only when `row_hash` changes

### 3. One procedure per table

There is one procedure per Program Operations source table.

### 4. `@to_date` input

Each procedure accepts:

```sql
@to_date DATETIME2(0)
```

Rows are eligible when their source timestamp is less than or equal to `@to_date`.

For most tables:

```sql
COALESCE(updated_at, created_at) <= @to_date
```

For tables without `updated_at`, `created_at` or related parent dates are used.

### 5. Validation phase

Each procedure validates rows before loading to staging.

Examples:

- required values are not null
- parent references exist in the source
- score ranges are valid
- date ranges are valid
- attempt numbers are valid

Only valid rows are loaded to staging.

### 6. Large-table safe approach

The ETL does not truncate staging tables.

Instead, it uses `MERGE` by source `id`.

### 7. Main procedure

The main procedure runs all table ETLs in safe dependency order:

1. master/reference tables
2. lookup tables
3. task setup tables
4. daily/transactional tables
5. notes and audit logs
