# ETL Design

## Current ETL procedure

Procedure:

```sql
Stg_ProgramOps_DB.etl_admin.usp_load_program_ops_to_staging
```

Script:

```text
sql/04_etl/09_create_etl_load_program_ops_to_staging.sql
```

## Source and target

Source:

```text
Source_ProgramOps_DB.program_ops
```

Target:

```text
Stg_ProgramOps_DB.stg_program_ops
```

## Load behavior

The ETL procedure uses `MERGE` for each source table.

It:

- inserts new source rows into staging
- updates changed rows in staging
- does not truncate staging
- does not delete rows from staging
- computes a `row_hash` using `HASHBYTES('SHA2_256', ...)`
- updates rows only when the hash changes or the staging row is marked invalid

## Logging

Batch-level logs are stored in:

```text
Stg_ProgramOps_DB.etl_admin.etl_batch
```

Table-level logs are stored in:

```text
Stg_ProgramOps_DB.etl_admin.etl_load_log
```

The logs track:

- batch status
- source table
- target table
- rows read
- rows inserted
- rows updated
- rows written
- rows rejected
- start time
- end time
- error message

## Error handling

If a table load fails:

1. the current table log is marked as `failed`
2. the batch log is marked as `failed`
3. the procedure throws the SQL Server error

Successful table logs before the failure remain available for debugging.

## How to run

```sql
EXEC Stg_ProgramOps_DB.etl_admin.usp_load_program_ops_to_staging;
```

## How to inspect logs

```sql
SELECT *
FROM Stg_ProgramOps_DB.etl_admin.etl_batch
ORDER BY etl_batch_id DESC;

SELECT *
FROM Stg_ProgramOps_DB.etl_admin.etl_load_log
ORDER BY etl_load_log_id DESC;
```
