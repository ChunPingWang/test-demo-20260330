# API 清單 (API Inventory)

## 摘要

本文檔列舉了 Customer Management API 的所有端點及其對應的 Gherkins feature 檔案。

---

## API 清單

| # | HTTP 方法 | 端點 | 功能描述 | Feature 檔案 | Total Scenarios | Positive | Negative | Boundary |
|---|----------|------|--------|-------------|-----------------|----------|----------|----------|
| 1 | GET | `/api/customers` | 取得所有客戶列表 | customer-list.feature | 4 | 2 | 1 | 1 |
| 2 | GET | `/api/customers/{id}` | 根據 ID 取得客戶 | customer-get.feature | 7 | 2 | 3 | 2 |
| 3 | POST | `/api/customers` | 建立新客戶 | customer-create.feature | 18 | 3 | 7 | 8 |
| 4 | PUT | `/api/customers/{id}` | 更新客戶資訊 | customer-update.feature | 17 | 3 | 6 | 8 |
| 5 | DELETE | `/api/customers/{id}` | 刪除客戶 | customer-delete.feature | 10 | 3 | 4 | 2 |

---

## 統計資訊

### 總計
- **總 API 數量**: 5
- **總 Feature 檔案**: 5
- **總 Scenario 數量**: 56

### 場景分佈
- **正向 Scenario (Happy Path)**: 13 個 (23.2%)
- **反向 Scenario (Negative Cases)**: 21 個 (37.5%)
- **邊界值 Scenario (Boundary Cases)**: 21 個 (37.5%)
- **其他 Scenario (冪等性、時間戳等)**: 1 個 (1.8%)

### API 複雜度分析

| 複雜度 | API | 理由 |
|--------|-----|------|
| 🟢 低 | GET /api/customers | 無參數、無失敗情況 |
| 🟡 中 | GET /api/customers/{id} | 路徑參數驗證、404 錯誤 |
| 🟠 高 | POST /api/customers | 多個欄位、複雜驗證規則、唯一性檢查 |
| 🟠 高 | PUT /api/customers/{id} | 多個欄位、複雜驗證規則、唯一性檢查 |
| 🟡 中 | DELETE /api/customers/{id} | 路徑參數驗證、404 錯誤 |

---

## 測試覆蓋分析

### 必填欄位測試
- ✅ `name` (POST, PUT): 測試缺失、空值、長度限制
- ✅ `email` (POST, PUT): 測試缺失、格式驗證、唯一性、長度限制
- ✅ `id` (GET, PUT, DELETE): 測試無效格式、負數、邊界值

### 選用欄位測試
- ✅ `phone`: 長度限制測試
- ✅ `address`: 長度限制測試

### 驗證規則測試
- ✅ Email 格式驗證 (RFC 5322 基礎)
- ✅ 唯一性約束 (Email 不重複)
- ✅ 長度限制 (name 50, email 100, phone 20, address 200)
- ✅ 時間戳記格式 (ISO 8601)

### 邊界值測試
- ✅ 字符長度邊界 (1, max, max+1)
- ✅ 特殊字符 (', -, +, .)
- ✅ 空值處理
- ✅ 最大 Long 值 ID 測試

### 錯誤情況測試
- ✅ HTTP 400 (Bad Request): 驗證失敗
- ✅ HTTP 404 (Not Found): 資源不存在
- ✅ HTTP 201 (Created): POST 成功
- ✅ HTTP 200 (OK): GET/PUT 成功
- ✅ HTTP 204 (No Content): DELETE 成功

---

## Feature 檔案詳細說明

### 1. customer-list.feature
**目的**: 驗證取得所有客戶列表的功能

**場景覆蓋**:
- ✅ 正常取得多個客戶
- ✅ 取得空列表
- ✅ 回應格式驗證
- ✅ 伺服器錯誤處理

---

### 2. customer-get.feature
**目的**: 驗證根據 ID 取得單個客戶的功能

**場景覆蓋**:
- ✅ 成功取得存在的客戶
- ✅ 驗證時間戳記格式
- ✅ 客戶不存在 (404)
- ✅ 無效 ID 格式 (400)
- ✅ 負數 ID (400)
- ✅ 邊界值 ID (1, 最大值)
- ✅ 浮點數 ID (400)

---

### 3. customer-create.feature
**目的**: 驗證建立新客戶的功能

**場景覆蓋**:
- ✅ 建立包含所有欄位的客戶
- ✅ 建立僅含必填欄位的客戶
- ✅ 建立包含部分選用欄位的客戶
- ✅ 缺少必填欄位 (name, email)
- ✅ Email 格式驗證 (無 @, 無域名)
- ✅ Email 唯一性檢查
- ✅ 長度限制測試 (name, email, phone, address)
- ✅ 特殊字符測試 (', -, +, .)
- ✅ Content-Type 驗證

**測試數量**: 18 個 Scenario

---

### 4. customer-update.feature
**目的**: 驗證更新客戶資訊的功能

**場景覆蓋**:
- ✅ 更新所有欄位
- ✅ 更新部分欄位
- ✅ 清空選用欄位
- ✅ 客戶不存在 (404)
- ✅ 缺少必填欄位
- ✅ Email 格式驗證
- ✅ Email 唯一性檢查 (其他客戶)
- ✅ 無效 ID 格式
- ✅ 長度限制測試
- ✅ 特殊字符測試
- ✅ createdAt 不變、updatedAt 更新驗證

**測試數量**: 17 個 Scenario

---

### 5. customer-delete.feature
**目的**: 驗證刪除客戶的功能

**場景覆蓋**:
- ✅ 成功刪除客戶
- ✅ 驗證刪除後資源不存在
- ✅ 驗證列表更新
- ✅ 客戶不存在 (404)
- ✅ 無效 ID 格式
- ✅ 負數 ID (400)
- ✅ 浮點數 ID (400)
- ✅ 邊界值 ID (1, 最大值)
- ✅ 重複刪除 (冪等性)
- ✅ 刪除後立即查詢

**測試數量**: 10 個 Scenario

---

## 測試優先級

### 優先級 1 (必須執行)
- 所有 happy path 場景
- 所有必填欄位驗證
- 所有錯誤情況測試

### 優先級 2 (應該執行)
- 邊界值測試
- 特殊字符測試
- 唯一性約束測試

### 優先級 3 (可選)
- 極端邊界值 (最大 Long)
- 冪等性測試
- 並發測試 (未包含在此版本)

---

## 建議下一步

1. **實現 Step Definitions**
   - 使用 Cucumber/Java 或其他 BDD 框架
   - 實現 API 調用邏輯
   - 實現斷言驗證

2. **設置 CI/CD**
   - 集成到 Jenkins/GitHub Actions
   - 設定自動化測試運行
   - 生成測試報告

3. **執行測試**
   - 針對開發環境運行
   - 針對測試環境運行
   - 收集測試結果和覆蓋率

4. **維護和更新**
   - 根據 API 變更更新 feature 檔
   - 增加新的邊界值測試
   - 優化現有場景

---

## 相關文件

- [API 審查檢查清單](./REVIEW-CHECKLIST.md)
- [API 定義模板](../.github/skills/01-api-to-gherkin/templates/api-definition-template.md)
- [Gherkins 場景模板](../.github/skills/01-api-to-gherkin/templates/gherkin-scenario-template.md)

---

**生成日期**: 2026-03-29  
**轉換工具**: 01-api-to-gherkin Skill  
**API 版本**: v1  
**Customer API Base URL**: 由 `BASE_URL` 環境變數配置 (默認 `http://localhost:8080`)
