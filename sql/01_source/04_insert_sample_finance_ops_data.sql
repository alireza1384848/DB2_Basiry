/*
===============================================================================
 Project      : Charity Data Warehouse Project
 Phase        : Phase 1 - Operational Source Sample Data
 File         : 04_insert_sample_finance_ops_data.sql
 DBMS         : Microsoft SQL Server
 Tool         : SQL Server Management Studio (SSMS)

 Purpose:
   Insert realistic sample data into Source_FinanceOps_DB.finance_ops.

 Prerequisite:
   Run these first:
   - 01_create_source_program_ops_db.sql
   - 02_create_source_finance_ops_db.sql
   - 03_insert_sample_program_ops_data.sql

 Important design note:
   This finance source contains conceptual references to shared business entities:
   - center_id
   - child_id
   - teacher_id

   These IDs are intentionally NOT foreign keys in the finance source database.
   They correspond to Program Operations sample records conceptually:
   - centers: Tehran=1, Shiraz=2, Isfahan=3
   - children: Ali=1, Sara=2, Reza=3, Nika=4, Matin=5, Yasna=6
   - teachers: Mina=1, Omid=2, Laleh=3, Hamed=4

   In the warehouse phase, these references will be resolved through conformed
   dimensions such as dw.dim_center, dw.dim_child, and dw.dim_teacher.

 Important fix style:
   This script does NOT assume generated finance IDs start from 1.
   It captures real IDs using variables and then uses those IDs in child tables.
===============================================================================
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE Source_FinanceOps_DB;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /*=========================================================================
      1. Clear Existing Sample Data
      Delete child tables first, then parent tables.
    =========================================================================*/

    DELETE FROM finance_ops.currency_rates;
    DELETE FROM finance_ops.financial_transactions;
    DELETE FROM finance_ops.budget_allocations;
    DELETE FROM finance_ops.payments;
    DELETE FROM finance_ops.expenses;
    DELETE FROM finance_ops.expense_categories;
    DELETE FROM finance_ops.donations;
    DELETE FROM finance_ops.campaigns;
    DELETE FROM finance_ops.donors;

    /*=========================================================================
      2. Conceptual Shared Source References
      These are not foreign keys in this database.
    =========================================================================*/

    DECLARE
        @center_tehran  INT = 1,
        @center_shiraz  INT = 2,
        @center_isfahan INT = 3,

        @child_ali      INT = 1,
        @child_sara     INT = 2,
        @child_reza     INT = 3,
        @child_nika     INT = 4,
        @child_matin    INT = 5,
        @child_yasna    INT = 6,

        @teacher_mina   INT = 1,
        @teacher_omid   INT = 2,
        @teacher_laleh  INT = 3,
        @teacher_hamed  INT = 4,

        @user_admin     INT = 1,
        @user_mina      INT = 2,
        @user_laleh     INT = 4;

    /*=========================================================================
      3. Parent Tables: Donors, Campaigns, Expense Categories
    =========================================================================*/

    INSERT INTO finance_ops.donors
        (full_name, national_id, phone, email, donor_type, is_active, created_at, updated_at)
    VALUES
        (N'Parsa Mehr Charity Group', N'ORG-1001', N'02144000001', N'contact@parsamehr.org', N'organization', 1, '2025-01-05 09:00:00', NULL),
        (N'Sina Rahmanian',           N'1000000001', N'09121000001', N'sina.rahmanian@example.com', N'individual', 1, '2025-01-08 10:00:00', NULL),
        (N'Niloofar Tavakoli',        N'1000000002', N'09121000002', N'niloofar.tavakoli@example.com', N'individual', 1, '2025-01-10 11:00:00', NULL),
        (N'Blue Sky Foundation',      N'ORG-1002', N'02155000002', N'finance@blueskyfoundation.org', N'organization', 1, '2025-01-12 09:30:00', NULL),
        (N'Arman Logistics Co.',      N'ORG-1003', N'02166000003', N'csr@armanlogistics.com', N'organization', 1, '2025-02-01 08:45:00', NULL),
        (N'Inactive Test Donor',      N'1000000003', N'09121000003', N'inactive.donor@example.com', N'individual', 0, '2024-10-01 08:45:00', '2025-02-01 12:00:00');

    DECLARE
        @donor_parsa     INT,
        @donor_sina      INT,
        @donor_niloofar  INT,
        @donor_bluesky   INT,
        @donor_arman     INT,
        @donor_inactive  INT;

    SELECT @donor_parsa    = id FROM finance_ops.donors WHERE national_id = N'ORG-1001';
    SELECT @donor_sina     = id FROM finance_ops.donors WHERE national_id = N'1000000001';
    SELECT @donor_niloofar = id FROM finance_ops.donors WHERE national_id = N'1000000002';
    SELECT @donor_bluesky  = id FROM finance_ops.donors WHERE national_id = N'ORG-1002';
    SELECT @donor_arman    = id FROM finance_ops.donors WHERE national_id = N'ORG-1003';
    SELECT @donor_inactive = id FROM finance_ops.donors WHERE national_id = N'1000000003';

    INSERT INTO finance_ops.campaigns
        (title, description, target_amount, start_date, end_date, status, created_at, updated_at)
    VALUES
        (N'Spring Education Support 2025', N'Campaign to support education and therapy programs in spring 2025.', 500000000.00, '2025-03-01', '2025-05-31', N'active', '2025-02-15 09:00:00', NULL),
        (N'Therapy Equipment Fund',        N'Fund for buying therapy and assessment equipment.', 300000000.00, '2025-04-01', '2025-06-30', N'active', '2025-03-15 09:00:00', NULL),
        (N'Monthly Meals Program',         N'Food and daily care support for children.', 200000000.00, '2025-05-01', '2025-05-31', N'closed', '2025-04-20 09:00:00', '2025-06-01 10:00:00'),
        (N'Winter Clothes 2025',           N'Future campaign for winter clothing support.', 150000000.00, '2025-11-01', '2025-12-31', N'planned', '2025-05-01 09:00:00', NULL);

    DECLARE
        @campaign_spring     INT,
        @campaign_equipment  INT,
        @campaign_meals      INT,
        @campaign_winter     INT;

    SELECT @campaign_spring    = id FROM finance_ops.campaigns WHERE title = N'Spring Education Support 2025';
    SELECT @campaign_equipment = id FROM finance_ops.campaigns WHERE title = N'Therapy Equipment Fund';
    SELECT @campaign_meals     = id FROM finance_ops.campaigns WHERE title = N'Monthly Meals Program';
    SELECT @campaign_winter    = id FROM finance_ops.campaigns WHERE title = N'Winter Clothes 2025';

    INSERT INTO finance_ops.expense_categories
        (name, parent_id, is_active, created_at, updated_at)
    VALUES
        (N'Education Program', NULL, 1, '2025-01-01 08:00:00', NULL),
        (N'Therapy Equipment', NULL, 1, '2025-01-01 08:00:00', NULL),
        (N'Food and Meals', NULL, 1, '2025-01-01 08:00:00', NULL),
        (N'Salaries', NULL, 1, '2025-01-01 08:00:00', NULL),
        (N'Operations', NULL, 1, '2025-01-01 08:00:00', NULL);

    DECLARE
        @cat_education INT,
        @cat_equipment INT,
        @cat_food      INT,
        @cat_salaries  INT,
        @cat_ops       INT;

    SELECT @cat_education = id FROM finance_ops.expense_categories WHERE name = N'Education Program';
    SELECT @cat_equipment = id FROM finance_ops.expense_categories WHERE name = N'Therapy Equipment';
    SELECT @cat_food      = id FROM finance_ops.expense_categories WHERE name = N'Food and Meals';
    SELECT @cat_salaries  = id FROM finance_ops.expense_categories WHERE name = N'Salaries';
    SELECT @cat_ops       = id FROM finance_ops.expense_categories WHERE name = N'Operations';

    INSERT INTO finance_ops.expense_categories
        (name, parent_id, is_active, created_at, updated_at)
    VALUES
        (N'Books and Learning Materials', @cat_education, 1, '2025-01-01 08:15:00', NULL),
        (N'Assessment Tools',             @cat_equipment, 1, '2025-01-01 08:15:00', NULL),
        (N'Daily Lunch',                  @cat_food,      1, '2025-01-01 08:15:00', NULL),
        (N'Building Maintenance',         @cat_ops,       1, '2025-01-01 08:15:00', NULL);

    DECLARE
        @cat_books       INT,
        @cat_assessment  INT,
        @cat_lunch       INT,
        @cat_maintenance INT;

    SELECT @cat_books       = id FROM finance_ops.expense_categories WHERE name = N'Books and Learning Materials';
    SELECT @cat_assessment  = id FROM finance_ops.expense_categories WHERE name = N'Assessment Tools';
    SELECT @cat_lunch       = id FROM finance_ops.expense_categories WHERE name = N'Daily Lunch';
    SELECT @cat_maintenance = id FROM finance_ops.expense_categories WHERE name = N'Building Maintenance';

    /*=========================================================================
      4. Donations
    =========================================================================*/

    INSERT INTO finance_ops.donations
        (donor_id, campaign_id, amount, currency, donation_type, donation_date, status, reference_code, created_at, updated_at)
    VALUES
        (@donor_parsa,    @campaign_spring,    120000000.00, 'IRR', N'bank_transfer', '2025-05-01', N'confirmed', N'DON-2025-0001', '2025-05-01 09:15:00', '2025-05-01 10:00:00'),
        (@donor_sina,     @campaign_spring,     15000000.00, 'IRR', N'online',        '2025-05-01', N'confirmed', N'DON-2025-0002', '2025-05-01 11:00:00', '2025-05-01 11:05:00'),
        (@donor_niloofar, @campaign_meals,       8000000.00, 'IRR', N'online',        '2025-05-02', N'confirmed', N'DON-2025-0003', '2025-05-02 12:00:00', '2025-05-02 12:05:00'),
        (@donor_bluesky,  @campaign_equipment,  90000000.00, 'IRR', N'bank_transfer', '2025-05-03', N'pending',   N'DON-2025-0004', '2025-05-03 09:30:00', NULL),
        (@donor_arman,    @campaign_equipment,  45000000.00, 'IRR', N'in_kind',       '2025-05-04', N'confirmed', N'DON-2025-0005', '2025-05-04 10:00:00', '2025-05-04 12:00:00'),
        (@donor_sina,     @campaign_meals,       5000000.00, 'IRR', N'cash',          '2025-05-05', N'rejected',  N'DON-2025-0006', '2025-05-05 10:00:00', '2025-05-05 13:00:00'),
        (@donor_niloofar, @campaign_spring,     10000000.00, 'IRR', N'online',        '2025-05-06', N'refunded',  N'DON-2025-0007', '2025-05-06 10:00:00', '2025-05-07 09:00:00'),
        (@donor_parsa,    NULL,                 30000000.00, 'IRR', N'bank_transfer', '2025-05-07', N'confirmed', N'DON-2025-0008', '2025-05-07 09:45:00', '2025-05-07 10:00:00');

    DECLARE
        @don_0001 INT,
        @don_0002 INT,
        @don_0003 INT,
        @don_0004 INT,
        @don_0005 INT,
        @don_0006 INT,
        @don_0007 INT,
        @don_0008 INT;

    SELECT @don_0001 = id FROM finance_ops.donations WHERE reference_code = N'DON-2025-0001';
    SELECT @don_0002 = id FROM finance_ops.donations WHERE reference_code = N'DON-2025-0002';
    SELECT @don_0003 = id FROM finance_ops.donations WHERE reference_code = N'DON-2025-0003';
    SELECT @don_0004 = id FROM finance_ops.donations WHERE reference_code = N'DON-2025-0004';
    SELECT @don_0005 = id FROM finance_ops.donations WHERE reference_code = N'DON-2025-0005';
    SELECT @don_0006 = id FROM finance_ops.donations WHERE reference_code = N'DON-2025-0006';
    SELECT @don_0007 = id FROM finance_ops.donations WHERE reference_code = N'DON-2025-0007';
    SELECT @don_0008 = id FROM finance_ops.donations WHERE reference_code = N'DON-2025-0008';

    /*=========================================================================
      5. Expenses
    =========================================================================*/

    INSERT INTO finance_ops.expenses
        (center_id, child_id, category_id, amount, currency, expense_date, description, approved_by_user_id, status, created_at, updated_at)
    VALUES
        (@center_tehran,  @child_ali,   @cat_books,       3500000.00,  'IRR', '2025-05-01', N'Learning materials for Ali.',        @user_admin, N'approved', '2025-05-01 14:00:00', '2025-05-01 16:00:00'),
        (@center_tehran,  @child_sara,  @cat_books,       3200000.00,  'IRR', '2025-05-01', N'Learning materials for Sara.',       @user_admin, N'approved', '2025-05-01 14:05:00', '2025-05-01 16:00:00'),
        (@center_tehran,  NULL,         @cat_lunch,       9000000.00,  'IRR', '2025-05-02', N'Daily lunch for Tehran center.',     @user_admin, N'approved', '2025-05-02 13:00:00', '2025-05-02 15:00:00'),
        (@center_shiraz,  @child_nika,  @cat_assessment,  7500000.00,  'IRR', '2025-05-02', N'Assessment tools for Nika.',         @user_admin, N'approved', '2025-05-02 14:00:00', '2025-05-02 16:00:00'),
        (@center_shiraz,  @child_matin, @cat_lunch,       2800000.00,  'IRR', '2025-05-03', N'Meal support for Matin.',            @user_admin, N'pending',  '2025-05-03 13:00:00', NULL),
        (@center_isfahan, NULL,         @cat_maintenance, 22000000.00, 'IRR', '2025-05-02', N'Building maintenance in Isfahan.',   @user_admin, N'approved', '2025-05-02 09:00:00', '2025-05-02 11:00:00'),
        (@center_isfahan, @child_yasna, @cat_assessment,  6000000.00,  'IRR', '2025-05-04', N'Balance assessment tool for Yasna.', @user_admin, N'rejected', '2025-05-04 10:00:00', '2025-05-04 12:00:00');

    DECLARE
        @expense_ali_books      INT,
        @expense_sara_books     INT,
        @expense_tehran_lunch   INT,
        @expense_nika_tool      INT,
        @expense_matin_lunch    INT,
        @expense_isf_maint      INT,
        @expense_yasna_tool     INT;

    SELECT @expense_ali_books    = id FROM finance_ops.expenses WHERE description = N'Learning materials for Ali.';
    SELECT @expense_sara_books   = id FROM finance_ops.expenses WHERE description = N'Learning materials for Sara.';
    SELECT @expense_tehran_lunch = id FROM finance_ops.expenses WHERE description = N'Daily lunch for Tehran center.';
    SELECT @expense_nika_tool    = id FROM finance_ops.expenses WHERE description = N'Assessment tools for Nika.';
    SELECT @expense_matin_lunch  = id FROM finance_ops.expenses WHERE description = N'Meal support for Matin.';
    SELECT @expense_isf_maint    = id FROM finance_ops.expenses WHERE description = N'Building maintenance in Isfahan.';
    SELECT @expense_yasna_tool   = id FROM finance_ops.expenses WHERE description = N'Balance assessment tool for Yasna.';

    /*=========================================================================
      6. Payments
    =========================================================================*/

    INSERT INTO finance_ops.payments
        (payment_type, teacher_id, center_id, amount, currency, payment_date, status, created_at, updated_at)
    VALUES
        (N'salary', @teacher_mina,  @center_tehran,  65000000.00, 'IRR', '2025-05-31', N'paid',     '2025-05-31 09:00:00', '2025-05-31 12:00:00'),
        (N'salary', @teacher_omid,  @center_tehran,  42000000.00, 'IRR', '2025-05-31', N'paid',     '2025-05-31 09:05:00', '2025-05-31 12:05:00'),
        (N'salary', @teacher_laleh, @center_shiraz,  62000000.00, 'IRR', '2025-05-31', N'approved', '2025-05-31 09:10:00', NULL),
        (N'salary', @teacher_hamed, @center_isfahan, 60000000.00, 'IRR', '2025-05-31', N'pending',  '2025-05-31 09:15:00', NULL),
        (N'bonus',  @teacher_mina,  @center_tehran,   5000000.00, 'IRR', '2025-05-20', N'paid',     '2025-05-20 10:00:00', '2025-05-20 12:00:00'),
        (N'vendor', NULL,           @center_isfahan, 18000000.00, 'IRR', '2025-05-03', N'paid',     '2025-05-03 11:00:00', '2025-05-03 13:00:00'),
        (N'refund', NULL,           @center_tehran,  10000000.00, 'IRR', '2025-05-07', N'paid',     '2025-05-07 09:00:00', '2025-05-07 10:00:00');

    DECLARE
        @payment_mina_salary  INT,
        @payment_omid_salary  INT,
        @payment_laleh_salary INT,
        @payment_hamed_salary INT,
        @payment_mina_bonus   INT,
        @payment_vendor_isf   INT,
        @payment_refund       INT;

    SELECT @payment_mina_salary  = id FROM finance_ops.payments WHERE teacher_id = @teacher_mina  AND payment_type = N'salary';
    SELECT @payment_omid_salary  = id FROM finance_ops.payments WHERE teacher_id = @teacher_omid  AND payment_type = N'salary';
    SELECT @payment_laleh_salary = id FROM finance_ops.payments WHERE teacher_id = @teacher_laleh AND payment_type = N'salary';
    SELECT @payment_hamed_salary = id FROM finance_ops.payments WHERE teacher_id = @teacher_hamed AND payment_type = N'salary';
    SELECT @payment_mina_bonus   = id FROM finance_ops.payments WHERE teacher_id = @teacher_mina  AND payment_type = N'bonus';
    SELECT @payment_vendor_isf   = id FROM finance_ops.payments WHERE teacher_id IS NULL AND center_id = @center_isfahan AND payment_type = N'vendor';
    SELECT @payment_refund       = id FROM finance_ops.payments WHERE payment_type = N'refund';

    /*=========================================================================
      7. Budget Allocations
    =========================================================================*/

    INSERT INTO finance_ops.budget_allocations
        (source_type, source_id, center_id, child_id, category_id, allocated_amount, allocation_date, reason, created_at)
    VALUES
        (N'donation',        @don_0001, @center_tehran,  NULL,         @cat_education, 60000000.00, '2025-05-02', N'Allocate Spring campaign donation to Tehran education program.', '2025-05-02 09:00:00'),
        (N'donation',        @don_0001, @center_shiraz,  NULL,         @cat_education, 30000000.00, '2025-05-02', N'Allocate Spring campaign donation to Shiraz education program.', '2025-05-02 09:05:00'),
        (N'donation',        @don_0002, @center_tehran,  @child_ali,   @cat_books,     5000000.00,  '2025-05-02', N'Direct support for Ali learning materials.', '2025-05-02 09:10:00'),
        (N'donation',        @don_0003, @center_shiraz,  @child_matin, @cat_lunch,     3000000.00,  '2025-05-03', N'Meal support allocation for Matin.', '2025-05-03 09:00:00'),
        (N'donation',        @don_0005, @center_shiraz,  @child_nika,  @cat_assessment,15000000.00, '2025-05-05', N'In-kind equipment allocation for Nika assessment.', '2025-05-05 09:00:00'),
        (N'internal_budget', NULL,      @center_isfahan, NULL,         @cat_maintenance,25000000.00,'2025-05-02', N'Internal budget for Isfahan maintenance.', '2025-05-02 08:30:00'),
        (N'internal_budget', NULL,      @center_tehran,  NULL,         @cat_salaries,  50000000.00, '2025-05-31', N'Monthly salary support for Tehran.', '2025-05-31 08:30:00');

    DECLARE
        @alloc_tehran_edu INT,
        @alloc_shiraz_edu INT,
        @alloc_ali_books  INT,
        @alloc_matin_food INT,
        @alloc_nika_tool  INT,
        @alloc_isf_maint  INT,
        @alloc_salary     INT;

    SELECT @alloc_tehran_edu = id FROM finance_ops.budget_allocations WHERE reason = N'Allocate Spring campaign donation to Tehran education program.';
    SELECT @alloc_shiraz_edu = id FROM finance_ops.budget_allocations WHERE reason = N'Allocate Spring campaign donation to Shiraz education program.';
    SELECT @alloc_ali_books  = id FROM finance_ops.budget_allocations WHERE reason = N'Direct support for Ali learning materials.';
    SELECT @alloc_matin_food = id FROM finance_ops.budget_allocations WHERE reason = N'Meal support allocation for Matin.';
    SELECT @alloc_nika_tool  = id FROM finance_ops.budget_allocations WHERE reason = N'In-kind equipment allocation for Nika assessment.';
    SELECT @alloc_isf_maint  = id FROM finance_ops.budget_allocations WHERE reason = N'Internal budget for Isfahan maintenance.';
    SELECT @alloc_salary     = id FROM finance_ops.budget_allocations WHERE reason = N'Monthly salary support for Tehran.';

    /*=========================================================================
      8. Financial Transactions
    =========================================================================*/

    INSERT INTO finance_ops.financial_transactions
        (entity_type, entity_id, transaction_type, amount, transaction_date, created_at)
    VALUES
        (N'donation', @don_0001, N'credit', 120000000.00, '2025-05-01', '2025-05-01 10:00:00'),
        (N'donation', @don_0002, N'credit',  15000000.00, '2025-05-01', '2025-05-01 11:05:00'),
        (N'donation', @don_0003, N'credit',   8000000.00, '2025-05-02', '2025-05-02 12:05:00'),
        (N'donation', @don_0005, N'credit',  45000000.00, '2025-05-04', '2025-05-04 12:00:00'),
        (N'donation', @don_0008, N'credit',  30000000.00, '2025-05-07', '2025-05-07 10:00:00'),

        (N'expense', @expense_ali_books,    N'debit',  3500000.00,  '2025-05-01', '2025-05-01 16:00:00'),
        (N'expense', @expense_sara_books,   N'debit',  3200000.00,  '2025-05-01', '2025-05-01 16:00:00'),
        (N'expense', @expense_tehran_lunch, N'debit',  9000000.00,  '2025-05-02', '2025-05-02 15:00:00'),
        (N'expense', @expense_nika_tool,    N'debit',  7500000.00,  '2025-05-02', '2025-05-02 16:00:00'),
        (N'expense', @expense_isf_maint,    N'debit', 22000000.00,  '2025-05-02', '2025-05-02 11:00:00'),

        (N'payment', @payment_mina_salary,  N'debit', 65000000.00,  '2025-05-31', '2025-05-31 12:00:00'),
        (N'payment', @payment_omid_salary,  N'debit', 42000000.00,  '2025-05-31', '2025-05-31 12:05:00'),
        (N'payment', @payment_mina_bonus,   N'debit',  5000000.00,  '2025-05-20', '2025-05-20 12:00:00'),
        (N'payment', @payment_vendor_isf,   N'debit', 18000000.00,  '2025-05-03', '2025-05-03 13:00:00'),
        (N'payment', @payment_refund,       N'debit', 10000000.00,  '2025-05-07', '2025-05-07 10:00:00');

    /*=========================================================================
      9. Currency Rates
    =========================================================================*/

    INSERT INTO finance_ops.currency_rates
        (from_currency, to_currency, rate, rate_date)
    VALUES
        ('IRR', 'IRR', 1.00000000, '2025-05-01'),
        ('IRR', 'IRR', 1.00000000, '2025-05-02'),
        ('IRR', 'IRR', 1.00000000, '2025-05-03'),
        ('IRR', 'IRR', 1.00000000, '2025-05-04'),
        ('IRR', 'IRR', 1.00000000, '2025-05-05'),
        ('IRR', 'IRR', 1.00000000, '2025-05-06'),
        ('IRR', 'IRR', 1.00000000, '2025-05-07'),
        ('USD', 'IRR', 420000.00000000, '2025-05-01'),
        ('EUR', 'IRR', 455000.00000000, '2025-05-01');

    COMMIT TRANSACTION;

    PRINT 'Finance operations sample data inserted successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE
        @ErrorMessage NVARCHAR(4000),
        @ErrorSeverity INT,
        @ErrorState INT;

    SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    PRINT 'Finance operations sample data insert failed. Transaction rolled back.';
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO

/*=============================================================================
  10. Validation Queries
=============================================================================*/

PRINT 'Row counts by table:';

SELECT 'donors' AS table_name, COUNT(*) AS row_count FROM finance_ops.donors
UNION ALL SELECT 'campaigns', COUNT(*) FROM finance_ops.campaigns
UNION ALL SELECT 'donations', COUNT(*) FROM finance_ops.donations
UNION ALL SELECT 'expense_categories', COUNT(*) FROM finance_ops.expense_categories
UNION ALL SELECT 'expenses', COUNT(*) FROM finance_ops.expenses
UNION ALL SELECT 'payments', COUNT(*) FROM finance_ops.payments
UNION ALL SELECT 'budget_allocations', COUNT(*) FROM finance_ops.budget_allocations
UNION ALL SELECT 'financial_transactions', COUNT(*) FROM finance_ops.financial_transactions
UNION ALL SELECT 'currency_rates', COUNT(*) FROM finance_ops.currency_rates
ORDER BY table_name;
GO

/*=============================================================================
  11. Foreign Key Sanity Checks
=============================================================================*/

PRINT 'Foreign key sanity checks: expected result is zero rows for each check.';

SELECT 'donations missing donor' AS check_name, COUNT(*) AS problem_count
FROM finance_ops.donations d
LEFT JOIN finance_ops.donors r ON r.id = d.donor_id
WHERE r.id IS NULL

UNION ALL

SELECT 'donations missing campaign where campaign_id is not null', COUNT(*)
FROM finance_ops.donations d
LEFT JOIN finance_ops.campaigns c ON c.id = d.campaign_id
WHERE d.campaign_id IS NOT NULL
  AND c.id IS NULL

UNION ALL

SELECT 'expenses missing category', COUNT(*)
FROM finance_ops.expenses e
LEFT JOIN finance_ops.expense_categories c ON c.id = e.category_id
WHERE c.id IS NULL

UNION ALL

SELECT 'budget_allocations missing category where category_id is not null', COUNT(*)
FROM finance_ops.budget_allocations b
LEFT JOIN finance_ops.expense_categories c ON c.id = b.category_id
WHERE b.category_id IS NOT NULL
  AND c.id IS NULL

UNION ALL

SELECT 'financial transaction donation missing source entity', COUNT(*)
FROM finance_ops.financial_transactions ft
LEFT JOIN finance_ops.donations d ON d.id = ft.entity_id
WHERE ft.entity_type = N'donation'
  AND d.id IS NULL

UNION ALL

SELECT 'financial transaction expense missing source entity', COUNT(*)
FROM finance_ops.financial_transactions ft
LEFT JOIN finance_ops.expenses e ON e.id = ft.entity_id
WHERE ft.entity_type = N'expense'
  AND e.id IS NULL

UNION ALL

SELECT 'financial transaction payment missing source entity', COUNT(*)
FROM finance_ops.financial_transactions ft
LEFT JOIN finance_ops.payments p ON p.id = ft.entity_id
WHERE ft.entity_type = N'payment'
  AND p.id IS NULL;
GO

/*=============================================================================
  12. Business Sample Summary
=============================================================================*/

PRINT 'Finance sample summary:';

SELECT
    status,
    COUNT(*) AS donation_count,
    SUM(amount) AS total_amount
FROM finance_ops.donations
GROUP BY status
ORDER BY status;

SELECT
    center_id,
    COUNT(*) AS expense_count,
    SUM(amount) AS total_expense_amount
FROM finance_ops.expenses
GROUP BY center_id
ORDER BY center_id;

SELECT
    center_id,
    COUNT(*) AS payment_count,
    SUM(amount) AS total_payment_amount
FROM finance_ops.payments
GROUP BY center_id
ORDER BY center_id;

SELECT
    center_id,
    COUNT(*) AS allocation_count,
    SUM(allocated_amount) AS total_allocated_amount
FROM finance_ops.budget_allocations
GROUP BY center_id
ORDER BY center_id;
GO
