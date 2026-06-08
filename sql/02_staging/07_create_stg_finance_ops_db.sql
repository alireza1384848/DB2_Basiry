/*
===============================================================================
 Project      : Charity Data Warehouse Project
 Phase        : Phase 2 - Staging Layer
 File         : 07_create_stg_finance_ops_db.sql
 DBMS         : Microsoft SQL Server
 Tool         : SQL Server Management Studio (SSMS)

 Purpose:
   Create the staging database for Finance Operations source data.

 Naming decision:
   Database : Stg_FinanceOps_DB
   Schema   : stg_finance_ops

 Why this name:
   - `Stg_FinanceOps_DB` clearly identifies this as the staging database for
     the Finance Operations source system.
   - `stg_finance_ops` keeps the schema aligned with source schema
     `finance_ops`, while clearly separating staging from source.

 Current scope:
   - Create staging database.
   - Create staging schema.
   - Create ETL admin schema and minimal ETL metadata tables.

 Source system:
   - Source_FinanceOps_DB.finance_ops
===============================================================================
*/

SET NOCOUNT ON;
GO

/*=============================================================================
  1. Create Staging Database
=============================================================================*/

IF DB_ID(N'Stg_FinanceOps_DB') IS NULL
BEGIN
    CREATE DATABASE Stg_FinanceOps_DB;
END
GO

USE Stg_FinanceOps_DB;
GO

/*=============================================================================
  2. Create Staging Schema
=============================================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = N'stg_finance_ops'
)
BEGIN
    EXEC(N'CREATE SCHEMA stg_finance_ops');
END
GO

/*=============================================================================
  3. Create ETL Admin Schema
=============================================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = N'etl_admin'
)
BEGIN
    EXEC(N'CREATE SCHEMA etl_admin');
END
GO

/*=============================================================================
  4. Create Minimal ETL Batch Control Table
=============================================================================*/

IF OBJECT_ID(N'etl_admin.etl_batch', N'U') IS NULL
BEGIN
    CREATE TABLE etl_admin.etl_batch (
        etl_batch_id        INT IDENTITY(1,1) NOT NULL,
        source_system       NVARCHAR(100) NOT NULL,
        target_layer        NVARCHAR(100) NOT NULL,
        batch_status        NVARCHAR(50) NOT NULL CONSTRAINT DF_finance_etl_batch_status DEFAULT (N'created'),
        started_at          DATETIME2(0) NOT NULL CONSTRAINT DF_finance_etl_batch_started_at DEFAULT (SYSDATETIME()),
        ended_at            DATETIME2(0) NULL,
        rows_extracted      INT NULL,
        rows_inserted       INT NULL,
        rows_rejected       INT NULL,
        error_message       NVARCHAR(MAX) NULL,
        created_by          NVARCHAR(128) NOT NULL CONSTRAINT DF_finance_etl_batch_created_by DEFAULT (SUSER_SNAME()),

        CONSTRAINT PK_finance_etl_batch PRIMARY KEY CLUSTERED (etl_batch_id),
        CONSTRAINT CK_finance_etl_batch_status
            CHECK (batch_status IN (N'created', N'running', N'succeeded', N'failed', N'cancelled'))
    );
END
GO

/*=============================================================================
  5. Create Minimal ETL Load Log Table
=============================================================================*/

IF OBJECT_ID(N'etl_admin.etl_load_log', N'U') IS NULL
BEGIN
    CREATE TABLE etl_admin.etl_load_log (
        etl_load_log_id     BIGINT IDENTITY(1,1) NOT NULL,
        etl_batch_id        INT NULL,
        source_database     NVARCHAR(128) NOT NULL,
        source_schema       NVARCHAR(128) NOT NULL,
        source_table        NVARCHAR(128) NOT NULL,
        target_database     NVARCHAR(128) NOT NULL,
        target_schema       NVARCHAR(128) NOT NULL,
        target_table        NVARCHAR(128) NOT NULL,
        load_status         NVARCHAR(50) NOT NULL,
        rows_read           INT NULL,
        rows_written        INT NULL,
        rows_rejected       INT NULL,
        started_at          DATETIME2(0) NOT NULL CONSTRAINT DF_finance_etl_load_log_started_at DEFAULT (SYSDATETIME()),
        ended_at            DATETIME2(0) NULL,
        message             NVARCHAR(MAX) NULL,

        CONSTRAINT PK_finance_etl_load_log PRIMARY KEY CLUSTERED (etl_load_log_id),
        CONSTRAINT FK_finance_etl_load_log_etl_batch
            FOREIGN KEY (etl_batch_id) REFERENCES etl_admin.etl_batch(etl_batch_id),
        CONSTRAINT CK_finance_etl_load_log_status
            CHECK (load_status IN (N'created', N'running', N'succeeded', N'failed', N'skipped'))
    );
END
GO

/*=============================================================================
  6. Helpful Indexes
=============================================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_finance_etl_batch_source_status'
      AND object_id = OBJECT_ID(N'etl_admin.etl_batch')
)
BEGIN
    CREATE INDEX IX_finance_etl_batch_source_status
        ON etl_admin.etl_batch(source_system, target_layer, batch_status, started_at);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_finance_etl_load_log_batch'
      AND object_id = OBJECT_ID(N'etl_admin.etl_load_log')
)
BEGIN
    CREATE INDEX IX_finance_etl_load_log_batch
        ON etl_admin.etl_load_log(etl_batch_id, load_status, started_at);
END
GO

/*=============================================================================
  7. Completion Message
=============================================================================*/

PRINT 'Stg_FinanceOps_DB created successfully.';
PRINT 'Schemas created or verified: stg_finance_ops, etl_admin';
PRINT 'Minimal ETL admin tables created or verified: etl_batch, etl_load_log';
PRINT 'Next step: create staging tables under stg_finance_ops.';
GO
