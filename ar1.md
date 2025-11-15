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
© 2025 All Rights Reserved