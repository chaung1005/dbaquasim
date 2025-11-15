-- =====================================================
-- MIGRATION: ADD POND PREPARATION FIELDS TO FarmingCycle
-- Ngày: 2025-11-14
-- Mục đích: Bổ sung quy trình chuẩn bị ao 2 ngày đầu
-- =====================================================

USE aquasim_VHC;
GO

PRINT '========================================';
PRINT 'MIGRATION: Add Pond Preparation Fields';
PRINT '========================================';

-- 1. Kiểm tra và thêm cột PreparationDays
IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE object_id = OBJECT_ID('FarmingCycle') 
               AND name = 'PreparationDays')
BEGIN
    ALTER TABLE FarmingCycle 
    ADD PreparationDays INT NOT NULL DEFAULT 2;
    PRINT '✓ Đã thêm cột PreparationDays (mặc định 2 ngày)';
END
ELSE
    PRINT '⚠ Cột PreparationDays đã tồn tại';

-- 2. Kiểm tra và thêm cột PreparationStartDate
IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE object_id = OBJECT_ID('FarmingCycle') 
               AND name = 'PreparationStartDate')
BEGIN
    ALTER TABLE FarmingCycle 
    ADD PreparationStartDate DATETIME NULL;
    PRINT '✓ Đã thêm cột PreparationStartDate';
END
ELSE
    PRINT '⚠ Cột PreparationStartDate đã tồn tại';

-- 3. Kiểm tra và thêm cột StockingDate (ngày thả cá thực tế)
IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE object_id = OBJECT_ID('FarmingCycle') 
               AND name = 'StockingDate')
BEGIN
    ALTER TABLE FarmingCycle 
    ADD StockingDate DATETIME NULL;
    PRINT '✓ Đã thêm cột StockingDate';
    
    -- Cập nhật StockingDate cho các cycle hiện có
    UPDATE FarmingCycle
    SET StockingDate = DATEADD(DAY, PreparationDays, StartDate)
    WHERE StockingDate IS NULL AND StartDate IS NOT NULL;
    PRINT '✓ Đã cập nhật StockingDate cho các cycle hiện có';
END
ELSE
    PRINT '⚠ Cột StockingDate đã tồn tại';

-- 4. Kiểm tra và thêm cột PreparationChemicals (JSON log hóa chất chuẩn bị)
IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE object_id = OBJECT_ID('FarmingCycle') 
               AND name = 'PreparationChemicals')
BEGIN
    ALTER TABLE FarmingCycle 
    ADD PreparationChemicals NVARCHAR(MAX) NULL;
    PRINT '✓ Đã thêm cột PreparationChemicals (JSON format)';
END
ELSE
    PRINT '⚠ Cột PreparationChemicals đã tồn tại';

-- 5. Kiểm tra và thêm cột IsPreparationComplete
IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE object_id = OBJECT_ID('FarmingCycle') 
               AND name = 'IsPreparationComplete')
BEGIN
    ALTER TABLE FarmingCycle 
    ADD IsPreparationComplete BIT NOT NULL DEFAULT 0;
    PRINT '✓ Đã thêm cột IsPreparationComplete';
END
ELSE
    PRINT '⚠ Cột IsPreparationComplete đã tồn tại';

-- 6. Tạo index cho PreparationStartDate và StockingDate
IF NOT EXISTS (SELECT 1 FROM sys.indexes 
               WHERE object_id = OBJECT_ID('FarmingCycle') 
               AND name = 'IX_FarmingCycle_PreparationDates')
BEGIN
    CREATE NONCLUSTERED INDEX IX_FarmingCycle_PreparationDates
    ON FarmingCycle (PreparationStartDate, StockingDate)
    INCLUDE (CycleID, Status);
    PRINT '✓ Đã tạo index IX_FarmingCycle_PreparationDates';
END
ELSE
    PRINT '⚠ Index IX_FarmingCycle_PreparationDates đã tồn tại';

-- 7. Thêm COMPUTED COLUMN để tính ActualCycleDays
IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE object_id = OBJECT_ID('FarmingCycle') 
               AND name = 'TotalDaysWithPreparation')
BEGIN
    ALTER TABLE FarmingCycle
    ADD TotalDaysWithPreparation AS (ISNULL(PlannedDays, 90) + PreparationDays) PERSISTED;
    PRINT '✓ Đã thêm computed column TotalDaysWithPreparation';
END
ELSE
    PRINT '⚠ Computed column TotalDaysWithPreparation đã tồn tại';

GO

-- 8. Tạo view hiển thị thông tin preparation
IF OBJECT_ID('vw_CyclePreparationInfo', 'V') IS NOT NULL
    DROP VIEW vw_CyclePreparationInfo;
GO

CREATE VIEW vw_CyclePreparationInfo AS
SELECT 
    fc.CycleID,
    fc.CycleCode,
    fc.CycleName,
    p.PondCode,
    p.PondName,
    fc.StartDate,
    fc.PreparationDays,
    fc.PreparationStartDate,
    fc.StockingDate,
    fc.IsPreparationComplete,
    fc.PreparationChemicals,
    fc.Status,
    fc.PlannedDays,
    fc.TotalDaysWithPreparation,
    CASE 
        WHEN fc.LastProcessedDay <= fc.PreparationDays THEN 'PREPARATION'
        WHEN fc.LastProcessedDay > fc.PreparationDays THEN 'FARMING'
        ELSE 'NOT_STARTED'
    END AS CurrentPhase,
    CASE 
        WHEN fc.LastProcessedDay <= fc.PreparationDays 
        THEN CONCAT('Ngày ', fc.LastProcessedDay, '/', fc.PreparationDays, ' - Chuẩn bị ao')
        ELSE CONCAT('Ngày ', fc.LastProcessedDay - fc.PreparationDays, '/', fc.PlannedDays, ' - Nuôi cá')
    END AS PhaseDescription
FROM FarmingCycle fc
INNER JOIN Pond p ON fc.PondID = p.PondID;
GO

PRINT '✓ Đã tạo view vw_CyclePreparationInfo';

-- 9. Tạo stored procedure để khởi tạo preparation phase
IF OBJECT_ID('sp_InitializePondPreparation', 'P') IS NOT NULL
    DROP PROCEDURE sp_InitializePondPreparation;
GO

CREATE PROCEDURE sp_InitializePondPreparation
    @CycleID INT,
    @PreparationDays INT = 2
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartDate DATETIME;
    DECLARE @PreparationStartDate DATETIME;
    DECLARE @StockingDate DATETIME;
    
    -- Lấy StartDate hiện tại
    SELECT @StartDate = StartDate 
    FROM FarmingCycle 
    WHERE CycleID = @CycleID;
    
    IF @StartDate IS NULL
    BEGIN
        RAISERROR('CycleID không tồn tại hoặc chưa có StartDate', 16, 1);
        RETURN;
    END
    
    -- Tính toán ngày chuẩn bị và ngày thả cá
    SET @PreparationStartDate = @StartDate;
    SET @StockingDate = DATEADD(DAY, @PreparationDays, @StartDate);
    
    -- Cập nhật FarmingCycle
    UPDATE FarmingCycle
    SET 
        PreparationDays = @PreparationDays,
        PreparationStartDate = @PreparationStartDate,
        StockingDate = @StockingDate,
        IsPreparationComplete = 0,
        UpdatedAt = GETDATE()
    WHERE CycleID = @CycleID;
    
    PRINT CONCAT('✓ Đã khởi tạo preparation phase cho CycleID ', @CycleID);
    PRINT CONCAT('  - Preparation Start: ', FORMAT(@PreparationStartDate, 'dd/MM/yyyy'));
    PRINT CONCAT('  - Stocking Date: ', FORMAT(@StockingDate, 'dd/MM/yyyy'));
    PRINT CONCAT('  - Preparation Days: ', @PreparationDays);
END
GO

PRINT '✓ Đã tạo stored procedure sp_InitializePondPreparation';

-- 10. Tạo trigger để tự động tính StockingDate khi thay đổi StartDate
IF OBJECT_ID('trg_FarmingCycle_AutoCalculateStockingDate', 'TR') IS NOT NULL
    DROP TRIGGER trg_FarmingCycle_AutoCalculateStockingDate;
GO

CREATE TRIGGER trg_FarmingCycle_AutoCalculateStockingDate
ON FarmingCycle
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tự động tính StockingDate khi insert hoặc update StartDate
    UPDATE fc
    SET 
        StockingDate = DATEADD(DAY, fc.PreparationDays, fc.StartDate),
        PreparationStartDate = fc.StartDate
    FROM FarmingCycle fc
    INNER JOIN inserted i ON fc.CycleID = i.CycleID
    WHERE fc.StartDate IS NOT NULL 
      AND (fc.StockingDate IS NULL 
           OR i.StartDate <> fc.StartDate 
           OR i.PreparationDays <> fc.PreparationDays);
END
GO

PRINT '✓ Đã tạo trigger trg_FarmingCycle_AutoCalculateStockingDate';

GO

PRINT '';
PRINT '========================================';
PRINT 'MIGRATION HOÀN TẤT';
PRINT '========================================';
PRINT '';
PRINT 'Các cột đã thêm vào bảng FarmingCycle:';
PRINT '  1. PreparationDays (INT, default 2)';
PRINT '  2. PreparationStartDate (DATETIME)';
PRINT '  3. StockingDate (DATETIME)';
PRINT '  4. PreparationChemicals (NVARCHAR(MAX))';
PRINT '  5. IsPreparationComplete (BIT, default 0)';
PRINT '  6. TotalDaysWithPreparation (Computed)';
PRINT '';
PRINT 'Đã tạo:';
PRINT '  - View: vw_CyclePreparationInfo';
PRINT '  - Stored Procedure: sp_InitializePondPreparation';
PRINT '  - Trigger: trg_FarmingCycle_AutoCalculateStockingDate';
PRINT '  - Index: IX_FarmingCycle_PreparationDates';
PRINT '';

-- Test query
PRINT 'Test query - Hiển thị 5 cycles gần nhất với thông tin preparation:';
SELECT TOP 5
    CycleID,
    CycleCode,
    PondCode,
    Status,
    CurrentPhase,
    PhaseDescription,
    FORMAT(PreparationStartDate, 'dd/MM/yyyy') AS NgayChuanBi,
    FORMAT(StockingDate, 'dd/MM/yyyy') AS NgayThaCa
FROM vw_CyclePreparationInfo
ORDER BY CycleID DESC;
GO
