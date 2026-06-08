# Staging Design

## Current staging database

Database:
- `Stg_ProgramOps_DB`

Schemas:
- `stg_program_ops`
- `etl_admin`

## Purpose

`stg_program_ops` stores extracted copies of source tables from:

- `Source_ProgramOps_DB.program_ops`

`etl_admin` stores ETL operational metadata such as:

- batch status
- load logs
- row counts
- error messages

## Tables created under `stg_program_ops`

- `centers`
- `children`
- `teachers`
- `users`
- `domains`
- `score_scales`
- `task_templates`
- `closure_reasons`
- `absence_reasons`
- `no_score_reasons`
- `center_daily_status`
- `child_daily_status`
- `child_task_plans`
- `daily_task_assignments`
- `assessment_sessions`
- `task_assessments`
- `notes`
- `note_batches`
- `note_batch_items`
- `audit_logs`

## Staging table design

Staging tables mirror the source structure and add ETL metadata:

- `stg_row_id`
- `etl_batch_id`
- `source_system`
- `source_database`
- `source_schema`
- `source_table`
- `extracted_at`
- `source_updated_at`
- `row_hash`
- `is_valid`
- `validation_message`

## Why no business foreign keys in staging?

The staging layer is a landing area. It should accept source data as-is.

Data-quality problems should be:

1. loaded into staging,
2. detected by quality checks,
3. logged,
4. handled before warehouse loading.

This avoids losing problematic records before they can be analyzed.
