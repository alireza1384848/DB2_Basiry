/*
===============================================================================
 Project      : Charity Data Warehouse Project
 Phase        : Phase 2 - Staging Layer
 File         : 08_create_stg_finance_ops_tables.sql
 DBMS         : Microsoft SQL Server
 Tool         : SQL Server Management Studio (SSMS)

 Purpose:
   Create staging tables under Stg_FinanceOps_DB.stg_finance_ops.

 Prerequisite:
   Run this first:
   - 07_create_stg_finance_ops_db.sql

 Design:
   - Tables mirror Source_FinanceOps_DB.finance_ops source tables.
   - No business foreign keys are created in staging.
   - Staging should accept source data as-is, then validation is done later.
   - Every staging table has ETL metadata columns:
       stg_row_id
       etl_batch_id
       source_system
       source_database
       source_schema
       source_table
       extracted_at
       source_updated_at
       row_hash
       is_valid
       validation_message

 Why no foreign keys in staging?
   Staging is a landing area. It should not reject source rows too early.
   Data-quality issues should be loaded, detected, logged, and handled by ETL.

 Source system:
   Source_FinanceOps_DB.finance_ops
===============================================================================
*/

SET NOCOUNT ON;
GO

USE Stg_FinanceOps_DB;
GO

/*=============================================================================
  1. Verify Required Schemas
=============================================================================*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'stg_finance_ops')
BEGIN
    EXEC(N'CREATE SCHEMA stg_finance_ops');
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'etl_admin')
BEGIN
    EXEC(N'CREATE SCHEMA etl_admin');
END
GO

/*=============================================================================
  2. Drop Existing Staging Tables
     Development-friendly and re-runnable.
=============================================================================*/

DROP TABLE IF EXISTS stg_finance_ops.currency_rates;
DROP TABLE IF EXISTS stg_finance_ops.financial_transactions;
DROP TABLE IF EXISTS stg_finance_ops.budget_allocations;
DROP TABLE IF EXISTS stg_finance_ops.payments;
DROP TABLE IF EXISTS stg_finance_ops.expenses;
DROP TABLE IF EXISTS stg_finance_ops.expense_categories;
DROP TABLE IF EXISTS stg_finance_ops.donations;
DROP TABLE IF EXISTS stg_finance_ops.campaigns;
DROP TABLE IF EXISTS stg_finance_ops.donors;
GO

/*=============================================================================
  3. Donors
=============================================================================*/

CREATE TABLE stg_finance_ops.donors (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    full_name           NVARCHAR(200) NULL,
    national_id         NVARCHAR(50) NULL,
    phone               NVARCHAR(30) NULL,
    email               NVARCHAR(255) NULL,
    donor_type          NVARCHAR(50) NULL,
    is_active           BIT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_finance_donors_source_system DEFAULT (N'FINANCE_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_donors_source_database DEFAULT (N'Source_FinanceOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_donors_source_schema DEFAULT (N'finance_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_donors_source_table DEFAULT (N'donors'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_finance_donors_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_finance_donors_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_finance_donors PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  4. Campaigns
=============================================================================*/

CREATE TABLE stg_finance_ops.campaigns (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    title               NVARCHAR(300) NULL,
    description         NVARCHAR(2000) NULL,
    target_amount       DECIMAL(18,2) NULL,
    start_date          DATE NULL,
    end_date            DATE NULL,
    status              NVARCHAR(50) NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_finance_campaigns_source_system DEFAULT (N'FINANCE_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_campaigns_source_database DEFAULT (N'Source_FinanceOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_campaigns_source_schema DEFAULT (N'finance_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_campaigns_source_table DEFAULT (N'campaigns'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_finance_campaigns_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_finance_campaigns_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_finance_campaigns PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  5. Donations
=============================================================================*/

CREATE TABLE stg_finance_ops.donations (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    donor_id            INT NULL,
    campaign_id         INT NULL,
    amount              DECIMAL(18,2) NULL,
    currency            CHAR(3) NULL,
    donation_type       NVARCHAR(50) NULL,
    donation_date       DATE NULL,
    status              NVARCHAR(50) NULL,
    reference_code      NVARCHAR(100) NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_finance_donations_source_system DEFAULT (N'FINANCE_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_donations_source_database DEFAULT (N'Source_FinanceOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_donations_source_schema DEFAULT (N'finance_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_donations_source_table DEFAULT (N'donations'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_finance_donations_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_finance_donations_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_finance_donations PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  6. Expense Categories
=============================================================================*/

CREATE TABLE stg_finance_ops.expense_categories (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    name                NVARCHAR(200) NULL,
    parent_id           INT NULL,
    is_active           BIT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_finance_expense_categories_source_system DEFAULT (N'FINANCE_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_expense_categories_source_database DEFAULT (N'Source_FinanceOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_expense_categories_source_schema DEFAULT (N'finance_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_expense_categories_source_table DEFAULT (N'expense_categories'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_finance_expense_categories_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_finance_expense_categories_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_finance_expense_categories PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  7. Expenses
=============================================================================*/

CREATE TABLE stg_finance_ops.expenses (
    stg_row_id              BIGINT IDENTITY(1,1) NOT NULL,
    id                      INT NULL,
    center_id               INT NULL,
    child_id                INT NULL,
    category_id             INT NULL,
    amount                  DECIMAL(18,2) NULL,
    currency                CHAR(3) NULL,
    expense_date            DATE NULL,
    description             NVARCHAR(2000) NULL,
    approved_by_user_id     INT NULL,
    status                  NVARCHAR(50) NULL,
    created_at              DATETIME2(0) NULL,
    updated_at              DATETIME2(0) NULL,

    etl_batch_id            INT NULL,
    source_system           NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_finance_expenses_source_system DEFAULT (N'FINANCE_OPS'),
    source_database         NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_expenses_source_database DEFAULT (N'Source_FinanceOps_DB'),
    source_schema           NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_expenses_source_schema DEFAULT (N'finance_ops'),
    source_table            NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_expenses_source_table DEFAULT (N'expenses'),
    extracted_at            DATETIME2(0) NOT NULL CONSTRAINT DF_stg_finance_expenses_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at       DATETIME2(0) NULL,
    row_hash                VARBINARY(32) NULL,
    is_valid                BIT NOT NULL CONSTRAINT DF_stg_finance_expenses_is_valid DEFAULT (1),
    validation_message      NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_finance_expenses PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  8. Payments
=============================================================================*/

CREATE TABLE stg_finance_ops.payments (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    payment_type        NVARCHAR(50) NULL,
    teacher_id          INT NULL,
    center_id           INT NULL,
    amount              DECIMAL(18,2) NULL,
    currency            CHAR(3) NULL,
    payment_date        DATE NULL,
    status              NVARCHAR(50) NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_finance_payments_source_system DEFAULT (N'FINANCE_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_payments_source_database DEFAULT (N'Source_FinanceOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_payments_source_schema DEFAULT (N'finance_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_payments_source_table DEFAULT (N'payments'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_finance_payments_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_finance_payments_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_finance_payments PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  9. Budget Allocations
=============================================================================*/

CREATE TABLE stg_finance_ops.budget_allocations (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    source_type         NVARCHAR(50) NULL,
    source_id           INT NULL,
    center_id           INT NULL,
    child_id            INT NULL,
    category_id         INT NULL,
    allocated_amount    DECIMAL(18,2) NULL,
    allocation_date     DATE NULL,
    reason              NVARCHAR(2000) NULL,
    created_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_finance_budget_allocations_source_system DEFAULT (N'FINANCE_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_budget_allocations_source_database DEFAULT (N'Source_FinanceOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_budget_allocations_source_schema DEFAULT (N'finance_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_budget_allocations_source_table DEFAULT (N'budget_allocations'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_finance_budget_allocations_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_finance_budget_allocations_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_finance_budget_allocations PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  10. Financial Transactions
=============================================================================*/

CREATE TABLE stg_finance_ops.financial_transactions (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  BIGINT NULL,
    entity_type         NVARCHAR(50) NULL,
    entity_id           INT NULL,
    transaction_type    NVARCHAR(50) NULL,
    amount              DECIMAL(18,2) NULL,
    transaction_date    DATE NULL,
    created_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_finance_financial_transactions_source_system DEFAULT (N'FINANCE_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_financial_transactions_source_database DEFAULT (N'Source_FinanceOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_financial_transactions_source_schema DEFAULT (N'finance_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_financial_transactions_source_table DEFAULT (N'financial_transactions'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_finance_financial_transactions_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_finance_financial_transactions_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_finance_financial_transactions PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  11. Currency Rates
=============================================================================*/

CREATE TABLE stg_finance_ops.currency_rates (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    from_currency       CHAR(3) NULL,
    to_currency         CHAR(3) NULL,
    rate                DECIMAL(18,8) NULL,
    rate_date           DATE NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_finance_currency_rates_source_system DEFAULT (N'FINANCE_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_currency_rates_source_database DEFAULT (N'Source_FinanceOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_currency_rates_source_schema DEFAULT (N'finance_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_finance_currency_rates_source_table DEFAULT (N'currency_rates'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_finance_currency_rates_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_finance_currency_rates_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_finance_currency_rates PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  12. Helpful Staging Indexes
=============================================================================*/

CREATE INDEX IX_stg_finance_donors_source_id
    ON stg_finance_ops.donors(id);
GO

CREATE INDEX IX_stg_finance_donors_national_id
    ON stg_finance_ops.donors(national_id);
GO

CREATE INDEX IX_stg_finance_campaigns_source_id
    ON stg_finance_ops.campaigns(id);
GO

CREATE INDEX IX_stg_finance_donations_source_id
    ON stg_finance_ops.donations(id);
GO

CREATE INDEX IX_stg_finance_donations_date
    ON stg_finance_ops.donations(donation_date, donor_id, campaign_id);
GO

CREATE INDEX IX_stg_finance_donations_reference
    ON stg_finance_ops.donations(reference_code);
GO

CREATE INDEX IX_stg_finance_expense_categories_source_id
    ON stg_finance_ops.expense_categories(id);
GO

CREATE INDEX IX_stg_finance_expenses_source_id
    ON stg_finance_ops.expenses(id);
GO

CREATE INDEX IX_stg_finance_expenses_date
    ON stg_finance_ops.expenses(expense_date, center_id, child_id, category_id);
GO

CREATE INDEX IX_stg_finance_payments_source_id
    ON stg_finance_ops.payments(id);
GO

CREATE INDEX IX_stg_finance_payments_date
    ON stg_finance_ops.payments(payment_date, center_id, teacher_id);
GO

CREATE INDEX IX_stg_finance_budget_allocations_source_id
    ON stg_finance_ops.budget_allocations(id);
GO

CREATE INDEX IX_stg_finance_budget_allocations_date
    ON stg_finance_ops.budget_allocations(allocation_date, center_id, child_id, category_id);
GO

CREATE INDEX IX_stg_finance_financial_transactions_entity
    ON stg_finance_ops.financial_transactions(entity_type, entity_id);
GO

CREATE INDEX IX_stg_finance_currency_rates_date
    ON stg_finance_ops.currency_rates(rate_date, from_currency, to_currency);
GO

/* ETL metadata indexes */

CREATE INDEX IX_stg_finance_donors_etl_batch
    ON stg_finance_ops.donors(etl_batch_id, extracted_at);
GO

CREATE INDEX IX_stg_finance_donations_etl_batch
    ON stg_finance_ops.donations(etl_batch_id, extracted_at);
GO

CREATE INDEX IX_stg_finance_expenses_etl_batch
    ON stg_finance_ops.expenses(etl_batch_id, extracted_at);
GO

CREATE INDEX IX_stg_finance_payments_etl_batch
    ON stg_finance_ops.payments(etl_batch_id, extracted_at);
GO

CREATE INDEX IX_stg_finance_budget_allocations_etl_batch
    ON stg_finance_ops.budget_allocations(etl_batch_id, extracted_at);
GO

/*=============================================================================
  13. Completion and Verification
=============================================================================*/

PRINT 'Finance Operations staging tables created successfully.';

SELECT
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s
    ON s.schema_id = t.schema_id
WHERE s.name = N'stg_finance_ops'
ORDER BY t.name;
GO
