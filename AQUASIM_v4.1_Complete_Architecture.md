# AQUASIM v4.1 - SYSTEM ARCHITECTURE DOCUMENT
## Comprehensive Technical Architecture

**Ngày**: 15/11/2025  
**Phiên bản**: 4.1 - Complete Architecture  
**Tác giả**: AquaSim Architecture Team  
**Trạng thái**: ✅ APPROVED FOR DEVELOPMENT  

---

# MỤC LỤC

1. [Tổng Quan Kiến Trúc](#1-tổng-quan-kiến-trúc)
2. [High-Level Architecture (3-Layer)](#2-high-level-architecture)
3. [Presentation Layer (Windows Forms)](#3-presentation-layer)
4. [Business Logic Layer (11 Engines)](#4-business-logic-layer)
5. [Data Access Layer (EF Core)](#5-data-access-layer)
6. [Database Design](#6-database-design)
7. [Data Flow & Pipelines](#7-data-flow--pipelines)
8. [Component Interactions](#8-component-interactions)
9. [Deployment Architecture](#9-deployment-architecture)
10. [Technology Stack](#10-technology-stack)

---

# 1. TỔNG QUAN KIẾN TRÚC

## 1.1 Mục Tiêu Kiến Trúc

```
AQUASIM = Hệ thống tự động hóa 100% chu kỳ nuôi 90 ngày
├─ Deterministic Simulation (cùng seed = cùng kết quả)
├─ Real-time Monitoring & Alerts
├─ FSIS Compliance (8 forms)
└─ Cost Optimization (FCR, Mortality, Feed)
```

## 1.2 Nguyên Tắc Thiết Kế

| Nguyên Tắc | Mô Tả |
|-----------|-------|
| **Separation of Concerns** | Mỗi layer riêng biệt, không phụ thuộc |
| **DDD (Domain-Driven Design)** | Entities, ValueObjects, Services focused |
| **SOLID Principles** | Single Resp, Open/Closed, Liskov, Interface Seg, Dependency Inv |
| **Deterministic** | Cùng input, cùng output (seed-based) |
| **Scalable** | Xử lý 1,000+ cycles, 50 concurrent users |
| **Maintainable** | Clear naming, documented, testable |

---

# 2. HIGH-LEVEL ARCHITECTURE (3-LAYER)

## 2.1 Kiến Trúc Tổng Quan

```
┌────────────────────────────────────────────────────────────────┐
│          PRESENTATION LAYER (UI)                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Windows Forms                                          │  │
│  │  ├─ CycleBatchDeclarationForm                          │  │
│  │  ├─ FarmingCycleManagementForm                         │  │
│  │  ├─ InventoryManagementForm                           │  │
│  │  ├─ DailyLogForm                                      │  │
│  │  ├─ ReportingForm                                     │  │
│  │  └─ AlertDashboard                                    │  │
│  └─────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
                            ↕ (Service calls)
┌────────────────────────────────────────────────────────────────┐
│        BUSINESS LOGIC LAYER (Services + Engines)               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  11 Simulation Engines:                                │  │
│  │  ├─ EnvironmentGenerator    (DO, pH, H2S, NH3, Temp)  │  │
│  │  ├─ MortalityEngine         (Cá chết)                 │  │
│  │  ├─ GrowthEngine            (Tăng trọng)              │  │
│  │  ├─ FeedPlanner             (Thức ăn)                 │  │
│  │  ├─ ChemicalEngine          (Hóa chất)                │  │
│  │  ├─ WaterOpsEngine          (Thay nước)               │  │
│  │  ├─ InventoryEngine         (FEFO, kho)               │  │
│  │  ├─ CostTracker             (Chi phí)                 │  │
│  │  ├─ AlertSystem             (Cảnh báo)                │  │
│  │  ├─ ValidationService       (Kiểm tra)                │  │
│  │  └─ ReportingEngine         (8 FSIS forms)            │  │
│  │                                                       │  │
│  │  Services:                                            │  │
│  │  ├─ DailyPipelineService    (10-step pipeline)       │  │
│  │  ├─ CycleManagementService  (Chu kỳ nuôi)            │  │
│  │  ├─ InventoryService        (FEFO allocation)        │  │
│  │  ├─ CostCalculationService  (Chi phí)                │  │
│  │  └─ AlertingService         (Alert logic)            │  │
│  └─────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
                            ↕ (Data access)
┌────────────────────────────────────────────────────────────────┐
│        DATA ACCESS LAYER (EF Core + Repositories)              │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Entity Framework Core 9.0                              │  │
│  │  ├─ DbContext                                          │  │
│  │  ├─ DbSets (25+ entities)                             │  │
│  │  └─ Migrations                                         │  │
│  │                                                       │  │
│  │  Repositories:                                        │  │
│  │  ├─ IFarmingCycleRepository                          │  │
│  │  ├─ IDailyLogRepository                              │  │
│  │  ├─ IInventoryRepository                             │  │
│  │  ├─ IAlertRepository                                 │  │
│  │  └─ ... (other repositories)                         │  │
│  │                                                       │  │
│  │  Stored Procedures:                                  │  │
│  │  ├─ sp_GenerateDailyLogs                             │  │
│  │  ├─ sp_CalculateCycleStats                           │  │
│  │  ├─ sp_AllocateFEFO                                  │  │
│  │  └─ ... (other SPs)                                  │  │
│  └─────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
                            ↕ (SQL queries)
┌────────────────────────────────────────────────────────────────┐
│           DATABASE LAYER (SQL Server 2019+)                    │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  SQL Server 2019+                                       │  │
│  │  ├─ Master Data: Farms, Ponds, Warehouses, Users       │  │
│  │  ├─ Cycle Data: FarmingCycles, DailyLogs              │  │
│  │  ├─ Environment: EnvironmentLogs, MortalityEvents     │  │
│  │  ├─ Inventory: InventoryLedger, FEFOAllocation        │  │
│  │  ├─ Reporting: AlertLogs, AuditTrail, Events         │  │
│  │  └─ Indices: ON FarmingCycleID, PondID, Date...       │  │
│  └─────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

## 2.2 Luồng Dữ Liệu Chính

```
User Input (Form)
    ↓
Service Layer (Validate + Logic)
    ↓
Engine Layer (Calculate + Simulate)
    ↓
Repository Layer (Persist)
    ↓
Database (CRUD)
    ↓
Cache (Optional - Redis)
    ↓
Report Output (8 FSIS Forms)
```

---

# 3. PRESENTATION LAYER (WINDOWS FORMS)

## 3.1 Form Architecture

```csharp
namespace AquaSim.UI.Forms
{
    // Master Data Forms
    public partial class FarmMasterForm : BaseForm { }
    public partial class PondMasterForm : BaseForm { }
    public partial class WarehouseMasterForm : BaseForm { }
    public partial class FeedMasterForm : BaseForm { }
    public partial class ChemicalMasterForm : BaseForm { }
    public partial class UserManagementForm : BaseForm { }
    
    // Cycle Management Forms
    public partial class CycleBatchDeclarationForm : BaseForm { }      // Tạo cycle
    public partial class FarmingCycleManagementForm : BaseForm { }     // Quản lý cycle
    public partial class DailyLogEntryForm : BaseForm { }             // Ghi nhật ký
    public partial class CycleVisualizationForm : BaseForm { }        // Chart/Analytics
    
    // Inventory Forms
    public partial class InventoryReceiptForm : BaseForm { }          // Nhập kho
    public partial class InventoryIssuanceForm : BaseForm { }         // Xuất kho (FEFO)
    public partial class InventoryAuditForm : BaseForm { }            // Kiểm kho
    
    // Reporting Forms
    public partial class ReportingForm : BaseForm { }                 // FSIS Forms
    public partial class AlertDashboardForm : BaseForm { }            // Alerts
    
    // Base Class
    public abstract class BaseForm : Form
    {
        protected IServiceProvider _serviceProvider;
        protected ILogger _logger;
        
        // Common methods
        protected virtual void LoadData() { }
        protected virtual void SaveData() { }
        protected virtual void ValidateInput() { }
    }
}
```

## 3.2 Form Binding & Validation

```csharp
public partial class CycleBatchDeclarationForm : BaseForm
{
    private readonly ICycleManagementService _cycleService;
    private readonly IFarmService _farmService;
    
    // Controls
    private DataGridView gvCycles;
    private TextBox txtCycleName;
    private ComboBox cboPond;
    private NumericUpDown nudSeedQty;
    
    // Validation Rules
    private ValidationRuleSet _validationRules = new ValidationRuleSet
    {
        new NotEmptyRule(nameof(txtCycleName), "Tên chu kỳ không được trống"),
        new NotZeroRule(nameof(nudSeedQty), "Số lượng cá phải > 0"),
        new DateRangeRule(dtStartDate, dtEndDate, "Ngày kết thúc phải > ngày bắt đầu")
    };
    
    // Data Binding
    public void LoadCycles()
    {
        var cycles = _cycleService.GetAllCycles();
        gvCycles.DataSource = cycles.ToList();
    }
}
```

## 3.3 MVP (Model-View-Presenter) Pattern

```csharp
// Model
public class CycleViewModel
{
    public int CycleID { get; set; }
    public string CycleName { get; set; }
    public DateTime StartDate { get; set; }
    public int SeedQty { get; set; }
    public decimal AvgWeightG { get; set; }
}

// View Interface
public interface ICycleView
{
    CycleViewModel SelectedCycle { get; }
    event EventHandler CreateCycleClicked;
    event EventHandler DeleteCycleClicked;
    
    void ShowCycles(List<CycleViewModel> cycles);
    void ShowError(string message);
    void ShowSuccess(string message);
}

// Presenter
public class CyclePresenter
{
    private readonly ICycleView _view;
    private readonly ICycleManagementService _service;
    
    public CyclePresenter(ICycleView view, ICycleManagementService service)
    {
        _view = view;
        _service = service;
        _view.CreateCycleClicked += OnCreateCycle;
        _view.DeleteCycleClicked += OnDeleteCycle;
    }
    
    private async void OnCreateCycle(object sender, EventArgs e)
    {
        var cycle = _view.SelectedCycle;
        var result = await _service.CreateCycleAsync(cycle);
        if (result.Success)
            _view.ShowSuccess("Tạo chu kỳ thành công");
        else
            _view.ShowError(result.Message);
    }
}
```

---

# 4. BUSINESS LOGIC LAYER (11 ENGINES)

## 4.1 Engine Architecture

```csharp
namespace AquaSim.Engine
{
    // Base Engine Interface
    public interface ISimulationEngine
    {
        Task<EngineOutput> ExecuteAsync(DailyPipelineInput input);
        Task<ValidationResult> ValidateAsync(DailyPipelineInput input);
    }
    
    // Environment Engine
    public class EnvironmentGenerator : ISimulationEngine
    {
        private readonly IRandomService _random;
        private readonly IEnvironmentRepository _repo;
        
        public async Task<EngineOutput> ExecuteAsync(DailyPipelineInput input)
        {
            // 1. Tính DO
            var baseDoValue = GetBaseDoValue(input.Cycle.AgeInDays);
            var biomassEffect = (input.CurrentBiomassKg / 15000m) * 0.3m;
            var randomVar = _random.Next(-0.2, 0.2);
            var doValue = Math.Max(2.8m, Math.Min(4.2m, baseDoValue - biomassEffect + randomVar));
            
            // 2. Tính pH
            var phValue = CalculatePH(input);
            
            // 3. Tính H2S
            var h2sValue = CalculateH2S(input);
            
            // 4. Tính NH3
            var nh3Value = CalculateNH3(input);
            
            // 5. Tính Nhiệt độ
            var tempValue = CalculateTemperature(input);
            
            return new EnvironmentOutput
            {
                DO = doValue,
                pH = phValue,
                H2S = h2sValue,
                NH3 = nh3Value,
                Temperature = tempValue
            };
        }
    }
    
    // Mortality Engine
    public class MortalityEngine : ISimulationEngine
    {
        public async Task<EngineOutput> ExecuteAsync(DailyPipelineInput input)
        {
            var baseRate = GetBaseRate(input.Cycle.AgeInDays);
            var stressAdj = 0m;
            
            // Stress adjustments (ADDITIVE)
            if (input.EnvironmentData.DO < 4.0m) 
                stressAdj += 0.5m * baseRate;
            if (input.EnvironmentData.pH < 6.5m || input.EnvironmentData.pH > 8.5m)
                stressAdj += 0.7m * baseRate;
            // ... more adjustments
            
            var adjustedRate = Math.Max(0m, Math.Min(0.1m, baseRate + stressAdj));
            var deadCount = (int)Math.Round(input.CurrentFishCount * adjustedRate * Random(0.8, 1.2));
            
            return new MortalityOutput
            {
                DeadFishCount = Math.Max(0, Math.Min(input.CurrentFishCount, deadCount))
            };
        }
    }
    
    // ... 9 more engines
}
```

## 4.2 Service Layer

```csharp
namespace AquaSim.Services
{
    // Daily Pipeline Service - Orchestrator
    public class DailyPipelineService
    {
        private readonly IEnvironmentGenerator _envGen;
        private readonly IMortalityEngine _mortalityEng;
        private readonly IGrowthEngine _growthEng;
        private readonly IFeedPlanner _feedPlan;
        // ... 8 more engines
        
        public async Task<DailyPipelineResult> ExecuteDailyPipelineAsync(DailyPipelineInput input)
        {
            var result = new DailyPipelineResult();
            
            // Step 1: Weather Anchor
            var seedValue = input.Cycle.Seed ?? GenerateSeed();
            
            // Step 2: EnvironmentGenerator
            var envOutput = await _envGen.ExecuteAsync(input);
            result.EnvironmentData = envOutput;
            
            // Step 3: MortalityEngine
            input.EnvironmentData = envOutput;
            var morOutput = await _mortalityEng.ExecuteAsync(input);
            result.DeadFishCount = morOutput.DeadFishCount;
            
            // Step 4: GrowthEngine
            var growOutput = await _growthEng.ExecuteAsync(input);
            result.DailyGrowth = growOutput.ActualGrowth;
            
            // Step 5-10: ... more engines
            
            // Step 9: Save Logs
            await _repo.SaveDailyLogAsync(result);
            
            // Step 10: Alert System
            var alerts = await _alertSys.CheckAlertsAsync(result);
            result.Alerts = alerts;
            
            return result;
        }
    }
    
    // Cycle Management Service
    public class CycleManagementService
    {
        public async Task<Result> CreateCycleAsync(CreateCycleRequest request)
        {
            // Validate
            // Initialize
            // Set PreparationDays, StockingDate
            // Save
        }
        
        public async Task<Result> GenerateCycleDaysAsync(int cycleId)
        {
            // Fetch cycle
            // Loop 92 days
            // Call DailyPipelineService
            // Aggregate results
        }
    }
    
    // Inventory Service (FEFO)
    public class InventoryService
    {
        public async Task<InventoryAllocationResult> AllocateFEFOAsync(
            int feedId, decimal quantityNeeded)
        {
            // Get available batches sorted by ExpiryDate ASC
            // Allocate đủ quantity
            // Create PO nếu thiếu
        }
    }
}
```

## 4.3 11 Engines Detail

| # | Engine | Input | Output | Formula |
|---|--------|-------|--------|---------|
| 1 | EnvironmentGenerator | Seed, Biomass | DO, pH, H2S, NH3, Temp | DO = base - effect + random |
| 2 | MortalityEngine | FishCount, Env | DeadCount | base_rate + stress_adj |
| 3 | GrowthEngine | BaseBW, Stress | ActualGrowth, TLBQ | base - penalty |
| 4 | FeedPlanner | Biomass, TLBQ | DailyFeed | biomass × baseBW% |
| 5 | ChemicalEngine | Schedule, Condition | ChemicalUsage | scheduled + emergency |
| 6 | WaterOpsEngine | WaterQuality | WaterExchange | calculated per tier |
| 7 | InventoryEngine | Feed/Chemical Need | FEFO Allocation | FIFO by ExpiryDate |
| 8 | CostTracker | Labor, Electricity | DailyCost | labor + power + material |
| 9 | AlertSystem | AllData | AlertList | threshold check |
| 10 | ValidationService | DailyLog | ValidationErrors | constraint check |
| 11 | ReportingEngine | AggregatedData | 8 FSIS Forms | template fill |

---

# 5. DATA ACCESS LAYER (EF CORE)

## 5.1 DbContext

```csharp
namespace AquaSim.Data
{
    public class AquaSimDbContext : DbContext
    {
        // Master Data
        public DbSet<Farm> Farms { get; set; }
        public DbSet<Pond> Ponds { get; set; }
        public DbSet<Warehouse> Warehouses { get; set; }
        public DbSet<Feed> Feeds { get; set; }
        public DbSet<Chemical> Chemicals { get; set; }
        public DbSet<User> Users { get; set; }
        
        // Cycle Data
        public DbSet<FarmingCycle> FarmingCycles { get; set; }
        public DbSet<DailyLog> DailyLogs { get; set; }
        public DbSet<EnvironmentLog> EnvironmentLogs { get; set; }
        public DbSet<MortalityEvent> MortalityEvents { get; set; }
        public DbSet<GrowthRecord> GrowthRecords { get; set; }
        
        // Inventory
        public DbSet<InventoryLedger> InventoryLedgers { get; set; }
        public DbSet<FEFOAllocation> FEFOAllocations { get; set; }
        public DbSet<PurchaseOrder> PurchaseOrders { get; set; }
        
        // System
        public DbSet<AlertLog> AlertLogs { get; set; }
        public DbSet<AuditTrail> AuditTrails { get; set; }
        public DbSet<SystemEvent> SystemEvents { get; set; }
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Fluent API configurations
            modelBuilder.Entity<FarmingCycle>()
                .HasKey(c => c.CycleID);
            
            modelBuilder.Entity<FarmingCycle>()
                .HasOne(c => c.Pond)
                .WithMany(p => p.FarmingCycles)
                .HasForeignKey(c => c.PondID);
            
            // Indices
            modelBuilder.Entity<DailyLog>()
                .HasIndex(d => new { d.CycleID, d.LogDate })
                .IsUnique()
                .HasName("IX_DailyLog_CycleDate");
            
            modelBuilder.Entity<InventoryLedger>()
                .HasIndex(i => i.ExpiryDate)
                .HasName("IX_Inventory_ExpiryDate");
        }
    }
}
```

## 5.2 Repository Pattern

```csharp
namespace AquaSim.Data.Repositories
{
    public interface IRepository<T> where T : class
    {
        Task<T> GetByIdAsync(int id);
        Task<IEnumerable<T>> GetAllAsync();
        Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate);
        Task AddAsync(T entity);
        Task UpdateAsync(T entity);
        Task DeleteAsync(T entity);
        Task<int> SaveChangesAsync();
    }
    
    public class FarmingCycleRepository : IRepository<FarmingCycle>
    {
        private readonly AquaSimDbContext _context;
        
        public async Task<FarmingCycle> GetByIdAsync(int id)
        {
            return await _context.FarmingCycles
                .Include(c => c.Pond)
                .Include(c => c.DailyLogs)
                .FirstOrDefaultAsync(c => c.CycleID == id);
        }
        
        public async Task<IEnumerable<FarmingCycle>> FindAsync(
            Expression<Func<FarmingCycle, bool>> predicate)
        {
            return await _context.FarmingCycles
                .Where(predicate)
                .Include(c => c.Pond)
                .ToListAsync();
        }
    }
    
    public class DailyLogRepository : IRepository<DailyLog>
    {
        // Similar implementation
    }
    
    public class InventoryRepository : IRepository<InventoryLedger>
    {
        public async Task<List<InventoryLedger>> GetAvailableBatchesAsync(
            int feedId, DateTime asOfDate)
        {
            return await _context.InventoryLedgers
                .Where(i => i.FeedID == feedId 
                    && i.ExpiryDate >= asOfDate
                    && i.RemainingQty > 0)
                .OrderBy(i => i.ExpiryDate)
                .ToListAsync();
        }
    }
}
```

## 5.3 Stored Procedures

```sql
-- Generate Daily Logs for entire cycle
CREATE PROCEDURE sp_GenerateDailyLogs
    @CycleID INT
AS
BEGIN
    DECLARE @StartDate DATETIME = (SELECT StartDate FROM FarmingCycles WHERE CycleID = @CycleID)
    DECLARE @EndDate DATETIME = (SELECT DATEADD(DAY, 89, @StartDate) FROM FarmingCycles WHERE CycleID = @CycleID)
    DECLARE @CurrentDate DATETIME = @StartDate
    
    WHILE @CurrentDate <= @EndDate
    BEGIN
        INSERT INTO DailyLogs (CycleID, LogDate, ...)
        VALUES (@CycleID, @CurrentDate, ...)
        
        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate)
    END
END

-- Calculate FEFO allocation
CREATE PROCEDURE sp_AllocateFEFO
    @FeedID INT,
    @QuantityNeeded DECIMAL(10,2),
    @AllocationDate DATETIME
AS
BEGIN
    WITH RankedBatches AS (
        SELECT 
            InventoryID,
            RemainingQty,
            ROW_NUMBER() OVER (ORDER BY ExpiryDate ASC) AS RN
        FROM InventoryLedger
        WHERE FeedID = @FeedID 
            AND ExpiryDate >= @AllocationDate
            AND RemainingQty > 0
    )
    SELECT TOP 1 InventoryID, RemainingQty
    FROM RankedBatches
    WHERE RN = 1
END
```

---

# 6. DATABASE DESIGN

## 6.1 Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                      MASTER DATA                                    │
├─────────────────────────────────────────────────────────────────────┤

Farms (PK: FarmID)
├─ FarmName
├─ Address
├─ Phone
└─ 1:N → Ponds

Ponds (PK: PondID)
├─ PondCode
├─ FarmID (FK)
├─ SurfaceArea
├─ Volume
└─ 1:N → FarmingCycles

Warehouses (PK: WarehouseID)
├─ WarehouseName
├─ FarmID (FK)
├─ Capacity
└─ 1:N → InventoryLedger

Feeds (PK: FeedID)
├─ FeedName
├─ CompanyName
├─ Protein%
└─ 1:N → InventoryLedger

Chemicals (PK: ChemicalID)
├─ ChemicalName
├─ CompanyName
├─ Type
└─ 1:N → InventoryLedger

Users (PK: UserID)
├─ UserName
├─ Role
└─ 1:N → AuditTrail

┌─────────────────────────────────────────────────────────────────────┐
│                      CYCLE DATA                                     │
├─────────────────────────────────────────────────────────────────────┤

FarmingCycles (PK: CycleID)
├─ CycleCode
├─ PondID (FK)
├─ StartDate
├─ PlannedDays
├─ PreparationDays
├─ Status (PLANNING, ACTIVE, COMPLETED)
└─ 1:N → DailyLogs

DailyLogs (PK: LogID)
├─ CycleID (FK)
├─ LogDate
├─ FishCount
├─ TLBQ
├─ DeadCount
├─ FeedAmount
├─ 1:1 → EnvironmentLog
└─ 1:N → Alerts

EnvironmentLog (PK: EnvironmentID)
├─ LogID (FK)
├─ DO
├─ pH
├─ H2S
├─ NH3
├─ Temperature

MortalityEvent (PK: EventID)
├─ LogID (FK)
├─ DeadCount
├─ DeadWeightKg
├─ Reason

GrowthRecord (PK: RecordID)
├─ LogID (FK)
├─ DailyGrowth
├─ ActualGrowth
├─ AdjustmentFactors (JSON)

┌─────────────────────────────────────────────────────────────────────┐
│                      INVENTORY DATA                                 │
├─────────────────────────────────────────────────────────────────────┤

InventoryLedger (PK: InventoryID)
├─ WarehouseID (FK)
├─ FeedID or ChemicalID (FK)
├─ InputDate
├─ QuantityInput
├─ BatchCode
├─ ExpiryDate
├─ QuantityOutput
├─ RemainingQty
└─ 1:N → FEFOAllocation

FEFOAllocation (PK: AllocationID)
├─ InventoryID (FK)
├─ AllocationDate
├─ AllocatedQuantity
├─ LogID (FK)

PurchaseOrder (PK: POID)
├─ WarehouseID (FK)
├─ FeedID/ChemicalID (FK)
├─ QuantityOrdered
├─ Status

┌─────────────────────────────────────────────────────────────────────┐
│                      SYSTEM DATA                                    │
├─────────────────────────────────────────────────────────────────────┤

AlertLog (PK: AlertID)
├─ CycleID (FK)
├─ AlertDate
├─ AlertLevel (CRITICAL, WARNING, INFO)
├─ AlertMessage
├─ Status (ACTIVE, RESOLVED)

AuditTrail (PK: AuditID)
├─ UserID (FK)
├─ EntityType
├─ EntityID
├─ Action (CREATE, UPDATE, DELETE)
├─ OldValue
├─ NewValue
├─ Timestamp
```

## 6.2 Key Tables Definition

```sql
CREATE TABLE FarmingCycles (
    CycleID INT PRIMARY KEY IDENTITY(1,1),
    CycleCode NVARCHAR(50) UNIQUE NOT NULL,
    PondID INT NOT NULL FOREIGN KEY REFERENCES Ponds(PondID),
    StartDate DATETIME NOT NULL,
    PlannedDays INT DEFAULT 90,
    PreparationDays INT DEFAULT 2,
    StockingDate DATETIME NULL,
    SeedQty INT NOT NULL,
    AvgWeightG DECIMAL(10,4) NOT NULL,
    FCRTarget DECIMAL(5,2) NOT NULL,
    Status NVARCHAR(20) DEFAULT 'PLANNING',  -- PLANNING, ACTIVE, COMPLETED
    LastProcessedDay INT DEFAULT 0,
    Seed NVARCHAR(256) NULL,  -- For deterministic replay
    IsPreparationComplete BIT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE DailyLogs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    CycleID INT NOT NULL FOREIGN KEY REFERENCES FarmingCycles(CycleID),
    LogDate DATE NOT NULL,
    FishCount INT NOT NULL,
    DeadCount INT DEFAULT 0,
    DeadWeightKg DECIMAL(10,2) DEFAULT 0,
    TLBQ DECIMAL(10,4) NOT NULL,
    Biomass DECIMAL(10,2) NOT NULL,
    DO DECIMAL(5,2) NOT NULL,
    pH DECIMAL(5,2) NOT NULL,
    H2S DECIMAL(7,4) DEFAULT 0,
    NH3 DECIMAL(7,4) DEFAULT 0,
    Temperature DECIMAL(5,2) DEFAULT 0,
    FeedAmount DECIMAL(10,2) DEFAULT 0,
    FCR DECIMAL(5,2) NULL,
    DailyCost DECIMAL(15,2) DEFAULT 0,
    CumulativeCost DECIMAL(18,2) DEFAULT 0,
    Notes NVARCHAR(MAX) NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    
    UNIQUE (CycleID, LogDate),
    FOREIGN KEY (CycleID) REFERENCES FarmingCycles(CycleID)
);

CREATE INDEX IX_DailyLog_CycleDate ON DailyLogs(CycleID, LogDate);
CREATE INDEX IX_DailyLog_Date ON DailyLogs(LogDate);

CREATE TABLE InventoryLedger (
    InventoryID INT PRIMARY KEY IDENTITY(1,1),
    WarehouseID INT NOT NULL FOREIGN KEY REFERENCES Warehouses(WarehouseID),
    FeedID INT NULL FOREIGN KEY REFERENCES Feeds(FeedID),
    ChemicalID INT NULL FOREIGN KEY REFERENCES Chemicals(ChemicalID),
    InputDate DATE NOT NULL,
    QuantityInput DECIMAL(10,2) NOT NULL,
    BatchCode NVARCHAR(50) NOT NULL,
    MSL NVARCHAR(50) NULL,
    ExpiryDate DATE NOT NULL,
    QuantityOutput DECIMAL(10,2) DEFAULT 0,
    RemainingQty DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(20) DEFAULT 'ACTIVE',  -- ACTIVE, EXPIRED, DEPLETED
    CreatedDate DATETIME DEFAULT GETDATE(),
    
    CHECK ((FeedID IS NOT NULL AND ChemicalID IS NULL) OR 
           (FeedID IS NULL AND ChemicalID IS NOT NULL))
);

CREATE INDEX IX_Inventory_ExpiryDate ON InventoryLedger(ExpiryDate);
CREATE INDEX IX_Inventory_Warehouse ON InventoryLedger(WarehouseID);
CREATE INDEX IX_Inventory_RemainingQty ON InventoryLedger(RemainingQty);

CREATE TABLE AlertLog (
    AlertID INT PRIMARY KEY IDENTITY(1,1),
    CycleID INT NOT NULL FOREIGN KEY REFERENCES FarmingCycles(CycleID),
    LogID INT NULL FOREIGN KEY REFERENCES DailyLogs(LogID),
    AlertDate DATETIME NOT NULL,
    AlertLevel NVARCHAR(20) NOT NULL,  -- CRITICAL, WARNING, INFO
    AlertCategory NVARCHAR(50) NOT NULL,  -- DO_LOW, FCR_HIGH, etc.
    AlertMessage NVARCHAR(MAX) NOT NULL,
    Status NVARCHAR(20) DEFAULT 'ACTIVE',  -- ACTIVE, RESOLVED, IGNORED
    ResolvedDate DATETIME NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_Alert_CycleDate ON AlertLog(CycleID, AlertDate);
CREATE INDEX IX_Alert_Level ON AlertLog(AlertLevel);

CREATE TABLE AuditTrail (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    EntityType NVARCHAR(50) NOT NULL,  -- FarmingCycle, DailyLog, etc.
    EntityID INT NOT NULL,
    Action NVARCHAR(20) NOT NULL,  -- CREATE, UPDATE, DELETE
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    Description NVARCHAR(MAX) NULL,
    IPAddress NVARCHAR(50) NULL,
    Timestamp DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_Audit_Entity ON AuditTrail(EntityType, EntityID);
CREATE INDEX IX_Audit_User ON AuditTrail(UserID);
CREATE INDEX IX_Audit_Timestamp ON AuditTrail(Timestamp);
```

---

# 7. DATA FLOW & PIPELINES

## 7.1 10-Step Daily Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DAILY PIPELINE EXECUTION                         │
├─────────────────────────────────────────────────────────────────────┤

DAY_START
  ↓
┌─ STEP 1: Weather Anchor ────────────────────────────────────────┐
│ Input: Cycle.Seed (or generate new)                             │
│ Output: Random seed for day                                     │
│ ─────────────────────────────────────────────────────────────── │
│ var seed = input.Cycle.Seed ?? GenerateSeed();                  │
│ random = new Random(seed);                                       │
└──────────────────────────────────────────────────────────────────┘
  ↓
┌─ STEP 2: EnvironmentGenerator ─────────────────────────────────┐
│ Input: Sinh_khối, Tuổi cá, Previous env data                   │
│ Output: DO, pH, H2S, NH3, Temperature                           │
│ ─────────────────────────────────────────────────────────────── │
│ DO(t) = base_DO - (biomass/15000)*0.3 + Random(±0.2)            │
│ pH(t) = 7.2 + Random(±0.2), clamp [6.5-8.5]                     │
│ H2S(t) = (biomass/1000)*0.0008 - exchange - aeration            │
│ NH3(t) = (biomass/100)*0.0015 - (exchange% × 0.002)             │
└──────────────────────────────────────────────────────────────────┘
  ↓
┌─ STEP 3: MortalityEngine ──────────────────────────────────────┐
│ Input: FishCount, Environment data                              │
│ Output: DeadFishCount, DeadFishWeightKg                         │
│ ─────────────────────────────────────────────────────────────── │
│ baseRate = GetBaseRate(age)                                      │
│ stressAdj = Σ(stress factors)                                    │
│ deadCount = FishCount × (baseRate + stressAdj) × Random(0.8-1.2)│
│ Update: FishCount = FishCount - deadCount                       │
└──────────────────────────────────────────────────────────────────┘
  ↓
┌─ STEP 4: GrowthEngine ─────────────────────────────────────────┐
│ Input: TLBQ, Environment, Stress, Age                           │
│ Output: ActualGrowth, NewTLBQ                                   │
│ ─────────────────────────────────────────────────────────────── │
│ baseGrowth = GetBaseGrowth(age)                                  │
│ stressPenalty = Σ(stress factors) × baseGrowth                  │
│ actualGrowth = max(0, baseGrowth - stressPenalty)               │
│ newTLBQ = TLBQ + actualGrowth                                   │
│ newBiomass = FishCount × newTLBQ / 1000                         │
└──────────────────────────────────────────────────────────────────┘
  ↓
┌─ STEP 5: FeedPlanner ──────────────────────────────────────────┐
│ Input: Biomass, TLBQ, Stress, Age                               │
│ Output: DailyFeedAmount, FeedBatchID                            │
│ ─────────────────────────────────────────────────────────────── │
│ baseBW% = GetBaseBW(TLBQ)                                        │
│ feedNeeded = (biomass/1000) × baseBW%/100                       │
│ feedAdjusted = feedNeeded × adjustments                         │
│ finalFeed = CEILING(feedAdjusted / bagSize) × bagSize           │
│ Validate: ±50% change, < 10% biomass                           │
└──────────────────────────────────────────────────────────────────┘
  ↓
┌─ STEP 6: ChemicalEngine ───────────────────────────────────────┐
│ Input: Schedule, Environment, Stress                            │
│ Output: ChemicalType, Dosage, BatchID                           │
│ ─────────────────────────────────────────────────────────────── │
│ if (scheduled || emergency_condition)                           │
│   chemical = SelectChemical(condition)                          │
│   dosage = CalculateDosage(condition)                           │
│   batch = SelectFEFOBatch(chemical)                             │
└──────────────────────────────────────────────────────────────────┘
  ↓
┌─ STEP 7: WaterOpsEngine ───────────────────────────────────────┐
│ Input: DO, pH, H2S, Biomass, Age                                │
│ Output: WaterExchangeAmount, IntakeDischarge                    │
│ ─────────────────────────────────────────────────────────────── │
│ if (problemCondition)                                           │
│   exchangeM3 = CalculateExchange(condition)                     │
│   Update: WaterLevel, intakeM3, dischargeM3                     │
└──────────────────────────────────────────────────────────────────┘
  ↓
┌─ STEP 8: InventoryEngine (FEFO) ───────────────────────────────┐
│ Input: FeedBatchNeeded, ChemicalNeeded                          │
│ Output: FEFO Allocation, PO created if shortage                 │
│ ─────────────────────────────────────────────────────────────── │
│ for each (feed/chemical):                                       │
│   batches = GetBatches(item).OrderBy(ExpiryDate).ThenBy(Qty)    │
│   allocated = AllocateFEFO(batches, needed)                     │
│   if (allocated < needed)                                       │
│     CreatePO(item, shortage)                                    │
└──────────────────────────────────────────────────────────────────┘
  ↓
┌─ STEP 9: SaveLogs ─────────────────────────────────────────────┐
│ Input: All engine outputs                                        │
│ Output: DailyLog saved, AuditTrail created                      │
│ ─────────────────────────────────────────────────────────────── │
│ dailyLog = CreateDailyLog(...)  // Aggregate all data           │
│ context.DailyLogs.Add(dailyLog)                                 │
│ context.AuditTrails.Add(...)   // Auto-audit                    │
│ context.SaveChanges()                                            │
└──────────────────────────────────────────────────────────────────┘
  ↓
┌─ STEP 10: AlertSystem ─────────────────────────────────────────┐
│ Input: All dailyLog data                                         │
│ Output: AlertLog entries if thresholds exceeded                 │
│ ─────────────────────────────────────────────────────────────── │
│ if (DO < 2.5) Alert(CRITICAL, "DO Low")                         │
│ if (FCR > 3.0) Alert(WARNING, "FCR High")                       │
│ if (mortality% > 5%) Alert(WARNING, "High Mortality")           │
│ ... (20+ alert conditions)                                      │
└──────────────────────────────────────────────────────────────────┘
  ↓
DAY_END: Return DailyPipelineResult
```

## 7.2 Data Transformation Flow

```
User Input (Form)
  ├─ CycleName, PondID, SeedQty, TLBQ
  ├─ Validate input (NotEmpty, Range, etc.)
  └─ Create FarmingCycle entity
       ↓
       Service Layer (CycleManagementService)
       ├─ Auto-set PreparationDays = 2
       ├─ Auto-set StockingDate = StartDate + 2
       ├─ Auto-set Seed (for deterministic)
       └─ Save to DB
            ↓
            Generate 92 Days Loop
            ├─ Day 1-2: Preparation phase
            │  ├─ Run simplified pipeline (env + chemical only)
            │  └─ Create DailyLog with IsPreparationDay = true
            │
            └─ Day 3-92: Normal farming
               ├─ Call DailyPipelineService (10 steps)
               ├─ Pass Cycle object to detect phase
               ├─ Create comprehensive DailyLog
               └─ Generate Alerts if needed
                    ↓
                    Aggregate 92 DailyLogs
                    ├─ Calculate Cycle Statistics
                    │  ├─ Total Mortality %
                    │  ├─ Final FCR
                    │  ├─ Survival %
                    │  ├─ Total Cost
                    │  └─ Revenue
                    │
                    └─ Generate 8 FSIS Forms
                       ├─ P301-F01 (Nhật ký nuôi)
                       ├─ P301-F06 (Biên bản giao TA)
                       ├─ P301-F07 (Sổ TA)
                       ├─ P303-F03 (Phiếu giao HC)
                       ├─ P303-F04 (Sổ HC)
                       ├─ P303-F06 (Phiếu SP)
                       ├─ P303-F07 (Sức khỏe)
                       └─ P305-F37 (Chất thải)
```

---

# 8. COMPONENT INTERACTIONS

## 8.1 Dependency Injection Setup

```csharp
public static class ServiceRegistration
{
    public static void RegisterServices(IServiceCollection services)
    {
        // Repositories
        services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
        services.AddScoped<IFarmingCycleRepository, FarmingCycleRepository>();
        services.AddScoped<IDailyLogRepository, DailyLogRepository>();
        services.AddScoped<IInventoryRepository, InventoryRepository>();
        
        // Engines
        services.AddScoped<IEnvironmentGenerator, EnvironmentGenerator>();
        services.AddScoped<IMortalityEngine, MortalityEngine>();
        services.AddScoped<IGrowthEngine, GrowthEngine>();
        services.AddScoped<IFeedPlanner, FeedPlanner>();
        services.AddScoped<IChemicalEngine, ChemicalEngine>();
        services.AddScoped<IWaterOpsEngine, WaterOpsEngine>();
        services.AddScoped<IInventoryEngine, InventoryEngine>();
        services.AddScoped<ICostTracker, CostTracker>();
        services.AddScoped<IAlertSystem, AlertSystem>();
        services.AddScoped<IValidationService, ValidationService>();
        services.AddScoped<IReportingEngine, ReportingEngine>();
        
        // Services
        services.AddScoped<IDailyPipelineService, DailyPipelineService>();
        services.AddScoped<ICycleManagementService, CycleManagementService>();
        services.AddScoped<IInventoryService, InventoryService>();
        services.AddScoped<IReportService, ReportService>();
        
        // Utilities
        services.AddScoped<IRandomService, RandomService>();
        services.AddScoped<ILogger, Logger>();
        
        // DbContext
        services.AddDbContext<AquaSimDbContext>(options =>
            options.UseSqlServer("connection-string"));
    }
}
```

## 8.2 Component Call Chain

```
User Form
  ↓ (Button Click: "Generate 90 Days")
  ↓
CycleBatchDeclarationForm.OnGenerateClicked()
  ├─ Validate input
  └─ Call CycleManagementService.GenerateCycleDaysAsync()
       ↓
       CycleManagementService
       ├─ Fetch FarmingCycle from DB
       ├─ Loop: for day = 1 to 92
       │  └─ Create DailyPipelineInput
       │     └─ Call DailyPipelineService.ExecuteDailyPipelineAsync()
       │        ↓
       │        DailyPipelineService (Orchestrator)
       │        ├─ STEP 1: Weather Anchor
       │        ├─ STEP 2: EnvironmentGenerator.ExecuteAsync()
       │        │           ├─ Calculate DO, pH, H2S, NH3
       │        │           └─ Return EnvironmentOutput
       │        │
       │        ├─ STEP 3: MortalityEngine.ExecuteAsync()
       │        │           ├─ Input: FishCount, DO, pH, H2S, NH3
       │        │           └─ Return MortalityOutput
       │        │
       │        ├─ STEP 4: GrowthEngine.ExecuteAsync()
       │        │           ├─ Input: TLBQ, Stress
       │        │           └─ Return GrowthOutput
       │        │
       │        ├─ STEP 5: FeedPlanner.ExecuteAsync()
       │        │           └─ Return FeedOutput
       │        │
       │        ├─ STEP 6-8: Chemical, Water, Inventory Engines
       │        │
       │        ├─ STEP 9: SaveLogs()
       │        │           ├─ IDailyLogRepository.AddAsync()
       │        │           ├─ AuditTrail auto-created
       │        │           └─ SaveChanges()
       │        │
       │        └─ STEP 10: AlertSystem.CheckAlertsAsync()
       │                    ├─ Check 20+ alert conditions
       │                    └─ IAlertRepository.AddAsync()
       │
       ├─ Calculate Cycle Stats (sp_CalculateCycleStats)
       ├─ Generate 8 FSIS Forms
       └─ Return DailyPipelineResult
           ↓
       UI: Show summary, save to file, display alerts
```

---

# 9. DEPLOYMENT ARCHITECTURE

## 9.1 Deployment Options

```
Option 1: Single Machine Deployment
┌──────────────────────────────────┐
│    Windows Client Machine        │
├──────────────────────────────────┤
│ Windows Forms App                │
│  (AquaSim.UI.exe)                │
│                                  │
│ .NET 9 Runtime                   │
│ SQL Server ODAC Client           │
└──────────────────────────────────┘
  ↓ (TCP/IP)
┌──────────────────────────────────┐
│    SQL Server 2019+              │
│    (Database Server)             │
└──────────────────────────────────┘

Option 2: LAN Deployment (Multi-user)
┌──────────────────────┐
│  Client Machine 1    │
│  (Windows Forms)     │
└──────────────────────┘
         ↓
┌──────────────────────────────────┐
│    Application Server            │
│  (ASP.NET Core WebAPI)           │
│  - DailyPipelineService          │
│  - CycleManagementService        │
│  - InventoryService              │
└──────────────────────────────────┘
  ↓ (TCP/IP)
┌──────────────────────────────────┐
│    SQL Server 2019+              │
│    (Database Server)             │
└──────────────────────────────────┘

Option 3: Cloud Deployment
┌──────────────────────────────────┐
│  Client (Windows Forms or Web)   │
└──────────────────────────────────┘
  ↓ (HTTPS)
┌──────────────────────────────────┐
│  Azure App Service (API)         │
│  .NET 9 Application              │
└──────────────────────────────────┘
  ↓ (TCP/IP)
┌──────────────────────────────────┐
│  Azure SQL Database              │
│  (Managed SQL Server)            │
└──────────────────────────────────┘
```

## 9.2 Scalability Strategy

| Layer | Current | Scalable To | Strategy |
|-------|---------|-------------|----------|
| **Database** | 1 DB (SQL Server) | Multiple sharded DBs | Partition by Farm/Year |
| **Application** | 1 process | Load balanced servers | Stateless APIs on multiple servers |
| **Concurrent Users** | 50 | 500+ | Connection pooling, async I/O |
| **Daily Cycles** | 1,000 | 10,000+ | Batch processing, background jobs |

---

# 10. TECHNOLOGY STACK

## 10.1 Frontend

```
Technology         Version     Purpose
─────────────────────────────────────────────────────
Windows Forms      .NET 9.0    UI for data entry
DevExpress         22.x        Advanced grids, charts
ClosedXML           1.x        Excel export
iText7              7.x        PDF generation
```

## 10.2 Backend

```
Technology         Version     Purpose
─────────────────────────────────────────────────────
C#                 12.0        Core language
.NET               9.0         Runtime
ASP.NET Core       9.0         API (if needed)
Entity Framework   9.0         ORM
Dapper             2.x         Micro-ORM for SPs
AutoMapper         13.x        Object mapping
FluentValidation   11.x        Input validation
Serilog            4.x         Logging
```

## 10.3 Database

```
Technology         Version     Purpose
─────────────────────────────────────────────────────
SQL Server         2019+       Database engine
T-SQL              2019+       Stored procedures
SSMS               19.x        Database management
Azure SQL (opt)    Latest      Cloud deployment
```

## 10.4 DevOps

```
Technology         Version     Purpose
─────────────────────────────────────────────────────
Git                Latest      Version control
GitHub/Azure Dev   Latest      Repository
SQL Server Mgt     Latest      Backup/restore
Visual Studio      2022+       Development IDE
Rider              2024.x      Alternative IDE (JetBrains)
```

---

# IMPLEMENTATION ROADMAP

## Phase 1: Core Engine Implementation (Week 1-4)
- [ ] Setup project structure
- [ ] Implement 11 Engines (DO, Growth, Mortality, Feed, etc.)
- [ ] Unit tests for each engine
- [ ] Formula validation

## Phase 2: Database & DAL (Week 5-6)
- [ ] EF Core DbContext setup
- [ ] Create 25+ entities
- [ ] Repositories implementation
- [ ] Stored procedures

## Phase 3: Services & Business Logic (Week 7-8)
- [ ] DailyPipelineService (10-step orchestrator)
- [ ] CycleManagementService
- [ ] InventoryService (FEFO)
- [ ] AlertingService

## Phase 4: UI Implementation (Week 9-10)
- [ ] Master data forms
- [ ] Cycle management forms
- [ ] Inventory forms
- [ ] Reporting forms

## Phase 5: Testing & Deployment (Week 11-14)
- [ ] UAT with real data
- [ ] Performance testing
- [ ] Security audit
- [ ] Production deployment

---

**Status**: ✅ ARCHITECTURE APPROVED FOR DEVELOPMENT  
**Last Updated**: 15/11/2025  
**Reviewed By**: Technical Lead  
© 2025 All Rights Reserved# KIẾN TRÚC HỆ THỐNG QUẢN LÝ TRANG TRẠI NUÔI THỦY SẢN - AQUASIM (PHARE2)

**Dự án**: AQUASIM - Hệ thống Quản lý Trang trại Nuôi Thủy sản Tự động
**Phiên bản**: Final 4.0 (VHC Consolidated)
**Ngày tạo**: 15/11/2025
**Trạng thái**: APPROVED
**Cơ sở dữ liệu**: aquasim_VHC (SQL Server 2019+)
**Server**: 172.17.254.222:1433

---

## MỤC LỤC

1. [TỔNG QUAN HỆ THỐNG](#1-tổng-quan-hệ-thống)
2. [KIẾN TRÚC TỔNG THỂ](#2-kiến-trúc-tổng-thể)
3. [CÔNG NGHỆ SỬ DỤNG](#3-công-nghệ-sử-dụng)
4. [CẤU TRÚC DỮ LIỆU](#4-cấu-trúc-dữ-liệu)
5. [CHỨC NĂNG CHÍNH](#5-chức-năng-chính)
6. [BẢO MẬT VÀ PHÂN QUYỀN](#6-bảo-mật-và-phân-quyền)
7. [TRIỂN KHAI](#7-triển-khai)

---

## 1. TỔNG QUAN HỆ THỐNG

### 1.1 Mô tả Hệ thống

**AquaSim** là hệ thống quản lý trang trại nuôi thủy sản toàn diện, được thiết kế để tự động hóa và chuẩn hóa quy trình nuôi trồng thủy sản theo tiêu chuẩn FSIS (Food Safety and Inspection Service) và các chứng nhận quốc tế (ASC, BAP, GAA).

Hệ thống thay thế hoàn toàn quy trình quản lý thủ công bằng Excel, tự động sinh dữ liệu cho toàn bộ chu kỳ nuôi 90 ngày từ một form nhập liệu duy nhất, đảm bảo tính nhất quán và khả năng truy xuất nguồn gốc.

### 1.2 Mục đích và Phạm vi

#### Mục tiêu Chính

| Mục tiêu | Chi tiết |
|----------|----------|
| **Tự động hóa 100%** | Quy trình sinh dữ liệu toàn chu kỳ nuôi 90 ngày |
| **Thay thế Excel** | Các quy trình theo dõi, báo cáo thủ công |
| **Chuẩn hóa báo cáo** | Xuất 8 biểu mẫu chuẩn FSIS (P301/P303/P304/P305) |
| **Quản lý FEFO** | Kho thức ăn & hóa chất theo First-Expired-First-Out |
| **Deterministic Simulation** | Cùng seed → cùng kết quả (reproducible) |
| **Replay Mode** | Xác minh tính nhất quán và audit trail |

#### Phạm vi Chức năng

1. **Master Data Management (MDM)**
   - Quản lý Farms (Trang trại)
   - Quản lý Ponds (Ao nuôi)
   - Quản lý Warehouses (Kho)
   - Quản lý FeedInventory (Thức ăn)
   - Quản lý ChemicalInventory (Hóa chất)
   - Quản lý Users & Permissions

2. **Operational Management**
   - Fish Stocking (Thả giống)
   - Farming Cycles (Vụ nuôi 90 ngày)
   - Daily Logs (Nhật ký hàng ngày)
   - Health Monitoring (Giám sát sức khỏe)
   - Water Quality Management (Quản lý chất lượng nước)
   - Waste Management (Quản lý chất thải)

3. **Inventory Management**
   - Receipt (Nhập kho) với auto-split theo capacity
   - Issue (Xuất kho) với FEFO algorithm
   - Real-time stock tracking
   - Expiry date alerts

4. **Auto-Generation & Simulation**
   - 11 Simulation Engines
   - Daily Pipeline (10 bước)
   - Deterministic output
   - Manifest & Checksum verification

5. **Reporting & Analytics**
   - Standard Reports
   - 8 FSIS Forms (P301-F01, P301-F06, P301-F07, P303-F03, P303-F04, P303-F06, P303-F07, P304-F04, P305-F37)
   - Export to Excel/PDF/Word
   - Dashboard & Alerts

### 1.3 Các Stakeholders

| Vai trò | Trách nhiệm | Quyền hạn |
|---------|-------------|-----------|
| **Admin** | Quản trị hệ thống, cấu hình toàn bộ | Full access |
| **Manager** | Quản lý trang trại, duyệt báo cáo | CRUD Farms, Ponds, Cycles, Reports |
| **Staff** | Nhập liệu hàng ngày, theo dõi ao nuôi | CRUD Daily Logs, Inventory |
| **Viewer** | Xem báo cáo, dashboard | Read-only |
| **Veterinarian** | Theo dõi sức khỏe, chỉ định thuốc | CRUD Health Monitoring, Chemical Usage |

### 1.4 Vấn đề Hiện tại và Giải pháp

#### Vấn đề

- Excel thủ công → Không đồng bộ, dễ lỗi
- Theo dõi thủ công → Tốn thời gian, sai sót
- Báo cáo không chuẩn → Không đạt tiêu chuẩn FSIS
- Khó truy xuất nguồn gốc
- Không có audit trail

#### Giải pháp AquaSim

- Tự động hóa 100% chu kỳ nuôi
- Sinh dữ liệu thông minh từ 1 form input
- Quản lý FEFO kho thức ăn & hóa chất
- Xuất chuẩn FSIS 8 biểu mẫu
- Deterministic simulation (reproducible)
- Replay mode để xác minh
- Full audit trail cho mọi thao tác

### 1.5 KPIs Chính

| Chỉ số | Target | Hiện tại | Cải thiện |
|--------|--------|---------|----------|
| Thời gian nhập liệu | 1 ngày | 90 ngày | 99% |
| FCR (Feed Conversion Ratio) | < 2.0 | 2.3 | 13% |
| Survival Rate | > 85% | 82% | 3% |
| Báo cáo chuẩn FSIS | 8/8 | 2/8 | 300% |
| Compliance | 100% | 60% | 67% |
| Truy xuất nguồn gốc | 100% | 30% | 233% |

---

## 2. KIẾN TRÚC TỔNG THỂ

### 2.1 Sơ đồ Tổng quan

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│    Windows Forms (.NET 9.0) - MUST USE DESIGNER                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Main Dashboard, Forms, Reports, Settings                │   │
│  │ ⚠️  REQUIREMENT: ALL UI must be created with           │   │
│  │     Windows Forms Designer (.Designer.cs files)         │   │
│  │                                                          │   │
│  │ - frmMainDashboard (KPIs, Alerts)                       │   │
│  │ - frmScenarioEditor (Create cycles)                     │   │
│  │ - frmDailyLogViewer (Review data)                       │   │
│  │ - frmInventoryManager (FEFO tracking)                   │   │
│  │ - frmReportGenerator (8 FSIS forms)                     │   │
│  │ - (3-file structure: .cs, .Designer.cs, .resx)         │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────┬──────────────────────────────────────┘
                           │ Call via Repository/Services
┌──────────────────────────▼──────────────────────────────────────┐
│                 BUSINESS LOGIC LAYER (BLL)                      │
│                     C# .NET 9.0 Services                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           11 SIMULATION ENGINES                         │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │ ➤ EnvironmentGenerator    ➤ MortalityEngine             │   │
│  │ ➤ GrowthEngine            ➤ FeedPlanner                 │   │
│  │ ➤ ChemicalEngine          ➤ WaterOpsEngine             │   │
│  │ ➤ InventoryEngine         ➤ CostTracker                │   │
│  │ ➤ AlertSystem             ➤ ValidationService          │   │
│  │ ➤ ReportingEngine                                       │   │
│  └──────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           CORE SERVICES                                 │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │ ➤ GeneratorService (Điều phối pipeline)                │   │
│  │ ➤ InventoryService (FEFO logic)                        │   │
│  │ ➤ HealthService (Sức khỏe cá)                          │   │
│  │ ➤ ReportingService (Xuất báo cáo)                      │   │
│  │ ➤ AuditService (Ghi chép thay đổi)                     │   │
│  │ ➤ AlertService (Phát sinh cảnh báo)                    │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────┬──────────────────────────────────────┘
                           │ Via Repository Pattern
┌──────────────────────────▼──────────────────────────────────────┐
│                   DATA ACCESS LAYER (DAL)                       │
│          Entity Framework Core 9.0 + Stored Procedures          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Generic Repository<T> + Specific Repositories            │   │
│  │ - IRepository<T> (CRUD chung)                           │   │
│  │ - IDailyLogRepository (Query riêng)                     │   │
│  │ - IFeedLedgerRepository (FEFO queries)                  │   │
│  │ - IAuditRepository (Audit trail)                        │   │
│  └──────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Stored Procedures (Hiệu năng cao)                       │   │
│  │ - sp_GenerateDailyLogs (Pipeline chính)                 │   │
│  │ - sp_AllocateFEFO (Xuất kho FEFO)                       │   │
│  │ - sp_SplitReceiptByCapacity (Chia nhỏ nhập kho)         │   │
│  │ - sp_CalculateCycleStats (Thống kê)                     │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                    SQL SERVER 2019+                             │
│            Database: aquasim_VHC (172.17.254.222)              │
│                    📌 DATABASE-FIRST APPROACH                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ ✅ Bắt buộc: Database tồn tại trước khi tạo models      │   │
│  │ ✅ Bắt buộc: Dùng EF Core Scaffold từ DB thực tế       │   │
│  │ ✅ Bắt buộc: Stored Procedures cho hiệu năng cao       │   │
│  │ ✅ Bắt buộc: Models phải match 100% với schema         │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Các Tầng/Layers Chính

#### 2.2.1 Presentation Layer (UI)

**Công nghệ**: Windows Forms (.NET 9.0)

**Nguyên tắc BẮT BUỘC**:
- Tất cả giao diện PHẢI được tạo qua Visual Studio Designer
- Mỗi form có 3 file: `.cs` (logic), `.Designer.cs` (UI), `.resx` (resources)
- Chỉ sửa UI qua Designer, KHÔNG sửa Designer.cs code
- Tất cả event hook qua Properties panel → Events

**Forms chính**:
- `frmMainDashboard`: KPIs, Alerts, Tổng quan
- `frmScenarioEditor`: Tạo/Chỉnh sửa Farming Cycles
- `frmDailyLogViewer`: Xem/Chỉnh sửa Daily Logs
- `frmInventoryManager`: Quản lý kho FEFO
- `frmReportGenerator`: Xuất 8 FSIS forms
- `frmMasterData`: Quản lý Farms, Ponds, Warehouses
- `frmHealthMonitoring`: Theo dõi sức khỏe cá
- `frmWaterQuality`: Quản lý chất lượng nước

#### 2.2.2 Business Logic Layer (BLL)

**11 Simulation Engines**:

1. **EnvironmentGenerator**: Sinh dữ liệu môi trường (DO, pH, nhiệt độ)
2. **GrowthEngine**: Tính toán tăng trưởng cá (TLBQ, Biomass)
3. **MortalityEngine**: Mô phỏng tỷ lệ chết
4. **FeedPlanner**: Tính toán lượng thức ăn hàng ngày
5. **ChemicalEngine**: Quản lý sử dụng hóa chất
6. **WaterOpsEngine**: Tính toán lượng nước cấp/xả
7. **InventoryEngine**: FEFO allocation cho feed & chemical
8. **CostTracker**: Theo dõi chi phí hàng ngày
9. **AlertSystem**: Phát sinh cảnh báo (DO thấp, FCR cao, etc.)
10. **ValidationService**: Kiểm tra dữ liệu, business rules
11. **ReportingEngine**: Tạo 8 FSIS forms

**Core Services**:
- **GeneratorService**: Điều phối Daily Pipeline (10 bước)
- **InventoryService**: FEFO logic cho nhập/xuất kho
- **HealthService**: Quản lý sức khỏe, bệnh tật
- **ReportingService**: Xuất báo cáo (Excel/PDF/Word)
- **AuditService**: Ghi chép mọi thay đổi
- **AlertService**: Quản lý và gửi cảnh báo

#### 2.2.3 Data Access Layer (DAL)

**Repository Pattern**:
```csharp
// Generic Repository
public interface IRepository<T> where T : class
{
    Task<T> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
}

// Specific Repositories
public interface IDailyLogRepository : IRepository<DailyLog>
{
    Task<IEnumerable<DailyLog>> GetByCycleIdAsync(int cycleId);
    Task<DailyLog> GetByDateAsync(int cycleId, DateTime date);
}

public interface IFeedLedgerRepository : IRepository<FeedLedger>
{
    Task<IEnumerable<FeedLedger>> AllocateFEFO(int warehouseId, int feedId, decimal qtyKg);
    Task<decimal> GetAvailableStock(int warehouseId, int feedId);
}
```

**Stored Procedures**:
- `sp_GenerateDailyLogs`: Pipeline chính cho 1 ngày
- `sp_AllocateFEFO`: Xuất kho theo FEFO
- `sp_SplitReceiptByCapacity`: Chia nhỏ nhập kho
- `sp_CalculateCycleStats`: Thống kê vụ nuôi

#### 2.2.4 Database Layer

**SQL Server 2019+**
- Database: `aquasim_VHC`
- Server: `172.17.254.222:1433`
- User: `mhkpi`
- Approach: **DATABASE-FIRST** (Bắt buộc)

### 2.3 Luồng Dữ liệu

#### Luồng 1: Tạo Farming Cycle mới

```
User Input (frmScenarioEditor)
    ↓
ScenarioInput Table (Save parameters)
    ↓
GeneratorService.CreateCycle()
    ↓
Create FarmingCycle record (Status = PLANNING)
    ↓
Trigger Daily Pipeline (90 days)
    ↓
Generate: DailyLogs, EnvironmentLogs, FeedLedger, ChemicalLedger, etc.
    ↓
Update FarmingCycle (Status = ACTIVE)
    ↓
Display in frmDailyLogViewer
```

#### Luồng 2: Daily Pipeline (Tự động hóa 1 ngày)

```
Input: CycleID, DayNumber, Seed
    ↓
Step 1: EnvironmentGenerator → TempAM, TempPM, DO, pH
    ↓
Step 2: MortalityEngine → DeadCount (random but seeded)
    ↓
Step 3: GrowthEngine → AvgWeightGr, BiomassKg
    ↓
Step 4: FeedPlanner → FeedKg (based on biomass)
    ↓
Step 5: InventoryEngine → Allocate feed FEFO
    ↓
Step 6: ChemicalEngine → (if needed) Chemical usage
    ↓
Step 7: WaterOpsEngine → WaterIntakeM3, WaterDischargeM3
    ↓
Step 8: CostTracker → Calculate daily cost
    ↓
Step 9: AlertSystem → Check thresholds, create alerts
    ↓
Step 10: ValidationService → Verify data consistency
    ↓
Save: DailyLog, EnvironmentLog, FeedLedger, AlertLogs, CostTracking
    ↓
Update: FarmingCycle.LastProcessedDay++
```

#### Luồng 3: FEFO Inventory Allocation

```
Request: WarehouseID, FeedID, QtyKg
    ↓
Query FeedLedger WHERE Direction='I' AND ExpiryDate IS NOT NULL
    ↓
ORDER BY ExpiryDate ASC (earliest first)
    ↓
Loop: Allocate từ lô sớm nhất đến đủ QtyKg
    ↓
Insert FeedLedger (Direction='O', CycleID, QtyKg, BatchCode, ExpiryDate)
    ↓
Alert if ExpiryDate < 30 days
```

---

## 3. CÔNG NGHỆ SỬ DỤNG

### 3.1 Technology Stack

| Component | Technology | Version | Mục đích |
|-----------|-----------|---------|---------|
| **Frontend** | Windows Forms | .NET 9.0 | UI Desktop |
| **Backend** | C# | 13 | Business Logic |
| **Database** | SQL Server | 2019+ | Data Storage |
| **ORM** | Entity Framework Core | 9.0 | Data Access |
| **Logging** | Serilog | 4.3.0 | Audit & Trace |
| **Excel Export** | EPPlus | Latest | XLSX Files |
| **PDF Export** | iText7 | Latest | PDF Reports |
| **Word Export** | DocumentFormat.OpenXml | Latest | DOCX Reports |
| **Testing** | NUnit | Latest | Unit Tests |
| **Authentication** | BCrypt | Latest | Password Hash |
| **DI Container** | Microsoft.Extensions.DependencyInjection | 9.0 | IoC |
| **Configuration** | Microsoft.Extensions.Configuration | 9.0 | Settings |

### 3.2 Frontend Technologies

**Windows Forms (.NET 9.0)**

- **Requirement**: PHẢI sử dụng Designer cho tất cả UI
- **3-File Structure**:
  - `MyForm.cs`: User code (logic, events)
  - `MyForm.Designer.cs`: Auto-generated UI layout
  - `MyForm.resx`: Resources (images, strings)

**Control Naming Convention**:
```csharp
txt{ControlName}      // TextBox: txtFarmCode
lbl{ControlName}      // Label: lblFarmName
btn{ActionName}       // Button: btnSave, btnDelete
cmb{ListName}         // ComboBox: cmbWarehouse
dgv{ListName}         // DataGridView: dgvFarms
chk{OptionName}       // CheckBox: chkIsActive
pnl{SectionName}      // Panel: pnlHeader
```

### 3.3 Backend Technologies

**C# 13 (.NET 9.0)**

- **Design Patterns**:
  - Repository Pattern (Clean Architecture)
  - Dependency Injection (IoC Container)
  - Unit of Work (Transaction Management)
  - Factory Pattern (Object Creation)
  - Strategy Pattern (11 Simulation Engines)
  - Observer Pattern (Event & Alert Handling)
  - Interceptor Pattern (Audit Trail auto-logging)
  - Template Method (Daily Pipeline orchestration)

**Entity Framework Core 9.0**:
```powershell
# Scaffold từ database (DATABASE-FIRST)
dotnet ef dbcontext scaffold \
  "Server=tcp:172.17.254.222,1433;Database=aquasim_VHC;User Id=mhkpi;Password=Try@VhcQAZXCV;Encrypt=false;TrustServerCertificate=true;" \
  Microsoft.EntityFrameworkCore.SqlServer \
  --context AquaSimDbContext \
  --output-dir Models \
  --force \
  --no-pluralize
```

### 3.4 Database Technologies

**SQL Server 2019+**

- **Connection String**:
  ```
  Server=tcp:172.17.254.222,1433;
  Database=aquasim_VHC;
  User Id=mhkpi;
  Password=Try@VhcQAZXCV;
  Encrypt=false;
  TrustServerCertificate=true;
  ```

- **Features**:
  - Stored Procedures (hiệu năng cao)
  - Triggers (Audit Trail tự động)
  - Indexes (Query optimization)
  - Constraints (Data integrity)
  - Views (Reporting)

### 3.5 Infrastructure

**Development Environment**:
- Visual Studio 2022 (17.8+)
- SQL Server Management Studio (SSMS 19+)
- Git for version control

**Production Environment**:
- Windows Server 2019+
- SQL Server 2019 Standard/Enterprise
- IIS (nếu cần web interface sau này)

---

## 4. CẤU TRÚC DỮ LIỆU

### 4.1 Entity Relationship Diagram (ERD)

```
CORE ENTITIES:
├── Farms (1) ──────────────────< (N) Ponds
│   ├── (1) ──────────────────< (N) Warehouses
│   └── (1) ──────────────────< (N) Users (Staff)
│
├── Ponds (1) ──────────────────< (N) FarmingCycles
│   └── (1) ──────────────────< (N) DailyLogs
│
├── FarmingCycles (1) ──────────────────< (N) Operations
│   ├── (1) ──────────────────< (N) EnvironmentLogs
│   ├── (1) ──────────────────< (N) MortalityEvents
│   ├── (1) ──────────────────< (N) GrowthLogs
│   ├── (1) ──────────────────< (N) CostLogs
│   ├── (1) ──────────────────< (N) AlertLogs
│   └── (1) ──────────────────< (N) StatusChanges

INVENTORY ENTITIES:
├── Warehouses (1) ──────────────────< (N) FeedLedger
│   └── (1) ──────────────────< (N) FeedInventory
│
├── Warehouses (1) ──────────────────< (N) ChemicalLedger
│   └── (1) ──────────────────< (N) ChemicalInventory

WORKFLOW & AUDIT:
├── Users (1) ──────────────────< (N) AuditTrail
├── Users (1) ──────────────────< (N) UserResponsibilities
├── Users (1) ──────────────────< (N) Approvals
└── Cycles (1) ──────────────────< (N) ProductSpecifications
```

### 4.2 Các Bảng/Entities Chính

#### GROUP 1: MASTER DATA

**1. Farms** (Trang trại)
```sql
CREATE TABLE Farms (
    FarmID INT PRIMARY KEY IDENTITY(1,1),
    FarmCode NVARCHAR(50) UNIQUE NOT NULL,
    FarmName NVARCHAR(100) NOT NULL,
    ShortName NVARCHAR(50),
    Address NVARCHAR(255),
    Province NVARCHAR(100),
    District NVARCHAR(100),
    Phone NVARCHAR(20),
    Manager NVARCHAR(100),
    ASC BIT DEFAULT 0,           -- ASC Certification
    BAP BIT DEFAULT 0,            -- BAP Certification
    GG BIT DEFAULT 0,             -- GAA Certification
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
```

**2. Ponds** (Ao nuôi)
```sql
CREATE TABLE Ponds (
    PondID INT PRIMARY KEY IDENTITY(1,1),
    PondCode NVARCHAR(50) UNIQUE NOT NULL,
    PondName NVARCHAR(100) NOT NULL,
    FarmID INT FOREIGN KEY REFERENCES Farms(FarmID),
    WarehouseID INT FOREIGN KEY REFERENCES Warehouses(WarehouseID),
    SurfaceAreaM2 DECIMAL(10,2),    -- Diện tích (m²)
    DepthM DECIMAL(5,2),             -- Độ sâu (m)
    CapacityKg DECIMAL(12,2),        -- Dung tích (kg)
    MaxIntakeWaterM3 DECIMAL(10,2),
    MaxDischargeWaterM3 DECIMAL(10,2),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
```

**3. Warehouses** (Kho)
```sql
CREATE TABLE Warehouses (
    WarehouseID INT IDENTITY(1,1) PRIMARY KEY,
    WarehouseCode NVARCHAR(50) UNIQUE NOT NULL,
    WarehouseName NVARCHAR(100) NOT NULL,
    FarmID INT FOREIGN KEY REFERENCES Farms(FarmID),
    Location NVARCHAR(200),
    CapacityKg DECIMAL(12,2) NULL,  -- Sức chứa tối đa
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
```

**4. FeedInventory** (Danh mục thức ăn)
```sql
CREATE TABLE FeedInventory (
    FeedID INT PRIMARY KEY IDENTITY(1,1),
    FeedCode NVARCHAR(50) UNIQUE NOT NULL,
    FeedName NVARCHAR(100) NOT NULL,
    ProteinPercent DECIMAL(5,2),
    FatPercent DECIMAL(5,2),
    FiberPercent DECIMAL(5,2),
    ParticleSizeMm DECIMAL(5,2),
    SizeBand NVARCHAR(50),           -- Small, Medium, Large
    Supplier NVARCHAR(100),
    Price DECIMAL(10,2),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
```

**5. ChemicalInventory** (Danh mục hóa chất)
```sql
CREATE TABLE ChemicalInventory (
    ChemicalID INT PRIMARY KEY IDENTITY(1,1),
    ChemicalCode NVARCHAR(50) UNIQUE NOT NULL,
    ChemicalName NVARCHAR(100) NOT NULL,
    ChemicalType NVARCHAR(50),       -- PROBIOTIC, VITAMIN, ANTIBIOTIC, pH_ADJUSTER, SALT
    Purpose NVARCHAR(200),
    DosageUnit NVARCHAR(50),         -- mg/L, kg, etc.
    Supplier NVARCHAR(100),
    Price DECIMAL(10,2),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
```

**6. Users** (Người dùng)
```sql
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Email NVARCHAR(100),
    PasswordHash NVARCHAR(MAX) NOT NULL,  -- bcrypt
    Role NVARCHAR(50),                    -- Admin, Manager, Staff, Viewer
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    LastLogin DATETIME NULL
);
```

#### GROUP 2: FARMING CYCLE & DAILY OPERATIONS

**7. FarmingCycles** (Vụ nuôi)
```sql
CREATE TABLE FarmingCycles (
    CycleID INT IDENTITY(1,1) PRIMARY KEY,
    PondID INT NOT NULL REFERENCES Ponds(PondID),
    CycleName NVARCHAR(100),
    StartDate DATETIME NOT NULL,
    EndDate DATETIME,
    Species NVARCHAR(50), -- 'CATFISH', 'TILAPIA', 'SHRIMP'

    -- Initial state
    InitialFishCount INT,
    InitialAvgWeightGr FLOAT,
    InitialBiomasKg INT,

    -- Current state
    FishRemain INT,
    AvgWeightGr FLOAT,
    BiomasKg INT,

    -- Simulation control
    Seed INT,
    Status NVARCHAR(20) DEFAULT 'PLANNING'
        CHECK (Status IN ('PLANNING', 'ACTIVE', 'MEDICATING', 'HARVESTING', 'CLOSED', 'CANCELLED')),
    LastProcessedDay INT DEFAULT 0,
    IsMedicatingToday BIT DEFAULT 0,
    Manifest NVARCHAR(MAX) NULL,        -- JSON: seed, version, checksums

    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
```

**8. DailyLogs** (Nhật ký hàng ngày)
```sql
CREATE TABLE DailyLogs (
    LogID BIGINT PRIMARY KEY IDENTITY(1,1),
    CycleID INT NOT NULL REFERENCES FarmingCycles(CycleID),
    LogDate DATE NOT NULL,
    DayNumber INT NOT NULL,

    -- Environment
    TempAM FLOAT,
    TempPM FLOAT,
    TempMean FLOAT,
    DOmin FLOAT,
    DOmax FLOAT,
    DOavg FLOAT,
    pH_AM FLOAT,
    pH_PM FLOAT,
    H2S FLOAT,
    NH3 FLOAT,
    Alkalinity DECIMAL(8,2),

    -- Biology
    FishCount INT,
    AvgWeightGr FLOAT,
    BiomassKg FLOAT,
    DeadCount INT,
    SurvivalRate FLOAT,
    DailyGrowthG DECIMAL(8,2),

    -- Feed
    FeedKg FLOAT,
    FeedType NVARCHAR(50),
    FCR FLOAT,

    -- Water
    WaterIntakeM3 FLOAT,
    WaterDischargeM3 FLOAT,

    -- Chemical
    ChemicalUsed NVARCHAR(200),
    ChemicalCost DECIMAL(10,2),

    Notes NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_DailyLog_CycleDay UNIQUE (CycleID, LogDate)
);
```

**9. HealthMonitoring** (Giám sát sức khỏe)
```sql
CREATE TABLE HealthMonitoring (
    HealthID INT PRIMARY KEY IDENTITY(1,1),
    PondID INT NOT NULL REFERENCES Ponds(PondID),
    CycleID INT REFERENCES FarmingCycles(CycleID),
    InspectionDate DATE NOT NULL,
    AvgWeightG DECIMAL(8,2),
    Parasites NVARCHAR(500),
    ClinicalSigns NVARCHAR(500),
    Treatment NVARCHAR(500),
    VeterinarianID INT REFERENCES Users(UserID),
    Notes NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
```

**10. WaterManagement** (Quản lý nước)
```sql
CREATE TABLE WaterManagement (
    WaterID INT PRIMARY KEY IDENTITY(1,1),
    PondID INT NOT NULL REFERENCES Ponds(PondID),
    CycleID INT REFERENCES FarmingCycles(CycleID),
    InspectionDate DATE NOT NULL,
    IntakeVolumeM3 DECIMAL(12,2),     -- Lượng nước cấp
    OutletVolumeM3 DECIMAL(12,2),     -- Lượng nước xả
    DOmg DECIMAL(5,2),
    pH DECIMAL(4,2),
    Smell NVARCHAR(50),               -- No, Slight, Strong
    Conclusion NVARCHAR(50),          -- Pass, Fail
    Notes NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
```

**11. WasteManagement** (Quản lý chất thải)
```sql
CREATE TABLE WasteManagement (
    WasteID INT PRIMARY KEY IDENTITY(1,1),
    PondID INT REFERENCES Ponds(PondID),
    CycleID INT REFERENCES FarmingCycles(CycleID),
    WasteDate DATE NOT NULL,
    WasteType NVARCHAR(50),           -- Dead_Fish, Feed_Bag, Chemical_Bag, Other
    QuantityKg DECIMAL(12,2),
    Disposal NVARCHAR(100),           -- Burial, Incineration, Compost, Other
    DeliveredBy INT REFERENCES Users(UserID),
    ReceivedBy INT REFERENCES Users(UserID),
    DeliveredAt DATETIME,
    ReceivedAt DATETIME,
    Notes NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
```

#### GROUP 3: INVENTORY LEDGERS

**12. FeedLedger** (Sổ kho thức ăn)
```sql
CREATE TABLE FeedLedger (
    LedgerID BIGINT IDENTITY(1,1) PRIMARY KEY,
    WarehouseID INT NOT NULL REFERENCES Warehouses(WarehouseID),
    FeedID INT NOT NULL REFERENCES FeedInventory(FeedID),
    TxnDate DATE NOT NULL,
    Direction CHAR(1) NOT NULL,       -- I = Nhập, O = Xuất
    QtyKg DECIMAL(12,3) NOT NULL,
    BatchCode NVARCHAR(50),           -- Mã số lô
    ExpiryDate DATE,                  -- Hạn sử dụng
    CycleID INT REFERENCES FarmingCycles(CycleID),
    Notes NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT CK_FeedLedger_Direction CHECK (Direction IN ('I', 'O')),
    CONSTRAINT CK_FeedLedger_Qty CHECK (QtyKg > 0)
);
```

**13. ChemicalLedger** (Sổ kho hóa chất)
```sql
CREATE TABLE ChemicalLedger (
    LedgerID BIGINT IDENTITY(1,1) PRIMARY KEY,
    WarehouseID INT NOT NULL REFERENCES Warehouses(WarehouseID),
    ChemicalID INT NOT NULL REFERENCES ChemicalInventory(ChemicalID),
    TxnDate DATE NOT NULL,
    Direction CHAR(1) NOT NULL,       -- I = Nhập, O = Xuất
    Qty DECIMAL(12,3) NOT NULL,
    BatchCode NVARCHAR(50),
    ExpiryDate DATE,
    CycleID INT REFERENCES FarmingCycles(CycleID),
    ApprovalStatus NVARCHAR(20) DEFAULT 'Pending',  -- Pending, Approved, Rejected
    ApprovedBy INT REFERENCES Users(UserID),
    ApprovedAt DATETIME,
    RejectionReason NVARCHAR(500),
    Notes NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT CK_ChemicalLedger_Direction CHECK (Direction IN ('I', 'O')),
    CONSTRAINT CK_ChemicalLedger_Qty CHECK (Qty > 0)
);
```

#### GROUP 4: ALERTS & AUDIT

**14. AlertLogs** (Nhật ký cảnh báo)
```sql
CREATE TABLE AlertLogs (
    AlertID BIGINT PRIMARY KEY IDENTITY(1,1),
    CycleID INT REFERENCES FarmingCycles(CycleID),
    AlertDate DATETIME DEFAULT GETDATE(),
    DayNo INT,
    AlertLevel NVARCHAR(20) CHECK (AlertLevel IN ('INFO', 'WARNING', 'CRITICAL')),
    AlertCategory NVARCHAR(50), -- WATER_QUALITY, HEALTH, INVENTORY, COST, GROWTH
    AlertMessage NVARCHAR(1000) NOT NULL,
    TriggerValue DECIMAL(10,4),
    ThresholdValue DECIMAL(10,4),

    -- Resolution
    Status NVARCHAR(20) DEFAULT 'OPEN' CHECK (Status IN ('OPEN', 'ACKNOWLEDGED', 'RESOLVED', 'IGNORED')),
    ResolvedAt DATETIME NULL,
    ResolvedBy INT NULL REFERENCES Users(UserID),
    Resolution NVARCHAR(1000),

    CreatedAt DATETIME DEFAULT GETDATE()
);
```

**15. AuditTrail** (Audit Trail)
```sql
CREATE TABLE AuditTrail (
    AuditID BIGINT PRIMARY KEY IDENTITY(1,1),
    TableName NVARCHAR(100) NOT NULL,
    RecordID INT,
    Action NVARCHAR(20) CHECK (Action IN ('INSERT', 'UPDATE', 'DELETE')),
    OldValues NVARCHAR(MAX),          -- JSON format
    NewValues NVARCHAR(MAX),          -- JSON format
    ChangedFields NVARCHAR(1000),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    Username NVARCHAR(100),
    IPAddress NVARCHAR(50),
    MachineName NVARCHAR(100),
    ActionDate DATETIME DEFAULT GETDATE()
);
```

### 4.3 Relationships

**Quan hệ chính**:
1. `Farms` 1-N `Ponds` (Một trang trại có nhiều ao)
2. `Farms` 1-N `Warehouses` (Một trang trại có nhiều kho)
3. `Ponds` 1-N `FarmingCycles` (Một ao có nhiều vụ nuôi)
4. `FarmingCycles` 1-N `DailyLogs` (Một vụ nuôi có nhiều nhật ký hàng ngày)
5. `Warehouses` 1-N `FeedLedger` (Một kho có nhiều giao dịch thức ăn)
6. `Warehouses` 1-N `ChemicalLedger` (Một kho có nhiều giao dịch hóa chất)
7. `FeedInventory` 1-N `FeedLedger` (Một loại thức ăn có nhiều giao dịch)
8. `ChemicalInventory` 1-N `ChemicalLedger` (Một loại hóa chất có nhiều giao dịch)
9. `FarmingCycles` 1-N `AlertLogs` (Một vụ nuôi có nhiều cảnh báo)
10. `Users` 1-N `AuditTrail` (Một user có nhiều audit logs)

### 4.4 Key Fields

**Primary Keys**:
- Tất cả bảng đều có IDENTITY(1,1) PRIMARY KEY
- Sử dụng INT cho master data, BIGINT cho transactional data

**Foreign Keys**:
- Tất cả quan hệ đều có FOREIGN KEY constraints
- ON DELETE CASCADE hoặc NO ACTION tùy business logic

**Unique Constraints**:
- `Farms.FarmCode`
- `Ponds.PondCode`
- `Warehouses.WarehouseCode`
- `FeedInventory.FeedCode`
- `ChemicalInventory.ChemicalCode`
- `Users.Username`
- `DailyLogs (CycleID, LogDate)` - Composite unique

**Indexes**:
- Tất cả Foreign Keys đều có index
- Composite index cho query thường dùng:
  - `IX_DailyLogs_CycleID_Day (CycleID, DayNumber DESC)`
  - `IX_FeedLedger_ExpiryDirection (ExpiryDate ASC, Direction)`
  - `IX_AlertLog_CycleID_Level (CycleID, AlertLevel)`

---

## 5. CHỨC NĂNG CHÍNH

### 5.1 Danh sách Modules

#### Module 1: Master Data Management

**FR-MDM-001: Farm Management**
- CRUD Operations: Thêm, sửa, xóa, xem thông tin trang trại
- Lưu trữ: Tên, mã, địa chỉ, tọa độ, chứng nhận (ASC, BAP, GG)
- Phạm vi: Quản lý vùng/khu vực nuôi
- Cấu hình: Tham số riêng (giới hạn nước cấp/xả, aeration)

**FR-MDM-002: Pond Management**
- CRUD Operations: Thêm, sửa, xóa, xem thông tin ao
- Lưu trữ: Diện tích (m²), độ sâu (m), dung tích (kg), loại ao
- Theo dõi: Ngày chuẩn bị, phương pháp chuẩn bị
- Mực nước: 5 level tùy chỉnh (vét bùn, lưới, nước)

**FR-MDM-003: Warehouse Management**
- CRUD Operations: Thêm, sửa, xóa, xem kho
- Lưu trữ: Tên, mã, sức chứa tối đa (kg)
- Điều kiện: Theo dõi điều kiện lưu kho (nhiệt độ, độ ẩm)
- Real-time: Giám sát mức tồn kho (% capacity)

**FR-MDM-004: Product Management**
- Feed Inventory: Loại thức ăn, protein %, quy cách (40kg/bao, 600kg/túi)
- Chemical Inventory: Hóa chất, loại, nồng độ, quy cách
- Thông tin: Nhà sản xuất, HSD, giá, supplier
- Phân loại: Feed, Chemical, Supplement, Environment

**FR-MDM-005: User & Role Management**
- Tạo/Quản lý: Tài khoản người dùng
- Roles: Admin, Manager, Staff, Viewer, Veterinarian
- Audit Trail: Log mọi thao tác (INSERT, UPDATE, DELETE)
- Phạm vi: Trách nhiệm theo thời gian, ao, trang trại

#### Module 2: Operational Management

**FR-OPS-001: Fish Stocking (Thả giống)**
- Ghi nhận: Nguồn giống, chất lượng giống
- Theo dõi: Mật độ thả (con/m²), số lượng thả
- Thông tin: Tuổi giống, kích cỡ (cm hoặc g/con), loại cá
- Sản lượng: Kỳ vọng theo ao (kg)
- Form: P301-F01 (Nhật ký nuôi - Trang đầu)

**FR-OPS-002: Farming Cycle (Vụ nuôi 90 ngày)**
- Khởi tạo: Với thông số đầu vào (StartDate, SeedQty, FCR, Species, etc.)
- Trạng thái: PLANNING → ACTIVE → MEDICATING → HARVESTING → CLOSED
- Theo dõi: FCR, tỷ lệ chết, growth curve, biomass
- Chi tiết: 90 ngày dữ liệu tự động sinh
- Deterministic: Cùng seed → cùng kết quả

**FR-OPS-003: Daily Logs (Nhật ký hàng ngày)**
- Ghi nhận hàng ngày: Thức ăn (kg), cá chết (con), pH, DO, nhiệt độ
- Sinh khối & TLBQ: Tính toán tự động
- Ghi chú: Sự kiện đặc biệt (bão, mưa lớn, etc.)
- Form: P301-F01 (Nhật ký nuôi)
- Cho phép: Chỉnh sửa thủ công (Thời gian thu hoạch, Sản lượng, TLBQ, FCR)

**FR-OPS-004: Health Monitoring (Giám sát sức khỏe)**
- TLBQ & Bệnh: Ký sinh trùng, dấu hiệu lâm sàng
- Hao hụt: Tỷ lệ hao hụt theo ao (%)
- Điều trị: Ghi nhận thuốc, liều lượng, hiệu quả
- Form: P303-F07 (Phiếu sức khỏe cá nuôi)
- Tổng hợp: Ngày cân mẫu → loại + lượng hóa chất

**FR-OPS-005: Water Management (Quản lý nước)**
- Cấp/Thoát: Lượng nước (m³), nhịp trao đổi
- Giám sát: DO, pH, H2S, NH3, độ kiềm, độ mặn
- Lịch thay: Theo chu kỳ, tự động tính
- Form: P304-F04 (Kết quả theo dõi nước thải)
- Cảnh báo: Vượt giới hạn cấp/xả (theo giấy phép)

**FR-OPS-006: Waste Management (Quản lý chất thải)**
- Loại & Số lượng: Cá chết (kg/ngày), bao bì thức ăn, túi hóa chất
- Xử lý: Phương pháp (Burial, Incineration, Compost)
- Giao nhận: Người giao, người nhận, thời gian
- Form: P305-F37 (Sổ giao nhận chất thải)
- Tổng hợp:
  - Cá chết (trừ ao vượt ngưỡng)
  - Bao bì thức ăn (40kg/bao, 600kg/túi)

#### Module 3: Inventory Management

**FR-INV-001: Receipt (Nhập kho)**
- Ghi nhận: BatchCode (MSL), ExpiryDate (HSD)
- Direction: 'I' (Inbound)
- Auto-split: Nếu vượt capacity kho → tạo nhiều records
- Validation: Cảnh báo nếu nhập trước ngày sản xuất hoặc hết HSD
- HSD thức ăn: Tính từ MSL (ký tự 2-4 từ bên phải theo ngày Julian + 89 ngày)
- Form:
  - P301-F07 (Sổ kho thức ăn)
  - P303-F04 (Sổ kho hóa chất)

**FR-INV-002: Issue (Xuất kho)**
- Algorithm: FEFO (First-Expired-First-Out)
- Direction: 'O' (Outbound)
- Allocation: Từ lô sớm HSD nhất
- Alert: Nếu ExpiryDate < 30 ngày
- Form: Tự động tổng hợp từ Daily Logs

**FR-INV-003: Stock Tracking**
- Real-time: Tồn kho hiện tại (kg)
- Theo dõi: Theo Warehouse, Feed/Chemical, BatchCode
- Alert:
  - Hết HSD
  - Hóa chất lỏng > 90% capacity kho
  - Tồn kho < mức tối thiểu

**FR-INV-004: Transfer (Giao nhận)**
- Thức ăn:
  - Form: P301-F06 (Biên bản giao nhận thức ăn)
  - Thông tin: Ghe vận chuyển, người vận chuyển (từ DS ghe)
  - 48h trước: "Huyện Cao Lãnh - Đồng Tháp"
- Hóa chất:
  - Form: P303-F03 (Biên bản giao nhận hóa chất)
  - Người giao: "Lê Thị Hồng Ngọc"
  - 48h trước: "Thành phố Cao Lãnh - Đồng Tháp"

#### Module 4: Auto-Generation & Simulation

**FR-SIM-001: 11 Simulation Engines**

1. **EnvironmentGenerator**: Sinh dữ liệu môi trường
   - Input: MonthNo, BaseTempC, Seed
   - Output: TempAM, TempPM, DO (min/max/avg), pH (AM/PM), H2S, NH3, Alkalinity
   - Logic: Seasonal variation + random noise (seeded)

2. **GrowthEngine**: Tính toán tăng trưởng
   - Input: CurrentAvgWeightGr, FeedKg, FCR, Temperature, DO
   - Output: NewAvgWeightGr, DailyGrowthG, BiomassKg
   - Formula: Growth curve (Logistic, Gompertz, hoặc linear)

3. **MortalityEngine**: Mô phỏng tỷ lệ chết
   - Input: DayNumber, FishCount, DO, pH, Temperature
   - Output: DeadCount, SurvivalRate
   - Logic: Base mortality + stress factors (random seeded)

4. **FeedPlanner**: Tính toán lượng thức ăn
   - Input: BiomassKg, AvgWeightGr, Temperature
   - Output: FeedKg, FeedType (Small/Medium/Large)
   - Formula: Feeding rate (% biomass) based on weight & temp

5. **ChemicalEngine**: Quản lý hóa chất
   - Input: DO, pH, Disease events
   - Output: ChemicalID, Dosage, Purpose
   - Logic: Rule-based (probiotic, pH adjuster, medication)

6. **WaterOpsEngine**: Tính toán nước cấp/xả
   - Input: DayNumber, BiomassKg, MaxIntake/Discharge
   - Output: WaterIntakeM3, WaterDischargeM3
   - Logic: Exchange schedule (%, frequency)

7. **InventoryEngine**: FEFO allocation
   - Input: WarehouseID, FeedID/ChemicalID, QtyRequired
   - Output: FeedLedger/ChemicalLedger records (Direction='O')
   - Algorithm: ORDER BY ExpiryDate ASC, allocate until fulfilled

8. **CostTracker**: Theo dõi chi phí
   - Input: FeedCost, ChemicalCost, Electricity, Labor
   - Output: TotalDailyCost, CumulativeCost, CostPerKgBiomass
   - Logic: Sum all costs, calculate cumulative

9. **AlertSystem**: Phát sinh cảnh báo
   - Input: All metrics (DO, pH, FCR, Mortality, etc.)
   - Output: AlertLogs (Level, Category, Message)
   - Rules:
     - DO < 3.0 → CRITICAL
     - pH < 6.5 or > 8.5 → WARNING
     - FCR > 2.5 → WARNING
     - Mortality > 5%/day → CRITICAL
     - Density > 37 kg/m² → WARNING
     - Expiry < 30 days → WARNING

10. **ValidationService**: Kiểm tra dữ liệu
    - Input: DailyLog record
    - Output: IsValid, ErrorMessages[]
    - Checks:
      - DO, pH, Temp in valid ranges
      - FishCount >= 0
      - BiomassKg > 0
      - FCR > 0
      - No duplicate (CycleID, LogDate)

11. **ReportingEngine**: Tạo báo cáo
    - Input: CycleID, ReportType
    - Output: Excel/PDF/Word file
    - Forms: 8 FSIS forms (P301/P303/P304/P305)

**FR-SIM-002: Daily Pipeline (10 bước)**

```
FOR each day FROM StartDate TO EndDate (90 days):
    Step 1: EnvironmentGenerator → Environment data
    Step 2: MortalityEngine → DeadCount
    Step 3: GrowthEngine → AvgWeightGr, BiomassKg
    Step 4: FeedPlanner → FeedKg, FeedType
    Step 5: InventoryEngine → Allocate feed (FEFO)
    Step 6: ChemicalEngine → (if needed) Chemical usage
    Step 7: WaterOpsEngine → WaterIntakeM3, WaterDischargeM3
    Step 8: CostTracker → Calculate costs
    Step 9: AlertSystem → Check thresholds
    Step 10: ValidationService → Verify consistency

    SAVE: DailyLog, EnvironmentLog, FeedLedger, ChemicalLedger, AlertLogs, CostTracking
    UPDATE: FarmingCycle.LastProcessedDay++
END FOR
```

**FR-SIM-003: Deterministic Output**
- Seed: Integer (1-999999)
- Reproducibility: Cùng seed + cùng input → cùng output
- Manifest: JSON lưu seed, version, checksums
- Replay: Chạy lại để verify

**FR-SIM-004: Manifest & Checksum**
```json
{
  "seed": 123456,
  "version": "4.0",
  "cycleID": 1001,
  "startDate": "2025-01-01",
  "endDate": "2025-03-31",
  "checksums": {
    "dailyLogs": "SHA256_HASH",
    "feedLedger": "SHA256_HASH",
    "chemicalLedger": "SHA256_HASH"
  }
}
```

#### Module 5: Reporting & Analytics

**FR-RPT-001: Standard Reports**

1. **Dashboard (frmMainDashboard)**
   - KPIs: FCR, Survival Rate, Biomass, Cost/kg
   - Alerts: Danh sách cảnh báo chưa xử lý
   - Charts: Growth curve, Mortality trend, Cost trend

2. **Cycle Summary**
   - Tổng quan vụ nuôi: Thời gian, sản lượng, chi phí
   - So sánh: Target vs Actual
   - Recommendations: Dựa trên KPIs

**FR-RPT-002: 8 FSIS Forms**

1. **P301-F01: Nhật ký nuôi**
   - Trang đầu: Thông tin ao, chuẩn bị ao, thông tin giống
   - Các trang sau: Daily Logs (Environment, Feed, Mortality, etc.)
   - Cho phép: Chỉnh sửa thủ công (Thu hoạch, TLBQ, FCR)

2. **P301-F06: Biên bản giao nhận thức ăn**
   - Tổng hợp từ: P301-F07 (Sổ kho thức ăn)
   - Thông tin: Ngày, loại, lượng, quy cách, MSL, kho
   - Ghe vận chuyển: Từ DS ghe (sheet "Ds ghe vận chuyển thức ăn")
   - 48h trước: "Huyện Cao Lãnh - Đồng Tháp"

3. **P301-F07: Sổ theo dõi thức ăn**
   - Tổng hợp: Lượng thức ăn các ao/ngày về kho
   - Phân biệt: Theo kích cỡ (Small/Medium/Large)
   - Nhập tay: Ngày nhập, lượng, MSL, quy cách
   - HSD: Tính từ MSL (ký tự 2-4 từ phải, ngày Julian + 89)
   - Cảnh báo: Nhập trước ngày SX hoặc hết HSD

4. **P303-F03: Biên bản giao nhận hóa chất**
   - Tổng hợp từ: P303-F04 (Sổ kho hóa chất)
   - Thông tin: Ngày, tên hàng, lượng, quy cách, MSL/HSD, nhà SX
   - Người giao: "Lê Thị Hồng Ngọc"
   - 48h trước: "Thành phố Cao Lãnh - Đồng Tháp"

5. **P303-F04: Sổ theo dõi hóa chất**
   - Tổng hợp: Lượng hóa chất các ao/ngày về kho
   - Phân biệt: Theo loại (Probiotic, Vitamin, etc.)
   - Nhập tay: Ngày nhập, lượng, MSL, HSD
   - Lấy: Nhà SX, quy cách từ "Danh mục hóa chất"
   - Cảnh báo:
     - Hết HSD
     - Hóa chất lỏng > 90% capacity kho

6. **P303-F06: Phiếu chỉ định sản phẩm**
   - Tổng hợp: Ngày sử dụng hóa chất (trừ thuốc trị bệnh, ký sinh)
   - Thông tin: Ngày, Ao, tên SP, đơn vị, lượng, lý do sử dụng

7. **P303-F07: Phiếu sức khỏe cá nuôi**
   - Tổng hợp: Ngày cân mẫu
   - Thông tin: Ngày, ao, số con chết, TLBQ, loại + lượng hóa chất

8. **P304-F04: Kết quả theo dõi nước thải**
   - Lượng nước: Cấp/Thoát (m³)
   - Nhịp trao đổi: Có thể chọn khi bắt đầu PM
   - Cho phép: Thay đổi giới hạn (theo giấy phép)

9. **P305-F37: Sổ giao nhận chất thải**
   - Tổng hợp:
     - Cá chết (kg/ngày) - trừ ao vượt ngưỡng
     - Bao bì thức ăn (40kg/bao, 600kg/túi)
   - Đơn vị: Chọn (bao/túi)

**FR-RPT-003: Export Formats**
- Excel (XLSX): EPPlus library
- PDF: iText7 library
- Word (DOCX): DocumentFormat.OpenXml library

**FR-RPT-004: Additional Reports**
- Báo cáo tốc độ tăng trưởng (Growth rate by day)
- Báo cáo mật độ (Density kg/m² by pond)
- Báo cáo chi phí (Cost breakdown by category)
- Báo cáo FEFO (Inventory turnover, expiry tracking)

---

## 6. BẢO MẬT VÀ PHÂN QUYỀN

### 6.1 Authentication

#### 6.1.1 Password Hashing

**Technology**: BCrypt

```csharp
using BCrypt.Net;

public class AuthService
{
    public string HashPassword(string password)
    {
        return BCrypt.HashPassword(password, BCrypt.GenerateSalt(12));
    }

    public bool VerifyPassword(string password, string hashedPassword)
    {
        return BCrypt.Verify(password, hashedPassword);
    }
}
```

#### 6.1.2 Login Flow

```
User → frmLogin
    ↓
Enter: Username, Password
    ↓
Click "Login"
    ↓
AuthService.Login(username, password)
    ↓
Query: SELECT UserID, PasswordHash, Role FROM Users WHERE Username = @username
    ↓
BCrypt.Verify(password, hashedPassword)
    ↓
IF verified:
    ↓
    Create Session (UserID, Role, LoginTime)
    ↓
    Update: Users.LastLogin = NOW()
    ↓
    Open: frmMainDashboard
    ↓
    Load: Permissions based on Role
ELSE:
    ↓
    Show: "Invalid username or password"
    ↓
    Log: Failed login attempt (AuditTrail)
```

### 6.2 Authorization

#### 6.2.1 Role-Based Access Control (RBAC)

| Role | Permissions |
|------|-------------|
| **Admin** | Full CRUD on all tables, System settings, User management |
| **Manager** | CRUD Farms, Ponds, Cycles, Reports; View Inventory; Approve chemicals |
| **Staff** | CRUD Daily Logs, Inventory (Receipt/Issue); View Reports |
| **Viewer** | Read-only all data; No CRUD |
| **Veterinarian** | CRUD Health Monitoring, Chemical usage; View Cycles |

#### 6.2.2 Permission Matrix

| Feature | Admin | Manager | Staff | Viewer | Veterinarian |
|---------|-------|---------|-------|--------|--------------|
| Farm Management | CRUD | CRUD | R | R | R |
| Pond Management | CRUD | CRUD | R | R | R |
| Warehouse Management | CRUD | CRUD | R | R | R |
| User Management | CRUD | R | - | - | - |
| Farming Cycles | CRUD | CRUD | R | R | R |
| Daily Logs | CRUD | CRUD | CRUD | R | R |
| Health Monitoring | CRUD | R | R | R | CRUD |
| Inventory (Receipt/Issue) | CRUD | R | CRUD | R | R |
| Chemical Approval | CRUD | CRUD | - | - | CRUD |
| Reports | CRUD | CRUD | R | R | R |
| Alerts | CRUD | CRUD | R | R | CRUD |
| Audit Trail | R | R | - | - | - |

**Legend**: CRUD = Create, Read, Update, Delete; R = Read-only; - = No access

### 6.3 Data Security

#### 6.3.1 SQL Injection Prevention

**Sử dụng Parameterized Queries** (EF Core tự động)

```csharp
// BAD (vulnerable to SQL injection)
string sql = $"SELECT * FROM Users WHERE Username = '{username}'";

// GOOD (parameterized)
var user = await _context.Users
    .Where(u => u.Username == username)
    .FirstOrDefaultAsync();
```

### 6.4 Audit Trail

**EF Core Interceptor** tự động log tất cả thay đổi:
- INSERT, UPDATE, DELETE
- User, IP Address, Machine Name
- Old Values vs New Values (JSON)

---

## 7. TRIỂN KHAI

### 7.1 Môi trường

#### 7.1.1 Development Environment

| Component | Specification |
|-----------|--------------|
| **OS** | Windows 10/11 Pro (64-bit) |
| **IDE** | Visual Studio 2022 (17.8+) |
| **Database** | SQL Server 2019 Express/Developer |
| **.NET SDK** | .NET 9.0 SDK |
| **Git** | Git for Windows 2.40+ |
| **SQL Tools** | SSMS 19+ |

**Cài đặt**:
```powershell
# Install .NET 9.0 SDK
winget install Microsoft.DotNet.SDK.9

# Install Visual Studio 2022
winget install Microsoft.VisualStudio.2022.Community

# Install SQL Server 2019 Express
winget install Microsoft.SQLServer.2019.Express

# Install SSMS
winget install Microsoft.SQLServerManagementStudio

# Clone repository
git clone https://github.com/yourorg/aquasim-vhc.git
cd aquasim-vhc

# Restore packages
dotnet restore

# Build solution
dotnet build

# Run application
dotnet run --project AquaSim.UI
```

#### 7.1.2 Production Environment

| Component | Specification |
|-----------|--------------|
| **OS** | Windows Server 2019/2022 Standard |
| **Database** | SQL Server 2019 Standard/Enterprise |
| **RAM** | 16 GB minimum, 32 GB recommended |
| **CPU** | 4 cores minimum, 8 cores recommended |
| **Storage** | 500 GB SSD (Database + Logs + Backups) |
| **Network** | 1 Gbps LAN |

**Connection**:
- Server: `172.17.254.222:1433`
- Database: `aquasim_VHC`
- User: `mhkpi`
- Password: `Try@VhcQAZXCV` (encrypted in config)

### 7.2 Database Deployment

#### 7.2.1 Schema Updates

**Quy trình DATABASE-FIRST**:

1. **Update SQL Server trực tiếp**:
   ```sql
   USE aquasim_VHC;
   GO

   ALTER TABLE Ponds
   ADD MaxDensityKgPerM2 DECIMAL(5,2) NULL;
   GO
   ```

2. **Re-scaffold Models**:
   ```powershell
   dotnet ef dbcontext scaffold \
     "Server=tcp:172.17.254.222,1433;Database=aquasim_VHC;User Id=mhkpi;Password=Try@VhcQAZXCV;Encrypt=false;TrustServerCertificate=true;" \
     Microsoft.EntityFrameworkCore.SqlServer \
     --context AquaSimDbContext \
     --output-dir Models \
     --force \
     --no-pluralize
   ```

### 7.3 Backup & Recovery

**Daily Full Backup**:
```sql
BACKUP DATABASE [aquasim_VHC]
TO DISK = 'D:\Backups\aquasim_VHC_Full_' + CONVERT(VARCHAR(8), GETDATE(), 112) + '.bak'
WITH COMPRESSION, CHECKSUM, STATS = 10;
```

**Retention Policy**:
- Full backups: 30 days
- Transaction log backups: 7 days
- Monthly backup: Keep 1 year

---

## PHỤ LỤC

### A. Glossary (Thuật ngữ)

| Thuật ngữ | Tiếng Việt | Giải thích |
|-----------|-----------|-----------|
| **Farm** | Vùng nuôi/Trang trại | Khu vực địa lý chứa nhiều ao |
| **Pond** | Ao | Đơn vị nuôi riêng lẻ |
| **Cycle** | Vụ nuôi | Từ thả giống đến thu hoạch (90 ngày) |
| **TLBQ** | Trọng lượng bình quân | Average weight (g/con) |
| **Biomass** | Sinh khối | Tổng khối lượng cá/tôm (kg) |
| **FCR** | Hệ số chuyển đổi thức ăn | Feed Conversion Ratio |
| **DO** | Oxy hòa tan | Dissolved Oxygen (mg/L) |
| **FEFO** | First-Expired, First-Out | Xuất theo HSD sớm nhất |
| **MSL** | Mã số lô | Batch Code |
| **HSD** | Hạn sử dụng | Expiry Date |

### B. Database-First Approach

**Lợi ích**:
- Single Source of Truth: Database là nguồn gốc duy nhất
- Dễ maintain khi DB tồn tại trước
- Tránh mismatch: Models luôn đồng bộ với DB
- Support Stored Procedures tốt hơn

---

## TÓM TẮT

**AquaSim VHC** là hệ thống quản lý trang trại nuôi thủy sản toàn diện, được xây dựng trên nền tảng **.NET 9.0 Windows Forms** với **SQL Server 2019+** (Database: `aquasim_VHC`).

**Điểm nổi bật**:
- Tự động hóa 100% chu kỳ nuôi 90 ngày
- Sinh dữ liệu thông minh từ 1 form input (Deterministic)
- Quản lý FEFO kho thức ăn & hóa chất
- Xuất 8 biểu mẫu chuẩn FSIS
- Full audit trail & alert system
- Replay mode để verify tính nhất quán

**Kiến trúc**:
- 3-Tier: Presentation (Windows Forms Designer) → BLL (11 Engines + Services) → DAL (Repository + Stored Procedures) → SQL Server
- Database-First Approach (Bắt buộc)
- RBAC (5 roles: Admin, Manager, Staff, Viewer, Veterinarian)

**Deployment**:
- Server: 172.17.254.222:1433
- Monitoring: SQL Extended Events + Serilog
- Backup: Daily full + Hourly transaction log

---

**Ngày tạo**: 15/11/2025
**Phiên bản**: VHC Final 1.0
**Tác giả**: AquaSim Technical Team
