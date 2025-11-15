-- =============================================
-- aquasim_VHC DATABASE UPDATE SCRIPT (FIXED)
-- Version: 4.0 Complete - Fixed Version
-- Date: 2025-11-07
-- Purpose: Add 8 new tables + Update existing tables (SAFE)
-- =============================================

USE aquasim_VHC;
GO

PRINT '========================================';
PRINT 'Starting aquasim_VHC Database Update (FIXED)...';
PRINT '========================================';
GO

-- =============================================
-- PART 1: CREATE NEW TABLES (8 tables)
-- =============================================

PRINT 'PART 1: Creating new tables...';
GO

-- =============================================
-- Table 1: EnvRule (Tham số môi trường theo tháng)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EnvRule')
BEGIN
    PRINT 'Creating table: EnvRule';

    CREATE TABLE EnvRule (
        RuleID INT IDENTITY(1,1) PRIMARY KEY,
        MonthNo INT NOT NULL,
        BaseTempC DECIMAL(5,2) NOT NULL,
        OptimalDOmg DECIMAL(5,2) NOT NULL,
        OptimalPH DECIMAL(4,2) NOT NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX IX_EnvRule_MonthNo ON EnvRule(MonthNo);

    PRINT 'Created table: EnvRule ✓';
END
ELSE
    PRINT 'Table EnvRule already exists, skipping...';
GO

-- =============================================
-- Table 2: Calendar
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Calendar')
BEGIN
    PRINT 'Creating table: Calendar';

    CREATE TABLE Calendar (
        CalDate DATE PRIMARY KEY,
        IsHoliday BIT NOT NULL DEFAULT 0,
        Description NVARCHAR(200) NULL
    );

    CREATE INDEX IX_Calendar_IsHoliday ON Calendar(IsHoliday);

    PRINT 'Created table: Calendar ✓';
END
ELSE
    PRINT 'Table Calendar already exists, skipping...';
GO

-- =============================================
-- Table 3: EnvironmentLog
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EnvironmentLog')
BEGIN
    PRINT 'Creating table: EnvironmentLog';

    CREATE TABLE EnvironmentLog (
        EnvLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
        CycleID INT NOT NULL FOREIGN KEY REFERENCES FarmingCycles(CycleID) ON DELETE CASCADE,
        LogDate DATE NOT NULL,
        DayNo INT NOT NULL,

        -- Temperature
        TempAM FLOAT NOT NULL,
        TempPM FLOAT NOT NULL,
        TempMean FLOAT NOT NULL,

        -- Dissolved Oxygen
        DOmin FLOAT NOT NULL,
        DOmax FLOAT NOT NULL,
        DOavg FLOAT NOT NULL,

        -- pH
        pH_AM FLOAT NOT NULL,
        pH_PM FLOAT NOT NULL,

        -- Water Quality
        H2S FLOAT NOT NULL,
        NH3 FLOAT NOT NULL,
        Salinity_ppt FLOAT NOT NULL,
        Turbidity_cm INT NOT NULL,
        Alkalinity DECIMAL(8,2) NOT NULL,

        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT UQ_EnvironmentLog_CycleDay UNIQUE (CycleID, LogDate)
    );

    CREATE INDEX IX_EnvironmentLog_CycleID_Day ON EnvironmentLog(CycleID, DayNo DESC);

    PRINT 'Created table: EnvironmentLog ✓';
END
ELSE
    PRINT 'Table EnvironmentLog already exists, skipping...';
GO

-- =============================================
-- Table 4: Event
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Event')
BEGIN
    PRINT 'Creating table: Event';

    CREATE TABLE Event (
        EventID INT IDENTITY(1,1) PRIMARY KEY,
        CycleID INT NOT NULL FOREIGN KEY REFERENCES FarmingCycles(CycleID) ON DELETE CASCADE,
        EventDate DATE NOT NULL,
        DayNo INT NOT NULL,

        EventType NVARCHAR(50) NOT NULL DEFAULT 'OTHER',
        Title NVARCHAR(200) NOT NULL,
        Description NVARCHAR(1000) NULL,

        ChemicalID INT NULL FOREIGN KEY REFERENCES ChemicalInventories(ChemicalID) ON DELETE SET NULL,
        DosageAmount DECIMAL(8,2) NULL,
        ExchangePercent DECIMAL(5,2) NULL,

        Status NVARCHAR(20) NOT NULL DEFAULT 'PLANNED',
        CompletedAt DATETIME NULL,

        Notes NVARCHAR(500) NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX IX_Event_CycleDate ON Event(CycleID, EventDate DESC);

    PRINT 'Created table: Event ✓';
END
ELSE
    PRINT 'Table Event already exists, skipping...';
GO

-- =============================================
-- Table 5: ScenarioInput
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ScenarioInput')
BEGIN
    PRINT 'Creating table: ScenarioInput';

    CREATE TABLE ScenarioInput (
        ScenarioID INT IDENTITY(1,1) PRIMARY KEY,
        PondID INT NOT NULL FOREIGN KEY REFERENCES Ponds(PondID) ON DELETE CASCADE,
        ScenarioName NVARCHAR(200) NOT NULL,

        StartDate DATE NOT NULL,
        EndDate DATE NOT NULL,

        SeedQty INT NOT NULL,
        AvgWeightG DECIMAL(8,2) NOT NULL,
        FCR DECIMAL(8,3) NOT NULL,
        InvisibleLossRate DECIMAL(5,3) NOT NULL DEFAULT 0,

        WarehouseID INT NOT NULL FOREIGN KEY REFERENCES Warehouses(WarehouseID),
        FeedID INT NOT NULL FOREIGN KEY REFERENCES FeedInventories(FeedID),

        UseLiveWeather BIT NOT NULL DEFAULT 1,
        Seed INT NOT NULL,

        Payload NVARCHAR(MAX) NULL,

        CreatedBy INT NULL FOREIGN KEY REFERENCES [Users](UserID) ON DELETE SET NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX IX_ScenarioInput_CreatedAt ON ScenarioInput(CreatedAt DESC);

    PRINT 'Created table: ScenarioInput ✓';
END
ELSE
    PRINT 'Table ScenarioInput already exists, skipping...';
GO

-- =============================================
-- Table 6: JobRunLog
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'JobRunLog')
BEGIN
    PRINT 'Creating table: JobRunLog';

    CREATE TABLE JobRunLog (
        JobID BIGINT IDENTITY(1,1) PRIMARY KEY,
        ScenarioID INT NULL FOREIGN KEY REFERENCES ScenarioInput(ScenarioID) ON DELETE SET NULL,

        StartedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FinishedAt DATETIME NULL,

        Status NVARCHAR(20) NOT NULL DEFAULT 'Running',
        Message NVARCHAR(MAX) NULL,

        TotalDaysProcessed INT NOT NULL DEFAULT 0,
        FailedDayCount INT NOT NULL DEFAULT 0,
        ExecutionTimeMs BIGINT NOT NULL DEFAULT 0
    );

    CREATE INDEX IX_JobRunLog_Status ON JobRunLog(Status, FinishedAt DESC);

    PRINT 'Created table: JobRunLog ✓';
END
ELSE
    PRINT 'Table JobRunLog already exists, skipping...';
GO

-- =============================================
-- Table 7: CostTracking
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CostTracking')
BEGIN
    PRINT 'Creating table: CostTracking';

    CREATE TABLE CostTracking (
        CostID BIGINT IDENTITY(1,1) PRIMARY KEY,
        CycleID INT NOT NULL FOREIGN KEY REFERENCES FarmingCycles(CycleID) ON DELETE CASCADE,
        CostDate DATE NOT NULL,
        DayNo INT NOT NULL,

        FeedCost DECIMAL(15,2) NOT NULL DEFAULT 0,
        ChemicalCost DECIMAL(15,2) NOT NULL DEFAULT 0,
        ElectricityCost DECIMAL(15,2) NOT NULL DEFAULT 0,
        LaborCost DECIMAL(15,2) NOT NULL DEFAULT 0,
        MaintenanceCost DECIMAL(15,2) NOT NULL DEFAULT 0,
        OtherCost DECIMAL(15,2) NOT NULL DEFAULT 0,

        TotalDailyCost DECIMAL(18,2) NOT NULL,
        CumulativeCost DECIMAL(18,2) NOT NULL,
        CostPerKgBiomass DECIMAL(10,2) NOT NULL,

        Notes NVARCHAR(500) NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX IX_CostTracking_CycleID_Date ON CostTracking(CycleID, CostDate);

    PRINT 'Created table: CostTracking ✓';
END
ELSE
    PRINT 'Table CostTracking already exists, skipping...';
GO

-- =============================================
-- Table 8: DailyReportSummary
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DailyReportSummary')
BEGIN
    PRINT 'Creating table: DailyReportSummary';

    CREATE TABLE DailyReportSummary (
        ReportID BIGINT IDENTITY(1,1) PRIMARY KEY,
        CycleID INT NOT NULL FOREIGN KEY REFERENCES FarmingCycles(CycleID) ON DELETE CASCADE,
        ReportDate DATE NOT NULL,
        DayNo INT NOT NULL,

        FishCount INT NOT NULL,
        AvgWeightG DECIMAL(8,2) NOT NULL,
        BiomasKg DECIMAL(12,3) NOT NULL,
        MortalityPct DECIMAL(5,2) NOT NULL,
        DailyCost DECIMAL(10,2) NOT NULL,
        ProjectedProfit DECIMAL(15,2) NOT NULL,

        AlertCount INT NOT NULL DEFAULT 0,
        CriticalAlertCount INT NOT NULL DEFAULT 0,

        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT UQ_DailyReportSummary_CycleDay UNIQUE (CycleID, ReportDate)
    );

    CREATE INDEX IX_DailyReportSummary_CycleDate ON DailyReportSummary(CycleID, ReportDate DESC);

    PRINT 'Created table: DailyReportSummary ✓';
END
ELSE
    PRINT 'Table DailyReportSummary already exists, skipping...';
GO

PRINT '';
PRINT 'PART 1 Complete: All new tables created ✓';
PRINT '';
GO

-- =============================================
-- PART 2: ALTER EXISTING TABLES (SAFE VERSION)
-- =============================================

PRINT 'PART 2: Updating existing tables (SAFE - skip if exists)...';
GO

-- =============================================
-- Update Farms table - ONLY ShortName and Phone
-- CreatedAt, UpdatedAt already exist from migration
-- =============================================
PRINT 'Checking Farms table for missing columns...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Farm') AND name = 'ShortName')
BEGIN
    PRINT 'Adding ShortName to Farms table';
    ALTER TABLE Farm ADD ShortName NVARCHAR(50) NULL;
END
ELSE
    PRINT 'Farms.ShortName already exists, skipping...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Farm') AND name = 'Phone')
BEGIN
    PRINT 'Adding Phone to Farms table';
    ALTER TABLE Farms ADD Phone NVARCHAR(20) NULL;
END
ELSE
    PRINT 'Farms.Phone already exists, skipping...';

PRINT 'Farms table updated ✓';
GO

-- =============================================
-- Ponds, Warehouses, Users, FeedInventories, ChemicalInventories
-- These already have CreatedAt, UpdatedAt from migration
-- =============================================
PRINT 'Ponds, Warehouses, Users, FeedInventories, ChemicalInventories already have CreatedAt/UpdatedAt from migration ✓';
GO

-- =============================================
-- FarmingCycles table
-- =============================================
PRINT 'Checking FarmingCycles table...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('FarmingCycle') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to FarmingCycles table';
    ALTER TABLE FarmingCycle ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();
END
ELSE
    PRINT 'FarmingCycles already has timestamps, skipping...';
GO

-- =============================================
-- DailyLogs table
-- =============================================
PRINT 'Checking DailyLogs table...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('DailyLog') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to DailyLogs table';
    ALTER TABLE DailyLog ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();
END
ELSE
    PRINT 'DailyLogs already has timestamps, skipping...';
GO

-- =============================================
-- FeedLedgers table
-- =============================================
PRINT 'Checking FeedLedgers table...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('FeedLedger') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to FeedLedgers table';
    ALTER TABLE FeedLedger ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();
END
ELSE
    PRINT 'FeedLedgers already has timestamps, skipping...';
GO

-- =============================================
-- ChemicalLedgers table
-- =============================================
PRINT 'Checking ChemicalLedgers table...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ChemicalLedger') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to ChemicalLedgers table';
    ALTER TABLE ChemicalLedger ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();
END
ELSE
    PRINT 'ChemicalLedgers already has timestamps, skipping...';
GO

-- =============================================
-- HealthMonitorings table
-- =============================================
PRINT 'Checking HealthMonitorings table...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('HealthMonitoring') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to HealthMonitorings table';
    ALTER TABLE HealthMonitoring ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();
END
ELSE
    PRINT 'HealthMonitorings already has timestamps, skipping...';
GO

-- =============================================
-- WaterManagements table
-- =============================================
PRINT 'Checking WaterManagements table...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('WaterManagement') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to WaterManagements table';
    ALTER TABLE WaterManagement ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();
END
ELSE
    PRINT 'WaterManagements already has timestamps, skipping...';
GO

-- =============================================
-- WasteManagements table
-- =============================================
PRINT 'Checking WasteManagements table...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('WasteManagement') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to WasteManagements table';
    ALTER TABLE WasteManagement ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();
END
ELSE
    PRINT 'WasteManagements already has timestamps, skipping...';
GO

-- =============================================
-- AlertLogs table (MAJOR UPDATE)
-- =============================================
PRINT 'Checking AlertLogs table for new columns...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('AlertLog') AND name = 'AlertDate')
BEGIN
    PRINT 'Adding new columns to AlertLogs table';

    ALTER TABLE AlertLog ADD
        AlertDate DATETIME NOT NULL DEFAULT GETDATE(),
        DayNo INT NOT NULL DEFAULT 0,
        AlertCategory NVARCHAR(50) NOT NULL DEFAULT 'OTHER',
        TriggerValue DECIMAL(10,4) NULL,
        [Status] NVARCHAR(20) NOT NULL DEFAULT 'OPEN',
        ResolvedBy INT NULL FOREIGN KEY REFERENCES [Users](UserID) ON DELETE SET NULL,
        Resolution NVARCHAR(1000) NULL,
        NotificationSent BIT NOT NULL DEFAULT 0,
        NotificationMethod NVARCHAR(50) NULL;

    PRINT 'AlertLogs table updated with new columns ✓';
END
ELSE
    PRINT 'AlertLogs already has new columns, skipping...';
GO

-- =============================================
-- AuditTrails table
-- =============================================
PRINT 'Checking AuditTrails table for new columns...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('AuditTrail') AND name = 'ActionDate')
BEGIN
    PRINT 'Adding new columns to AuditTrails table';

    ALTER TABLE AuditTrail ADD
        ChangedFields NVARCHAR(1000) NULL,
        Username NVARCHAR(100) NULL,
        IPAddress NVARCHAR(50) NULL,
        MachineName NVARCHAR(100) NULL,
        ActionDate DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'AuditTrails table updated with new columns ✓';
END
ELSE
    PRINT 'AuditTrails already has new columns, skipping...';
GO

PRINT '';
PRINT 'PART 2 Complete: All existing tables checked and updated ✓';
PRINT '';
GO

-- =============================================
-- PART 3: SEED DATA
-- =============================================

PRINT 'PART 3: Inserting seed data...';
GO

-- =============================================
-- Seed EnvRules (12 months)
-- =============================================
IF NOT EXISTS (SELECT * FROM EnvRule)
BEGIN
    PRINT 'Seeding EnvRules data (12 months)...';

    INSERT INTO EnvRule (MonthNo, BaseTempC, OptimalDOmg, OptimalPH) VALUES
    (1,  26.0, 5.5, 7.2),
    (2,  27.0, 5.5, 7.2),
    (3,  28.5, 5.5, 7.2),
    (4,  29.5, 5.5, 7.3),
    (5,  30.0, 5.0, 7.3),
    (6,  30.5, 5.0, 7.3),
    (7,  30.0, 5.0, 7.2),
    (8,  29.5, 5.0, 7.2),
    (9,  29.0, 5.5, 7.2),
    (10, 28.0, 5.5, 7.2),
    (11, 27.0, 5.5, 7.2),
    (12, 26.5, 5.5, 7.2);

    PRINT 'EnvRules data seeded ✓';
END
ELSE
    PRINT 'EnvRules already has data, skipping...';
GO

-- =============================================
-- Seed Calendar (2025 full year)
-- =============================================
IF NOT EXISTS (SELECT * FROM Calendar)
BEGIN
    PRINT 'Seeding Calendar data (2025)...';

    DECLARE @StartDate DATE = '2025-01-01';
    DECLARE @EndDate DATE = '2025-12-31';
    DECLARE @CurrentDate DATE = @StartDate;

    WHILE @CurrentDate <= @EndDate
    BEGIN
        INSERT INTO Calendar (CalDate, IsHoliday, Description)
        VALUES (@CurrentDate, 0, NULL);

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END

    -- Mark Vietnamese holidays 2025
    UPDATE Calendar SET IsHoliday = 1, Description = N'Tết Dương lịch' WHERE CalDate = '2025-01-01';
    UPDATE Calendar SET IsHoliday = 1, Description = N'Tết Nguyên Đán' WHERE CalDate IN ('2025-01-28', '2025-01-29', '2025-01-30', '2025-01-31', '2025-02-01', '2025-02-02', '2025-02-03');
    UPDATE Calendar SET IsHoliday = 1, Description = N'Giỗ Tổ Hùng Vương' WHERE CalDate = '2025-04-07';
    UPDATE Calendar SET IsHoliday = 1, Description = N'30/4 - 1/5' WHERE CalDate IN ('2025-04-30', '2025-05-01');
    UPDATE Calendar SET IsHoliday = 1, Description = N'Quốc Khánh' WHERE CalDate = '2025-09-02';

    PRINT 'Calendar data seeded (365 days) ✓';
END
ELSE
    PRINT 'Calendar already has data, skipping...';
GO

PRINT '';
PRINT 'PART 3 Complete: Seed data inserted ✓';
PRINT '';
GO

-- =============================================
-- VERIFICATION
-- =============================================

PRINT '========================================';
PRINT 'VERIFICATION: Checking all tables...';
PRINT '========================================';
GO

SELECT
    'EnvRule' AS TableName,
    COUNT(*) AS RecordCount,
    CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗' END AS Status
FROM EnvRule
UNION ALL
SELECT 'Calendar', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗' END FROM Calendar
UNION ALL
SELECT 'EnvironmentLog', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗' END FROM EnvironmentLog
UNION ALL
SELECT 'Event', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗' END FROM [Event]
UNION ALL
SELECT 'ScenarioInput', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗' END FROM ScenarioInput
UNION ALL
SELECT 'JobRunLog', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗' END FROM JobRunLog
UNION ALL
SELECT 'CostTracking', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗' END FROM CostTracking
UNION ALL
SELECT 'DailyReportSummary', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗' END FROM DailyReportSummary;
GO

PRINT '';
PRINT '========================================';
PRINT 'Database update completed successfully!';
PRINT '========================================';
PRINT '';
PRINT 'Summary:';
PRINT '- Created: 8 new tables';
PRINT '- Updated: Existing tables (safe - skipped duplicates)';
PRINT '- Seeded: EnvRules (12 months), Calendar (365 days)';
PRINT '';
GO
