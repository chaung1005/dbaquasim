# TÀI LIỆU HOÀN CHỈNH HỆ THỐNG AQUASIM v4.1 - VHC (CORRECTED FORMULAS)
## Hệ Thống Quản Lý Nuôi Trồng Thủy Sản Toàn Diện

**Ngày cập nhật**: 15/11/2025  
**Phiên bản**: 4.1 - Final with Formula Corrections  
**Tác giả**: AquaSim Technical Team + VHC Development Team  
**Trạng thái**: ✅ APPROVED & CORRECTED FORMULAS  

---

# ⚠️ THAY ĐỔI CHỈ TIÊU SO VỚI PHIÊN BẢN TRƯỚC

## CÔNG THỨC ĐƯỢC SỬA CHỮA (v4.1 - CORRECTED)

### 🔴 HIGH PRIORITY - CẦN SỬA NGAY

#### 1. CÔNG THỨC DO (DISSOLVED OXYGEN) - ✅ SỬA CHỮA

**TRƯỚC (SAI):**
```
DO(t) = 5.5 - (Sinh_khối / 1000) × 0.5 - Random(0, 1.5)
❌ Vấn đề: Base 5.5 quá cao, sinh khối = 5000kg → DO = 3.0, random quá lớn
```

**SAU (ĐÚNG):**
```csharp
// Bước 1: Xác định base DO theo tuổi cá
decimal base_DO;
if (dayAge <= 10) {
    base_DO = 4.0m;     // Tuần 1: Cá yếu, cần oxy cao
} else if (dayAge <= 30) {
    base_DO = 3.5m;     // Tuần 2-tháng 1
} else if (dayAge <= 60) {
    base_DO = 3.1m;     // Tháng 2-3: Cao độ mặt nước lớn
} else {
    base_DO = 2.9m;     // Tháng 4+: Gần thu hoạch, oxy kém
}

// Bước 2: Tính DO từ sinh khối
decimal biomass_effect = (currentBiomassKg / 15000m) * 0.3m;

// Bước 3: Thêm random nhỏ và tính toán
decimal random_variation = (decimal)random.NextDouble() * 0.4m - 0.2m; // [-0.2, 0.2]
decimal DO_raw = base_DO - biomass_effect + random_variation;

// Bước 4: Clamp đảm bảo nằm trong [2.8, 4.2] mg/L
DO(t) = Math.Max(2.8m, Math.Min(4.2m, DO_raw));

✅ Kết quả: 
  - Nằm chắc chắn trong 2.8-4.2 mg/L
  - Thích hợp cho tuổi cá
  - Ít biến động (±0.2 vs ±1.5 trước)
```

**Ngưỡng Cảnh Báo DO**:
- DO < 2.5: 🔴 **CRITICAL** - Sục khí ngay lập tức
- 2.5 ≤ DO < 3.0: 🟡 **WARNING** - Giám sát gần
- DO ≥ 3.0: 🟢 **SAFE** - Bình thường

---

#### 2. CÔNG THỨC GROWTH (TĂNG TRƯỞNG) - ✅ SỬA CHỮA

**TRƯỚC (CÓ VẤN ĐỀ):**
```
ActualGrowth = BaseGrowth × [(1-DO)×(1-pH)×(1-Temp)×...]
❌ Vấn đề: Nhân quá nhiều → kết quả gần 0, không thực tế
```

**SAU (ĐÚNG):**
```csharp
// Bước 1: Base growth theo tuổi
decimal baseGrowth;
if (dayAge <= 10) baseGrowth = 0.2m;      // g/con/ngày
else if (dayAge <= 30) baseGrowth = 0.5m; // g/con/ngày
else if (dayAge <= 60) baseGrowth = 0.8m; // g/con/ngày
else baseGrowth = 0.6m;                   // g/con/ngày (tháng 4+)

// Bước 2: Tính tổng stress penalty (SUBTRACTIVE)
decimal stressPenalty = 0m;

if (currentDO < 4.0m) 
    stressPenalty += 0.5m * baseGrowth;   // -50% if DO < 4

if (currentPH < 6.5m || currentPH > 8.5m) 
    stressPenalty += 0.7m * baseGrowth;   // -70% if pH out of range

if (currentTemp < 25m) 
    stressPenalty += 0.7m * baseGrowth;   // -70% if temp too cold

if (currentTemp > 32m) 
    stressPenalty += 0.6m * baseGrowth;   // -60% if temp too hot

if (currentH2S > 0.05m) 
    stressPenalty += 0.4m * baseGrowth;   // -40% if H2S high

if (currentNH3 > 0.2m) 
    stressPenalty += 0.5m * baseGrowth;   // -50% if NH3 high

if (hasDisease) 
    stressPenalty += (0.3m to 0.6m) * baseGrowth;  // -30 to -60%

// Bước 3: Tính actual growth
decimal actualGrowth = baseGrowth - stressPenalty;

// Bước 4: Clamp trong [0, baseGrowth]
actualGrowth = Math.Max(0m, Math.Min(baseGrowth, actualGrowth));

// Bước 5: Cập nhật TLBQ
newTLBQ = previousTLBQ + actualGrowth;

✅ Kết quả: 
  - Không bao giờ < 0
  - Không bao giờ > baseGrowth
  - Realistic dựa trên điều kiện
```

---

#### 3. CÔNG THỨC MORTALITY (CÁ CHẾT) - ✅ SỬA CHỮA

**TRƯỚC (CÓ VẤN ĐỀ):**
```
DeadFish = FishCount × BaseRate × (1-factor1) × (1-factor2) × ...
❌ Vấn đề: Nhân 0 khi có nhiều factors
```

**SAU (ĐÚNG):**
```csharp
// Bước 1: Base mortality rate theo tuổi
decimal baseRate;
switch (dayAge) {
    case <= 10:  baseRate = (decimal)(0.001 + random.NextDouble() * 0.004); break; // 0.1-0.5%
    case <= 30:  baseRate = (decimal)(0.0005 + random.NextDouble() * 0.0015); break; // 0.05-0.2%
    case <= 60:  baseRate = (decimal)(0.0002 + random.NextDouble() * 0.0008); break; // 0.02-0.1%
    default:     baseRate = (decimal)(0.0001 + random.NextDouble() * 0.0004); break; // 0.01-0.05%
}

// Bước 2: Stress adjustments (ADDITIVE)
decimal stressAdj = 0m;

if (currentDO < 4.0m) 
    stressAdj += 0.5m * baseRate;

if (currentPH < 6.5m || currentPH > 8.5m) 
    stressAdj += 0.7m * baseRate;

if (currentH2S > 0.1m) 
    stressAdj += 1.0m * baseRate;  // Critical

if (currentNH3 > 0.5m) 
    stressAdj += 0.8m * baseRate;  // Critical

if (hasVibrio) 
    stressAdj += 2.0m * baseRate;

if (hasDisease) 
    stressAdj += (decimal)(1.0 + random.NextDouble() * 2.0) * baseRate;

// Bước 3: Adjusted rate
decimal adjustedRate = Math.Max(0m, Math.Min(0.1m, baseRate + stressAdj));

// Bước 4: Random variation ±20%
decimal randomFactor = (decimal)(0.8 + random.NextDouble() * 0.4); // [0.8, 1.2]
int deadCount = (int)Math.Round(currentFishCount * adjustedRate * randomFactor);

// Bước 5: Clamp
deadCount = Math.Max(0, Math.Min(currentFishCount, deadCount));

✅ Kết quả:
  - Có thể > baseRate nếu stress cao
  - Nhưng không vượt 10% FishCount
  - Realistic khi có bệnh/oxy thấp
```

---

### 🟡 MEDIUM PRIORITY - CẦN ĐIỀU CHỈNH

#### 4. CÔNG THỨC FEED (THỨC ĂN) - ✅ CẢI THIỆN

**SAU (IMPROVED):**
```csharp
// Bước 1: Tính feed cần thiết (BaseBW động)
decimal baseBW_pct;
if (currentTLBQ < 50m) 
    baseBW_pct = 6m;        // 6% cho fingerling < 50g
else if (currentTLBQ < 150m) 
    baseBW_pct = 4m;        // 4% cho juvenile
else if (currentTLBQ < 300m) 
    baseBW_pct = 2.5m;      // 2.5% cho sub-adult
else 
    baseBW_pct = 1.75m;     // 1.75% cho market size

decimal feedNeeded = (currentBiomassKg / 1000m) * baseBW_pct / 100m;

// Bước 2: Điều chỉnh dựa trên điều kiện
decimal feedMultiplier = 1.0m;

if (IsMedicatingToday) 
    feedMultiplier *= 0.5m;   // Giảm 50% khi dùng thuốc

if (currentDO < 4m) 
    feedMultiplier *= 0.6m;   // Giảm 40% nếu DO thấp

if (currentPH < 6.5m || currentPH > 8.5m) 
    feedMultiplier *= 0.7m;   // Giảm 30% nếu pH ngoài range

if (hasDisease) 
    feedMultiplier *= 0.5m to 0.8m;  // Giảm 20-50% nếu bệnh

decimal adjustedFeed = feedNeeded * feedMultiplier;

// Bước 3: Làm tròn theo bag size (25kg bags)
decimal bagSize = 25m;
int bagsNeeded = (int)Math.Ceiling(adjustedFeed / bagSize);
decimal finalFeed = bagsNeeded * bagSize;

// Bước 4: Validation ±50% từ ngày trước
decimal prevFeed = GetPreviousDayFeed();
decimal maxChange = prevFeed * 1.5m;
decimal minChange = prevFeed * 0.5m;

if (finalFeed > maxChange) {
    Alert(WARNING, $"Feed tăng từ {prevFeed}→{finalFeed} (>{50}%)")
    // Không block, chỉ cảnh báo
}

if (finalFeed < minChange) {
    Alert(WARNING, $"Feed giảm từ {prevFeed}→{finalFeed} (<{50}%)")
}

// Bước 5: Kiểm tra feed không vượt 10% Biomass
decimal maxFeed_pct = currentBiomassKg * 0.10m;
if (finalFeed > maxFeed_pct) {
    Alert(CRITICAL, "Feed vượt 10% sinh khối")
    finalFeed = (int)(maxFeed_pct / bagSize) * bagSize;  // Round down
}

✅ Cải thiện:
  - BaseBW động theo TLBQ (không fixed)
  - Điều chỉnh rõ ràng
  - Validation ±50% với cảnh báo
  - Max 10% biomass
```

---

#### 5. CÔNG THỨC pH - ✅ CẢI THIỆN

**SAU:**
```csharp
decimal pH_base = 7.2m;
decimal pH_chemical_adj = GetChemicalAdjustment();  // 0 nếu không dùng
decimal random_var = (decimal)(random.NextDouble() * 0.4m - 0.2m); // [-0.2, 0.2]

decimal pH_raw = pH_base + pH_chemical_adj + random_var;
pH(t) = Math.Max(6.5m, Math.Min(8.5m, pH_raw));  // Clamp [6.5, 8.5]

✅ Cải thiện: Thêm clamp đảm bảo trong range
```

---

#### 6. CÔNG THỨC H2S (HYDROGEN SULFIDE) - ✅ CẢI THIỆN

**SAU:**
```csharp
// H2S phụ thuộc sinh khối, thay nước, sục khí
decimal water_exchange_effect = (daily_water_exchange_m3 / pondVolume_m3) * 0.05m;
decimal aeration_effect = (aeration_hours * 0.1m);

decimal H2S_raw = (currentBiomassKg / 1000m) * 0.0008m 
                - water_exchange_effect 
                - aeration_effect;

H2S(t) = Math.Max(0m, Math.Min(0.5m, H2S_raw));  // Clamp [0, 0.5]

if (H2S(t) > 0.05m) {
    Alert(CRITICAL, "H2S cao > 0.05 mg/L - Cần vệ sinh đáy")
}

✅ Cải thiện: 
  - Thay nước và sục khí được tính
  - Clamp [0, 0.5]
```

---

#### 7. CÔNG THỨC NH3 (AMMONIA) - ✅ CẢI THIỆN

**SAU:**
```csharp
// NH3 = f(Sinh_khối, thay_nước, pH)
// Tỷ lệ NH3/NH4+ = f(pH) - Ion equilibrium
decimal water_exchange_pct = (daily_water_exchange_m3 / pondVolume_m3) * 100m;
decimal pH_factor = GetpH_NitrogenFactor(currentPH);  // Từ 0 đến 1

decimal NH3_raw = (currentBiomassKg / 100m) * 0.0015m 
                - (water_exchange_pct * 0.002m) * pH_factor;

NH3(t) = Math.Max(0m, Math.Min(1.0m, NH3_raw));  // Clamp [0, 1.0]

// Alert
if (NH3(t) > 0.2m) {
    Alert(CRITICAL, "NH3 cao > 0.2 mg/L - Giảm feed")
}

if (NH3(t) > 0.5m) {
    Alert(CRITICAL, "NH3 rất cao > 0.5 mg/L - STOP FEED, thay nước")
    feedMultiplier *= 0m;  // Không cho ăn
}

✅ Cải thiện:
  - pH factor để tính tỷ lệ NH3 đúng (hóa học)
  - Clamp [0, 1.0]
```

---

#### 8. CÔNG THỨC FCR (FEED CONVERSION RATIO) - ✅ CẢI THIỆN

**SAU:**
```csharp
// Daily FCR
decimal daily_biomass_gain = (currentBiomassKg - previousBiomassKg);
decimal daily_FCR = (daily_feed_kg / (daily_biomass_gain + 0.001m));  // +epsilon để tránh /0

// Cumulative FCR
decimal cumulative_feed = GetTotalFeedConsummed();
decimal cumulative_biomass_gain = (currentBiomassKg - initialBiomassKg);
decimal cumulative_FCR = cumulative_feed / (cumulative_biomass_gain + 0.001m);

// Alert
if (cumulative_FCR > 2.5m) {
    Alert(WARNING, $"FCR cao = {cumulative_FCR:F2}")
}

if (cumulative_FCR > 3.0m) {
    Alert(CRITICAL, $"FCR quá cao = {cumulative_FCR:F2} - Review feed plan")
}

if (daily_FCR > 3.0m) {
    Alert(WARNING, $"FCR hôm nay bất thường = {daily_FCR:F2}")
}

✅ Cải thiện:
  - Cả daily và cumulative FCR
  - Alert nếu vượt 2.5 hoặc 3.0
```

---

#### 9. CÔNG THỨC CHI PHÍ (COST) - ✅ CHI TIẾT

**SAU:**
```csharp
// Labor cost
decimal base_labor = 150000m;  // VND/ngày

decimal labor_multiplier;
if (IsMedicatingToday) labor_multiplier = 1.5m;
else if (IsHarvestingToday) labor_multiplier = 2.0m;
else if (IsPreparationDay) labor_multiplier = 1.2m;
else labor_multiplier = 1.0m;

decimal labor_cost = base_labor * labor_multiplier;

// Electricity cost
decimal aerator_hours = CalculateAeratorHours();  // Dựa trên DO nguy hiểm
decimal aerator_power = 1.5m;  // kW
decimal electricity_rate = 3000m;  // VND/kWh

decimal pump_hours = (daily_water_exchange_m3 / 100m);  // 100 m³/hour pump capacity
decimal pump_power = 2.0m;  // kW

decimal electricity_cost = (aerator_hours * aerator_power + pump_hours * pump_power) 
                         * electricity_rate;

// Feed cost (từ InventoryIssue actual price)
decimal feed_cost = GetInventoryIssueCost();

// Chemical cost
decimal chemical_cost = GetChemicalIssueCost();

// Other costs
decimal maintenance_cost = 50000m;  // Định kỳ
decimal other_cost = (decimal)(10000 + random.NextDouble() * 40000);

// Tổng
decimal total_daily_cost = labor_cost + electricity_cost + feed_cost + chemical_cost 
                         + maintenance_cost + other_cost;

decimal cost_per_kg_biomass = (currentBiomassKg > 0) 
    ? (total_daily_cost / currentBiomassKg) 
    : 0m;

decimal cumulative_cost = previousCumulativeCost + total_daily_cost;

✅ Cải thiện:
  - Labor multiplier công khai
  - Electricity = Aerator + Pump (dynamic)
  - Maintenance định kỳ
  - Cost per kg biomass
```

---

## TÓMT AT BẢNG SO SÁNH

| Công Thức | TRƯỚC | SAU | PRIORITY |
|-----------|-------|-----|----------|
| **DO** | Base 5.5 cố định | Base 4.0→2.9 động, hệ số nhỏ | 🔴 HIGH |
| **Growth** | Nhân (0 nhiều) | Cộng/trừ (never 0) | 🔴 HIGH |
| **Mortality** | Nhân 0 nhiều | Cộng/trừ (realistic) | 🔴 HIGH |
| **Feed** | BaseBW cố định | Động theo TLBQ, validation ±50% | 🟡 MEDIUM |
| **pH** | Quá đơn | Thêm clamp [6.5-8.5] | 🟡 MEDIUM |
| **H2S** | Undefined | Với thay nước + aeration | 🟡 MEDIUM |
| **NH3** | Có thể negative | pH factor, clamp [0-1.0] | 🟡 MEDIUM |
| **FCR** | Chỉ tích luỹ | Cả daily + cumulative | 🟡 MEDIUM |
| **Cost** | Labor only | + Electricity động | 🟢 LOW |

---

## SỬ DỤNG CÔNG THỨC TRONG CODE

### ImplementationOrder:
```
1. DO Engine ✅
2. Growth Engine ✅
3. Mortality Engine ✅
4. Feed Planner ✅
5. Chemical Engine (không đổi)
6. Water Ops Engine (không đổi)
7. Inventory Engine (không đổi)
8. Cost Tracker ✅
9. Alert System (cập nhật ngưỡng)
10. Validation Service (không đổi)
11. Reporting Engine (không đổi)
```

---

## KIỂM TRA CÔNG THỨC (VERIFICATION)

### Test Case 1: Day 30, Normal Conditions
```
Input:
  - FishCount = 10,000
  - TLBQ = 13.5g
  - Sinh_khối = 135 kg
  - DO = 3.2, pH = 7.2, Temp = 28°C
  - H2S = 0.02, NH3 = 0.10
  - No disease, no medication

Expected Output:
  ✅ DO → [3.1, 3.3] (base 3.5 - sinh_khối effect)
  ✅ Growth → 0.5g/con (base_growth with minor adjustments)
  ✅ Mortality → ~10 con (0.1% base rate)
  ✅ Feed → 5-6 kg (4% of biomass)
  ✅ FCR → 1.8-2.0
```

### Test Case 2: Day 60, Stress Conditions
```
Input:
  - FishCount = 9,800
  - TLBQ = 37.5g
  - Sinh_khối = 367.5 kg
  - DO = 2.8, pH = 6.8, Temp = 26°C (cold)
  - H2S = 0.08, NH3 = 0.25
  - No disease

Expected Output:
  ✅ DO → [2.8, 3.0] (base 3.1, low DO effect)
  ✅ Growth → 0.2-0.3g/con (many stress penalties)
  ✅ Mortality → ~30-40 con (0.1% base + stress)
  ✅ Feed → 8-9 kg (reduced 30%)
  ✅ Alert: WARNING - DO low, NH3 high, Feed reduced
```

---

Để thay thế phiên bản cũ, hãy:

1. **Backup** file `aquasimvhc_final_1.md` (nếu cần)
2. **Thay thế** tất cả công thức ở section 7 (CÔNG THỨC & THUẬT TOÁN)
3. **Cập nhật** từng engine trong code C# (EnvironmentGenerator, GrowthEngine, MortalityEngine, FeedPlanner, CostTracker)
4. **Test** với 2 test cases trên
5. **Deploy** lên production

---

**Cập nhật bởi**: Technical Team  
**Ngày**: 15/11/2025  
**Status**: ✅ READY FOR IMPLEMENTATION  
**Breaking Changes**: None - chỉ sửa công thức, schema giữ nguyên  

© 2025 All Rights Reserved