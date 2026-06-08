# Staging Design

## Staging databases

### Program Operations staging

Database:
- `Stg_ProgramOps_DB`

Schemas:
- `stg_program_ops`
- `etl_admin`

Source:
- `Source_ProgramOps_DB.program_ops`

### Finance Operations staging

Database:
- `Stg_FinanceOps_DB`

Schemas:
- `stg_finance_ops`
- `etl_admin`

Source:
- `Source_FinanceOps_DB.finance_ops`

## Purpose

The staging layer stores extracted source data before it is transformed and loaded into the data warehouse.

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

## Tables created under `stg_finance_ops`

- `donors`
- `campaigns`
- `donations`
- `expense_categories`
- `expenses`
- `payments`
- `budget_allocations`
- `financial_transactions`
- `currency_rates`

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
