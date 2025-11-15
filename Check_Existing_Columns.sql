-- =============================================
-- CHECK EXISTING COLUMNS SCRIPT
-- Purpose: Kiểm tra columns hiện có trong database
-- =============================================

USE aquasim_VHC;
GO

PRINT '========================================';
PRINT 'CHECKING EXISTING COLUMNS...';
PRINT '========================================';
GO

-- =============================================
-- Check Farms table
-- =============================================
PRINT '';
PRINT '=== Farms Table ===';
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Farms'
ORDER BY ORDINAL_POSITION;
GO

-- =============================================
-- Check Ponds table
-- =============================================
PRINT '';
PRINT '=== Ponds Table ===';
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Ponds'
ORDER BY ORDINAL_POSITION;
GO

-- =============================================
-- Check Warehouses table
-- =============================================
PRINT '';
PRINT '=== Warehouses Table ===';
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Warehouses'
ORDER BY ORDINAL_POSITION;
GO

-- =============================================
-- Check Users table
-- =============================================
PRINT '';
PRINT '=== Users Table ===';
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Users'
ORDER BY ORDINAL_POSITION;
GO

-- =============================================
-- Check FeedInventories table
-- =============================================
PRINT '';
PRINT '=== FeedInventories Table ===';
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FeedInventories'
ORDER BY ORDINAL_POSITION;
GO

-- =============================================
-- Check ChemicalInventories table
-- =============================================
PRINT '';
PRINT '=== ChemicalInventories Table ===';
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ChemicalInventories'
ORDER BY ORDINAL_POSITION;
GO

-- =============================================
-- Check AlertLogs table
-- =============================================
PRINT '';
PRINT '=== AlertLogs Table ===';
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AlertLogs'
ORDER BY ORDINAL_POSITION;
GO

-- =============================================
-- Summary: Check which NEW tables exist
-- =============================================
PRINT '';
PRINT '=== NEW TABLES STATUS ===';
SELECT
    'EnvRule' AS TableName,
    CASE WHEN EXISTS (SELECT * FROM sys.tables WHERE name = 'EnvRule') THEN 'EXISTS' ELSE 'NOT EXISTS' END AS Status
UNION ALL
SELECT 'Calendar', CASE WHEN EXISTS (SELECT * FROM sys.tables WHERE name = 'Calendar') THEN 'EXISTS' ELSE 'NOT EXISTS' END
UNION ALL
SELECT 'EnvironmentLog', CASE WHEN EXISTS (SELECT * FROM sys.tables WHERE name = 'EnvironmentLog') THEN 'EXISTS' ELSE 'NOT EXISTS' END
UNION ALL
SELECT 'Event', CASE WHEN EXISTS (SELECT * FROM sys.tables WHERE name = 'Event') THEN 'EXISTS' ELSE 'NOT EXISTS' END
UNION ALL
SELECT 'ScenarioInput', CASE WHEN EXISTS (SELECT * FROM sys.tables WHERE name = 'ScenarioInput') THEN 'EXISTS' ELSE 'NOT EXISTS' END
UNION ALL
SELECT 'JobRunLog', CASE WHEN EXISTS (SELECT * FROM sys.tables WHERE name = 'JobRunLog') THEN 'EXISTS' ELSE 'NOT EXISTS' END
UNION ALL
SELECT 'CostTracking', CASE WHEN EXISTS (SELECT * FROM sys.tables WHERE name = 'CostTracking') THEN 'EXISTS' ELSE 'NOT EXISTS' END
UNION ALL
SELECT 'DailyReportSummary', CASE WHEN EXISTS (SELECT * FROM sys.tables WHERE name = 'DailyReportSummary') THEN 'EXISTS' ELSE 'NOT EXISTS' END;
GO

PRINT '';
PRINT '========================================';
PRINT 'CHECK COMPLETE!';
PRINT '========================================';
GO
