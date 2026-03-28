# API 轉換工作流程參考

## 轉換工作流架構

```
┌─────────────────────────────────────────────────────────────┐
│ 步驟 1: 文件準備                                              │
│ 支援格式: .docx, .xlsx, .pdf, .md, .txt                    │
│ 輸入: API 規格文檔                                           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 步驟 2: 文件解析                                              │
│ 提取: HTTP 方法、端點、參數、回應、錯誤處理                 │
│ 輸出: 結構化 API 信息                                        │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 步驟 3: Gherkin 生成                                         │
│ 每個 API → 一個 .feature 檔                                 │
│ 包含:                                                        │
│  - 功能描述 (Feature)                                       │
│  - 背景 (Background)                                        │
│  - 正向測試 (Scenario - Happy Path)                         │
│  - 反向測試 (Scenario - Error Cases)                        │
│  - 邊界測試 (Scenario - Boundary Values)                    │
│ 輸出: .feature 檔案到 ./features                           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 步驟 4: 列表生成                                              │
│ 輸出:                                                        │
│  - API-INVENTORY.md (API 清單)                             │
│  - REVIEW-CHECKLIST.md (審查檢查清單)                       │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 步驟 5: 品質檢查                                              │
│ - Gherkins 語法驗證                                         │
│ - 場景覆蓋驗證                                              │
│ - API 與 feature 對應驗證                                   │
│ - 輸出完整性檢查                                            │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 步驟 6: BA/SA 審查                                           │
│ 審查內容:                                                    │
│  - API 完整性 (所有端點都已涵蓋)                            │
│  - 測試場景合理性                                          │
│  - Gherkins 品質 (清晰、可執行)                             │
│ 反饋: 調整並重新迭代                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 詳細轉換過程

### 步驟 1: 文件解析 (Document Parsing)

根據不同的輸入格式，提取關鍵資訊：

#### Markdown (.md)

```markdown
❌ 不容易解析的格式:
這是一個 API，用於建立客戶...
請求包括 name, email...

✅ 易於解析的格式:
## API: Create Customer
- **Method**: POST
- **Endpoint**: /api/customers
- **Request**: name (required), email (required)
- **Success**: 201 Created
- **Errors**: 400 Invalid, 409 Duplicate
```

#### Excel (.xlsx)

```
推薦列:
| HTTP Method | Endpoint | Operation | Auth | 
| Params | Required | Success Status | Success Response |
| Error Status | Error Message | Edge Cases |
```

#### Word (.docx)

```
推薦結構:
- 標題: API 名稱
- 表格 1: 基本信息 (Method, Endpoint, Auth)
- 表格 2: 請求參數
- 表格 3: 回應 (成功和失敗情況)
```

### 步驟 2: API 信息提取 (Information Extraction)

提取的核心信息結構:

```json
{
  "api": {
    "method": "POST",
    "endpoint": "/api/customers",
    "description": "Create a new customer",
    "authentication": "Bearer Token",
    "requestBody": {
      "fields": [
        {
          "name": "name",
          "type": "string",
          "required": true,
          "validation": "1-100 chars",
          "examples": ["John Doe"]
        },
        {
          "name": "email",
          "type": "string",
          "required": true,
          "validation": "valid email, unique",
          "examples": ["john@example.com"]
        }
      ]
    },
    "successResponse": {
      "status": 201,
      "body": {
        "id": "string",
        "name": "string",
        "email": "string",
        "createdAt": "timestamp"
      }
    },
    "errorCases": [
      {
        "status": 400,
        "code": "INVALID_INPUT",
        "message": "name is required",
        "condition": "missing name field"
      },
      {
        "status": 409,
        "code": "DUPLICATE_EMAIL",
        "message": "email already exists",
        "condition": "email already in use"
      }
    ],
    "edgeCases": [
      {
        "description": "name with minimum length",
        "value": "A",
        "expectedStatus": 201
      },
      {
        "description": "name with maximum length",
        "value": "A" * 100,
        "expectedStatus": 201
      }
    ]
  }
}
```

### 步驟 3: Gherkins 場景生成 (Scenario Generation)

針對每個 API，生成多個測試場景：

#### 場景類型分類

```
1. 正向測試 (Happy Path): 2-3 個
   - 所有必填欄位
   - 最小必填欄位
   - 包含選用欄位

2. 反向測試 (Negative Cases): 3-5 個
   - 缺少必填欄位
   - 欄位格式無效
   - 邏輯衝突 (如 duplicate key)
   - 認證/授權問題

3. 邊界值測試 (Boundary Cases): 2-3 個
   - 字段長度邊界 (1, max, max+1)
   - 數值邊界
   - 特殊字符

4. 業務邏輯測試 (Business Logic): 1-2 個
   - 依賴關係
   - 狀態轉換
```

#### 場景生成規則

```gherkin
# 規則 1: 每個必填字段缺失 → 一個 negative scenario
Given API POST /api/customers 有必填欄位 [name, email]
Then 生成 Scenario: "缺少 name" 和 "缺少 email"

# 規則 2: 每個錯誤狀態 → 至少一個 scenario
Given API 文件列出 400, 409, 401, 500 錯誤
Then 生成 4 個 error handling scenarios

# 規則 3: 字段長度限制 → 邊界測試
Given 欄位約束 "name: 1-100 chars"
Then 生成 Scenario 測試 1, 50, 100, 0, 101 字符

# 規則 4: Unique 欄位 → duplicate 測試
Given 欄位標記為 "unique"
Then 生成 Scenario 測試重複值的 409 響應
```

### 步驟 4: Feature 檔案組織

```
./features/
├── customer-create.feature      # POST /api/customers
├── customer-get.feature         # GET /api/customers/{id}
├── customer-update.feature      # PUT /api/customers/{id}
├── customer-delete.feature      # DELETE /api/customers/{id}
├── customer-list.feature        # GET /api/customers
├── API-INVENTORY.md             # API 清單
└── REVIEW-CHECKLIST.md          # BA/SA 審查清單
```

### 步驟 5: API 清單生成 (Inventory Generation)

```markdown
# API 清單 API-INVENTORY.md

生成欄位:
- 序號
- HTTP 方法
- 端點
- 功能描述
- Feature 檔名
- 總 Scenario 數
- 正向 Scenario 數  
- 反向 Scenario 數
- 邊界 Scenario 數

範例:
| # | Method | Endpoint | Description | Feature | S | P | N | B |
|----|--------|----------|-------------|---------|---|---|---|---|
| 1 | POST | /api/customers | Create | customer-create.feature | 6 | 2 | 3 | 1 |
| 2 | GET | /api/customers/{id} | Read | customer-get.feature | 4 | 1 | 2 | 1 |

統計:
- 總 API 數: 5
- 總 Feature 檔: 5
- 總 Scenario: 22
- 平均每 API Scenario 數: 4.4
- 正/反向比例: 9:13
```

### 步驟 6: 審查檢查清單生成 (Review Checklist Generation)

```markdown
# REVIEW-CHECKLIST.md

## API 完整性檢查
☐ 所有 API 端點都已列出
☐ 每個端點都有對應的 .feature 檔
☐ 端點的 HTTP 方法正確
☐ 功能描述清晰

## 測試覆蓋檢查
☐ 每個 API 都有正向測試
☐ 所有錯誤情況都被測試
☐ 邊界值都被覆蓋
☐ 認證/授權都被測試

## Gherkins 品質檢查
☐ Scenario 標題清晰
☐ Given-When-Then 結構正確
☐ 使用一致的語言 (中文 or 英文)
☐ 沒有重複的 Scenario

## 簽核欄位
| 角色 | 姓名 | 日期 | 批准 |
|-----|------|------|------|
| BA | | | ☐ |
| SA | | | ☐ |
| QA | | | ☐ |
```

---

## 轉換常見問題

### Q1: 如何判斷 API 文件是否符合轉換條件？

**檢查清單**:
- ✅ 包含 HTTP 方法 (GET, POST, etc.)
- ✅ 包含明確的端點路徑
- ✅ 列出所有請求參數和類型
- ✅ 說明成功和失敗的回應
- ✅ 標注哪些欄位是必填

**如果缺少**:
- ❌ 邊界值信息 → 詢問並補充
- ❌ 錯誤情況詳情 → 與團隊討論新增
- ❌ 認證方式 → 假設 Bearer Token

### Q2: 一個 API 應該生成多少個 Scenario？

**推薦規則**:
```
基礎: 3-4 個 (1 Happy Path + 2-3 Error Cases)
+ 每個必填欄位: 1 個缺失測試
+ 每個有長度限制的欄位: 1-2 個邊界測試
+ 每個 unique 欄位: 1 個 duplicate 測試

範例:
API 參數: [name (required, 1-100), email (required, unique)]
→ 基礎 3 個
→ + 1 個 missing name
→ + 1 個 missing email  
→ + 2 個邊界測試 (name length)
→ + 1 個 duplicate email
總計: ~8 個 Scenario
```

### Q3: Gherkins 中應該使用什麼語言？

**推薦**:
- 中文優先（符合 BA/SA 習慣）
- 英文作為補充（便於國際化）
- 保持一致（不混用）

### Q4: Feature 檔如何組織？

**選項 1: 按 API 端點** (推薦)
```
customer-create.feature
customer-read.feature
customer-update.feature
customer-delete.feature
```

**選項 2: 按功能模塊**
```
customer-management.feature    # 包含 CRUD
order-management.feature
```

**推薦理由**:
- 一個 API → 一個 .feature 檔
- 便於並行測試執行
- 責任明確

---

## 轉換後驗證

### 檢查項目

```bash
# 1. 語法驗證
✅ 所有 .feature 檔都符合 Gherkins 語法
✅ 沒有 Scenario 或 step 缺失定義

# 2. 覆蓋驗證
✅ 每個 API 都有對應 .feature 檔
✅ 每個 .feature 都有 Feature 標題
✅ 每個 Scenario 都有 Given-When-Then

# 3. 一致性驗證
✅ 語言使用一致 (中文 or 英文)
✅ Scenario 命名風格一致
✅ Step 語句形式一致

# 4. 品質驗證
✅ 沒有過長的 Scenario (>8 steps)
✅ 沒有重複的 Scenario
✅ 每個 Scenario 有明確的目的
```

---

## BA/SA 審查要點

### 需要檢查的內容

| 項目 | 檢查點 | Yes/No |
|------|--------|--------|
| **功能完整** | 是否覆蓋所有 API 功能 | ☐ |
| **場景合理** | 場景設計是否符合業務邏輯 | ☐ |
| **正反向** | 是否既有成功又有失敗場景 | ☐ |
| **邊界** | 是否測試了邊界和極端情況 | ☐ |
| **可讀性** | 場景標題和步驟是否清晰 | ☐ |
| **可執行性** | Gherkins 是否能實現自動化 | ☐ |

### 常見反饋和調整

```
反饋 1: "這個錯誤情況不太可能發生"
→ 移除或標記為低優先級

反饋 2: "缺少對權限的測試"
→ 添加認證/授權 Scenario

反饋 3: "Scenario 標題太技術化"
→ 改為業務導向的標題
   ❌ "Validate email regex pattern"
   ✅ "驗證 email 格式有效"

反饋 4: "邊界值設定不合理"
→ 根據實際需求調整
   例: name 長度上限實際是 50，不是 100
```

---

## 與自動化測試框架集成

生成的 .feature 檔可直接用於:

### Cucumber (Java/JavaScript)
```bash
# 使用 Cucumber Runner
mvn test -Dcucumber.filter.tags="@api"

# 需要實現 Step Definitions
src/test/java/com/example/customer/CustomerStepDefinitions.java
```

### SpecFlow (.NET)
```bash
# 使用 SpecFlow
dotnet test

# 需要實現 StepDefinition 類
Features/Customer/CustomerCreate.feature
```

### Behave (Python)
```bash
# 運行測試
behave features/

# 需要實現 step_impl.py
```

### REST Assured / Rest-AutoIt
```bash
# 自動化 API 測試
# Step Definition 實現 HTTP 調用
# 驗證響應狀態和內容
```

---

## 迭代優化

### 第 1 輪: 初次轉換
```
輸入: API 文件
輸出: Feature 檔初稿
時間: ~1-2 小時 (視 API 複雜度)
```

### 第 2 輪: BA/SA 審查
```
輸入: Feature 檔初稿 + 審查意見
調整: 補充場景、調整文案、移除冗餘
時間: ~1-2 天
```

### 第 3 輪: QA 實現
```
輸入: 確認的 Feature 檔
實現: Step Definitions、自動化框架
驗證: 所有 Scenario 都能執行
時間: ~2-3 天 (視複雜度)
```

---

## 輸出物清單

轉換完成後，應包含:

```
./features/
├── ✅ {api-name}-{operation}.feature (多個文件)
├── ✅ API-INVENTORY.md
├── ✅ REVIEW-CHECKLIST.md
└── ✅ README.md (可選，說明如何使用)

統計:
- 總 API 數: __
- 總 Feature 檔: __
- 總 Scenario 數: __
- 預計自動化時間: __
```

---

**下一步**: 開始轉換你的 API 文件！在聊天中提供文件路徑，我會自動執行上述所有步驟。
