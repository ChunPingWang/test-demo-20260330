# 快速開始指南 (Quick Start)

## 5 分鐘快速上手

### 1️⃣ 準備你的 API 文件

支援格式: **Word (.docx), Excel (.xlsx), PDF, Markdown (.md), Text (.txt)**

**最簡單的格式** - Markdown:

```markdown
## API: 建立客戶

- **方法**: POST
- **端點**: /api/customers
- **描述**: 建立新客戶
- **參數**:
  - name (string, 必須): 客戶名稱
  - email (string, 必須): 電子郵件
- **成功**: 201 Created, 返回 Customer ID
- **失敗**: 
  - 400: name 或 email 缺失
  - 409: email 已存在
```

### 2️⃣ 在聊天中使用此 Skill

```
請使用 01-api-to-gherkin 技能，將我的 API 文件轉換為 Gherkins feature 檔:

文件位置: ./docs/api-spec.md
輸出目錄: ./features (預設)
```

### 3️⃣ 我會為你:

✅ 解析 API 文件  
✅ 生成 feature 檔 (到 ./features)  
✅ 建立 API 清單  
✅ 生成審查檢查清單  

### 4️⃣ 審查和迭代

- 打開 `./features/` 目錄查看生成的 feature 檔
- 查看 `API-INVENTORY.md` 了解 API 對應關係
- 查看 `REVIEW-CHECKLIST.md` 準備 BA/SA 審查
- 根據反饋調整場景

---

## 範例: 完整的轉換流程

### 輸入: customer-api.md

```markdown
# Customer Management API

## Create Customer
- Method: POST
- Endpoint: /api/customers
- Description: Create new customer
- Auth: Bearer Token

### Request
- name (string, required): 1-100 chars
- email (string, required): valid email, unique
- phone (string, optional)

### Success (201)
Returns Customer object with id, name, email, phone, createdAt

### Errors
- 400: Missing name or email, invalid email format
- 409: Email already exists
- 401: Unauthorized (missing/invalid token)
```

### 執行轉換

```
我有一個 API 文件: ./docs/customer-api.md

請使用 01-api-to-gherkin 進行轉換:
- 解析 API 定義
- 生成 feature 檔
- 產生 API 清單和審查清單
```

### 輸出: ./features/customer-create.feature

```gherkin
Feature: 建立客戶 (Create Customer)
  作為 API 使用者
  我希望能建立新客戶
  以便 管理客戶資訊

  Background:
    Given API 基底 URL 為 "http://localhost:8080"
    And Content-Type 設定為 "application/json"
    And Authorization header 已設定

  Scenario: 成功建立客戶 - 所有必填欄位
    When 我發送 POST 請求到 "/api/customers" 含以下資料
      | 欄位 | 值 |
      | name | John Doe |
      | email | john@example.com |
    Then 回應狀態碼應為 201
    And 回應中應包含 Customer ID
    And 回應中的 name 應為 "John Doe"

  Scenario: 成功建立客戶 - 包含選用欄位
    When 我發送 POST 請求到 "/api/customers" 含以下資料
      | 欄位 | 值 |
      | name | John Doe |
      | email | john@example.com |
      | phone | 123-456-7890 |
    Then 回應狀態碼應為 201
    And 回應中的 phone 應為 "123-456-7890"

  Scenario: 建立失敗 - 缺少 name 欄位
    When 我發送 POST 請求到 "/api/customers" (不含 name)
      | 欄位 | 值 |
      | email | john@example.com |
    Then 回應狀態碼應為 400
    And 錯誤訊息應包含 "name is required"

  Scenario: 建立失敗 - Email 已存在
    Given 系統已存在 email 為 "existing@example.com" 的客戶
    When 我發送 POST 請求到 "/api/customers" 含以下資料
      | 欄位 | 值 |
      | name | Other User |
      | email | existing@example.com |
    Then 回應狀態碼應為 409
    And 錯誤訊息應包含 "email already exists"

  Scenario: 建立失敗 - 無效的 email 格式
    When 我發送 POST 請求到 "/api/customers" 含以下資料
      | 欄位 | 值 |
      | name | John Doe |
      | email | invalid-email |
    Then 回應狀態碼應為 400
    And 錯誤訊息應包含 "invalid email format"

  Scenario: 建立失敗 - name 超出長度限制
    When 我發送 POST 請求到 "/api/customers" 含以下資料
      | 欄位 | 值 |
      | name | {'A'*101} |
      | email | john@example.com |
    Then 回應狀態碼應為 400
    And 錯誤訊息應包含 "exceeds maximum length"

  Scenario: 建立失敗 - 無效或缺少認證令牌
    When 我發送 POST 請求到 "/api/customers" (不含 Authorization header)
      | 欄位 | 值 |
      | name | John Doe |
      | email | john@example.com |
    Then 回應狀態碼應為 401
    And 錯誤訊息應包含 "unauthorized"
```

### 輸出: ./features/API-INVENTORY.md

```markdown
# API 清單

| # | Method | Endpoint | 功能 | Feature 檔 | 總 Scenario |
|---|--------|----------|------|-----------|------------|
| 1 | POST | /api/customers | 建立客戶 | customer-create.feature | 7 |

**統計資訊**
- 總 API 數: 1
- 總 Feature 檔: 1
- 總 Scenario 數: 7
- 正向 Scenario: 2
- 反向 Scenario: 5

**下一步**: 提交 BA/SA 審查
```

### 輸出: ./features/REVIEW-CHECKLIST.md

```markdown
# 審查檢查清單

## API 完整性
- [x] 所有 API 都已涵蓋
- [x] 每個 API 有對應 feature 檔
- [x] HTTP 方法正確
- [x] 功能描述清晰

## 測試覆蓋
- [x] 包含正向測試 (Happy Path)
- [x] 包含邊界值測試
- [x] 包含錯誤處理測試
- [x] 包含認證測試

## Gherkins 品質
- [x] Scenario 標題清晰
- [x] Given-When-Then 結構正確
- [x] 語言一致 (繁體中文)
- [x] 沒有重複場景

## 審查簽核

| 角色 | 姓名 | 簽核日期 | 批准 |
|-----|------|---------|------|
| BA | | | ☐ |
| SA | | | ☐ |
| QA Lead | | | ☐ |

**審查意見**:
_請在此填寫審查意見_
```

---

## 常見用案例

### 案例 1: 單個 API 轉換

```
我有一個 REST API:
- POST /api/customers
- 請求: name, email, phone
- 成功: 201 + customer ID
- 失敗: 400, 409

請轉換為 feature 檔和測試場景。
```

### 案例 2: 整個系統 API 轉換

```
我有一份完整的 API 規格文檔 (docs/api-spec.docx):
- 5 個 API 端點
- CRUD 操作
- 複雜的業務邏輯

請:
1. 解析所有 API
2. 為每個 API 生成 feature 檔
3. 建立 API 清單和審查清單
```

### 案例 3: 已有 Feature 檔，需要優化

```
我已經有一些 feature 檔 (./features/),
但想添加更全面的邊界值和錯誤場景。

請根據 API 規格優化這些 feature 檔。
```

---

## 常見問題

### Q: 我的 API 文件格式不標準怎麼辦？

**A**: 沒關係！只要文件中包含以下信息，我都能解析:
- API 端點 (URL)
- HTTP 方法
- 請求參數
- 成功/失敗回應

### Q: 生成的 Scenario 太多/太少？

**A**: 可以調整，告訴我:
- 🔍 "為每個 API 生成 5-6 個 Scenario"
- 🔍 "只生成基礎正反向測試，不要邊界值"
- 🔍 "重點關注認證和權限測試"

### Q: 可以修改生成的 feature 檔嗎？

**A**: 當然可以！Feature 檔生成後:
- 可以直接編輯
- 可以添加更多 Scenario
- 可以用於自動化測試框架

### Q: 如何與我的測試框架集成？

**A**: 生成的 .feature 檔可用於:
- **Cucumber** (Java): 實現 Step Definitions
- **SpecFlow** (.NET): 實現 StepDefinition 類
- **Behave** (Python): 實現 step_impl.py
- **REST Assured**: 直接支援 API 測試

詳見 [轉換工作流參考](./references/conversion-workflow.md)

---

## 最佳實踐

### ✅ 準備 API 文件的技巧

1. **清楚的端點**
   ```
   ✅ POST /api/customers
   ❌ customer 創建端點
   ```

2. **完整的參數信息**
   ```
   ✅ name (string, required, 1-100 chars)
   ❌ 名稱
   ```

3. **明確的失敗情況**
   ```
   ✅ 400: Missing name | 409: Email exists | 401: Auth failed
   ❌ 可能失敗
   ```

### ✅ 审查生成的 Feature 檔

1. **檢查 Scenario 覆蓋**
   - 正向測試夠嗎？
   - 邊界值都測試了嗎？
   - 所有錯誤都有對應 Scenario？

2. **檢查 Given-When-Then 結構**
   - 是否有明確的前置條件？
   - 操作是否清晰？
   - 期望結果是否具體？

3. **檢查語言和命名**
   - Scenario 標題是否清晰？
   - Step 是否用一致的語言？
   - 有沒有技術細節混入？

---

## 獲取更多幫助

- 📖 [API 定義模板](./templates/api-definition-template.md) - 看有哪些格式
- 📖 [Gherkin 場景模板](./templates/gherkin-scenario-template.md) - 參考各種場景類型
- 📖 [轉換工作流參考](./references/conversion-workflow.md) - 了解完整的轉換過程

---

**準備好了嗎？** 在聊天中提供你的 API 文件，我會立即開始轉換！
