-- =============================================
-- aquasim_VHC Database - Complete SQL Script
-- Version: 3.0 Final
-- Date: 06/11/2025
-- Description: Complete database schema for aquasim_VHC system
-- =============================================

USE master;
GO

-- Drop database if exists (BE CAREFUL!)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'aquasim_VHC')
BEGIN
    ALTER DATABASE aquasim_VHC SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE aquasim_VHC;
END
GO

-- Create database
CREATE DATABASE aquasim_VHC
GO

USE aquasim_VHC;
GO

-- =============================================
-- SECTION 1: MASTER DATA TABLES
-- =============================================

PRINT 'Creating Master Data Tables...';
GO

-- ====================
-- FARMS MASTER
-- ====================
CREATE TABLE Farms (
    FarmID INT PRIMARY KEY IDENTITY(1,1),
    FarmCode NVARCHAR(50) UNIQUE NOT NULL,
    FarmName NVARCHAR(100) NOT NULL,
    Province NVARCHAR(100),
    District NVARCHAR(100),
    Ward NVARCHAR(100),
    Address NVARCHAR(500),
    Latitude DECIMAL(10,8),
    Longitude DECIMAL(11,8),
    TotalArea DECIMAL(12,2), -- m²
    Manager NVARCHAR(100),
    ManagerPhone NVARCHAR(20),
    ManagerEmail NVARCHAR(100),
    -- Certifications
    [ASC] BIT DEFAULT 0,
    [BAP] BIT DEFAULT 0,
    [GG] BIT DEFAULT 0,
    -- Status
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy INT,
    UpdatedBy INT
);
GO

CREATE INDEX IX_Farms_FarmCode ON Farms(FarmCode);
CREATE INDEX IX_Farms_IsActive ON Farms(IsActive);
GO

-- ====================
-- WAREHOUSES MASTER
-- ====================
CREATE TABLE Warehouses (
    WarehouseID INT IDENTITY(1,1) PRIMARY KEY,
    WarehouseCode NVARCHAR(50) UNIQUE NOT NULL,
    WarehouseName NVARCHAR(100) NOT NULL,
    FarmID INT FOREIGN KEY REFERENCES Farms(FarmID),
    Location NVARCHAR(200),
    WarehouseType NVARCHAR(50), -- FEED, CHEMICAL, GENERAL
    CapacityKg DECIMAL(12,2) NULL, -- Sức chứa tối đa
    CurrentStock DECIMAL(12,2) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_Warehouses_FarmID ON Warehouses(FarmID);
CREATE INDEX IX_Warehouses_Type ON Warehouses(WarehouseType);
GO

-- ====================
-- PONDS MASTER
-- ====================
CREATE TABLE Ponds (
    PondID INT PRIMARY KEY IDENTITY(1,1),
    PondCode NVARCHAR(50) UNIQUE NOT NULL,
    PondName NVARCHAR(100) NOT NULL,
    FarmID INT FOREIGN KEY REFERENCES Farms(FarmID),
    WarehouseID INT FOREIGN KEY REFERENCES Warehouses(WarehouseID),
    -- Physical Attributes
    SurfaceAreaM2 DECIMAL(10,2),
    DepthM DECIMAL(5,2),
    VolumeM3 DECIMAL(12,2),
    CapacityKg DECIMAL(12,2),
    PondType NVARCHAR(50), -- EARTHEN, CONCRETE, LINER
    -- Preparation
    PreparedDate DATE,
    PreparationMethod NVARCHAR(200),
    -- Water Level Settings (5 levels)
    Level1_CM DECIMAL(5,2) DEFAULT 50,
    Level2_CM DECIMAL(5,2) DEFAULT 100,
    Level3_CM DECIMAL(5,2) DEFAULT 150,
    Level4_CM DECIMAL(5,2) DEFAULT 200,
    Level5_CM DECIMAL(5,2) DEFAULT 250,
    -- Status
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_Ponds_FarmID ON Ponds(FarmID);
CREATE INDEX IX_Ponds_PondCode ON Ponds(PondCode);
GO

-- ====================
-- FEED INVENTORY MASTER
-- ====================
CREATE TABLE FeedInventory (
    FeedID INT PRIMARY KEY IDENTITY(1,1),
    FeedCode NVARCHAR(50) UNIQUE NOT NULL,
    FeedName NVARCHAR(100) NOT NULL,
    -- Nutritional Info
    ProteinPercent DECIMAL(5,2),
    FatPercent DECIMAL(5,2),
    FiberPercent DECIMAL(5,2),
    MoisturePercent DECIMAL(5,2),
    -- Physical Properties
    ParticleSizeMm DECIMAL(5,2),
    SizeBand NVARCHAR(50), -- SMALL, MEDIUM, LARGE
    PelletType NVARCHAR(50), -- FLOATING, SINKING, SLOW_SINKING
    -- Supplier Info
    Supplier NVARCHAR(100),
    Brand NVARCHAR(100),
    -- Pricing
    UnitPrice DECIMAL(12,2),
    Currency NVARCHAR(10) DEFAULT 'VND',
    -- Status
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_FeedInventory_FeedCode ON FeedInventory(FeedCode);
CREATE INDEX IX_FeedInventory_SizeBand ON FeedInventory(SizeBand);
GO

-- ====================
-- CHEMICAL INVENTORY MASTER
-- ====================
CREATE TABLE ChemicalInventory (
    ChemicalID INT PRIMARY KEY IDENTITY(1,1),
    ChemicalCode NVARCHAR(50) UNIQUE NOT NULL,
    ChemicalName NVARCHAR(100) NOT NULL,
    ChemicalType NVARCHAR(50), -- PROBIOTIC, VITAMIN, ANTIBIOTIC, pH_ADJUSTER, SALT, LIME, ZEOLITE
    Purpose NVARCHAR(200),
    DosageUnit NVARCHAR(50),
    StandardDosage DECIMAL(10,4),
    MaxDosage DECIMAL(10,4),
    Supplier NVARCHAR(100),
    UnitPrice DECIMAL(12,2),
    Currency NVARCHAR(10) DEFAULT 'VND',
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_ChemicalInventory_Type ON ChemicalInventory(ChemicalType);
GO

-- ====================
-- ENVIRONMENT RULES
-- ====================
CREATE TABLE EnvRules (
    RuleID INT PRIMARY KEY IDENTITY(1,1),
    Species NVARCHAR(50) DEFAULT 'CATFISH',
    MonthNo INT CHECK (MonthNo BETWEEN 1 AND 12),
    BaseTempC DECIMAL(5,2),
    TempMinC DECIMAL(5,2),
    TempMaxC DECIMAL(5,2),
    JitterSigma DECIMAL(5,2) DEFAULT 2.0,
    OptimalDOmg DECIMAL(5,2) DEFAULT 5.5,
    OptimalPH DECIMAL(4,2) DEFAULT 7.2,
    OptimalAlkalinity DECIMAL(8,2) DEFAULT 100,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE UNIQUE INDEX UX_EnvRules_Species_Month ON EnvRules(Species, MonthNo);
GO

-- ====================
-- USERS & AUTHENTICATION
-- ====================
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    FullName NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    Role NVARCHAR(50) CHECK (Role IN ('Admin', 'Manager', 'Staff', 'Viewer')),
    FarmID INT FOREIGN KEY REFERENCES Farms(FarmID),
    IsActive BIT DEFAULT 1,
    IsLocked BIT DEFAULT 0,
    FailedLoginAttempts INT DEFAULT 0,
    LastLogin DATETIME NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_Users_Role ON Users(Role);
CREATE INDEX IX_Users_FarmID ON Users(FarmID);
GO

-- ====================
-- CALENDAR
-- ====================
CREATE TABLE Calendar (
    CalDate DATE PRIMARY KEY,
    IsHoliday BIT NOT NULL DEFAULT 0,
    IsWeekend BIT NOT NULL DEFAULT 0,
    Description NVARCHAR(200) NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- =============================================
-- SECTION 2: FARMING CYCLE & OPERATIONS
-- =============================================

PRINT 'Creating Farming Cycle & Operations Tables...';
GO

-- ====================
-- FARMING CYCLE
-- ====================
CREATE TABLE FarmingCycle (
    CycleID INT IDENTITY(1,1) PRIMARY KEY,
    CycleCode NVARCHAR(50) UNIQUE NOT NULL,
    PondID INT NOT NULL REFERENCES Ponds(PondID),
    CycleName NVARCHAR(200),
    Species NVARCHAR(50) DEFAULT 'CATFISH',
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    PlannedDays INT DEFAULT 90,
    ActualDays INT NULL,
    LastProcessedDay INT DEFAULT 0,
    -- Stocking Details
    SeedQty INT NOT NULL,
    SeedSource NVARCHAR(200),
    AvgWeightG DECIMAL(8,2) NOT NULL,
    InitialBiomassKg DECIMAL(12,3),
    -- Target Parameters
    FCR DECIMAL(8,3) NOT NULL,
    TargetWeightG DECIMAL(8,2),
    TargetBiomassKg DECIMAL(12,3),
    InvisibleLossRate DECIMAL(5,3) DEFAULT 0,
    -- State Machine
    Status NVARCHAR(20) DEFAULT 'PLANNING' 
        CHECK (Status IN ('PLANNING', 'ACTIVE', 'MEDICATING', 'HARVESTING', 'CLOSED', 'CANCELLED')),
    -- Determinism
    Seed INT NULL,
    Manifest NVARCHAR(MAX) NULL,
    -- Financial
    ExpectedRevenue DECIMAL(18,2),
    ActualRevenue DECIMAL(18,2),
    TotalCost DECIMAL(18,2),
    Profit DECIMAL(18,2),
    -- Metadata
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy INT,
    UpdatedBy INT
);
GO

CREATE INDEX IX_FarmingCycle_Status ON FarmingCycle(Status);
CREATE INDEX IX_FarmingCycle_StartDate ON FarmingCycle(StartDate);
CREATE INDEX IX_FarmingCycle_PondID ON FarmingCycle(PondID);
GO

-- ====================
-- DAILY LOG (P301-F01)
-- ====================
CREATE TABLE DailyLog (
    LogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CycleID INT NOT NULL REFERENCES FarmingCycle(CycleID),
    LogDate DATE NOT NULL,
    DayNo INT NOT NULL,
    -- Fish Status
    FishQty INT NOT NULL,
    DeathQty INT NOT NULL DEFAULT 0,
    DeathRate DECIMAL(5,3),
    SurvivalRate DECIMAL(5,2),
    -- Growth
    AvgWeightG DECIMAL(8,2),
    DailyGrowthG DECIMAL(8,2),
    BiomassKg DECIMAL(12,3),
    BiomassDeltaKg DECIMAL(12,3),
    -- Feeding
    FeedGivenKg DECIMAL(12,3) NOT NULL DEFAULT 0,
    FeedPercent DECIMAL(5,2),
    FeedType NVARCHAR(100),
    CumulativeFeedKg DECIMAL(12,3),
    -- FCR
    FCR DECIMAL(8,3),
    -- Water Quality
    DOmg DECIMAL(5,2) NULL,
    pH DECIMAL(4,2) NULL,
    TempC DECIMAL(5,2) NULL,
    H2S DECIMAL(6,3) NULL,
    NH3 DECIMAL(6,3) NULL,
    Salinity DECIMAL(5,2) NULL,
    Alkalinity DECIMAL(8,2) NULL,
    -- Health
    HealthStatus NVARCHAR(50),
    DiseaseDetected NVARCHAR(200),
    TreatmentApplied NVARCHAR(200),
    -- Notes
    Notes NVARCHAR(500) NULL,
    Alerts NVARCHAR(MAX) NULL,
    -- Metadata
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy INT,
    -- Constraints
    CONSTRAINT UQ_DailyLog_CycleDay UNIQUE (CycleID, LogDate),
    CONSTRAINT CK_DailyLog_FishQty CHECK (FishQty >= 0),
    CONSTRAINT CK_DailyLog_DeathQty CHECK (DeathQty >= 0),
    CONSTRAINT CK_DailyLog_DOmg CHECK (DOmg IS NULL OR (DOmg >= 0 AND DOmg <= 20)),
    CONSTRAINT CK_DailyLog_pH CHECK (pH IS NULL OR (pH >= 4 AND pH <= 11)),
    CONSTRAINT CK_DailyLog_TempC CHECK (TempC IS NULL OR (TempC >= 15 AND TempC <= 40))
);
GO

CREATE INDEX IX_DailyLog_CycleDay ON DailyLog(CycleID, LogDate DESC);
CREATE INDEX IX_DailyLog_CycleDay_Full ON DailyLog(CycleID, LogDate DESC) 
    INCLUDE (FishQty, AvgWeightG, BiomassKg, FCR, DOmg);
GO

-- ====================
-- ENVIRONMENT LOG (P304-F04)
-- ====================
CREATE TABLE EnvironmentLog (
    EnvLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CycleID INT NOT NULL REFERENCES FarmingCycle(CycleID),
    LogDate DATE NOT NULL,
    DayNo INT NOT NULL,
    -- Temperature
    TempAM DECIMAL(5,2),
    TempPM DECIMAL(5,2),
    TempMean DECIMAL(5,2),
    -- Dissolved Oxygen
    DOmin DECIMAL(5,2),
    DOmax DECIMAL(5,2),
    DOavg DECIMAL(5,2),
    -- pH
    pH_AM DECIMAL(4,2),
    pH_PM DECIMAL(4,2),
    -- Toxic Gases
    H2S DECIMAL(6,3),
    NH3 DECIMAL(6,3),
    -- Other Parameters
    Alkalinity DECIMAL(8,2),
    Hardness DECIMAL(8,2),
    Salinity DECIMAL(5,2),
    Turbidity DECIMAL(6,2),
    -- Weather
    WeatherCondition NVARCHAR(50),
    RainfallMm DECIMAL(6,2),
    -- Metadata
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_EnvironmentLog_CycleDay UNIQUE (CycleID, LogDate)
);
GO

CREATE INDEX IX_EnvironmentLog_CycleDate ON EnvironmentLog(CycleID, LogDate DESC) 
    INCLUDE (DOavg, pH_AM, H2S, NH3, TempMean);
GO

-- ====================
-- HEALTH MONITORING (P303-F07)
-- ====================
CREATE TABLE HealthMonitoring (
    HealthID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CycleID INT NOT NULL REFERENCES FarmingCycle(CycleID),
    InspectionDate DATE NOT NULL,
    DayNo INT,
    -- Sampling
    SampleSize INT,
    SampleAvgWeightG DECIMAL(8,2),
    -- Parasites
    ParasiteDetected NVARCHAR(200),
    ParasiteLevel NVARCHAR(20), -- NONE, LOW, MEDIUM, HIGH
    -- Clinical Signs
    ClinicalSigns NVARCHAR(500),
    Behavior NVARCHAR(200),
    MortalityObserved INT,
    -- Diagnosis
    Diagnosis NVARCHAR(500),
    Severity NVARCHAR(20), -- MILD, MODERATE, SEVERE
    -- Treatment
    TreatmentPlan NVARCHAR(1000),
    TreatmentApplied NVARCHAR(1000),
    TreatmentStatus NVARCHAR(50), -- PLANNED, IN_PROGRESS, COMPLETED
    -- Outcome
    Outcome NVARCHAR(500),
    FollowUpDate DATE,
    -- Metadata
    InspectedBy INT REFERENCES Users(UserID),
    Notes NVARCHAR(1000),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_HealthMonitoring_CycleID ON HealthMonitoring(CycleID);
CREATE INDEX IX_HealthMonitoring_Date ON HealthMonitoring(InspectionDate);
GO

-- ====================
-- WATER MANAGEMENT (P304-F04 & P304-F07)
-- ====================
CREATE TABLE WaterManagement (
    WaterID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CycleID INT NOT NULL REFERENCES FarmingCycle(CycleID),
    LogDate DATE NOT NULL,
    DayNo INT,
    -- Water Exchange
    WaterInM3 DECIMAL(10,2) DEFAULT 0,
    WaterOutM3 DECIMAL(10,2) DEFAULT 0,
    WaterExchangePercent DECIMAL(5,2),
    -- Water Level
    WaterLevelCm DECIMAL(6,2),
    WaterLevelSetting INT,
    -- Operations
    PumpRuntime DECIMAL(5,2),
    AeratorRuntime DECIMAL(5,2),
    -- Reason
    Reason NVARCHAR(200),
    -- Quality Check
    WastewaterQuality NVARCHAR(50),
    WastewaterNotes NVARCHAR(500),
    -- Metadata
    PerformedBy INT REFERENCES Users(UserID),
    Notes NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_WaterManagement_CycleID ON WaterManagement(CycleID);
CREATE INDEX IX_WaterManagement_Date ON WaterManagement(LogDate);
GO

-- ====================
-- WASTE MANAGEMENT (P305-F37)
-- ====================
CREATE TABLE WasteManagement (
    WasteID BIGINT IDENTITY(1,1) PRIMARY KEY,
    FarmID INT FOREIGN KEY REFERENCES Farms(FarmID),
    CycleID INT NULL REFERENCES FarmingCycle(CycleID),
    WasteDate DATE NOT NULL,
    -- Waste Details
    WasteType NVARCHAR(100), -- DEAD_FISH, SLUDGE, CHEMICAL_CONTAINER, OTHER
    QuantityKg DECIMAL(12,2) NOT NULL,
    Description NVARCHAR(500),
    -- Disposal
    DisposalMethod NVARCHAR(200),
    DisposalLocation NVARCHAR(200),
    DisposalCompany NVARCHAR(200),
    -- Handover
    HandedOverBy INT REFERENCES Users(UserID),
    ReceivedBy INT REFERENCES Users(UserID),
    HandoverStatus NVARCHAR(50) DEFAULT 'PENDING', -- PENDING, SIGNED, COMPLETED
    HandoverSignature VARBINARY(MAX),
    HandoverNotes NVARCHAR(500),
    -- Metadata
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_WasteManagement_FarmID ON WasteManagement(FarmID);
CREATE INDEX IX_WasteManagement_Date ON WasteManagement(WasteDate);
CREATE INDEX IX_WasteManagement_Status ON WasteManagement(HandoverStatus);
GO

-- =============================================
-- SECTION 3: INVENTORY & LEDGER
-- =============================================

PRINT 'Creating Inventory & Ledger Tables...';
GO

-- ====================
-- FEED LEDGER
-- ====================
CREATE TABLE FeedLedger (
    LedgerID BIGINT IDENTITY(1,1) PRIMARY KEY,
    WarehouseID INT NOT NULL REFERENCES Warehouses(WarehouseID),
    FeedID INT NOT NULL REFERENCES FeedInventory(FeedID),
    TxnDate DATE NOT NULL,
    -- Transaction Type
    Direction CHAR(1) NOT NULL CHECK (Direction IN('I','O')),
    QtyKg DECIMAL(12,3) NOT NULL,
    UnitPrice DECIMAL(12,2),
    TotalAmount DECIMAL(18,2),
    -- Batch Tracking (for FEFO)
    BatchCode NVARCHAR(50) NULL,
    ManufactureDate DATE NULL,
    ExpiryDate DATE NULL,
    -- Cycle Link
    CycleID INT NULL REFERENCES FarmingCycle(CycleID),
    -- Document Reference
    DocumentType NVARCHAR(50),
    DocumentNo NVARCHAR(100),
    SupplierID INT NULL,
    -- Metadata
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy INT REFERENCES Users(UserID),
    Notes NVARCHAR(500)
);
GO

CREATE INDEX IX_FeedLedger_WarehouseFeed ON FeedLedger(WarehouseID, FeedID);
CREATE INDEX IX_FeedLedger_ExpiryDate ON FeedLedger(ExpiryDate);
CREATE INDEX IX_FeedLedger_CycleID ON FeedLedger(CycleID);
CREATE INDEX IX_FeedLedger_TxnDate ON FeedLedger(TxnDate DESC);
GO

-- ====================
-- CHEMICAL LEDGER
-- ====================
CREATE TABLE ChemicalLedger (
    LedgerID BIGINT IDENTITY(1,1) PRIMARY KEY,
    WarehouseID INT NOT NULL REFERENCES Warehouses(WarehouseID),
    ChemicalID INT NOT NULL REFERENCES ChemicalInventory(ChemicalID),
    TxnDate DATE NOT NULL,
    -- Transaction Type
    Direction CHAR(1) NOT NULL CHECK (Direction IN('I','O')),
    Qty DECIMAL(12,3) NOT NULL,
    Unit NVARCHAR(50),
    UnitPrice DECIMAL(12,2),
    TotalAmount DECIMAL(18,2),
    -- Batch Tracking
    BatchCode NVARCHAR(50) NULL,
    ManufactureDate DATE NULL,
    ExpiryDate DATE NULL,
    -- Cycle Link
    CycleID INT NULL REFERENCES FarmingCycle(CycleID),
    -- Purpose
    Purpose NVARCHAR(200),
    -- Document Reference
    DocumentType NVARCHAR(50),
    DocumentNo NVARCHAR(100),
    SupplierID INT NULL,
    -- Metadata
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy INT REFERENCES Users(UserID),
    Notes NVARCHAR(500)
);
GO

CREATE INDEX IX_ChemicalLedger_WarehouseChemical ON ChemicalLedger(WarehouseID, ChemicalID);
CREATE INDEX IX_ChemicalLedger_ExpiryDate ON ChemicalLedger(ExpiryDate);
CREATE INDEX IX_ChemicalLedger_CycleID ON ChemicalLedger(CycleID);
CREATE INDEX IX_ChemicalLedger_TxnDate ON ChemicalLedger(TxnDate DESC);
GO

-- ====================
-- PRODUCT SPECIFICATION (P303-F06)
-- ====================
CREATE TABLE ProductSpecification (
    SpecID INT IDENTITY(1,1) PRIMARY KEY,
    SpecCode NVARCHAR(50) UNIQUE NOT NULL,
    SpecDate DATE NOT NULL,
    -- Requester
    RequestedBy INT REFERENCES Users(UserID),
    Position NVARCHAR(100),
    Department NVARCHAR(100),
    -- Target
    CycleID INT REFERENCES FarmingCycle(CycleID),
    PondID INT REFERENCES Ponds(PondID),
    -- Product Details
    ProductType NVARCHAR(50), -- FEED, CHEMICAL
    ProductID INT,
    Quantity DECIMAL(12,3),
    Unit NVARCHAR(50),
    -- Reason
    Reason NVARCHAR(1000) NOT NULL,
    Urgency NVARCHAR(20), -- LOW, MEDIUM, HIGH, CRITICAL
    -- Workflow
    Status NVARCHAR(50) DEFAULT 'PENDING' 
        CHECK (Status IN ('DRAFT', 'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED')),
    ApprovedBy INT NULL REFERENCES Users(UserID),
    ApprovedDate DATETIME NULL,
    RejectionReason NVARCHAR(500),
    -- Metadata
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_ProductSpec_Status ON ProductSpecification(Status);
CREATE INDEX IX_ProductSpec_RequestedBy ON ProductSpecification(RequestedBy);
GO

-- =============================================
-- SECTION 4: SUPPORT TABLES
-- =============================================

PRINT 'Creating Support Tables...';
GO

-- ====================
-- SCENARIO INPUT
-- ====================
CREATE TABLE ScenarioInput (
    ScenarioID INT IDENTITY(1,1) PRIMARY KEY,
    ScenarioName NVARCHAR(200),
    Description NVARCHAR(1000),
    Payload NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy INT REFERENCES Users(UserID)
);
GO

CREATE INDEX IX_ScenarioInput_CreatedAt ON ScenarioInput(CreatedAt DESC);
GO

-- ====================
-- JOB RUN LOG
-- ====================
CREATE TABLE JobRunLog (
    JobID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ScenarioID INT NULL REFERENCES ScenarioInput(ScenarioID),
    CycleID INT NULL REFERENCES FarmingCycle(CycleID),
    JobType NVARCHAR(50),
    StartedAt DATETIME DEFAULT GETDATE(),
    FinishedAt DATETIME NULL,
    Duration AS DATEDIFF(SECOND, StartedAt, FinishedAt) PERSISTED,
    Status NVARCHAR(20) NULL CHECK (Status IN ('RUNNING', 'SUCCESS', 'FAILED', 'CANCELLED')),
    Message NVARCHAR(MAX) NULL,
    ErrorDetails NVARCHAR(MAX) NULL,
    RecordsProcessed INT DEFAULT 0,
    RecordsFailed INT DEFAULT 0,
    CreatedBy INT REFERENCES Users(UserID)
);
GO

CREATE INDEX IX_JobRunLog_Status ON JobRunLog(Status);
CREATE INDEX IX_JobRunLog_StartedAt ON JobRunLog(StartedAt DESC);
GO

-- ====================
-- ALERT LOG
-- ====================
CREATE TABLE AlertLog (
    AlertID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CycleID INT NOT NULL REFERENCES FarmingCycle(CycleID),
    AlertDate DATETIME DEFAULT GETDATE(),
    DayNo INT,
    AlertLevel NVARCHAR(20) CHECK (AlertLevel IN ('INFO', 'WARNING', 'CRITICAL')),
    AlertCategory NVARCHAR(50), -- WATER_QUALITY, HEALTH, INVENTORY, COST, GROWTH
    AlertMessage NVARCHAR(1000),
    TriggerValue DECIMAL(10,4),
    ThresholdValue DECIMAL(10,4),
    Status NVARCHAR(20) DEFAULT 'OPEN' CHECK (Status IN ('OPEN', 'ACKNOWLEDGED', 'RESOLVED', 'IGNORED')),
    ResolvedAt DATETIME NULL,
    ResolvedBy INT NULL REFERENCES Users(UserID),
    Resolution NVARCHAR(1000),
    NotificationSent BIT DEFAULT 0,
    NotificationMethod NVARCHAR(50),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_AlertLog_CycleID ON AlertLog(CycleID);
CREATE INDEX IX_AlertLog_Level_Status ON AlertLog(AlertLevel, Status);
CREATE INDEX IX_AlertLog_Date ON AlertLog(AlertDate DESC);
GO

-- ====================
-- COST TRACKING
-- ====================
CREATE TABLE CostTracking (
    CostID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CycleID INT NOT NULL REFERENCES FarmingCycle(CycleID),
    CostDate DATE NOT NULL,
    DayNo INT,
    -- Cost Categories
    FeedCost DECIMAL(18,2) DEFAULT 0,
    ChemicalCost DECIMAL(18,2) DEFAULT 0,
    ElectricityCost DECIMAL(18,2) DEFAULT 0,
    LaborCost DECIMAL(18,2) DEFAULT 0,
    MaintenanceCost DECIMAL(18,2) DEFAULT 0,
    OtherCost DECIMAL(18,2) DEFAULT 0,
    TotalDailyCost DECIMAL(18,2),
    CumulativeCost DECIMAL(18,2),
    CostPerKgBiomass DECIMAL(10,2),
    Notes NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_CostTracking_CycleID ON CostTracking(CycleID);
CREATE INDEX IX_CostTracking_Date ON CostTracking(CostDate);
GO

-- ====================
-- AUDIT TRAIL
-- ====================
CREATE TABLE AuditTrail (
    AuditID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(100) NOT NULL,
    RecordID BIGINT NOT NULL,
    Action NVARCHAR(20) NOT NULL CHECK (Action IN ('INSERT', 'UPDATE', 'DELETE')),
    OldValues NVARCHAR(MAX),
    NewValues NVARCHAR(MAX),
    ChangedFields NVARCHAR(MAX),
    ActionDate DATETIME DEFAULT GETDATE(),
    UserID INT REFERENCES Users(UserID),
    Username NVARCHAR(50),
    IPAddress NVARCHAR(50),
    UserAgent NVARCHAR(500)
);
GO

CREATE INDEX IX_AuditTrail_TableRecord ON AuditTrail(TableName, RecordID);
CREATE INDEX IX_AuditTrail_UserID ON AuditTrail(UserID);
CREATE INDEX IX_AuditTrail_ActionDate ON AuditTrail(ActionDate DESC);
GO

-- =============================================
-- SECTION 5: VIEWS
-- =============================================

PRINT 'Creating Views...';
GO

-- ====================
-- VIEW: FeedUsage (Backward Compatibility)
-- ====================
CREATE VIEW vw_FeedUsage
AS
SELECT
    fl.LedgerID AS UsageID,
    c.PondID,
    fl.FeedID,
    fi.FeedName,
    fl.BatchCode AS FeedBatchCode,
    fl.ExpiryDate AS FeedExpiryDate,
    fl.QtyKg AS Quantity,
    fl.TxnDate AS UsageDate,
    fl.CycleID,
    fl.UnitPrice,
    fl.TotalAmount,
    fl.CreatedAt
FROM FeedLedger fl
INNER JOIN FarmingCycle c ON fl.CycleID = c.CycleID
INNER JOIN FeedInventory fi ON fl.FeedID = fi.FeedID
WHERE fl.Direction = 'O';
GO

-- ====================
-- VIEW: ChemicalUsage (Backward Compatibility)
-- ====================
CREATE VIEW vw_ChemicalUsage
AS
SELECT
    cl.LedgerID AS UsageID,
    c.PondID,
    cl.ChemicalID,
    ci.ChemicalName,
    cl.BatchCode AS ChemicalBatchCode,
    cl.ExpiryDate AS ChemicalExpiryDate,
    cl.Qty AS Quantity,
    cl.Unit,
    cl.TxnDate AS UsageDate,
    cl.CycleID,
    cl.Purpose,
    cl.UnitPrice,
    cl.TotalAmount,
    cl.CreatedAt
FROM ChemicalLedger cl
INNER JOIN FarmingCycle c ON cl.CycleID = c.CycleID
INNER JOIN ChemicalInventory ci ON cl.ChemicalID = ci.ChemicalID
WHERE cl.Direction = 'O';
GO

-- ====================
-- VIEW: Current Stock Levels
-- ====================
CREATE VIEW vw_CurrentStock
AS
SELECT
    w.WarehouseID,
    w.WarehouseName,
    f.FeedID,
    f.FeedName,
    fl.BatchCode,
    fl.ExpiryDate,
    SUM(CASE WHEN fl.Direction = 'I' THEN fl.QtyKg ELSE -fl.QtyKg END) AS CurrentStockKg,
    DATEDIFF(DAY, GETDATE(), fl.ExpiryDate) AS DaysToExpiry
FROM FeedLedger fl
INNER JOIN Warehouses w ON fl.WarehouseID = w.WarehouseID
INNER JOIN FeedInventory f ON fl.FeedID = f.FeedID
GROUP BY w.WarehouseID, w.WarehouseName, f.FeedID, f.FeedName, fl.BatchCode, fl.ExpiryDate
HAVING SUM(CASE WHEN fl.Direction = 'I' THEN fl.QtyKg ELSE -fl.QtyKg END) > 0;
GO

-- ====================
-- VIEW: Cycle Summary
-- ====================
CREATE VIEW vw_CycleSummary
AS
SELECT
    c.CycleID,
    c.CycleCode,
    c.CycleName,
    c.Species,
    c.Status,
    p.PondName,
    f.FarmName,
    c.StartDate,
    c.EndDate,
    c.SeedQty AS InitialFishCount,
    ISNULL((SELECT TOP 1 FishQty FROM DailyLog WHERE CycleID = c.CycleID ORDER BY DayNo DESC), 0) AS CurrentFishCount,
    ISNULL((SELECT TOP 1 AvgWeightG FROM DailyLog WHERE CycleID = c.CycleID ORDER BY DayNo DESC), 0) AS CurrentTLBQ,
    ISNULL((SELECT TOP 1 BiomassKg FROM DailyLog WHERE CycleID = c.CycleID ORDER BY DayNo DESC), 0) AS CurrentBiomass,
    ISNULL((SELECT TOP 1 FCR FROM DailyLog WHERE CycleID = c.CycleID ORDER BY DayNo DESC), 0) AS CurrentFCR,
    ISNULL((SELECT TOP 1 SurvivalRate FROM DailyLog WHERE CycleID = c.CycleID ORDER BY DayNo DESC), 100) AS SurvivalRate,
    ISNULL((SELECT COUNT(*) FROM DailyLog WHERE CycleID = c.CycleID), 0) AS DaysActive,
    ISNULL((SELECT SUM(TotalDailyCost) FROM CostTracking WHERE CycleID = c.CycleID), 0) AS TotalCost
FROM FarmingCycle c
INNER JOIN Ponds p ON c.PondID = p.PondID
INNER JOIN Farms f ON p.FarmID = f.FarmID;
GO

-- =============================================
-- SECTION 6: STORED PROCEDURES
-- =============================================

PRINT 'Creating Stored Procedures...';
GO

-- ====================
-- SP: FEFO Allocation
-- ====================
CREATE PROCEDURE sp_AllocateFEFO
    @WarehouseID INT,
    @FeedID INT,
    @RequiredQtyKg DECIMAL(12,3),
    @AsOfDate DATE,
    @CycleID INT,
    @AllocatedQtyKg DECIMAL(12,3) OUTPUT,
    @ShortageQtyKg DECIMAL(12,3) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BatchCode NVARCHAR(50);
    DECLARE @ExpiryDate DATE;
    DECLARE @AvailableQty DECIMAL(12,3);
    DECLARE @AllocateQty DECIMAL(12,3);
    
    SET @AllocatedQtyKg = 0;
    SET @ShortageQtyKg = @RequiredQtyKg;
    
    BEGIN TRY
        CREATE TABLE #AvailableBatches (
            BatchCode NVARCHAR(50),
            ExpiryDate DATE,
            AvailableQty DECIMAL(12,3)
        );
        
        INSERT INTO #AvailableBatches
        SELECT 
            BatchCode,
            ExpiryDate,
            SUM(CASE WHEN Direction = 'I' THEN QtyKg ELSE -QtyKg END) AS AvailableQty
        FROM FeedLedger
        WHERE WarehouseID = @WarehouseID
            AND FeedID = @FeedID
            AND ExpiryDate > @AsOfDate
        GROUP BY BatchCode, ExpiryDate
        HAVING SUM(CASE WHEN Direction = 'I' THEN QtyKg ELSE -QtyKg END) > 0
        ORDER BY ExpiryDate ASC;
        
        DECLARE batch_cursor CURSOR FOR
        SELECT BatchCode, ExpiryDate, AvailableQty
        FROM #AvailableBatches
        ORDER BY ExpiryDate;
        
        OPEN batch_cursor;
        
        FETCH NEXT FROM batch_cursor INTO @BatchCode, @ExpiryDate, @AvailableQty;
        
        WHILE @@FETCH_STATUS = 0 AND @ShortageQtyKg > 0
        BEGIN
            SET @AllocateQty = CASE 
                WHEN @AvailableQty >= @ShortageQtyKg THEN @ShortageQtyKg
                ELSE @AvailableQty
            END;
            
            INSERT INTO FeedLedger (
                WarehouseID, FeedID, TxnDate, Direction, QtyKg,
                BatchCode, ExpiryDate, CycleID
            )
            VALUES (
                @WarehouseID, @FeedID, @AsOfDate, 'O', @AllocateQty,
                @BatchCode, @ExpiryDate, @CycleID
            );
            
            SET @AllocatedQtyKg = @AllocatedQtyKg + @AllocateQty;
            SET @ShortageQtyKg = @ShortageQtyKg - @AllocateQty;
            
            FETCH NEXT FROM batch_cursor INTO @BatchCode, @ExpiryDate, @AvailableQty;
        END
        
        CLOSE batch_cursor;
        DEALLOCATE batch_cursor;
        
        DROP TABLE #AvailableBatches;
        
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('global', 'batch_cursor') >= 0
        BEGIN
            CLOSE batch_cursor;
            DEALLOCATE batch_cursor;
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ====================
-- SP: Split Receipt by Capacity
-- ====================
CREATE PROCEDURE sp_SplitReceiptByCapacity
    @WarehouseID INT,
    @FeedID INT,
    @TotalQtyKg DECIMAL(12,3),
    @BatchCode NVARCHAR(50),
    @ExpiryDate DATE,
    @TxnDate DATE,
    @UnitPrice DECIMAL(12,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CapacityKg DECIMAL(12,2);
    DECLARE @RemainingQty DECIMAL(12,3);
    DECLARE @AllocateQty DECIMAL(12,3);
    DECLARE @RecordCount INT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        SELECT @CapacityKg = CapacityKg
        FROM Warehouses
        WHERE WarehouseID = @WarehouseID;
        
        IF @CapacityKg IS NULL OR @CapacityKg <= 0
        BEGIN
            INSERT INTO FeedLedger (
                WarehouseID, FeedID, TxnDate, Direction, QtyKg,
                BatchCode, ExpiryDate, UnitPrice, TotalAmount
            )
            VALUES (
                @WarehouseID, @FeedID, @TxnDate, 'I', @TotalQtyKg,
                @BatchCode, @ExpiryDate, @UnitPrice, @TotalQtyKg * @UnitPrice
            );
            
            SET @RecordCount = 1;
        END
        ELSE
        BEGIN
            SET @RemainingQty = @TotalQtyKg;
            
            WHILE @RemainingQty > 0
            BEGIN
                SET @AllocateQty = CASE 
                    WHEN @RemainingQty > @CapacityKg THEN @CapacityKg
                    ELSE @RemainingQty
                END;
                
                INSERT INTO FeedLedger (
                    WarehouseID, FeedID, TxnDate, Direction, QtyKg,
                    BatchCode, ExpiryDate, UnitPrice, TotalAmount
                )
                VALUES (
                    @WarehouseID, @FeedID, @TxnDate, 'I', @AllocateQty,
                    @BatchCode, @ExpiryDate, @UnitPrice, @AllocateQty * @UnitPrice
                );
                
                SET @RemainingQty = @RemainingQty - @AllocateQty;
                SET @RecordCount = @RecordCount + 1;
            END
        END
        
        COMMIT TRANSACTION;
        
        SELECT @RecordCount AS RecordsCreated, @TotalQtyKg AS TotalQty;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ====================
-- SP: Verify Determinism
-- ====================
CREATE PROCEDURE sp_VerifyDeterminism
    @CycleID INT,
    @Seed INT,
    @ExpectedChecksum NVARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ActualChecksum NVARCHAR(64);
    DECLARE @RecordCount INT;
    DECLARE @IsMatch BIT;
    
    SELECT 
        @ActualChecksum = CONVERT(NVARCHAR(64), 
            HASHBYTES('SHA2_256', 
                STRING_AGG(
                    CONCAT(
                        CAST(DayNo AS VARCHAR),
                        CAST(FishQty AS VARCHAR),
                        CAST(AvgWeightG AS VARCHAR),
                        CAST(FeedGivenKg AS VARCHAR),
                        CAST(DOmg AS VARCHAR)
                    ), 
                    '|'
                ) WITHIN GROUP (ORDER BY DayNo)
            ), 
            2
        ),
        @RecordCount = COUNT(*)
    FROM DailyLog
    WHERE CycleID = @CycleID;
    
    SET @IsMatch = CASE 
        WHEN @ActualChecksum = @ExpectedChecksum THEN 1
        ELSE 0
    END;
    
    INSERT INTO JobRunLog (
        CycleID, 
        JobType,
        Status, 
        Message,
        RecordsProcessed
    )
    VALUES (
        @CycleID,
        'DETERMINISM_CHECK',
        CASE WHEN @IsMatch = 1 THEN 'SUCCESS' ELSE 'FAILED' END,
        CASE WHEN @IsMatch = 1 
            THEN 'Determinism verified successfully'
            ELSE CONCAT('Checksum mismatch. Expected: ', @ExpectedChecksum, ', Actual: ', @ActualChecksum)
        END,
        @RecordCount
    );
    
    SELECT 
        @IsMatch AS IsMatch,
        @ExpectedChecksum AS ExpectedChecksum,
        @ActualChecksum AS ActualChecksum,
        @RecordCount AS RecordsVerified,
        @Seed AS Seed;
END
GO

-- ====================
-- SP: Generate Daily Logs (Pipeline Orchestrator)
-- ====================
CREATE PROCEDURE sp_GenerateDailyLogs
    @CycleID INT,
    @StartDay INT,
    @EndDay INT,
    @UseLiveWeather BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @CurrentDay INT = @StartDay;
        DECLARE @LogDate DATE;
        DECLARE @FishQty INT;
        DECLARE @AvgWeightG DECIMAL(8,2);
        DECLARE @BiomassKg DECIMAL(12,3);
        DECLARE @DeathQty INT;
        DECLARE @FeedGivenKg DECIMAL(12,3);
        DECLARE @TempC DECIMAL(5,2);
        DECLARE @DOmg DECIMAL(5,2);
        DECLARE @pH DECIMAL(4,2);
        DECLARE @H2S DECIMAL(6,3);
        DECLARE @NH3 DECIMAL(6,3);
        
        WHILE @CurrentDay <= @EndDay
        BEGIN
            SELECT @LogDate = DATEADD(DAY, @CurrentDay - 1, StartDate)
            FROM FarmingCycle
            WHERE CycleID = @CycleID;
            
            -- Get previous day data
            IF @CurrentDay > 1
            BEGIN
                SELECT TOP 1
                    @FishQty = FishQty,
                    @AvgWeightG = AvgWeightG,
                    @BiomassKg = BiomassKg
                FROM DailyLog
                WHERE CycleID = @CycleID AND DayNo = @CurrentDay - 1;
            END
            ELSE
            BEGIN
                SELECT TOP 1
                    @FishQty = SeedQty,
                    @AvgWeightG = AvgWeightG,
                    @BiomassKg = (SeedQty * AvgWeightG) / 1000.0
                FROM FarmingCycle
                WHERE CycleID = @CycleID;
            END
            
            -- Temperature simulation
            SET @TempC = 28.0 + (RAND() - 0.5) * 4.0;
            
            -- DO simulation
            SET @DOmg = 5.5 - (@BiomassKg / 1000.0) * 0.5 - RAND() * 1.5;
            
            -- pH simulation
            SET @pH = 7.2 + (RAND() - 0.5) * 0.6;
            
            -- H2S simulation
            SET @H2S = (@BiomassKg / 1000.0) * 0.0005;
            
            -- NH3 simulation
            SET @NH3 = (@BiomassKg / 100.0) * 0.001;
            
            -- Mortality calculation
            SET @DeathQty = CAST(@FishQty * 0.001 * (0.8 + RAND() * 0.4) AS INT);
            SET @FishQty = @FishQty - @DeathQty;
            
            -- Growth calculation
            SET @AvgWeightG = @AvgWeightG + 0.3;
            SET @BiomassKg = (@FishQty * @AvgWeightG) / 1000.0;
            
            -- Feed calculation
            SET @FeedGivenKg = (@BiomassKg * 0.03);
            
            -- Insert DailyLog
            INSERT INTO DailyLog (
                CycleID, LogDate, DayNo, FishQty, DeathQty, AvgWeightG,
                BiomassKg, FeedGivenKg, DOmg, pH, TempC, H2S, NH3
            )
            VALUES (
                @CycleID, @LogDate, @CurrentDay, @FishQty, @DeathQty, @AvgWeightG,
                @BiomassKg, @FeedGivenKg, @DOmg, @pH, @TempC, @H2S, @NH3
            );
            
            SET @CurrentDay = @CurrentDay + 1;
        END
        
        COMMIT TRANSACTION;
        SELECT 'Success' AS Result, (@EndDay - @StartDay + 1) AS DaysGenerated;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ====================
-- SP: Calculate Cycle Statistics
-- ====================
CREATE PROCEDURE sp_CalculateCycleStats
    @CycleID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TotalFeed DECIMAL(12,3);
    DECLARE @BiomassGain DECIMAL(12,3);
    DECLARE @FCR DECIMAL(8,3);
    DECLARE @FinalBiomass DECIMAL(12,3);
    DECLARE @InitialBiomass DECIMAL(12,3);
    DECLARE @SurvivalRate DECIMAL(5,2);
    DECLARE @TotalCost DECIMAL(18,2);
    
    SELECT TOP 1
        @TotalFeed = SUM(FeedGivenKg),
        @FinalBiomass = MAX(BiomassKg),
        @SurvivalRate = MAX(SurvivalRate)
    FROM DailyLog
    WHERE CycleID = @CycleID;
    
    SELECT TOP 1
        @InitialBiomass = (SeedQty * AvgWeightG) / 1000.0
    FROM FarmingCycle
    WHERE CycleID = @CycleID;
    
    SET @BiomassGain = @FinalBiomass - @InitialBiomass;
    SET @FCR = CASE WHEN @BiomassGain > 0 THEN @TotalFeed / @BiomassGain ELSE 0 END;
    
    SELECT TOP 1
        @TotalCost = SUM(TotalDailyCost)
    FROM CostTracking
    WHERE CycleID = @CycleID;
    
    SELECT
        @CycleID AS CycleID,
        @InitialBiomass AS InitialBiomass,
        @FinalBiomass AS FinalBiomass,
        @BiomassGain AS BiomassGain,
        @TotalFeed AS TotalFeed,
        @FCR AS FCR,
        @SurvivalRate AS SurvivalRate,
        @TotalCost AS TotalCost,
        CASE WHEN @FinalBiomass > 0 THEN @TotalCost / @FinalBiomass ELSE 0 END AS CostPerKgBiomass;
END
GO

-- ====================
-- EVENTS TABLE (for Medication, Water Exchange, etc.)
-- ====================
CREATE TABLE Events (
    EventID INT PRIMARY KEY IDENTITY(1,1),
    CycleID INT NOT NULL REFERENCES FarmingCycle(CycleID),
    EventDate DATE NOT NULL,
    DayNo INT,
    EventType NVARCHAR(50), -- MEDICATION, WATER_EXCHANGE, HEALTH_CHECK, EMERGENCY, OTHER
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000),
    ChemicalID INT REFERENCES ChemicalInventory(ChemicalID),
    DosageAmount DECIMAL(8,2),
    ExchangePercent DECIMAL(5,2),
    Status NVARCHAR(20) DEFAULT 'PLANNED', -- PLANNED, COMPLETED, CANCELLED
    CompletedAt DATETIME,
    Notes NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy INT REFERENCES Users(UserID),
    INDEX IX_Event_CycleDate (CycleID, EventDate DESC)
);
GO

-- ====================
-- DAILY REPORT SUMMARY TABLE
-- ====================
CREATE TABLE DailyReportSummary (
    ReportID BIGINT PRIMARY KEY IDENTITY(1,1),
    CycleID INT NOT NULL REFERENCES FarmingCycle(CycleID),
    ReportDate DATE NOT NULL,
    DayNo INT,
    FishCount INT,
    AvgWeightG DECIMAL(8,2),
    BiomasKg DECIMAL(12,3),
    MortalityPct DECIMAL(5,2),
    SurvivalPct DECIMAL(5,2),
    FCR DECIMAL(8,3),
    DailyCost DECIMAL(10,2),
    CumulativeCost DECIMAL(18,2),
    ProjectedProfit DECIMAL(15,2),
    AlertCount INT DEFAULT 0,
    CriticalAlertCount INT DEFAULT 0,
    WarningAlertCount INT DEFAULT 0,
    DO_min DECIMAL(5,2),
    DO_max DECIMAL(5,2),
    DO_avg DECIMAL(5,2),
    pH_min DECIMAL(4,2),
    pH_max DECIMAL(4,2),
    Temp_min DECIMAL(5,2),
    Temp_max DECIMAL(5,2),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_DailyReportSummary_CycleDay UNIQUE (CycleID, ReportDate),
    INDEX IX_DailyReportSummary_CycleDate (CycleID, ReportDate DESC)
);
GO

-- ====================
-- TRIGGER: Auto Audit Trail for DailyLog
-- ====================
CREATE TRIGGER trg_AuditDailyLog
ON DailyLog
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM INSERTED)
    BEGIN
        -- INSERT or UPDATE
        INSERT INTO AuditTrail (
            TableName, RecordID, Action, OldValues, NewValues,
            ActionDate, UserID, Username
        )
        SELECT 
            'DailyLog',
            i.LogID,
            CASE WHEN d.LogID IS NULL THEN 'INSERT' ELSE 'UPDATE' END,
            ISNULL(CONCAT('FishQty:', d.FishQty, '|DeathQty:', d.DeathQty), 'NULL'),
            CONCAT('FishQty:', i.FishQty, '|DeathQty:', i.DeathQty),
            GETDATE(),
            NULL,
            'System'
        FROM INSERTED i
        LEFT JOIN DELETED d ON i.LogID = d.LogID;
    END
    ELSE IF EXISTS (SELECT 1 FROM DELETED)
    BEGIN
        -- DELETE
        INSERT INTO AuditTrail (
            TableName, RecordID, Action, OldValues, NewValues,
            ActionDate, UserID, Username
        )
        SELECT 
            'DailyLog',
            d.LogID,
            'DELETE',
            CONCAT('FishQty:', d.FishQty, '|DeathQty:', d.DeathQty),
            'NULL',
            GETDATE(),
            NULL,
            'System'
        FROM DELETED d;
    END
END
GO

-- ====================
-- TRIGGER: Update FarmingCycle LastProcessedDay
-- ====================
CREATE TRIGGER trg_UpdateCycleLastDay
ON DailyLog
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE FarmingCycle
    SET LastProcessedDay = COALESCE(
        (SELECT MAX(DayNo) FROM DailyLog WHERE CycleID = FarmingCycle.CycleID),
        0
    ),
    UpdatedAt = GETDATE()
    WHERE CycleID IN (SELECT DISTINCT CycleID FROM INSERTED);
END
GO

-- =============================================
-- SECTION 7: SEED DATA
-- =============================================

PRINT 'Seeding Master Data...';
GO

-- Seed EnvRules for CATFISH
INSERT INTO EnvRules (Species, MonthNo, BaseTempC, TempMinC, TempMaxC, JitterSigma, OptimalDOmg, OptimalPH)
VALUES
    ('CATFISH', 1, 27, 25, 32, 2.0, 5.5, 7.2),
    ('CATFISH', 2, 28, 25, 32, 2.0, 5.5, 7.2),
    ('CATFISH', 3, 29, 26, 33, 2.0, 5.5, 7.2),
    ('CATFISH', 4, 30, 27, 34, 2.0, 5.5, 7.2),
    ('CATFISH', 5, 30, 27, 34, 2.0, 5.5, 7.2),
    ('CATFISH', 6, 29, 27, 33, 2.0, 5.5, 7.2),
    ('CATFISH', 7, 29, 27, 33, 2.0, 5.5, 7.2),
    ('CATFISH', 8, 29, 27, 33, 2.0, 5.5, 7.2),
    ('CATFISH', 9, 29, 27, 33, 2.0, 5.5, 7.2),
    ('CATFISH', 10, 28, 26, 32, 2.0, 5.5, 7.2),
    ('CATFISH', 11, 27, 25, 31, 2.0, 5.5, 7.2),
    ('CATFISH', 12, 27, 25, 31, 2.0, 5.5, 7.2);
GO

-- Seed Default Admin User (Password: Admin@123 - BCrypt hashed)
INSERT INTO Users (Username, Email, PasswordHash, FullName, Role, IsActive)
VALUES 
    ('admin', 'admin@aquasim_VHC.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5eWxKkWxL4Kq2', 'Administrator', 'Admin', 1),
    ('manager', 'manager@aquasim_VHC.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5eWxKkWxL4Kq2', 'Manager User', 'Manager', 1);
GO

-- Seed Sample Farm
INSERT INTO Farms (FarmCode, FarmName, Province, District, Manager, [ASC], [BAP], IsActive)
VALUES ('F001', 'Demo Farm 1', 'Đồng Tháp', 'Cao Lãnh', 'Nguyễn Văn A', 1, 1, 1);
GO

-- Seed Sample Warehouse
INSERT INTO Warehouses (WarehouseCode, WarehouseName, FarmID, WarehouseType, CapacityKg, IsActive)
VALUES ('W001', 'Kho Thức Ăn Chính', 1, 'FEED', 10000, 1);
GO

-- Seed Sample Pond
INSERT INTO Ponds (PondCode, PondName, FarmID, WarehouseID, SurfaceAreaM2, DepthM, VolumeM3, IsActive)
VALUES ('P001', 'Ao 1', 1, 1, 5000, 2.0, 10000, 1);
GO

-- Seed Sample Feed
INSERT INTO FeedInventory (FeedCode, FeedName, ProteinPercent, SizeBand, PelletType, Supplier, UnitPrice, IsActive)
VALUES 
    ('CP30', 'Cám CP 30% đạm', 30, 'MEDIUM', 'FLOATING', 'CP Vietnam', 15000, 1),
    ('CP32', 'Cám CP 32% đạm', 32, 'LARGE', 'FLOATING', 'CP Vietnam', 16000, 1);
GO

-- Seed Sample Chemical
INSERT INTO ChemicalInventory (ChemicalCode, ChemicalName, ChemicalType, Purpose, DosageUnit, StandardDosage, UnitPrice, IsActive)
VALUES 
    ('PROB01', 'Men vi sinh', 'PROBIOTIC', 'Cải thiện môi trường nước', 'kg', 0.5, 50000, 1),
    ('VITC01', 'Vitamin C', 'VITAMIN', 'Tăng cường sức đề kháng', 'kg', 0.2, 80000, 1),
    ('LIME01', 'Vôi bột', 'pH_ADJUSTER', 'Điều chỉnh pH', 'kg', 10.0, 5000, 1);
GO

-- Seed Calendar Data (2025 Holidays & Weekends)
PRINT 'Seeding Calendar...';
GO

DECLARE @StartDate DATE = '2025-01-01';
DECLARE @EndDate DATE = '2025-12-31';
DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO Calendar (CalDate, IsHoliday, IsWeekend)
    VALUES (
        @CurrentDate,
        CASE 
            WHEN @CurrentDate IN ('2025-01-01', '2025-02-10', '2025-02-11', '2025-02-12', 
                                  '2025-04-18', '2025-04-19', '2025-04-20', '2025-04-21',
                                  '2025-05-01', '2025-09-02', '2025-09-03')
            THEN 1
            ELSE 0
        END,
        CASE 
            WHEN DATEPART(WEEKDAY, @CurrentDate) IN (1, 7)  -- Sunday=1, Saturday=7
            THEN 1
            ELSE 0
        END
    );
    
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END
GO

PRINT 'Database creation completed successfully!';
GO

-- =============================================
-- VERIFICATION
-- =============================================

PRINT '';
PRINT '===========================================';
PRINT 'DATABASE VERIFICATION';
PRINT '===========================================';
PRINT '';

-- Count tables
SELECT 
    'Total Tables' AS Metric,
    COUNT(*) AS Count
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

-- Count views
SELECT 
    'Total Views' AS Metric,
    COUNT(*) AS Count
FROM INFORMATION_SCHEMA.VIEWS;

-- Count stored procedures
SELECT 
    'Total Stored Procedures' AS Metric,
    COUNT(*) AS Count
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE';

-- List all tables
PRINT '';
PRINT 'Tables created:';
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

PRINT '';
PRINT '===========================================';
PRINT 'DATABASE READY!';
PRINT 'You can now start using aquasim_VHC system.';
PRINT '===========================================';
GO
