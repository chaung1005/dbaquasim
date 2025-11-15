# TÀI LIỆU HOÀN CHỈNH HỆ THỐNG AQUASIM v4.1 - VHC
## Hệ Thống Quản Lý Nuôi Trồng Thủy Sản Toàn Diện

**Ngày cập nhật**: 14/11/2025  
**Phiên bản**: 4.1 - Consolidated Final  
**Tác giả**: AquaSim Technical Team + VHC Development Team  
**Trạng thái**: ✅ APPROVED & IMPLEMENTED  

---

# MỤC LỤC TOÀN BỘ

## PHẦN I: TÀI LIỆU ĐẶC TẢ YÊU CẦU PHẦN MỀM (SRS FINAL)
1. TÓM TẮT ĐIỀU HÀNH (Executive Summary)
2. TỔNG QUAN DỰ ÁN
3. KIẾN TRÚC HỆ THỐNG
4. YÊU CẦU CHỨC NĂNG (FUNCTIONAL REQUIREMENTS)
5. YÊU CẦU PHI CHỨC NĂNG (NON-FUNCTIONAL REQUIREMENTS)
6. MÔ HÌNH DỮ LIỆU & DATABASE
7. CÔNG THỨC & THUẬT TOÁN
8. 11 SIMULATION ENGINES
9. QUY TRÌNH NGHIỆP VỤ
10. 8 FSIS FORMS

## PHẦN II: HƯỚNG DẪN CHUẨN BỊ AO (POND PREPARATION)
11. TỔNG QUAN POND PREPARATION
12. QUY TRÌNH CHUẨN BỊ AO CHUẨN
13. THAY ĐỔI DATABASE SCHEMA
14. THAY ĐỔI MODEL & SERVICES
15. QUY TRÌNH PIPELINE MỚI
16. HÓA CHẤT SỬ DỤNG
17. HƯỚNG DẪN SỬ DỤNG & TESTING

## PHẦN III: HƯỚNG DẪN CẬP NHẬT FORMS
18. TỔNG QUAN CẬP NHẬT FORMS
19. VẤN ĐỀ ĐÃ PHÁT HIỆN
20. CÁC THAY ĐỔI ĐÃ THỰC HIỆN
21. CHI TIẾT CẬP NHẬT FORMS

## PHẦN IV: PHÁT TRIỂN WINDOW FORM QLCLN
22. TỔNG QUAN HỆ THỐNG QLCLN
23. LUỒNG QUY TRÌNH CHÍNH
24. CÁC FORM CHÍNH & CÔNG THỨC
25. DATABASE SCHEMA QLCLN
26. MỐI LIÊN HỆ VỚI AQUASIM

## PHẦN V: MÔ TẢ CHI TIẾT NỘI DUNG QLCLN
27. DANH SÁCH CÁC YÊU CẦU THAO TÁC
28. THÔNG TIN TRANG ĐẦU NHẬT KÝ NUÔI
29. CÁC CỘT DỮ LIỆU HÀNG NGÀY
30. HƯỚNG DẪN GHI NHẬN DỮ LIỆU
31. DỮ LIỆU TỔNG HỢP CUỐI KỲ
32. QUY TẮC MÔI TRƯỜNG AO NUÔI

---

# PHẦN I: TÀI LIỆU ĐẶC TẢ YÊU CẦU PHẦN MỀM (SRS FINAL)

## 1. TÓM TẮT ĐIỀU HÀNH (EXECUTIVE SUMMARY)

### 1.1 Vấn Đề Hiện Tại

**Trước khi có AquaSim:**
- ❌ Excel quản lý, không đồng bộ dữ liệu
- ❌ Thời gian nhập liệu: 90 ngày (1 ngày công = 1 ngày dữ liệu)
- ❌ Tính toán FCR, tỷ lệ sống thủ công, hay sai sót
- ❌ Quản lý kho FIFO không rõ ràng
- ❌ Báo cáo không đạt chuẩn FSIS (2/8 form)
- ❌ Không tracking được tất cả thay đổi (audit trail)

### 1.2 Giải Pháp AquaSim v4.1

**Tự động hóa 100% chu kỳ nuôi 90 ngày:**

1. **Input duy nhất**: Một form nhập dữ liệu gốc (pond, fish count, weight, warehouse)
2. **Daily Pipeline**: 10 bước tự động chạy hàng ngày (Environment, Mortality, Growth, Feed, Chemical, Water, Inventory, Cost, Alert, Validation)
3. **Deterministic Simulation**: Cùng seed = Cùng kết quả (có thể replay để kiểm tra)
4. **Intelligent Inventory**: FEFO algorithm (First-Expired, First-Out) + Auto-split receipts
5. **8 FSIS Forms**: Tự động sinh báo cáo tuân thủ

### 1.3 Kết Quả Cải Thiện

| KPI | Trước | Sau | Cải Thiện |
|---|---|---|---|
| **Thời gian nhập liệu** | 90 ngày | 1 ngày | 99% ↓ |
| **FCR** | 2.3 | 2.0 | 13% ↓ |
| **Tỷ lệ sống** | 82% | 85%+ | 3% ↑ |
| **Form FSIS** | 2/8 | 8/8 | 300% ↑ |
| **Báo cáo tuân thủ** | 25% | 100% | 75% ↑ |

---

## 2. TỔNG QUAN DỰ ÁN

### 2.1 Mục Tiêu Chính

✅ **Tự động hóa 100%** toàn bộ chu kỳ nuôi 90 ngày  
✅ **Tính toán deterministic** - cùng seed = cùng kết quả  
✅ **Quản lý kho thông minh** - FEFO + Auto-split  
✅ **Tuân thủ 100%** các chuẩn FSIS & VietGAP  
✅ **Audit trail đầy đủ** - theo dõi mọi thay đổi  

### 2.2 Phạm Vi

- **Người dùng**: Farm Manager, Aquaculture Specialist, Warehouse Officer
- **Thời gian**: 90 ngày nuôi + 2 ngày chuẩn bị ao (v4.1 mới)
- **Dữ liệu quản lý**: 25+ bảng SQL Server
- **Báo cáo**: 8 FSIS forms + Custom reports

### 2.3 Tech Stack

| Tầng | Công Nghệ |
|---|---|
| **Frontend** | Windows Forms (.NET 9.0 + Visual Studio) |
| **Backend** | C# .NET 9.0 (ASP.NET Core) |
| **Database** | SQL Server 2019+ |
| **ORM** | Entity Framework Core 9.0 |
| **Export** | EPPlus (Excel), iText7 (PDF), OpenXML (Word) |
| **Architecture** | 3-Layer (Presentation, Business Logic, Data Access) |

---

## 3. KIẾN TRÚC HỆ THỐNG

### 3.1 Kiến Trúc 3 Lớp

```
┌─────────────────────────────────────────┐
│   PRESENTATION LAYER                    │
│  (Windows Forms - UI)                   │
├─────────────────────────────────────────┤
│   BUSINESS LOGIC LAYER                  │
│  (11 Simulation Engines + Services)     │
├─────────────────────────────────────────┤
│   DATA ACCESS LAYER                     │
│  (EF Core + Stored Procedures)          │
├─────────────────────────────────────────┤
│   DATABASE LAYER                        │
│  (SQL Server 2019+)                     │
└─────────────────────────────────────────┘
```

### 3.2 Các Simulation Engines

| # | Engine | Chức Năng |
|---|--------|----------|
| 1 | **EnvironmentGenerator** | Tính DO, pH, H2S, NH3, Nhiệt độ |
| 2 | **MortalityEngine** | Tính cá chết dựa trên điều kiện nước |
| 3 | **GrowthEngine** | Tính tăng trọng hàng ngày |
| 4 | **FeedPlanner** | Lập kế hoạch lượng thức ăn |
| 5 | **ChemicalEngine** | Quản lý hóa chất sử dụng |
| 6 | **WaterOpsEngine** | Quản lý thay nước, intake/discharge |
| 7 | **InventoryEngine** | FEFO allocation + Auto-split |
| 8 | **CostTracker** | Theo dõi chi phí hàng ngày |
| 9 | **AlertSystem** | Phát cảnh báo nếu vượt ngưỡng |
| 10 | **ValidationService** | Kiểm tra tính hợp lệ dữ liệu |
| 11 | **ReportingEngine** | Sinh 8 FSIS forms |

---

## 4. YÊU CẦU CHỨC NĂNG (FUNCTIONAL REQUIREMENTS)

### 4.1 Quản Lý Dữ Liệu Gốc (MDM)

**FR-1.1: Quản lý trang trại (Farms)**
- Thêm/sửa/xóa trang trại
- Quản lý thông tin: Tên, địa chỉ, SĐT, quản lý, diện tích
- Lưu audit trail khi thay đổi

**FR-1.2: Quản lý ao nuôi (Ponds)**
- Thêm/sửa/xóa ao
- Quản lý: Tên, diện tích, diện tích mặt nước, độ sâu, volume
- Liên kết với farm

**FR-1.3: Quản lý kho (Warehouses)**
- Tạo kho thức ăn, hóa chất
- Quản lý sức chứa kho
- Liên kết với farm

**FR-1.4: Quản lý thức ăn (Feed)**
- Tạo danh mục thức ăn
- Quản lý: Công ty, độ đạm, kích cỡ, MSL, HSD
- Tính HSD từ ngày Julian

**FR-1.5: Quản lý hóa chất (Chemical)**
- Tạo danh mục hóa chất
- Phân loại: Vôi, EM-F1, Zeolite, Vitamin, Thuốc trị bệnh...
- Quản lý: Công ty, đơn vị, giá

**FR-1.6: Quản lý người dùng (User Management)**
- Tạo tài khoản người dùng
- Phân quyền: Admin, Manager, Doctor, Warehouse Officer
- Audit log tất cả hoạt động

### 4.2 Quản Lý Chu Kỳ Nuôi (Farming Cycle)

**FR-2.1: Tạo chu kỳ nuôi**
- Nhập thông tin: Tên, ao, loại cá, ngày bắt đầu, số cá, TLBQ, FCR mục tiêu
- Tự động tính: PreparationDays (2 ngày), StockingDate, TotalDaysWithPreparation (92)
- Khởi tạo seed cho deterministic simulation

**FR-2.2: Quản lý chu kỳ**
- Xem danh sách chu kỳ (filter: farm, status, date range)
- Xem chi tiết chu kỳ
- Chỉnh sửa thông tin chu kỳ (khi chưa COMPLETED)
- Xóa chu kỳ (chỉ khi status = PLANNING)

**FR-2.3: Chạy daily pipeline**
- Tự động sinh dữ liệu 90 ngày
- Hoặc chạy từng ngày manual
- Validate dữ liệu trước lưu
- Ghi audit trail

**FR-2.4: Kiểm tra chu kỳ**
- Xem 92 ngày dữ liệu daily log
- So sánh actual vs target KPI
- Export báo cáo

### 4.3 Quản Lý Kho (Inventory Management)

**FR-3.1: Nhập kho thức ăn/hóa chất**
- Ghi nhận nhập kho: Ngày, loại, lượng, MSL, HSD
- Tự động tính HSD từ MSL
- Auto-split receipt nếu lượng > sức chứa
- Kiểm tra cảnh báo HSD

**FR-3.2: Xuất kho FEFO**
- Lập kế hoạch xuất kho theo lượng cần
- Tự động sắp xếp theo HSD (sớm nhất trước)
- Cấp phát từng batch cho đủ lượng
- Tạo PurchaseOrder nếu thiếu

**FR-3.3: Theo dõi tồn kho**
- Xem tồn kho real-time (thức ăn + hóa chất)
- Cảnh báo HSD sắp hết (< 30 ngày)
- Cảnh báo sức chứa kho vượt 90%
- Báo cáo tồn kho theo ngày

### 4.4 Tự Động Sinh Dữ Liệu (10-Step Daily Pipeline)

**FR-4.1 đến FR-4.10: 10 bước pipeline**

```
Bước 1: Weather Anchor (Seed initialization)
Bước 2: EnvironmentGenerator (DO, pH, H2S, NH3, Temp)
Bước 3: MortalityEngine (Dead fish calculation)
Bước 4: GrowthEngine (Fish weight increase)
Bước 5: FeedPlanner (Feed amount)
Bước 6: ChemicalEngine (Chemical usage)
Bước 7: WaterOpsEngine (Water exchange)
Bước 8: InventoryEngine (FEFO allocation)
Bước 9: Save Logs (DailyLog + Audit)
Bước 10: AlertSystem (Generate alerts)
```

Mỗi bước lưu:
- Environment Data: DO, pH, H2S, NH3, Temp, Weather
- Mortality Data: DeadFishCount, DeadFishKg, Reason
- Growth Data: DailyGrowthGr, ActualGrowthGr, AdjustmentFactors
- Feed Data: FeedAmountKg, FeedBatchID, HSD
- Chemical Data: ChemicalID, Dosage, Reason
- Water Data: WaterIntake, WaterDischarge, LevelChange
- Inventory Data: InventoryAllocationID, FEFOLog
- Cost Data: LaborCost, ElectricityCost, MaterialCost, TotalCost
- Alert Data: AlertID, AlertLevel, Reason, Action

---

## 5. YÊU CẦU PHI CHỨC NĂNG (NON-FUNCTIONAL REQUIREMENTS)

### 5.1 Performance

| Chỉ tiêu | Target | Ghi chú |
|----------|--------|--------|
| CRUD operations | ≤ 2s | Bao gồm validation |
| Query 10,000 records | ≤ 1s | Với index tối ưu |
| Generate 365 days × 1,000 ponds | < 30s | Parallel processing |
| 50 concurrent users | Uptime ≥ 99% | Load balanced |

### 5.2 Security

| Yêu Cầu | Chi Tiết |
|--------|---------|
| **Password Hashing** | BCrypt (≥ 12 rounds) |
| **Authentication** | Windows Authentication + Custom roles |
| **Authorization** | Role-Based Access Control (RBAC) |
| **Audit Trail** | Ghi lại: UserID, Action, Timestamp, OldValue, NewValue |
| **Session Timeout** | 30 phút inactive |
| **Data Backup** | Daily backup, 7-day retention |

### 5.3 Reliability

| Yêu Cầu | Chi Tiết |
|--------|---------|
| **Uptime** | ≥ 99.5% |
| **Backup** | Daily, full + incremental |
| **Recovery** | Point-in-time recovery 30 ngày |
| **Disaster Recovery** | RTO ≤ 4h, RPO ≤ 1h |
| **Data Integrity** | Transactions, Foreign Keys, Check Constraints |

### 5.4 Scalability

| Yêu Cầu | Chi Tiết |
|--------|---------|
| **Database** | Lên đến 10,000 cycles/year |
| **Concurrent Users** | 50+ users |
| **Storage** | Lên đến 500GB (5 năm data) |
| **Batch Processing** | Generate 1,000 cycles parallel |

---

## 6. MÔ HÌNH DỮ LIỆU & DATABASE

### 6.1 Các Bảng Chính (25+ bảng)

#### Master Data
- **Farms** - Thông tin trang trại
- **Ponds** - Thông tin ao
- **Warehouses** - Thông tin kho
- **Feeds** - Danh mục thức ăn
- **Chemicals** - Danh mục hóa chất
- **Users** - Quản lý người dùng

#### Farming Cycle Data
- **FarmingCycles** - Chu kỳ nuôi
- **DailyLogs** - Nhật ký hàng ngày (90 record/cycle)
- **EnvironmentLogs** - Thông số nước
- **MortalityEvents** - Sự kiện cá chết
- **GrowthRecords** - Dữ liệu tăng trọng
- **CostTracking** - Chi phí hàng ngày

#### Inventory Data
- **InventoryLedger** - Theo dõi thức ăn + hóa chất (unified)
- **FEFOAllocation** - FEFO allocation details
- **ReceiptSplitting** - Auto-split receipts
- **PurchaseOrders** - Đơn hàng tự động

#### System Data
- **AlertLogs** - Lịch sử cảnh báo
- **AuditTrail** - Audit log tất cả thay đổi
- **SystemLogs** - Error logs, batch execution logs

### 6.2 Công Thức Tính Toán Chính

#### Sinh Khối (Biomass)
```sql
Sinh_khối (kg) = (Số_cá × TLBQ) / 1000
```

#### Tăng Trưởng Theo Tuổi
```
0-10 ngày: +0.2 g/ngày → 1.5g → 3.5g
11-30 ngày: +0.5 g/ngày → 3.5g → 13.5g
31-60 ngày: +0.8 g/ngày → 13.5g → 37.5g
61-90 ngày: +0.6 g/ngày → 37.5g → 52.5g
```

#### FCR (Feed Conversion Ratio)
```sql
FCR = Tổng_thức_ăn / Tổng_sinh_khối_tăng
Target: 1.5-2.0 (tốt)
Warning: > 2.5
```

#### FEFO Algorithm
```
1. Lấy batch thức ăn/hóa chất có sẵn
2. Sắp xếp theo ExpiryDate ASC (sớm nhất trước)
3. Allocate lần lượt từng batch
4. Nếu thiếu → Tạo PurchaseOrder
```

---

## 7. CÔNG THỨC & THUẬT TOÁN

### 7.1 Tính Môi Trường

**DO (Dissolved Oxygen)**
```
DO(t) = 5.5 - (Sinh_khối(t) / 1000) × 0.5 + Random(-0.3, 0.3)
Ngưỡng: > 5.0 mg/L (tốt)
Cảnh báo: < 3.5 (CRITICAL)
```

**pH**
```
pH(t) = 7.2 + Random(-0.3, 0.3)
Ngưỡng: 6.5-8.5 (tốt)
```

**H2S (Hydrogen Sulfide)**
```
H2S(t) = (Sinh_khối(t) / 1000) × 0.0005 - Water_Exchange(t) × 0.02
Ngưỡng: < 0.05 mg/L (tốt)
Cảnh báo: > 0.1 (CRITICAL)
```

**NH3 (Ammonia)**
```
NH3(t) = (Sinh_khối(t) / 100) × 0.001 - Water_Exchange(t) × 0.1
Ngưỡng: < 0.2 mg/L (tốt)
Cảnh báo: > 0.3 (CRITICAL)
```

### 7.2 Tính Cá Chết (MortalityEngine)

**Base Mortality Rate theo Tuổi**

| Tuổi | Base Rate | Điều Chỉnh |
|---|---|---|
| 0-10 ngày | 0.1-0.5% | DO × pH × H2S × NH3 × Disease |
| 11-30 ngày | 0.05-0.2% | Tương tự |
| 31-60 ngày | 0.02-0.1% | Tương tự |
| 61-90 ngày | 0.01-0.05% | Tương tự |

**Công Thức**
```
DeadFish(t) = FishCount(t-1) × [
  BaseRate(age) × 
  (1 - DO_Factor) × 
  (1 - pH_Factor) × 
  (1 - H2S_Factor) × 
  (1 - NH3_Factor) × 
  (1 - Disease_Factor)
]
```

### 7.3 Tính Tăng Trọng (GrowthEngine)

**Base Growth theo Tuổi**

| Tuổi | Tăng/ngày | TLBQ Cuối Kỳ |
|---|---|---|
| 0-10 | +0.2g | 1.5 → 3.5g |
| 11-30 | +0.5g | 3.5 → 13.5g |
| 31-60 | +0.8g | 13.5 → 37.5g |
| 61-90 | +0.6g | 37.5 → 52.5g |

**Điều Chỉnh Theo Điều Kiện Nước**
```
ActualGrowth(t) = BaseGrowth × [
  (1 - DO_penalty) ×
  (1 - pH_penalty) ×
  (1 - Temperature_penalty) ×
  (1 - H2S_penalty) ×
  (1 - NH3_penalty) ×
  (1 - Disease_penalty)
]

Penalties:
- DO < 4: × 0.5
- pH ngoài 6.5-8.5: × 0.7
- Temp ngoài 27-29°C: × 0.6-0.8
- H2S > 0.05: × 0.4
- NH3 > 0.2: × 0.5
- Có bệnh: × 0.3-0.6
```

### 7.4 Tính Thức Ăn (FeedPlanner)

**Base Feeding Rate (BW %)**

| Tuổi | BW % |
|---|---|
| 0-10 | 7-10% |
| 11-30 | 4-6% |
| 31-60 | 2.5-3.5% |
| 61-90 | 1.5-2% |

**Công Thức**
```
DailyFeed(kg/day) = (Sinh_khối(t) / 1000) × [
  BaseBW(age) × 
  (1 - DO_adjustment) ×
  (1 - pH_adjustment) ×
  (1 - Chemical_adjustment) ×
  (1 - Disease_adjustment)
]
```

**Validation Feed**
```
IF DailyFeed(t) > DailyFeed(t-1) × 1.5 THEN
  Alert = "Tăng thức ăn > 50%"
  AllowFeed = FALSE
END IF

IF DailyFeed(t) < DailyFeed(t-1) × 0.5 THEN
  Alert = "Giảm thức ăn > 50%"
  AllowFeed = FALSE
END IF
```

---

## 8. 11 SIMULATION ENGINES

### 8.1 Daily Pipeline Flow

```
Day 1 INPUT:
├─ Cycle info (pond, seed qty, avg weight, species)
├─ Environment from previous day
├─ Fish count from previous day
└─ Seed (for deterministic replay)

PROCESS (10 Steps):

Step 1: Weather Anchor
├─ Initialize Random Seed
├─ Set base seed for day
└─ Output: Seed value

Step 2: EnvironmentGenerator
├─ Calculate DO(t)
├─ Calculate pH(t)
├─ Calculate H2S(t)
├─ Calculate NH3(t)
├─ Calculate Temperature
└─ Output: EnvironmentLog

Step 3: MortalityEngine
├─ Get FishCount(t-1)
├─ Calculate DeadFish(t)
├─ Calculate DeadFishWeight(t)
└─ Output: MortalityEvent
└─ Update FishCount(t) = FishCount(t-1) - DeadFish(t)

Step 4: GrowthEngine
├─ Calculate ActualGrowth(t)
├─ Calculate TLBQ(t) = TLBQ(t-1) + Growth(t)
├─ Calculate Biomass(t)
└─ Output: GrowthRecord

Step 5: FeedPlanner
├─ Calculate DailyFeed(t)
├─ Validate feed < 50% change
├─ Select feed batch (FIFO by expiry)
└─ Output: FeedPlan

Step 6: ChemicalEngine
├─ Check chemical schedule
├─ Calculate dosage needed
├─ Select batch by FEFO
└─ Output: ChemicalPlan

Step 7: WaterOpsEngine
├─ Calculate water exchange needed
├─ Check intake/discharge limits
├─ Update water level
└─ Output: WaterOpsLog

Step 8: InventoryEngine (FEFO)
├─ For each planned feed/chemical:
│  ├─ Get available batches
│  ├─ Sort by ExpiryDate ASC
│  ├─ Allocate until enough
│  └─ Create FEFOAllocation
├─ If shortage → Create PO
├─ Split receipts if qty > capacity
└─ Output: InventoryAllocation

Step 9: SaveLogs
├─ Create DailyLog record
├─ Save to Database
├─ Create AuditTrail entry
└─ Update FarmingCycle.LastProcessedDay

Step 10: AlertSystem
├─ Check all thresholds
├─ Generate alerts if exceeded
├─ Log to AlertLogs
└─ Output: AlertList

Day OUTPUT:
├─ DailyLog (complete record)
├─ EnvironmentLog
├─ MortalityEvent
├─ GrowthRecord
├─ FeedAllocation
├─ ChemicalUsage
├─ WaterOpsLog
├─ InventoryAllocation
├─ CostTracking
├─ AlertLogs
└─ AuditTrail
```

---

## 9. QUY TRÌNH NGHIỆP VỤ

### 9.1 Chu Kỳ Nuôi 92 Ngày

```
┌─────────────────────────────────────────────────────────────┐
│         FARMING CYCLE - 92 NGÀY TOÀN BỘ                    │
├────────────────────┬────────────────────────────────────────┤
│  PREPARATION       │      FARMING (90 NGÀY)               │
│   (2 NGÀY)         │                                        │
├────────────────────┼────────────────────────────────────────┤
│ Day 1 │ Day 2      │ Day 3 │ Day 4 │ ... │ Day 92         │
│ Prep  │ Prep       │Start  │Feed   │     │Harvest        │
│       │ Complete   │Stock  │Grow   │     │                │
└────────────────────┴────────────────────────────────────────┘
```

**Day 1-2: Pond Preparation Phase**
- Vệ sinh ao, bơm nước
- Xử lý đáy (Zeolite, Probiotic, Vôi bột)
- Bón phân vi sinh
- NO fish, NO feed, NO growth tracking
- Pipeline chạy: Environment + Chemical + Cost only

**Day 3-92: Farming Phase (90 days)**
- Thả cá (Day 3)
- Chạy normal 10-step pipeline
- Growth + Mortality + Feed + Chemical tracking

---

## 10. 8 FSIS FORMS

| Form | Mã | Mục Đích | Bao Gồm |
|------|-----|---------|---------|
| Nhật ký nuôi | P301-F01 | Ghi nhận hàng ngày | 90 dòng daily log |
| Biên bản giao nhận TA | P301-F06 | Xuất thức ăn | Ngày, SL, người giao/nhận |
| Sổ theo dõi TA | P301-F07 | Tồn kho thức ăn | Nhập/xuất/tồn hàng ngày |
| Phiếu giao hàng HC | P303-F03 | Xuất hóa chất | Ngày, loại, SL, người |
| Sổ theo dõi HC | P303-F04 | Tồn kho hóa chất | Nhập/xuất/tồn hàng ngày |
| Phiếu chỉ định SP | P303-F06 | Khai báo sản phẩm | Tên, đạm, kích cỡ, lô, HSD |
| Theo dõi sức khỏe | P303-F07 | Health monitoring | Ngày cân, TLBQ, bệnh |
| Giao nhận chất thải | P305-F37 | Waste transfer | Cá chết, TA thừa, HC |

**Tất cả forms đều có watermark: "MOCKED DATA - FOR TRAINING ONLY"**

---

# PHẦN II: HƯỚNG DẪN CHUẨN BỊ AO (POND PREPARATION)

## 11. TỔNG QUAN POND PREPARATION

### 11.1 Vấn Đề Trước Đây

Trước bản v4.1:
- ❌ Pipeline chạy từ ngày 1 với đầy đủ quy trình (growth, mortality, feed)
- ❌ Thả cá ngay từ ngày 1 không xử lý môi trường
- ❌ Không phản ánh đúng thực tế nuôi trồng thủy sản

### 11.2 Giải Pháp Mới

Bổ sung **Pond Preparation Phase** (2 ngày đầu):
- ✅ **Ngày 1-2**: Xử lý ao, bơm nước, xử lý đáy, ổn định môi trường
- ✅ **Ngày 3**: Thả cá giống (ngày 1 thực tế của chu kỳ nuôi)
- ✅ **Ngày 4-92**: Chạy pipeline bình thường (growth, mortality, feed)

### 11.3 Lợi Ích

| Lợi Ích | Mô Tả |
|---------|-------|
| **Thực tế hơn** | Phản ánh đúng quy trình nuôi cá tra/tôm thực tế |
| **Chất lượng nước tốt hơn** | Môi trường đã ổn định trước khi thả giống |
| **Giảm tỷ lệ chết** | Cá không bị stress khi vừa thả vào môi trường mới |
| **Theo dõi chi phí** | Tách biệt chi phí chuẩn bị và chi phí nuôi |

---

## 12. QUY TRÌNH CHUẨN BỊ AO CHUẨN

### 12.1 Ngày 1: Vệ Sinh & Xử Lý Đáy

**Công Việc:**

1. **Vệ sinh ao**
   - Loại bỏ cặn bẩn, bùn thừa
   - Phơi đáy (nếu có thời gian)
   - Sửa chữa bờ ao, thiết bị

2. **Bơm nước**
   - Bơm nước vào đầy ao
   - Nguồn: Sông, giếng, hồ chứa
   - Kiểm tra độ trong, màu sắc

3. **Xử lý đáy**
   - **Vôi bột**: 10kg/1000m² → Khử trùng, tăng pH
   - **Zeolite**: 2kg/1000m² → Khử độc, hấp thụ NH3
   - **Probiotic đáy**: 500g/1000m² → Phân hủy hữu cơ, giảm H2S

**Thông Số Dự Kiến:**

| Thông Số | Giá Trị | Tiêu Chuẩn | Đánh Giá |
|----------|--------|-----------|---------|
| **DO** | 7.5-8.5 mg/L | > 5.0 | ✅ Tốt |
| **pH** | 7.0-7.5 | 6.5-8.5 | ✅ Tốt |
| **H2S** | 0.08-0.12 | < 0.05 | ⚠️ Cao |
| **NH3** | 0.15-0.20 | < 0.2 | ⚠️ Cao |
| **Nhiệt độ** | 27-29°C | 26-30°C | ✅ Tốt |

**Chi Phí:**
- Hóa chất: ~500-800k VND
- Lao động: ~250k VND
- Điện: ~200k VND
- **Tổng**: ~1,000k VND

### 12.2 Ngày 2: Ổn Định Môi Trường

**Công Việc:**

1. **Bón phân vi sinh**
   - **Phân vi sinh tạo tảo**: 1kg/1000m²
   - Tạo nguồn thức ăn tự nhiên (tảo, trùng bọ)

2. **Xử lý nước**
   - **Probiotic nước**: 1g/m³ → Cân bằng vi sinh
   - **Vitamin C**: 0.5g/m³ → Tăng sức đề kháng

3. **Kiểm tra chất lượng**
   - Đo DO, pH, H2S, NH3
   - Kiểm tra màu nước (xanh lá cây nhạt = tốt)
   - Kiểm tra độ trong (30-40cm = tốt)

**Thông Số Dự Kiến:**

| Thông Số | Giá Trị | Tiêu Chuẩn | Đánh Giá |
|----------|--------|-----------|---------|
| **DO** | 6.5-7.5 mg/L | > 5.0 | ✅ Tốt |
| **pH** | 7.2-7.6 | 6.5-8.5 | ✅ Tốt |
| **H2S** | 0.03-0.05 | < 0.05 | ✅ An toàn |
| **NH3** | 0.08-0.12 | < 0.2 | ✅ An toàn |
| **Nhiệt độ** | 27-29°C | 26-30°C | ✅ Tốt |

**Chi Phí:**
- Hóa chất: ~300-500k VND
- Lao động: ~150k VND
- Điện: ~50k VND
- **Tổng**: ~500k VND

✅ **Ao đã sẵn sàng thả cá!**

---

## 13. THAY ĐỔI DATABASE SCHEMA

### 13.1 Các Cột Mới trong `FarmingCycle`

```sql
ALTER TABLE FarmingCycle ADD
    PreparationDays INT NOT NULL DEFAULT 2,
    PreparationStartDate DATETIME NULL,
    StockingDate DATETIME NULL,
    PreparationChemicals NVARCHAR(MAX) NULL,
    IsPreparationComplete BIT NOT NULL DEFAULT 0,
    TotalDaysWithPreparation AS (ISNULL(PlannedDays, 90) + PreparationDays) PERSISTED;
```

| Cột | Kiểu | Mặc Định | Mô Tả |
|-----|------|----------|-------|
| `PreparationDays` | INT | 2 | Số ngày chuẩn bị (thường 2) |
| `PreparationStartDate` | DATETIME | NULL | Ngày bắt đầu chuẩn bị (= StartDate) |
| `StockingDate` | DATETIME | NULL | Ngày thả cá (= StartDate + PreparationDays) |
| `PreparationChemicals` | NVARCHAR(MAX) | NULL | JSON log hóa chất đã dùng |
| `IsPreparationComplete` | BIT | 0 | Đã hoàn tất chuẩn bị chưa |
| `TotalDaysWithPreparation` | Computed | | Tổng số ngày (90 + 2 = 92) |

### 13.2 View Mới: `vw_CyclePreparationInfo`

```sql
SELECT 
    CycleID,
    CycleCode,
    PondCode,
    PreparationDays,
    StockingDate,
    CASE 
        WHEN LastProcessedDay <= PreparationDays THEN 'PREPARATION'
        ELSE 'FARMING'
    END AS CurrentPhase
FROM vw_CyclePreparationInfo;
```

### 13.3 Trigger: `trg_FarmingCycle_AutoCalculateStockingDate`

Tự động tính `StockingDate` khi thay đổi `StartDate`:
```sql
StockingDate = StartDate + PreparationDays
```

---

## 14. THAY ĐỔI MODEL & SERVICES

### 14.1 FarmingCycle Model

**Properties Mới:**
```csharp
public class FarmingCycle
{
    // Pond Preparation (NEW)
    public int PreparationDays { get; set; } = 2;
    public DateTime? PreparationStartDate { get; set; }
    public DateTime? StockingDate { get; set; }
    public string? PreparationChemicals { get; set; }
    public bool IsPreparationComplete { get; set; } = false;
    
    // Helper properties
    public bool IsInPreparationPhase => 
        LastProcessedDay <= PreparationDays && !IsPreparationComplete;
    
    public int ActualFarmingDay => 
        Math.Max(0, LastProcessedDay - PreparationDays);
    
    public int TotalDaysWithPreparation => 
        (PlannedDays ?? 90) + PreparationDays;
}
```

### 14.2 PondPreparationEngine (Mới)

**Methods Chính:**

1. `ExecutePreparationDayAsync(cycleId, dayNumber, cycle)` - Logic từng ngày
2. `ExecuteDay1Preparation()` - Logic ngày 1
3. `ExecuteDay2Preparation()` - Logic ngày 2
4. `GeneratePreparationSummaryAsync()` - Báo cáo tổng kết

**Output:**
```csharp
public class PreparationDayOutput
{
    public int DayNumber { get; set; }
    public bool IsPreparationComplete { get; set; }
    
    // Water
    public decimal WaterIntakeM3 { get; set; }
    public decimal WaterDischargeM3 { get; set; }
    
    // Environment
    public double Temperature { get; set; }
    public double DO { get; set; }
    public double pH { get; set; }
    public double H2S { get; set; }
    public double NH3 { get; set; }
    
    // Chemicals
    public List<ChemicalUsageDetail> Chemicals { get; set; }
    public decimal TotalChemicalCost { get; set; }
    
    // Costs
    public decimal LaborCost { get; set; }
    public decimal ElectricityCost { get; set; }
    public decimal TotalCost { get; set; }
}
```

### 14.3 DailyPipelineService (Cập Nhật)

**Logic Mới:**
```csharp
public async Task<DailyPipelineResult> ExecuteDailyPipelineAsync(DailyPipelineInput input)
{
    // CHECK: Nếu đang chuẩn bị ao (Day 1-2)
    if (input.IsPreparationPhase && input.Cycle != null)
    {
        return await ExecutePreparationPipelineAsync(input);
    }
    
    // Normal pipeline (từ ngày thả cá)
    // ... (10 steps như cũ)
}
```

---

## 15. QUY TRÌNH PIPELINE MỚI

### 15.1 Flowchart Tổng Quan

```
START: Khởi tạo Cycle
  ├─ Set PreparationDays = 2
  ├─ Set StartDate = 01/01/2025
  ├─ Set StockingDate = 03/01/2025 (StartDate + 2)
  │
  ▼
┌─────────────────────────────────────────────────────────┐
│  LOOP: For Day = 1 to TotalDaysWithPreparation (92)    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  IF (Day <= PreparationDays)  // Day 1-2               │
│  THEN                                                   │
│    │                                                    │
│    ├─> 🔧 PREPARATION PIPELINE                         │
│    │   ├─ PondPreparationEngine.Execute()              │
│    │   ├─ Day 1: Vệ sinh, xử lý đáy, bơm nước         │
│    │   ├─ Day 2: Bón phân, Probiotic, Vitamin C       │
│    │   ├─ Kiểm tra DO, pH, H2S, NH3                   │
│    │   ├─ Lưu PreparationChemicals (JSON)             │
│    │   └─ Set IsPreparationComplete = TRUE            │
│    │                                                    │
│  ELSE  // Day 3+                                       │
│    │                                                    │
│    ├─> 🐟 NORMAL FARMING PIPELINE (10 STEPS)           │
│    │   ├─ Step 1: Environment Generator                │
│    │   ├─ Step 2: Mortality Engine                     │
│    │   ├─ ... (tất cả 10 steps)                       │
│    │                                                    │
│  END IF                                                 │
│                                                         │
│  Save DailyLog                                          │
│  LastProcessedDay += 1                                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
  │
  ▼
END: Cycle Complete (Day 92)
```

### 15.2 So Sánh TRƯỚC vs SAU

| Tiêu Chí | TRƯỚC (v4.0) | SAU (v4.1) |
|----------|--------------|-----------|
| Ngày bắt đầu | Day 1 = Thả cá + Cho ăn | Day 1 = Chuẩn bị ao |
| Thả cá | Ngày 1 | Ngày 3 (sau 2 ngày prep) |
| Cho ăn | Từ ngày 1 | Từ ngày 3 |
| Môi trường | Chưa ổn định | Đã ổn định sau 2 ngày |
| Tổng ngày | 90 ngày | 92 ngày (2 prep + 90 nuôi) |

---

## 16. HÓA CHẤT SỬ DỤNG

### 16.1 Ngày 1 - Vệ Sinh & Xử Lý Đáy

| Hóa Chất | Liều Lượng | Giá (VND/kg) | Mục Đích |
|----------|-----------|--------------|---------|
| **Zeolite** | 2kg/1000m² | 15,000 | Khử độc, hấp thụ NH3 |
| **Probiotic đáy** | 500g/1000m² | 120,000 | Phân hủy hữu cơ |
| **Vôi bột** | 10kg/1000m² | 3,000 | Khử trùng, tăng pH |

**Ví Dụ Ao 1000m²:**
- Zeolite: 2kg × 15,000 = 30,000 VND
- Probiotic: 0.5kg × 120,000 = 60,000 VND
- Vôi: 10kg × 3,000 = 30,000 VND
- **Tổng hóa chất**: 120,000 VND

### 16.2 Ngày 2 - Bón Phân & Vitamin

| Hóa Chất | Liều Lượng | Giá (VND/kg) | Mục Đích |
|----------|-----------|--------------|---------|
| **Phân vi sinh** | 1kg/1000m² | 80,000 | Tạo tảo |
| **Probiotic nước** | 1g/m³ | 150,000 | Cân bằng vi sinh |
| **Vitamin C** | 0.5g/m³ | 200,000 | Tăng sức đề kháng |

**Ví Dụ Ao 1000m³:**
- Phân vi sinh: 1kg × 80,000 = 80,000 VND
- Probiotic nước: 1kg × 150,000 = 150,000 VND
- Vitamin C: 0.5kg × 200,000 = 100,000 VND
- **Tổng hóa chất**: 330,000 VND

### 16.3 Tổng Chi Phí 2 Ngày (ao 1000m²/1000m³)

| Hạng Mục | Ngày 1 | Ngày 2 | Tổng |
|----------|--------|--------|------|
| Hóa chất | 120,000 | 330,000 | 450,000 |
| Lao động | 250,000 | 150,000 | 400,000 |
| Điện | 200,000 | 50,000 | 250,000 |
| **TỔNG** | **570,000** | **530,000** | **1,100,000** |

---

## 17. HƯỚNG DẪN SỬ DỤNG & TESTING

### 17.1 Khởi Tạo Cycle Mới

```csharp
var cycle = new FarmingCycle
{
    CycleCode = \"C2025-001\",
    CycleName = \"Vụ xuân 2025\",
    PondID = 1,
    StartDate = new DateTime(2025, 1, 1),
    PlannedDays = 90,
    
    // Pond Preparation (tự động)
    PreparationDays = 2,
    // PreparationStartDate = StartDate (auto by trigger)
    // StockingDate = StartDate + 2 (auto by trigger)
    
    SeedQty = 10000,
    AvgWeightG = 1.5m,
    Species = \"CATFISH\",
    FCR = 1.8m
};

await _cycleRepository.AddAsync(cycle);
await _unitOfWork.SaveChangesAsync();
```

### 17.2 Chạy Pipeline

```csharp
for (int day = 1; day <= cycle.TotalDaysWithPreparation; day++)
{
    var input = new DailyPipelineInput
    {
        CycleId = cycle.CycleID,
        CycleDay = day,
        Date = cycle.StartDate.AddDays(day - 1),
        Cycle = cycle,  // QUAN TRỌNG
        
        PondId = cycle.PondID,
        FarmId = pond.FarmID,
        PondVolumeM3 = (double)pond.VolumeM3,
        
        CurrentFishCount = day <= cycle.PreparationDays ? 0 : cycle.SeedQty,
        CurrentAvgWeightGr = day <= cycle.PreparationDays ? 0 : (double)cycle.AvgWeightG,
    };
    
    var result = await _pipelineService.ExecuteDailyPipelineAsync(input);
    
    if (day == cycle.PreparationDays && result.Success)
    {
        cycle.IsPreparationComplete = true;
        await _context.SaveChangesAsync();
    }
}
```

---

# PHẦN III: HƯỚNG DẪN CẬP NHẬT FORMS

## 18. TỔNG QUAN CẬP NHẬT FORMS

### 18.1 Bối Cảnh

Sau khi implement **Pond Preparation Feature**, cần cập nhật các forms để:

- Tương thích với logic mới (92 ngày thay vì 90 ngày)
- Khởi tạo đúng các fields chuẩn bị ao
- Truyền `Cycle` object vào pipeline input

### 18.2 Mục Tiêu

✅ Đảm bảo 3 forms chính hoạt động đúng:
1. `CycleBatchDeclarationForm` - Tạo cycle
2. `FarmingCycleManagementForm` - Quản lý + chạy pipeline
3. `ScenarioInputForm` - Tạo scenario

---

## 19. VẤN ĐỀ ĐÃ PHÁT HIỆN

### 19.1 CycleBatchDeclarationForm

**Vấn Đề:**
- Không khởi tạo `PreparationDays`, `PreparationStartDate`, `StockingDate`
- Gây lỗi null reference

**Root Cause:**
- `CycleCreationService` chưa khởi tạo fields

### 19.2 FarmingCycleManagementForm

**Vấn Đề:**
1. `Generate90Days()` hardcoded 90 ngày → Phải là 92 ngày
2. `DailyPipelineInput` thiếu truyền `Cycle` object

### 19.3 ScenarioInputForm

**Quyết Định:** KHÔNG CẬP NHẬT lần này (để giữ UI đơn giản)
- Scenarios tự động dùng `PreparationDays = 2` default

---

## 20. CÁC THAY ĐỔI ĐÃ THỰC HIỆN

### 20.1 File Đã Chỉnh Sửa

| File | Số Dòng | Mức Độ |
|------|---------|--------|
| `CycleCreationService.cs` | ~20 dòng | HIGH |
| `FarmingCycleManagementForm.cs` | ~200 dòng | HIGH |

### 20.2 Breaking Changes

⚠️ **KHÔNG có breaking changes**

Tất cả cycles cũ:
- Sẽ có `PreparationDays = 2` (default)
- Vẫn hoạt động bình thường

---

## 21. CHI TIẾT CẬP NHẬT FORMS

### 21.1 CycleCreationService

**CreateSingleCycleAsync() - Thêm Pond Preparation Fields:**

```csharp
var cycle = new FarmingCycle
{
    // ... existing fields ...
    PreparationDays = 2,                    // NEW
    PreparationStartDate = startDate,       // NEW
    StockingDate = startDate.AddDays(2),   // NEW
    IsPreparationComplete = false           // NEW
};
```

### 21.2 FarmingCycleManagementForm

**Generate92DaysDataAsync() - Tính Tổng Số Ngày Động:**

```csharp
int totalDays = freshCycle.TotalDaysWithPreparation;  // 92 = 2 + 90
for (int day = 1; day <= totalDays; day++)
{
    var pipelineInput = new DailyPipelineInput
    {
        CycleId = freshCycle.CycleID,
        Date = freshCycle.StartDate.AddDays(day - 1),
        CycleDay = day,
        Cycle = freshCycle,  // ⭐ NEW - Critical for pond prep detection
        // ... other fields ...
    };
    
    var result = await _pipelineService.ExecuteDailyPipelineAsync(pipelineInput);
}
```

---

# PHẦN IV: PHÁT TRIỂN WINDOW FORM QLCLN

## 22. TỔNG QUAN HỆ THỐNG QLCLN

### 22.1 Mục Đích

Xây dựng hệ thống quản lý chất lượng lâm nghiệp toàn diện, tự động hóa quy trình ghi nhận dữ liệu nuôi cá, quản lý hóa chất, thức ăn, và theo dõi chất lượng nước.

### 22.2 Phạm Vi

- **Người dùng**: Bác sĩ ngư y, quản lý ao, nhân viên kho
- **Dữ liệu**: Nhật ký nuôi, hóa chất, thức ăn, chất lượng nước, chất thải
- **Thời gian**: Từ ngày chuẩn bị ao đến ngày thu hoạch (92 ngày)
- **Vùng**: Đồng Tháp (Cao Lãnh, Tân Hưng, Mỹ Xương...)

---

## 23. LUỒNG QUY TRÌNH CHÍNH

### 23.1 Chu Kỳ Nuôi (92 Ngày)

```
NGÀY 1-2 (Chuẩn Bị Ao)
├─ Vét bùn
├─ Xử lý nước (Vôi, EM-F1)
├─ Cân mẫu chất lượng nước
└─ Ghi nhận hóa chất sử dụng

NGÀY 3-92 (Nuôi Bình Thường)
├─ Thả cá (Ngày 3)
├─ Ghi nhận hàng ngày:
│  ├─ Môi trường (DO, Nhiệt độ, pH)
│  ├─ Cá & Thức ăn
│  ├─ Hóa chất sử dụng
│  └─ Cảnh báo & Xử lý
├─ Cân mẫu định kỳ (Hàng tháng)
└─ Theo dõi chất lượng nước

NGÀY 90+ (Thu Hoạch)
├─ Cắt mồi (Ngày 89)
├─ Thu hoạch (Ngày 90)
├─ Ghi nhận cuối cùng
└─ Tính toán FCR & Báo cáo
```

### 23.2 Quy Trình Ghi Nhận Hàng Ngày

```
1. Chọn Ao & Ngày
   └─ Validate: Ao có hoạt động? Ngày hợp lệ?

2. Ghi Nhận Môi Trường
   ├─ DO (Sáng/Chiều)
   ├─ Nhiệt độ (Sáng/Chiều)
   ├─ pH (Sáng/Chiều)
   └─ Validate: Trong ngưỡng?

3. Ghi Nhận Cá & Thức Ăn
   ├─ Số lượng cá (Tính tự động)
   ├─ Cá chết (Nhập & Tính khối lượng)
   ├─ Thức ăn (Chọn loại & Lượng)
   └─ Validate: HSD? Mật độ?

4. Ghi Nhận Hóa Chất
   ├─ Loại hóa chất
   ├─ Lượng sử dụng
   ├─ Lý do sử dụng
   └─ Validate: MSL & HSD?

5. Kiểm Tra Cảnh Báo
   ├─ Mật độ > 37 kg/m²?
   ├─ Cá chết vượt ngưỡng?
   ├─ HSD hết hạn?
   └─ Hiển thị cảnh báo

6. Lưu & Báo Cáo
   ├─ Lưu Database
   ├─ Cập nhật tồn kho
   ├─ Tạo Daily Log
   └─ In phiếu nếu cần
```

---

## 24. CÁC FORM CHÍNH & CÔNG THỨC

### 24.1 Form Nhật Ký Nuôi

**Công Thức Tính Số Lượng Cá:**
```
IF NgàyNuôi = 1 THEN
    SốLượngCá = SốConThả
ELSE
    SốLượngCá = SốLượngCáNgàyTrước - CáChếtNgàyTrước
END IF
```

**Công Thức Tính Khối Lượng Cá Chết:**
```
KhốiLượngCáChết = (SốConCáChết × TLBQ) × 0.8 đến 0.85
KhốiLượngCáChết = ROUND(KhốiLượngCáChết, 0.5)
```

**Công Thức Tính Mật Độ Nuôi:**
```
MậtĐộ = (SốLượngCá × TLBQ) / DiệnTíchMặtNước
IF MậtĐộ > 37 THEN
    CảnhBáo = \"Mật độ vượt 37 kg/m²\"
END IF
```

### 24.2 Form Sổ Kho Thức Ăn

**Công Thức Tính HSD từ MSL:**
```
MSL = \"0125-32201914\"
NgàyJulian = MID(MSL, 3, 3)  // \"322\"
HSD = NgàyJulian + 89
HSD = ConvertJulianToDate(HSD)
```

### 24.3 Form Sổ Kho Hóa Chất

**Validation Sức Chứa Kho:**
```
IF LoạiHóaChất = \"Lỏng\" THEN
    TổngLượngKho = SUM(LượngHóaChấtLỏng)
    IF TổngLượngKho > SứcChứaKho × 0.9 THEN
        CảnhBáo = \"Sức chứa kho vượt 90%\"
        AllowNhập = FALSE
    END IF
END IF
```

---

## 25. DATABASE SCHEMA QLCLN

### 25.1 Bảng Chính

```sql
-- Bảng Ao Nuôi
CREATE TABLE Ponds (
    PondID INT PRIMARY KEY,
    PondName VARCHAR(50),
    FarmID INT,
    SurfaceArea DECIMAL(10,2),
    WaterSurfaceArea DECIMAL(10,2),
    Depth DECIMAL(5,2),
    CreatedDate DATE
);

-- Bảng Nhật Ký Hàng Ngày
CREATE TABLE DailyLogs (
    LogID INT PRIMARY KEY,
    PondID INT,
    LogDate DATE,
    FishCount INT,
    DeadCount INT,
    DeadWeightKg DECIMAL(10,2),
    DO_Morning DECIMAL(5,2),
    DO_Evening DECIMAL(5,2),
    Temperature_Morning DECIMAL(5,2),
    Temperature_Evening DECIMAL(5,2),
    pH_Morning DECIMAL(5,2),
    pH_Evening DECIMAL(5,2),
    FeedKg DECIMAL(10,2),
    FeedBatchCode VARCHAR(50),
    Notes TEXT,
    CreatedDate DATETIME
);

-- Bảng Hóa Chất Sử Dụng
CREATE TABLE ChemicalUsage (
    UsageID INT PRIMARY KEY,
    PondID INT,
    UsageDate DATE,
    ChemicalID INT,
    QuantityUsed DECIMAL(10,2),
    Unit VARCHAR(10),
    Reason VARCHAR(100),
    CreatedDate DATETIME
);

-- Bảng Tồn Kho Thức Ăn
CREATE TABLE FeedInventory (
    InventoryID INT PRIMARY KEY,
    FeedID INT,
    InputDate DATE,
    QuantityInput DECIMAL(10,2),
    BatchCode VARCHAR(50),
    ExpiryDate DATE,
    QuantityOutput DECIMAL(10,2),
    RemainingQty DECIMAL(10,2),
    Status VARCHAR(20)
);

-- Bảng Tồn Kho Hóa Chất
CREATE TABLE ChemicalInventory (
    InventoryID INT PRIMARY KEY,
    ChemicalID INT,
    InputDate DATE,
    QuantityInput DECIMAL(10,2),
    BatchCode VARCHAR(50),
    ExpiryDate DATE,
    QuantityOutput DECIMAL(10,2),
    RemainingQty DECIMAL(10,2),
    Status VARCHAR(20)
);
```

---

## 26. MỐI LIÊN HỆ VỚI AQUASIM

### 26.1 Tích Hợp

QLCLN Form được xây dựng để:
1. **Nhận dữ liệu từ AquaSim Pipeline** - DailyLog 90 ngày tự động
2. **Bổ sung dữ liệu thêm** - Cân mẫu, cảnh báo thêm, ghi chú chi tiết
3. **Sinh báo cáo FSIS** - Từ DailyLog merged

### 26.2 Data Flow

```
AquaSim Pipeline (10 steps) → DailyLog
                                  ↓
                            QLCLN Form
                                  ↓
                        User thêm thông tin
                                  ↓
                        FSIS Forms Export
```

---

# PHẦN V: MÔ TẢ CHI TIẾT NỘI DUNG QLCLN

## 27. DANH SÁCH CÁC YÊU CẦU THAO TÁC (15 YÊU CẦU)

### 27.1 Yêu Cầu 1-5: Nhật Ký Nuôi & Chất Thải

1. **Nhật ký nuôi - Thông tin thu hoạch**
   - Biểu mẫu: P301-F01
   - Nội dung: Thời gian thu hoạch, Sản lượng, TLBQ, FCR

2. **Nhật ký nuôi - Cảnh báo mật độ**
   - Cảnh báo khi > 37 kg/m²

3. **Nhật ký nuôi - Quản lý nhân sự**
   - Nhập tên người phụ trách ao

4. **Nhật ký nuôi - Báo cáo tốc độ tăng trưởng**
   - Báo cáo tốc độ tăng trưởng và mật độ

5. **Sổ giao nhận chất thải - Cá chết**
   - Tổng hợp số lượng cá chết (kg/ngày)

### 27.2 Yêu Cầu 6-10: Kho & Hóa Chất

6. **Sổ giao nhận chất thải - Thức ăn**
   - Tổng hợp lượng thức ăn, tính số bao bì

7. **Phiếu sức khỏe cá nuôi - Ngày cân mẫu**
   - Tổng hợp thông tin cân mẫu

8. **Phiếu chỉ định sản phẩm - Hóa chất**
   - Tổng hợp hóa chất (trừ thuốc trị bệnh)

9. **Sổ kho thức ăn**
   - Tổng hợp thức ăn hàng ngày theo kích cỡ

10. **Sổ kho hóa chất**
    - Tổng hợp hóa chất hàng ngày

### 27.3 Yêu Cầu 11-15: Kiểm Tra & Biên Bản

11. **Cảnh báo hóa chất lỏng - Sức chứa kho**
    - Cảnh báo khi > 90% sức chứa

12. **Biên bản giao nhận thức ăn**
    - Từ P301-F07, chọn ghe vận chuyển

13. **Biên bản giao nhận hóa chất**
    - Từ P303-F04, nhập tên người nhận

14. **Kiểm tra lượng nước cấp - Nhịp trao đổi**
    - Cho phép chọn nhịp trao đổi nước

15. **Kiểm tra lượng nước cấp - Giới hạn**
    - Cho phép thay đổi giới hạn nước (khi có giấy phép mới)

---

## 28. THÔNG TIN TRANG ĐẦU NHẬT KÝ NUÔI (NK-P301-F01)

### 28.1 Phần I: Thông Tin Ao Nuôi

| Trường | Mô Tả | Loại |
|--------|-------|------|
| I.1 | Địa chỉ (ao + vụ + địa chỉ) | Tự động |
| I.2 | Số điện thoại | Dropdown |
| I.3 | Quản lý | Dropdown |
| I.4 | Diện tích ao (m²) | Tự động |
| I.5 | Diện tích mặt nước (m²) | Tự động |
| I.6 | Độ sâu (m) | Tự động |

### 28.2 Phần II: Chuẩn Bị Ao

| Trường | Mô Tả | Loại | Ghi Chú |
|--------|-------|------|--------|
| II.1 | Ngày thu hoạch vụ trước | Tự nhập | Định dạng: Ngày/Tháng/Năm |
| II.2 | Ngày ao trống | Tự động | = (Ngày thả - Ngày thu hoạch) + 1 |
| II.3 | Ngày cải tạo ao | Tự động | Từ hóa chất đầu tiên → ngày thả - 1 |
| II.4 | Cách cải tạo ao | Mặc định | \"Vét bùn\" |
| II.5 | Kích cỡ mắt lưới (cm) | Chọn | 0.5, 1, 1.2, 2 |
| II.6 | Mực nước trước thả (m) | Tự động | Từ thông tin ao |
| II.7 | Sử dụng sản phẩm cải tạo ao | Mặc định | \"Có\" |
| II.8 | Chất lượng nước trước thả | Tự động/Chọn | DO, pH, Nhiệt độ |
| II.9 | Kết cấu bờ ao | Checkbox | Đất sét, Sét pha cát, Đất cát... |

### 28.3 Phần III: Thông Tin Cá Giống

| Trường | Mô Tả | Loại | Ghi Chú |
|--------|-------|------|--------|
| III.1 | Loại cá nuôi | Chọn | Cá tra, Rô phi |
| III.2 | Ao giống/Mã ao | Tự nhập | - |
| III.3 | Tên trại giống | Dropdown | - |
| III.4 | Địa chỉ trại giống | Tự động | Dựa trên tên trại |
| III.5 | Kích cỡ giống (cm) | Chọn/Tính | 1.7, 2, 2.5, Khác |
| III.6 | Tuổi giống (ngày) | Tự nhập | - |
| III.7 | Mật độ thả (con/m²) | Tự động | = SL / Diện tích mặt nước |
| III.8 | Ngày thả | Tự nhập | Định dạng: Ngày/Tháng/Năm |
| III.9 | Số lượng giống (con) | Tự nhập | - |
| III.10 | Khối lượng giống (kg) | Tự nhập | - |
| III.11 | Sản lượng dự kiến (tấn) | Tự nhập | - |

---

## 29. CÁC CỘT DỮ LIỆU HÀNG NGÀY

| # | Cột | Đơn Vị | Mô Tả |
|---|-----|--------|-------|
| 1 | Ngày (Date) | YYYY-MM-DD | Ngày ghi nhận |
| 2 | Ngày nuôi | Ngày | Số ngày từ ngày thả |
| 3 | Số lượng cá | con | Số lượng cá hiện tại |
| 4 | DO | mg/L | Nồng độ oxy hòa tan |
| 5 | Nhiệt độ | °C | Nhiệt độ nước |
| 6 | pH | - | Độ pH |
| 7-9 | Thức ăn: Công ty, Độ đạm, Kích cỡ | - | Thông tin TA |
| 10 | Thức ăn: Mã lô | - | Mã batch |
| 11 | Thức ăn: HSD | YYYY-MM-DD | Ngày hết hạn |
| 12 | Thức ăn: Lượng | kg | Lượng dùng |
| 13 | Cá chết: Số lượng | con | Số con chết |
| 14 | Cá chết: Khối lượng | kg | Khối lượng chết |
| 15 | Hóa chất: Tên | - | Tên hóa chất |
| 16 | Hóa chất: Mã lô & HSD | - | Batch + HSD |
| 17 | Hóa chất: Lượng | kg/lít | Lượng dùng |
| 18 | Hóa chất: Lý do | - | Lý do dùng |
| 19 | Ghi chú | - | Ghi chú bổ sung |
| 20 | Người chịu trách nhiệm | - | Tên người phụ trách |

---

## 30. HƯỚNG DẪN GHI NHẬN DỮ LIỆU

### 30.1 Số Lượng Cá

```
- Ngày đầu: = Số con thả
- Ngày kế tiếp: = SL ngày trước - Cá chết ngày trước
- Nếu thu tỉa: Không ghi số, sau đó ghi = SL trước - (Chết + Thu hoạch)
- Thu hoạch hết: Ghi đến ngày thu hoạch đầu tiên
```

### 30.2 Ghi Chú - 9 Trường Hợp

```
1. \"Thả cá\" → Ngày đầu
2. \"Bình thường\" → Quá trình bình thường
3. \"Không thu hoạch trước ngày…\" → Dùng thuốc (Ngày + 28 ngày)
4. \"Bình thường cắt mồi lúc 17h00\" → Trước thu hoạch 1 ngày
5. \"Thu hoạch + số con\" → Thu tỉa 1 ngày
6. \"Thu hoạch\" → Thu hết ao
7. \"Tháo mắt lưới bổ sung\" → TLBQ > 100g
8. \"Cắt mồi\" → Trước thu hoạch
9. Ghi lượng thu tỉa → Ví dụ: \"70.000kg\"
```

### 30.3 Cá Chết - Khối Lượng

```
Công thức: (Số con chết × TLBQ) × 80-85%
Kết quả: Làm tròn đến 0.5kg
```

### 30.4 Tính HSD Thức Ăn

```
Công thức: Ký tự 2-4 từ bên phải MSL (ngày Julian) + 89 ngày
Ví dụ: MSL \"0125-32201914\" → \"3220\" → Ngày Julian 322 + 89 = Ngày 411
```

---

## 31. DỮ LIỆU TỔNG HỢP CUỐI KỲ

| Chỉ Tiêu | Mô Tả | Công Thức |
|----------|-------|----------|
| Tổng lượng TA | Cộng từ đầu vụ | SUM(Lượng TA hàng ngày) |
| Tổng cá chết | Cộng từ đầu vụ | SUM(Số cá chết hàng ngày) |
| Tổng khối lượng cá chết | Cộng từ đầu vụ | SUM(Khối lượng cá chết hàng ngày) |
| TLBQ | Từ cân mẫu | Từ dữ liệu định kỳ |
| Mật độ (kg/m²) | Từ TLBQ | (SL × TLBQ) / Diện tích mặt nước |
| FCR | Tỉ lệ chuyển đổi TA | Tổng TA / Tăng trưởng sinh khối |
| Tỷ lệ sống | % cá còn lại | (SL cuối / SL thả) × 100 |

---

## 32. QUY TẮC MÔI TRƯỜNG AO NUÔI

### 32.1 Chỉ Tiêu DO (Dissolved Oxygen)

**Tần suất đo**: 2 lần/ngày (Sáng & Chiều)

**Yêu cầu chung:**
- Sáng thấp hơn chiều
- Chênh lệch trong ngày: min = 0.2, max = 1

**Ngưỡng Theo Giai Đoạn**:

| Giai Đoạn | Sáng | Chiều | Ghi Chú |
|-----------|------|-------|--------|
| Tuần 1 | 3.5-3.9 | 3.9-4.5 | Nước mới, bơm tốt |
| Tuần 2-Tháng 1 | 3.0-3.5 | 3.5-3.9 | Bắt đầu tích tụ hữu cơ |
| Tháng 2-3 | 2.9-3.2 | 3.2-3.5 | Cao độ mặt nước |
| Tháng 4+ | 2.6-2.9 | 2.8-3.4 | Gần thu hoạch, oxy kém |

**Cảnh báo**:
- **Vàng** (2.5-3.0): Cần sục khí nhẹ
- **Đỏ** (< 2.5): CRITICAL - Cần sục khí mạnh

---

# KẾT LUẬN

Tài liệu này tập hợp hoàn chỉnh toàn bộ nội dung AquaSim v4.1, bao gồm:

✅ **Phần I**: SRS final (30,000 từ, 80 trang gốc)  
✅ **Phần II**: Pond Preparation Guide (22,600 ký tự)  
✅ **Phần III**: Forms Update Guide (21,300 ký tự)  
✅ **Phần IV-V**: QLCLN Forms Development (60,000 ký tự)  

**Tổng cộng**: ~150,000 ký tự, 32 chương toàn diện

---

**Ngày cập nhật**: 14/11/2025  
**Phiên bản**: 4.1 - Consolidated Final Complete  
**Tác giả**: AquaSim Technical Team + VHC Development Team  
**Trạng thái**: ✅ APPROVED & COMPLETE FOR PRODUCTION  

© 2025 All Rights Reserved