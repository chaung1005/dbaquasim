-- =============================================
-- CLEANUP DUPLICATE TABLES SCRIPT
-- Purpose: Xóa các tables duplicate trong database
-- Date: 2025-11-07
-- ⚠️ WARNING: Backup database trước khi chạy!
-- =============================================

USE aquasim_VHC;
GO

PRINT '========================================';
PRINT 'CLEANUP: Removing duplicate tables...';
PRINT '⚠️ WARNING: This will DELETE TABLES!';
PRINT '========================================';
GO

-- =============================================
-- Step 1: Backup data (nếu cần)
-- =============================================

PRINT '';
PRINT 'Step 1: Creating backup copies...';
GO

-- Backup EnvRule nếu cần giữ data
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'EnvRule')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EnvRule_Backup')
    BEGIN
        PRINT 'Backing up EnvRule to EnvRule_Backup...';
        SELECT * INTO EnvRule_Backup FROM EnvRule;
        PRINT 'Backup created ✓';
    END
    ELSE
        PRINT 'EnvRule_Backup already exists, skipping...';
END

PRINT '';
PRINT 'Step 1 Complete: Backups created ✓';
PRINT '';
GO

-- =============================================
-- Step 2: Check duplicate tables status
-- =============================================

PRINT 'Step 2: Checking duplicate tables...';
GO

-- Check EnvRule vs EnvRules
SELECT
    'EnvRule' AS TableName,
    COUNT(*) AS ColumnCount,
    (SELECT COUNT(*) FROM EnvRule) AS RecordCount
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'EnvRule'
UNION ALL
SELECT
    'EnvRules',
    COUNT(*),
    (SELECT COUNT(*) FROM EnvRules)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'EnvRules';
GO

-- Check Event vs Events
SELECT
    'Event' AS TableName,
    COUNT(*) AS ColumnCount,
    (SELECT COUNT(*) FROM Event) AS RecordCount
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Event'
UNION ALL
SELECT
    'Events',
    COUNT(*),
    (SELECT COUNT(*) FROM Events)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Events';
GO

PRINT '';
PRINT 'Step 2 Complete: Status checked ✓';
PRINT '';
GO

-- =============================================
-- Step 3: Drop duplicate table - EnvRule
-- Keep EnvRules (more columns, more complete)
-- =============================================

PRINT 'Step 3: Dropping EnvRule table (keeping EnvRules)...';
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'EnvRule')
BEGIN
    PRINT 'Dropping EnvRule...';

    -- Drop foreign keys first (if any)
    DECLARE @sql NVARCHAR(MAX) = '';

    SELECT @sql = @sql + 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id))
        + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
        + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
    FROM sys.foreign_keys
    WHERE referenced_object_id = OBJECT_ID('EnvRule');

    IF @sql <> ''
    BEGIN
        PRINT 'Dropping foreign keys referencing EnvRule...';
        EXEC sp_executesql @sql;
    END

    -- Drop table
    DROP TABLE EnvRule;
    PRINT 'Dropped EnvRule ✓';
    PRINT '✅ EnvRules table retained (more complete structure)';
END
ELSE
    PRINT 'EnvRule table not found, skipping...';

PRINT '';
GO

-- =============================================
-- Step 4: Check Event vs Events structure
-- =============================================

PRINT 'Step 4: Checking Event vs Events structure...';
GO

PRINT 'Event table columns:';
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Event'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT 'Events table columns:';
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Events'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT '⚠️ MANUAL ACTION REQUIRED:';
PRINT 'Please review the structures above and decide which table to keep.';
PRINT 'Then uncomment ONE of the DROP TABLE commands below:';
PRINT '';
PRINT '-- Option A: Keep Event, drop Events';
PRINT '-- DROP TABLE Events;';
PRINT '';
PRINT '-- Option B: Keep Events, drop Event';
PRINT '-- DROP TABLE Event;';
PRINT '';
GO

-- Uncomment the appropriate line after review:
-- DROP TABLE Events;  -- ⚠️ Uncomment if keeping Event
-- DROP TABLE Event;   -- ⚠️ Uncomment if keeping Events

-- =============================================
-- Step 5: Verification
-- =============================================

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION: Checking remaining tables...';
PRINT '========================================';
GO

SELECT
    TABLE_NAME,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS c WHERE c.TABLE_NAME = t.TABLE_NAME) AS ColumnCount
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME NOT LIKE '__EF%'
  AND TABLE_NAME NOT LIKE '%_Backup'
ORDER BY TABLE_NAME;
GO

PRINT '';
PRINT '========================================';
PRINT 'CLEANUP SCRIPT COMPLETED!';
PRINT '========================================';
PRINT '';
PRINT 'Summary:';
PRINT '- Dropped: EnvRule (kept EnvRules)';
PRINT '- Event/Events: Requires manual decision';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Review Event vs Events structure';
PRINT '2. Uncomment appropriate DROP TABLE command';
PRINT '3. Update Models in code to match database';
PRINT '4. Test application';
PRINT '';
GO
