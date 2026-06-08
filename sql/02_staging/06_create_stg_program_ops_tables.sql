/*
===============================================================================
 Project      : Charity Data Warehouse Project
 Phase        : Phase 2 - Staging Layer
 File         : 06_create_stg_program_ops_tables.sql
 DBMS         : Microsoft SQL Server
 Tool         : SQL Server Management Studio (SSMS)

 Purpose:
   Create staging tables under Stg_ProgramOps_DB.stg_program_ops.

 Prerequisite:
   Run this first:
   - 05_create_stg_program_ops_db.sql

 Design:
   - Tables mirror Source_ProgramOps_DB.program_ops source tables.
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
===============================================================================
*/

SET NOCOUNT ON;
GO

USE Stg_ProgramOps_DB;
GO

/*=============================================================================
  1. Verify Required Schemas
=============================================================================*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'stg_program_ops')
BEGIN
    EXEC(N'CREATE SCHEMA stg_program_ops');
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

DROP TABLE IF EXISTS stg_program_ops.audit_logs;
DROP TABLE IF EXISTS stg_program_ops.note_batch_items;
DROP TABLE IF EXISTS stg_program_ops.note_batches;
DROP TABLE IF EXISTS stg_program_ops.notes;
DROP TABLE IF EXISTS stg_program_ops.task_assessments;
DROP TABLE IF EXISTS stg_program_ops.assessment_sessions;
DROP TABLE IF EXISTS stg_program_ops.daily_task_assignments;
DROP TABLE IF EXISTS stg_program_ops.child_task_plans;
DROP TABLE IF EXISTS stg_program_ops.child_daily_status;
DROP TABLE IF EXISTS stg_program_ops.absence_reasons;
DROP TABLE IF EXISTS stg_program_ops.center_daily_status;
DROP TABLE IF EXISTS stg_program_ops.closure_reasons;
DROP TABLE IF EXISTS stg_program_ops.task_templates;
DROP TABLE IF EXISTS stg_program_ops.score_scales;
DROP TABLE IF EXISTS stg_program_ops.domains;
DROP TABLE IF EXISTS stg_program_ops.users;
DROP TABLE IF EXISTS stg_program_ops.teachers;
DROP TABLE IF EXISTS stg_program_ops.children;
DROP TABLE IF EXISTS stg_program_ops.centers;
DROP TABLE IF EXISTS stg_program_ops.no_score_reasons;
GO

/*=============================================================================
  3. Staging Tables - Core Master Tables
=============================================================================*/

CREATE TABLE stg_program_ops.centers (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    name                NVARCHAR(200) NULL,
    city                NVARCHAR(100) NULL,
    address             NVARCHAR(500) NULL,
    is_active           BIT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_centers_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_centers_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_centers_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_centers_source_table DEFAULT (N'centers'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_centers_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_centers_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_centers PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.children (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    center_id           INT NULL,
    first_name          NVARCHAR(100) NULL,
    last_name           NVARCHAR(100) NULL,
    national_code       NVARCHAR(20) NULL,
    birth_date          DATE NULL,
    gender              NVARCHAR(20) NULL,
    enrollment_date     DATE NULL,
    status              NVARCHAR(50) NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_children_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_children_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_children_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_children_source_table DEFAULT (N'children'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_children_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_children_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_children PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.teachers (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    center_id           INT NULL,
    first_name          NVARCHAR(100) NULL,
    last_name           NVARCHAR(100) NULL,
    phone               NVARCHAR(30) NULL,
    email               NVARCHAR(255) NULL,
    employment_status   NVARCHAR(50) NULL,
    is_active           BIT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_teachers_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_teachers_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_teachers_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_teachers_source_table DEFAULT (N'teachers'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_teachers_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_teachers_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_teachers PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.users (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    username            NVARCHAR(100) NULL,
    password_hash       NVARCHAR(500) NULL,
    role                NVARCHAR(50) NULL,
    teacher_id          INT NULL,
    is_active           BIT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_users_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_users_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_users_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_users_source_table DEFAULT (N'users'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_users_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_users_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_users PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  4. Staging Tables - Assessment Definition Tables
=============================================================================*/

CREATE TABLE stg_program_ops.domains (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    name                NVARCHAR(200) NULL,
    description         NVARCHAR(1000) NULL,
    is_active           BIT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_domains_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_domains_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_domains_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_domains_source_table DEFAULT (N'domains'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_domains_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_domains_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_domains PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.score_scales (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    name                NVARCHAR(100) NULL,
    min_score           DECIMAL(10,2) NULL,
    max_score           DECIMAL(10,2) NULL,
    description         NVARCHAR(1000) NULL,
    is_active           BIT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_score_scales_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_score_scales_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_score_scales_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_score_scales_source_table DEFAULT (N'score_scales'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_score_scales_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_score_scales_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_score_scales PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.task_templates (
    stg_row_id              BIGINT IDENTITY(1,1) NOT NULL,
    id                      INT NULL,
    domain_id               INT NULL,
    title                   NVARCHAR(300) NULL,
    description             NVARCHAR(2000) NULL,
    default_score_scale_id  INT NULL,
    is_active               BIT NULL,
    created_by              INT NULL,
    created_at              DATETIME2(0) NULL,
    updated_at              DATETIME2(0) NULL,

    etl_batch_id            INT NULL,
    source_system           NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_task_templates_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database         NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_task_templates_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema           NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_task_templates_source_schema DEFAULT (N'program_ops'),
    source_table            NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_task_templates_source_table DEFAULT (N'task_templates'),
    extracted_at            DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_task_templates_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at       DATETIME2(0) NULL,
    row_hash                VARBINARY(32) NULL,
    is_valid                BIT NOT NULL CONSTRAINT DF_stg_program_task_templates_is_valid DEFAULT (1),
    validation_message      NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_task_templates PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  5. Staging Tables - Lookup Reason Tables
=============================================================================*/

CREATE TABLE stg_program_ops.closure_reasons (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    title               NVARCHAR(200) NULL,
    description         NVARCHAR(1000) NULL,
    is_active           BIT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_closure_reasons_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_closure_reasons_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_closure_reasons_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_closure_reasons_source_table DEFAULT (N'closure_reasons'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_closure_reasons_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_closure_reasons_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_closure_reasons PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.absence_reasons (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    title               NVARCHAR(200) NULL,
    description         NVARCHAR(1000) NULL,
    is_active           BIT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_absence_reasons_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_absence_reasons_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_absence_reasons_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_absence_reasons_source_table DEFAULT (N'absence_reasons'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_absence_reasons_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_absence_reasons_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_absence_reasons PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.no_score_reasons (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    title               NVARCHAR(200) NULL,
    description         NVARCHAR(1000) NULL,
    is_active           BIT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_no_score_reasons_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_no_score_reasons_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_no_score_reasons_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_no_score_reasons_source_table DEFAULT (N'no_score_reasons'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_no_score_reasons_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_no_score_reasons_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_no_score_reasons PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  6. Staging Tables - Daily Status Tables
=============================================================================*/

CREATE TABLE stg_program_ops.center_daily_status (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    center_id           INT NULL,
    [date]              DATE NULL,
    status              NVARCHAR(50) NULL,
    closure_reason_id   INT NULL,
    note                NVARCHAR(2000) NULL,
    created_by          INT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_center_daily_status_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_center_daily_status_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_center_daily_status_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_center_daily_status_source_table DEFAULT (N'center_daily_status'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_center_daily_status_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_center_daily_status_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_center_daily_status PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.child_daily_status (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    child_id            INT NULL,
    [date]              DATE NULL,
    status              NVARCHAR(50) NULL,
    absence_reason_id   INT NULL,
    note                NVARCHAR(2000) NULL,
    created_by          INT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_child_daily_status_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_child_daily_status_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_child_daily_status_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_child_daily_status_source_table DEFAULT (N'child_daily_status'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_child_daily_status_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_child_daily_status_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_child_daily_status PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  7. Staging Tables - Task Planning and Assignment
=============================================================================*/

CREATE TABLE stg_program_ops.child_task_plans (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    child_id            INT NULL,
    task_template_id    INT NULL,
    domain_id           INT NULL,
    task_title          NVARCHAR(300) NULL,
    score_scale_id      INT NULL,
    start_date          DATE NULL,
    end_date            DATE NULL,
    is_active           BIT NULL,
    created_by          INT NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_child_task_plans_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_child_task_plans_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_child_task_plans_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_child_task_plans_source_table DEFAULT (N'child_task_plans'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_child_task_plans_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_child_task_plans_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_child_task_plans PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.daily_task_assignments (
    stg_row_id              BIGINT IDENTITY(1,1) NOT NULL,
    id                      INT NULL,
    child_id                INT NULL,
    [date]                  DATE NULL,
    child_task_plan_id      INT NULL,
    task_template_id        INT NULL,
    domain_id               INT NULL,
    task_title              NVARCHAR(300) NULL,
    score_scale_id          INT NULL,
    planned_by              INT NULL,
    status                  NVARCHAR(50) NULL,
    created_at              DATETIME2(0) NULL,
    updated_at              DATETIME2(0) NULL,

    etl_batch_id            INT NULL,
    source_system           NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_daily_task_assignments_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database         NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_daily_task_assignments_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema           NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_daily_task_assignments_source_schema DEFAULT (N'program_ops'),
    source_table            NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_daily_task_assignments_source_table DEFAULT (N'daily_task_assignments'),
    extracted_at            DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_daily_task_assignments_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at       DATETIME2(0) NULL,
    row_hash                VARBINARY(32) NULL,
    is_valid                BIT NOT NULL CONSTRAINT DF_stg_program_daily_task_assignments_is_valid DEFAULT (1),
    validation_message      NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_daily_task_assignments PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  8. Staging Tables - Assessment Sessions and Results
=============================================================================*/

CREATE TABLE stg_program_ops.assessment_sessions (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    child_id            INT NULL,
    teacher_id          INT NULL,
    center_id           INT NULL,
    [date]              DATE NULL,
    started_at          DATETIME2(0) NULL,
    ended_at            DATETIME2(0) NULL,
    session_status      NVARCHAR(50) NULL,
    general_note        NVARCHAR(2000) NULL,
    created_at          DATETIME2(0) NULL,
    updated_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_assessment_sessions_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_assessment_sessions_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_assessment_sessions_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_assessment_sessions_source_table DEFAULT (N'assessment_sessions'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_assessment_sessions_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_assessment_sessions_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_assessment_sessions PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.task_assessments (
    stg_row_id                  BIGINT IDENTITY(1,1) NOT NULL,
    id                          INT NULL,
    daily_task_assignment_id    INT NULL,
    assessment_session_id       INT NULL,
    child_id                    INT NULL,
    teacher_id                  INT NULL,
    [date]                      DATE NULL,
    score                       DECIMAL(10,2) NULL,
    normalized_score            DECIMAL(10,4) NULL,
    assessment_status           NVARCHAR(50) NULL,
    no_score_reason_id          INT NULL,
    attempt_no                  INT NULL,
    note                        NVARCHAR(2000) NULL,
    created_at                  DATETIME2(0) NULL,
    updated_at                  DATETIME2(0) NULL,

    etl_batch_id                INT NULL,
    source_system               NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_task_assessments_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database             NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_task_assessments_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema               NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_task_assessments_source_schema DEFAULT (N'program_ops'),
    source_table                NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_task_assessments_source_table DEFAULT (N'task_assessments'),
    extracted_at                DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_task_assessments_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at           DATETIME2(0) NULL,
    row_hash                    VARBINARY(32) NULL,
    is_valid                    BIT NOT NULL CONSTRAINT DF_stg_program_task_assessments_is_valid DEFAULT (1),
    validation_message          NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_task_assessments PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  9. Staging Tables - Notes and Batches
=============================================================================*/

CREATE TABLE stg_program_ops.notes (
    stg_row_id                  BIGINT IDENTITY(1,1) NOT NULL,
    id                          INT NULL,
    note_scope                  NVARCHAR(50) NULL,
    center_id                   INT NULL,
    child_id                    INT NULL,
    teacher_id                  INT NULL,
    [date]                      DATE NULL,
    daily_task_assignment_id    INT NULL,
    task_assessment_id          INT NULL,
    note_text                   NVARCHAR(MAX) NULL,
    created_by                  INT NULL,
    created_at                  DATETIME2(0) NULL,
    updated_at                  DATETIME2(0) NULL,

    etl_batch_id                INT NULL,
    source_system               NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_notes_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database             NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_notes_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema               NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_notes_source_schema DEFAULT (N'program_ops'),
    source_table                NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_notes_source_table DEFAULT (N'notes'),
    extracted_at                DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_notes_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at           DATETIME2(0) NULL,
    row_hash                    VARBINARY(32) NULL,
    is_valid                    BIT NOT NULL CONSTRAINT DF_stg_program_notes_is_valid DEFAULT (1),
    validation_message          NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_notes PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.note_batches (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    created_by          INT NULL,
    note_scope          NVARCHAR(50) NULL,
    note_text           NVARCHAR(MAX) NULL,
    created_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_note_batches_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_note_batches_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_note_batches_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_note_batches_source_table DEFAULT (N'note_batches'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_note_batches_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_note_batches_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_note_batches PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

CREATE TABLE stg_program_ops.note_batch_items (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  INT NULL,
    note_batch_id       INT NULL,
    note_id             INT NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_note_batch_items_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_note_batch_items_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_note_batch_items_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_note_batch_items_source_table DEFAULT (N'note_batch_items'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_note_batch_items_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_note_batch_items_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_note_batch_items PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  10. Staging Tables - Audit Logs
=============================================================================*/

CREATE TABLE stg_program_ops.audit_logs (
    stg_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    id                  BIGINT NULL,
    user_id             INT NULL,
    entity_name         NVARCHAR(200) NULL,
    entity_id           INT NULL,
    action              NVARCHAR(50) NULL,
    old_value           NVARCHAR(MAX) NULL,
    new_value           NVARCHAR(MAX) NULL,
    created_at          DATETIME2(0) NULL,

    etl_batch_id        INT NULL,
    source_system       NVARCHAR(100) NOT NULL CONSTRAINT DF_stg_program_audit_logs_source_system DEFAULT (N'PROGRAM_OPS'),
    source_database     NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_audit_logs_source_database DEFAULT (N'Source_ProgramOps_DB'),
    source_schema       NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_audit_logs_source_schema DEFAULT (N'program_ops'),
    source_table        NVARCHAR(128) NOT NULL CONSTRAINT DF_stg_program_audit_logs_source_table DEFAULT (N'audit_logs'),
    extracted_at        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_program_audit_logs_extracted_at DEFAULT (SYSDATETIME()),
    source_updated_at   DATETIME2(0) NULL,
    row_hash            VARBINARY(32) NULL,
    is_valid            BIT NOT NULL CONSTRAINT DF_stg_program_audit_logs_is_valid DEFAULT (1),
    validation_message  NVARCHAR(MAX) NULL,

    CONSTRAINT PK_stg_program_audit_logs PRIMARY KEY CLUSTERED (stg_row_id)
);
GO

/*=============================================================================
  11. Helpful Staging Indexes
=============================================================================*/

CREATE INDEX IX_stg_program_centers_source_id
    ON stg_program_ops.centers(id);
GO

CREATE INDEX IX_stg_program_children_source_id
    ON stg_program_ops.children(id);
GO

CREATE INDEX IX_stg_program_children_center_id
    ON stg_program_ops.children(center_id);
GO

CREATE INDEX IX_stg_program_teachers_source_id
    ON stg_program_ops.teachers(id);
GO

CREATE INDEX IX_stg_program_teachers_center_id
    ON stg_program_ops.teachers(center_id);
GO

CREATE INDEX IX_stg_program_users_source_id
    ON stg_program_ops.users(id);
GO

CREATE INDEX IX_stg_program_domains_source_id
    ON stg_program_ops.domains(id);
GO

CREATE INDEX IX_stg_program_score_scales_source_id
    ON stg_program_ops.score_scales(id);
GO

CREATE INDEX IX_stg_program_task_templates_source_id
    ON stg_program_ops.task_templates(id);
GO

CREATE INDEX IX_stg_program_center_daily_status_date
    ON stg_program_ops.center_daily_status([date], center_id);
GO

CREATE INDEX IX_stg_program_child_daily_status_date
    ON stg_program_ops.child_daily_status([date], child_id);
GO

CREATE INDEX IX_stg_program_child_task_plans_child_date
    ON stg_program_ops.child_task_plans(child_id, start_date, end_date);
GO

CREATE INDEX IX_stg_program_daily_task_assignments_date
    ON stg_program_ops.daily_task_assignments([date], child_id);
GO

CREATE INDEX IX_stg_program_assessment_sessions_date
    ON stg_program_ops.assessment_sessions([date], child_id, teacher_id);
GO

CREATE INDEX IX_stg_program_task_assessments_date
    ON stg_program_ops.task_assessments([date], child_id, teacher_id);
GO

CREATE INDEX IX_stg_program_notes_scope_date
    ON stg_program_ops.notes(note_scope, [date]);
GO

CREATE INDEX IX_stg_program_audit_logs_entity
    ON stg_program_ops.audit_logs(entity_name, entity_id, created_at);
GO

/* ETL metadata indexes */

CREATE INDEX IX_stg_program_centers_etl_batch
    ON stg_program_ops.centers(etl_batch_id, extracted_at);
GO

CREATE INDEX IX_stg_program_children_etl_batch
    ON stg_program_ops.children(etl_batch_id, extracted_at);
GO

CREATE INDEX IX_stg_program_teachers_etl_batch
    ON stg_program_ops.teachers(etl_batch_id, extracted_at);
GO

CREATE INDEX IX_stg_program_task_assessments_etl_batch
    ON stg_program_ops.task_assessments(etl_batch_id, extracted_at);
GO

/*=============================================================================
  12. Completion and Verification
=============================================================================*/

PRINT 'Program Operations staging tables created successfully.';

SELECT
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s
    ON s.schema_id = t.schema_id
WHERE s.name = N'stg_program_ops'
ORDER BY t.name;
GO
