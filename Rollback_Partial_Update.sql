-- =============================================
-- ROLLBACK PARTIAL UPDATE SCRIPT
-- Purpose: Xóa các tables/columns đã tạo để chạy lại script mới
-- ⚠️ WARNING: Script này sẽ XÓA DỮ LIỆU! Chỉ dùng khi cần rollback.
-- =============================================

USE aquasim_VHC;
GO

PRINT '========================================';
PRINT 'ROLLBACK: Removing partially created tables...';
PRINT '⚠️ WARNING: This will DELETE DATA!';
PRINT '========================================';
GO

-- =============================================
-- Step 1: Drop new tables in reverse order (FK dependencies)
-- =============================================

PRINT '';
PRINT 'Step 1: Dropping new tables (if they exist)...';
GO

-- Drop tables with FK first
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'DailyReportSummary')
BEGIN
    PRINT 'Dropping DailyReportSummary...';
    DROP TABLE DailyReportSummary;
    PRINT 'Dropped DailyReportSummary ✓';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CostTracking')
BEGIN
    PRINT 'Dropping CostTracking...';
    DROP TABLE CostTracking;
    PRINT 'Dropped CostTracking ✓';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'JobRunLog')
BEGIN
    PRINT 'Dropping JobRunLog...';
    DROP TABLE JobRunLog;
    PRINT 'Dropped JobRunLog ✓';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ScenarioInput')
BEGIN
    PRINT 'Dropping ScenarioInput...';
    DROP TABLE ScenarioInput;
    PRINT 'Dropped ScenarioInput ✓';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Event')
BEGIN
    PRINT 'Dropping Event...';
    DROP TABLE [Event];
    PRINT 'Dropped Event ✓';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'EnvironmentLog')
BEGIN
    PRINT 'Dropping EnvironmentLog...';
    DROP TABLE EnvironmentLog;
    PRINT 'Dropped EnvironmentLog ✓';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Calendar')
BEGIN
    PRINT 'Dropping Calendar...';
    DROP TABLE Calendar;
    PRINT 'Dropped Calendar ✓';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'EnvRule')
BEGIN
    PRINT 'Dropping EnvRule...';
    DROP TABLE EnvRule;
    PRINT 'Dropped EnvRule ✓';
END

PRINT '';
PRINT 'Step 1 Complete: All new tables dropped ✓';
PRINT '';
GO

-- =============================================
-- Step 2: Remove any duplicate columns that were added
-- (Optional - only if you need to clean up)
-- =============================================

PRINT 'Step 2: Checking for duplicate columns...';
GO

-- Note: SQL Server doesn't allow duplicate column names,
-- so if the ALTER TABLE failed, the columns weren't added.
-- This section is for documentation purposes.

PRINT 'If ALTER TABLE commands failed, no cleanup needed for columns.';
PRINT 'The database state before ALTER is preserved.';
GO

PRINT '';
PRINT '========================================';
PRINT 'ROLLBACK COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'You can now run the FIXED script:';
PRINT '- Database_Update_Script_FIXED.sql';
PRINT '';
GO

-- =============================================
-- Verification: Check remaining tables
-- =============================================

PRINT 'Verification: Checking database state...';
GO

SELECT
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

PRINT '';
PRINT 'Rollback script completed successfully!';
GO
