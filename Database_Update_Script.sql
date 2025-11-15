-- =============================================
-- aquasim_VHC DATABASE UPDATE SCRIPT
-- Version: 4.0 Complete
-- Date: 2025-11-07
-- Purpose: Add 8 new tables + Update existing tables
-- =============================================

USE aquasim_VHC;
GO

PRINT '========================================';
PRINT 'Starting aquasim_VHC Database Update...';
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
        MonthNo INT NOT NULL,                    -- 1=Jan, 12=Dec
        BaseTempC DECIMAL(5,2) NOT NULL,         -- Nhiệt độ cơ bản (°C)
        OptimalDOmg DECIMAL(5,2) NOT NULL,       -- Oxy hòa tan tối ưu (mg/L)
        OptimalPH DECIMAL(4,2) NOT NULL,         -- pH tối ưu
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX IX_EnvRule_MonthNo ON EnvRule(MonthNo);

    PRINT 'Created table: EnvRule ✓';
END
ELSE
    PRINT 'Table EnvRule already exists, skipping...';
GO

-- =============================================
-- Table 2: Calendar (Lịch ngày lễ)
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
-- Table 3: EnvironmentLog (Chi tiết môi trường hàng ngày)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EnvironmentLog')
BEGIN
    PRINT 'Creating table: EnvironmentLog';

    CREATE TABLE EnvironmentLog (
        EnvLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
        CycleID INT NOT NULL FOREIGN KEY REFERENCES FarmingCycle(CycleID) ON DELETE CASCADE,
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
        H2S FLOAT NOT NULL,                      -- Hydrogen Sulfide (mg/L)
        NH3 FLOAT NOT NULL,                      -- Ammonia (mg/L)
        Salinity_ppt FLOAT NOT NULL,            -- Độ mặn (ppt)
        Turbidity_cm INT NOT NULL,              -- Độ đục (cm)
        Alkalinity DECIMAL(8,2) NOT NULL,       -- Độ kiềm

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
-- Table 4: Event (Sự kiện đặc biệt)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Event')
BEGIN
    PRINT 'Creating table: Event';

    CREATE TABLE Event (
        EventID INT IDENTITY(1,1) PRIMARY KEY,
        CycleID INT NOT NULL FOREIGN KEY REFERENCES FarmingCycle(CycleID) ON DELETE CASCADE,
        EventDate DATE NOT NULL,
        DayNo INT NOT NULL,

        EventType NVARCHAR(50) NOT NULL DEFAULT 'OTHER',  -- MEDICATION, WATER_EXCHANGE, HEALTH_CHECK, EMERGENCY, OTHER
        Title NVARCHAR(200) NOT NULL,
        Description NVARCHAR(1000) NULL,

        -- For MEDICATION events
        ChemicalID INT NULL FOREIGN KEY REFERENCES ChemicalInventory(ChemicalID) ON DELETE SET NULL,
        DosageAmount DECIMAL(8,2) NULL,

        -- For WATER_EXCHANGE events
        ExchangePercent DECIMAL(5,2) NULL,

        Status NVARCHAR(20) NOT NULL DEFAULT 'PLANNED',   -- PLANNED, COMPLETED, CANCELLED
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
-- Table 5: ScenarioInput (Input kịch bản cho auto-generation)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ScenarioInput')
BEGIN
    PRINT 'Creating table: ScenarioInput';

    CREATE TABLE ScenarioInput (
        ScenarioID INT IDENTITY(1,1) PRIMARY KEY,
        PondID INT NOT NULL FOREIGN KEY REFERENCES Pond(PondID) ON DELETE CASCADE,
        ScenarioName NVARCHAR(200) NOT NULL,

        -- Date Range
        StartDate DATE NOT NULL,
        EndDate DATE NOT NULL,

        -- Initial Parameters
        SeedQty INT NOT NULL,                    -- Số lượng giống thả
        AvgWeightG DECIMAL(8,2) NOT NULL,        -- Trọng lượng bình quân giống (g)
        FCR DECIMAL(8,3) NOT NULL,               -- Target Feed Conversion Ratio
        InvisibleLossRate DECIMAL(5,3) NOT NULL DEFAULT 0,  -- Tỷ lệ hao hụt vô hình

        -- Warehouse & Feed
        WarehouseID INT NOT NULL FOREIGN KEY REFERENCES Warehouse(WarehouseID),
        FeedID INT NOT NULL FOREIGN KEY REFERENCES FeedInventory(FeedID),

        -- Simulation Settings
        UseLiveWeather BIT NOT NULL DEFAULT 1,
        Seed INT NOT NULL,                       -- Random seed for determinism

        -- JSON payload
        Payload NVARCHAR(MAX) NULL,              -- Additional parameters

        CreatedBy INT NULL FOREIGN KEY REFERENCES [User](UserID) ON DELETE SET NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX IX_ScenarioInput_CreatedAt ON ScenarioInput(CreatedAt DESC);

    PRINT 'Created table: ScenarioInput ✓';
END
ELSE
    PRINT 'Table ScenarioInput already exists, skipping...';
GO

-- =============================================
-- Table 6: JobRunLog (Log chạy job)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'JobRunLog')
BEGIN
    PRINT 'Creating table: JobRunLog';

    CREATE TABLE JobRunLog (
        JobID BIGINT IDENTITY(1,1) PRIMARY KEY,
        ScenarioID INT NULL FOREIGN KEY REFERENCES ScenarioInput(ScenarioID) ON DELETE SET NULL,

        StartedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FinishedAt DATETIME NULL,

        Status NVARCHAR(20) NOT NULL DEFAULT 'Running',  -- Running, Success, Failed
        Message NVARCHAR(MAX) NULL,

        TotalDaysProcessed INT NOT NULL DEFAULT 0,
        FailedDayCount INT NOT NULL DEFAULT 0,
        ExecutionTimeMs BIGINT NOT NULL DEFAULT 0        -- Thời gian thực thi (ms)
    );

    CREATE INDEX IX_JobRunLog_Status ON JobRunLog(Status, FinishedAt DESC);

    PRINT 'Created table: JobRunLog ✓';
END
ELSE
    PRINT 'Table JobRunLog already exists, skipping...';
GO

-- =============================================
-- Table 7: CostTracking (Theo dõi chi phí)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CostTracking')
BEGIN
    PRINT 'Creating table: CostTracking';

    CREATE TABLE CostTracking (
        CostID BIGINT IDENTITY(1,1) PRIMARY KEY,
        CycleID INT NOT NULL FOREIGN KEY REFERENCES FarmingCycle(CycleID) ON DELETE CASCADE,
        CostDate DATE NOT NULL,
        DayNo INT NOT NULL,

        -- Cost Categories (VND)
        FeedCost DECIMAL(15,2) NOT NULL DEFAULT 0,
        ChemicalCost DECIMAL(15,2) NOT NULL DEFAULT 0,
        ElectricityCost DECIMAL(15,2) NOT NULL DEFAULT 0,
        LaborCost DECIMAL(15,2) NOT NULL DEFAULT 0,
        MaintenanceCost DECIMAL(15,2) NOT NULL DEFAULT 0,
        OtherCost DECIMAL(15,2) NOT NULL DEFAULT 0,

        -- Totals
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
-- Table 8: DailyReportSummary (Tóm tắt báo cáo hàng ngày)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DailyReportSummary')
BEGIN
    PRINT 'Creating table: DailyReportSummary';

    CREATE TABLE DailyReportSummary (
        ReportID BIGINT IDENTITY(1,1) PRIMARY KEY,
        CycleID INT NOT NULL FOREIGN KEY REFERENCES FarmingCycle(CycleID) ON DELETE CASCADE,
        ReportDate DATE NOT NULL,
        DayNo INT NOT NULL,

        -- Summary Data
        FishCount INT NOT NULL,
        AvgWeightG DECIMAL(8,2) NOT NULL,
        BiomasKg DECIMAL(12,3) NOT NULL,
        MortalityPct DECIMAL(5,2) NOT NULL,
        DailyCost DECIMAL(10,2) NOT NULL,
        ProjectedProfit DECIMAL(15,2) NOT NULL,

        -- Alert Counts
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
-- PART 2: ALTER EXISTING TABLES (Add new columns)
-- =============================================

PRINT 'PART 2: Updating existing tables with new columns...';
GO

-- =============================================
-- Update Farm table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Farm') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt, ShortName, Phone to Farm table';

    ALTER TABLE Farm ADD
        ShortName NVARCHAR(50) NULL,
        Phone NVARCHAR(20) NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated Farm table ✓';
END
ELSE
    PRINT 'Farm table already has new columns, skipping...';
GO

-- =============================================
-- Update Pond table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Pond') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to Pond table';

    ALTER TABLE Pond ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated Pond table ✓';
END
ELSE
    PRINT 'Pond table already has new columns, skipping...';
GO

-- =============================================
-- Update Warehouse table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Warehouse') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to Warehouse table';

    ALTER TABLE Warehouse ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated Warehouse table ✓';
END
ELSE
    PRINT 'Warehouse table already has new columns, skipping...';
GO

-- =============================================
-- Update User table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[User]') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt to User table';

    ALTER TABLE [User] ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated User table ✓';
END
ELSE
    PRINT 'User table already has new columns, skipping...';
GO

-- =============================================
-- Update FeedInventory table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('FeedInventory') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to FeedInventory table';

    ALTER TABLE FeedInventory ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated FeedInventory table ✓';
END
ELSE
    PRINT 'FeedInventory table already has new columns, skipping...';
GO

-- =============================================
-- Update ChemicalInventory table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ChemicalInventory') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to ChemicalInventory table';

    ALTER TABLE ChemicalInventory ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated ChemicalInventory table ✓';
END
ELSE
    PRINT 'ChemicalInventory table already has new columns, skipping...';
GO

-- =============================================
-- Update FarmingCycle table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('FarmingCycle') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to FarmingCycle table';

    ALTER TABLE FarmingCycle ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated FarmingCycle table ✓';
END
ELSE
    PRINT 'FarmingCycle table already has new columns, skipping...';
GO

-- =============================================
-- Update DailyLog table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('DailyLog') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to DailyLog table';

    ALTER TABLE DailyLog ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated DailyLog table ✓';
END
ELSE
    PRINT 'DailyLog table already has new columns, skipping...';
GO

-- =============================================
-- Update FeedLedger table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('FeedLedger') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to FeedLedger table';

    ALTER TABLE FeedLedger ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated FeedLedger table ✓';
END
ELSE
    PRINT 'FeedLedger table already has new columns, skipping...';
GO

-- =============================================
-- Update ChemicalLedger table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ChemicalLedger') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to ChemicalLedger table';

    ALTER TABLE ChemicalLedger ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated ChemicalLedger table ✓';
END
ELSE
    PRINT 'ChemicalLedger table already has new columns, skipping...';
GO

-- =============================================
-- Update HealthMonitoring table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('HealthMonitoring') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to HealthMonitoring table';

    ALTER TABLE HealthMonitoring ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated HealthMonitoring table ✓';
END
ELSE
    PRINT 'HealthMonitoring table already has new columns, skipping...';
GO

-- =============================================
-- Update WaterManagement table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('WaterManagement') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to WaterManagement table';

    ALTER TABLE WaterManagement ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated WaterManagement table ✓';
END
ELSE
    PRINT 'WaterManagement table already has new columns, skipping...';
GO

-- =============================================
-- Update WasteManagement table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('WasteManagement') AND name = 'CreatedAt')
BEGIN
    PRINT 'Adding CreatedAt, UpdatedAt to WasteManagement table';

    ALTER TABLE WasteManagement ADD
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated WasteManagement table ✓';
END
ELSE
    PRINT 'WasteManagement table already has new columns, skipping...';
GO

-- =============================================
-- Update AlertLog table (MAJOR UPDATE)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('AlertLog') AND name = 'AlertDate')
BEGIN
    PRINT 'Adding new columns to AlertLog table';

    ALTER TABLE AlertLog ADD
        AlertDate DATETIME NOT NULL DEFAULT GETDATE(),
        DayNo INT NOT NULL DEFAULT 0,
        AlertCategory NVARCHAR(50) NOT NULL DEFAULT 'OTHER',
        TriggerValue DECIMAL(10,4) NULL,
        [Status] NVARCHAR(20) NOT NULL DEFAULT 'OPEN',
        ResolvedBy INT NULL FOREIGN KEY REFERENCES [User](UserID) ON DELETE SET NULL,
        Resolution NVARCHAR(1000) NULL,
        NotificationSent BIT NOT NULL DEFAULT 0,
        NotificationMethod NVARCHAR(50) NULL;

    -- Rename old IsResolved to IsResolvedOld if exists
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('AlertLog') AND name = 'IsResolved')
    BEGIN
        EXEC sp_rename 'AlertLog.IsResolved', 'IsResolvedOld', 'COLUMN';
    END

    PRINT 'Updated AlertLog table ✓';
END
ELSE
    PRINT 'AlertLog table already has new columns, skipping...';
GO

-- =============================================
-- Update AuditTrail table
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('AuditTrail') AND name = 'ActionDate')
BEGIN
    PRINT 'Adding new columns to AuditTrail table';

    ALTER TABLE AuditTrail ADD
        ChangedFields NVARCHAR(1000) NULL,
        Username NVARCHAR(100) NULL,
        IPAddress NVARCHAR(50) NULL,
        MachineName NVARCHAR(100) NULL,
        ActionDate DATETIME NOT NULL DEFAULT GETDATE();

    PRINT 'Updated AuditTrail table ✓';
END
ELSE
    PRINT 'AuditTrail table already has new columns, skipping...';
GO

PRINT '';
PRINT 'PART 2 Complete: All existing tables updated ✓';
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

    INSERT INTO EnvRules (MonthNo, BaseTempC, OptimalDOmg, OptimalPH) VALUES
    (1,  26.0, 5.5, 7.2),  -- January
    (2,  27.0, 5.5, 7.2),  -- February
    (3,  28.5, 5.5, 7.2),  -- March
    (4,  29.5, 5.5, 7.3),  -- April
    (5,  30.0, 5.0, 7.3),  -- May
    (6,  30.5, 5.0, 7.3),  -- June
    (7,  30.0, 5.0, 7.2),  -- July
    (8,  29.5, 5.0, 7.2),  -- August
    (9,  29.0, 5.5, 7.2),  -- September
    (10, 28.0, 5.5, 7.2),  -- October
    (11, 27.0, 5.5, 7.2),  -- November
    (12, 26.5, 5.5, 7.2);  -- December

    PRINT 'EnvRules data seeded ✓';
END
ELSE
    PRINT 'EnvRules already has data, skipping...';
GO

-- =============================================
-- Seed Calendar (2025 full year + holidays)
-- =============================================
IF NOT EXISTS (SELECT * FROM Calendar)
BEGIN
    PRINT 'Seeding Calendar data (2025)...';

    -- Generate all days of 2025
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

    PRINT 'Calendar data seeded (365 days + holidays) ✓';
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
PRINT '- Updated: 15 existing tables';
PRINT '- Seeded: EnvRules (12 months), Calendar (365 days)';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Verify all tables in SQL Server Management Studio';
PRINT '2. Test CRUD operations';
PRINT '3. Update application code if needed';
PRINT '';
GO
