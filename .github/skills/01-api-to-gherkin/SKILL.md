---
name: 01-api-to-gherkin
description: "自動化 API 文件轉換為 Gherkins BDD 測試案例。支援 Word, Excel, PDF, Markdown, Text 等格式。產生包含正反向測試案例的 feature 檔、API 清單，供 BA/SA 審查。使用此技能來：自動解讀API文件、生成Gherkins scenario、設計正反向測試、建立feature檔、生成API對應清單、準備審查文件。"
argument-hint: "提供API文件路徑或URL，指定輸出目錄（預設 ./features）"
---

# API 轉換成 Gherkins BDD 技能

## 概述

本 skill 自動化將 API 文件轉換為可執行的 Gherkins BDD 測試案例，助力團隊更好地定義業務需求、設計測試場景、進行質量控制。

**輸入格式支援**：Word (docx)、Excel (xlsx)、PDF、Markdown (md)、Text (txt)  
**輸出內容**：Feature 檔案、API 清單、審查檔案  
**輸出位置**：`./features` 目錄  

## 應用場景

- 🏗️ **API 規格定義**：從設計文件自動生成可執行的測試
- 🔄 **正反向測試**：自動設計 happy path 與 error cases
- 👥 **BA/SA 審查**：提供結構化的格式便於業務團隊審查
- 📋 **API 清單維護**：自動維護 API 與 feature 檔的對應關係
- ✅ **測試驅動開發**：將 API spec 直接轉換為 executable tests

## 工作流程

### 步驟 1：準備 API 文件

確保 API 文件包含以下資訊：

```
API 端點: POST /api/customers
功能描述: 建立新客戶
請求參數: 
  - name (string, 必須)
  - email (string, 必須)
  - phone (string, 選用)
成功回應: HTTP 201, Customer ID
失敗情況:
  - 缺少必須欄位 → HTTP 400
  - Email 已存在 → HTTP 409
  - 伺服器錯誤 → HTTP 500
```

👉 參考 [API 定義模板](./templates/api-definition-template.md)

### 步驟 2：執行轉換

在終端機執行：

```bash
# 方式 1：使用單一檔案
copilot --skill 01-api-to-gherkin --input ./docs/api-spec.md --output ./features

# 方式 2：使用以下命令邀請 Copilot 進行轉換
# 在聊天中提供：
# 1. API 文件路徑 (支援: .docx, .xlsx, .pdf, .md, .txt)
# 2. 希望的輸出目錄 (預設: ./features)
# 3. 額外需求 (正反向測試、特殊審查項目等)
```

### 步驟 3：產生 Gherkins Feature 檔

根據每個 API 端點產生對應的 `.feature` 檔：

```gherkin
# features/customer-create.feature

Feature: 建立新客戶 (Create Customer)
  作為 API 使用者
  我希望能建立新的客戶記錄
  以便 管理客戶資料

  Background:
    Given API 基底 URL 為 "http://localhost:8080"
    And Content-Type 設定為 "application/json"

  # 正向測試 (Happy Path)
  Scenario: 成功建立客戶 - 所有必填欄位
    Given 準備建立客戶的請求
      | 欄位  | 值          |
      | name  | John Doe    |
      | email | john@example.com |
      | phone | 123-456-7890 |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 201
    And 回應包含 Customer ID
    And 回應的 name 欄位應為 "John Doe"
    And 回應的 email 欄位應為 "john@example.com"

  # 正向測試 - 最小必填
  Scenario: 成功建立客戶 - 僅必填欄位
    Given 準備建立客戶的請求
      | 欄位  | 值          |
      | name  | Jane Doe    |
      | email | jane@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 201
    And 回應包含 Customer ID

  # 反向測試 - 缺少必填欄位
  Scenario: 建立客戶失敗 - 缺少 name
    Given 準備建立客戶的請求 (缺少 name)
      | 欄位  | 值          |
      | email | test@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "name is required"

  Scenario: 建立客戶失敗 - Email 已存在
    Given 系統已存在 Email 為 "existing@example.com" 的客戶
    And 準備建立客戶的請求
      | 欄位  | 值          |
      | name  | Duplicate   |
      | email | existing@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 409
    And 錯誤訊息應包含 "Email already exists"

  # 邊界測試
  Scenario: 建立客戶 - 特殊字符處理
    Given 準備建立客戶的請求
      | 欄位  | 值          |
      | name  | O'Brien-Smith |
      | email | test+tag@example.co.uk |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 201

  Scenario: 建立客戶失敗 - 無效的 Email 格式
    Given 準備建立客戶的請求
      | 欄位  | 值          |
      | name  | Bad Email   |
      | email | invalid-email |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid email format"
```

參考 [Gherkins 場景模板](./templates/gherkin-scenario-template.md)

### 步驟 4：生成 API 清單

自動生成 `./features/API-INVENTORY.md`，列出所有 API 與對應的 feature 檔：

```markdown
# API 清單 (API Inventory)

| Method | Endpoint | 功能描述 | Feature 檔 | 總場景數 |
|--------|----------|---------|-----------|--------|
| POST | /api/customers | 建立客戶 | customer-create.feature | 6 |
| GET | /api/customers/{id} | 取得客戶 | customer-get.feature | 4 |
| PUT | /api/customers/{id} | 更新客戶 | customer-update.feature | 5 |
| DELETE | /api/customers/{id} | 刪除客戶 | customer-delete.feature | 4 |

**統計**
- 總 API 數：4
- 總 Feature 檔：4  
- 總 Scenario 數：19
- 正向 Scenario：9
- 反向 Scenario：10
```

### 步驟 5：準備審查文件

生成 `./features/REVIEW-CHECKLIST.md` 供 BA/SA 審查：

```markdown
# 審查檢查清單 (Review Checklist)

## API 完整性
- [ ] 所有 API 端點都已涵蓋
- [ ] 每個端點的功能描述清晰
- [ ] HTTP 方法正確
- [ ] URL 路徑符合 RESTful 規範

## 測試涵蓋範圍
- [ ] 包含正向測試 (Happy Path)
- [ ] 包含邊界值測試 (Boundary Cases)
- [ ] 包含錯誤處理測試 (Error Cases)
- [ ] 包含權限驗證測試 (Authorization)
- [ ] 包含資料驗證測試 (Data Validation)

## Gherkins 品質
- [ ] Scenario 標題清晰且可執行
- [ ] Given-When-Then 語法正確
- [ ] Step 是業務層面，非技術細節
- [ ] 沒有重複的 Scenario

## 文檔完整性  
- [ ] 有 API 清單和 feature 檔對應關係
- [ ] 每個 feature 檔有明確的背景 (Background)
- [ ] 有測試資料準備說明
- [ ] 有預期結果說明

## 簽核

| 角色 | 姓名 | 簽核日期 | 備註 |
|-----|------|---------|------|
| BA | | | |
| SA | | | |
| QA Lead | | | |

```

## 轉換過程中的最佳實踐

### ✅ 做法

1. **一個 API → 一個 Feature 檔**
   - 便於管理和維護
   - 清晰的職責劃分

2. **完整的 Given-When-Then 結構**
   ```gherkin
   Given 系統初始狀態/前置條件
   When 執行的操作
   Then 預期的結果
   ```

3. **場景命名要清晰**
   - ✅ "成功建立客戶 - 所有必填欄位"
   - ❌ "TC001_Create"

4. **包含邊界和異常**
   - Happy Path (正常case)
   - Boundary Cases (邊界值)
   - Error Cases (異常case)
   - Permission Cases (權限case)

5. **使用 Scenario Outline 處理多個類似case**
   ```gherkin
   Scenario Outline: 驗證各種 email 格式
     When 使用 "<email>" 建立客戶
     Then 結果應為 "<expected>"
     
     Examples:
       | email | expected |
       | test@example.com | 成功 |
       | invalid-email | 失敗 |
   ```

### ❌ 避免

1. **技術細節混入 Scenario**
   - ❌ "解析 JSON 並驗證 email regex pattern"
   - ✅ "驗證 email 格式有效"

2. **過長複雜的 Scenario**
   - 保持在 5-8 步以內
   - 複雜邏輯拆分為多個場景

3. **缺少前置條件 (Background)**
   - 共同的 Given 應放在 Background
   - 避免重複

4. **不一致的語言**
   - 統一使用繁體中文或英文
   - 欄位名稱保持一致

## 執行轉換

當你提供 API 文件時，我會：

1. ✅ 解析並提取所有 API 端點
2. ✅ 為每個 API 設計正反向測試場景
3. ✅ 生成 Gherkins feature 檔到 `./features`
4. ✅ 建立 API 清單 (API-INVENTORY.md)
5. ✅ 產生審查檢查清單 (REVIEW-CHECKLIST.md)
6. ✅ 提供 BA/SA 審查版本供反饋

---

## 工作流需要

| 項目 | 說明 |
|------|------|
| **輸入** | API 文件 (.docx, .xlsx, .pdf, .md, .txt) |
| **工具** | 文件解析、Gherkins 生成、markdown 拼組 |
| **輸出** | Feature 檔、API 清單、審查清單 |
| **位置** | `./features` 目錄 |
| **質量檢查** | 確保 Gherkins 語法正確、場景覆蓋完整 |

---

**建議下一步**：  
1. 準備 API 規格文檔 → 提供給此 skill
2. 生成 feature 檔和 API 清單 → BA/SA 審查
3. 調整和確認 → 集成到自動化測試流程
