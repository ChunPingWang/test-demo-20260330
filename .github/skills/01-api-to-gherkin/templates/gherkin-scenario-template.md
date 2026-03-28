# Gherkins BDD 場景設計模板

## Gherkins 基本結構

```gherkin
Feature: 功能名稱（中文或英文）
  作為 <角色>
  我希望 <採取的行動>
  以便 <期望的結果>

  Background:
    Given 共同的前置條件

  Scenario: 場景標題
    Given 初始狀態或前置條件
    When 執行的操作
    Then 預期的結果
```

---

## API 轉換標準模板

### 模式 1：基礎 CRUD 操作

#### CREATE 操作

```gherkin
Feature: 建立資源
  作為 API 使用者
  我希望能建立新的資源
  以便 系統能儲存該資源

  Background:
    Given API 基底 URL 設定為 "{base_url}"
    And Content-Type 設定為 "application/json"
    And 認證令牌已設定

  # =========== 正向 Scenario ===========
  Scenario: 成功建立 - 所有必填欄位
    Given 準備建立資源的請求
      | 欄位 | 值 |
      | name | Test Name |
      | email | test@example.com |
    When 發送 POST 請求到 "{endpoint}"
    Then HTTP 狀態碼應為 201
    And 回應包含 resource ID
    And 回應的 name 應為 "Test Name"

  Scenario: 成功建立 - 最小必填欄位
    Given 準備建立資源的請求
      | 欄位 | 值 |
      | name | Min Test |
    When 發送 POST 請求到 "{endpoint}"
    Then HTTP 狀態碼應為 201
    And 回應包含 resource ID

  Scenario: 成功建立 - 包含選用欄位
    Given 準備建立資源的請求
      | 欄位 | 值 |
      | name | Full Test |
      | email | test@example.com |
      | phone | 123-456-7890 |
      | address | 123 Main St |
    When 發送 POST 請求到 "{endpoint}"
    Then HTTP 狀態碼應為 201
    And 回應包含所有提供的欄位

  # =========== 反向 Scenario ===========
  Scenario: 建立失敗 - 缺少必填欄位 (name)
    Given 準備建立資源的請求 (缺少 name)
      | 欄位 | 值 |
      | email | test@example.com |
    When 發送 POST 請求到 "{endpoint}"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "name is required"
    And 錯誤代碼應為 "INVALID_INPUT"

  Scenario: 建立失敗 - 無效的欄位格式
    Given 準備建立資源的請求
      | 欄位 | 值 |
      | name | Valid Name |
      | email | invalid-email-format |
    When 發送 POST 請求到 "{endpoint}"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid email format"

  Scenario: 建立失敗 - 重複的唯一值
    Given 系統已存在以下資源
      | name | email |
      | Existing | existing@example.com |
    And 準備建立資源的請求
      | 欄位 | 值 |
      | name | New Name |
      | email | existing@example.com |
    When 發送 POST 請求到 "{endpoint}"
    Then HTTP 狀態碼應為 409
    And 錯誤訊息應包含 "email already exists"
    And 錯誤代碼應為 "DUPLICATE_EMAIL"

  # =========== 邊界 Scenario ===========
  Scenario Outline: 驗證 name 欄位邊界值
    Given 準備建立資源的請求
      | 欄位 | 值 |
      | name | <name_value> |
      | email | test@example.com |
    When 發送 POST 請求到 "{endpoint}"
    Then HTTP 狀態碼應為 <expected_status>
    And 錯誤訊息應包含 "<error_msg>"

    Examples:
      | name_value | expected_status | error_msg |
      | A | 201 | |
      | A{'A'*100} | 201 | |
      | A{'A'*101} | 400 | exceeds maximum length |
      | | 400 | name is required |

  Scenario: 驗證電子郵件格式 - 特殊字符
    Given 準備建立資源的請求
      | 欄位 | 值 |
      | name | Test User |
      | email | user+tag@example.co.uk |
    When 發送 POST 請求到 "{endpoint}"
    Then HTTP 狀態碼應為 201

  # =========== 認證/授權 Scenario ===========
  Scenario: 建立失敗 - 缺少認證令牌
    Given 認證令牌未設定
    And 準備建立資源的請求
      | 欄位 | 值 |
      | name | Test |
    When 發送 POST 請求到 "{endpoint}" (不含認証令牌)
    Then HTTP 狀態碼應為 401
    And 錯誤訊息應包含 "unauthorized"

  Scenario: 建立失敗 - 無效的認證令牌
    Given 認證令牌設定為 "invalid_token_12345"
    And 準備建立資源的請求
      | 欄位 | 值 |
      | name | Test |
    When 發送 POST 請求到 "{endpoint}"
    Then HTTP 狀態碼應為 401
    And 錯誤訊息應包含 "invalid token"
```

#### READ 操作

```gherkin
Feature: 查詢資源
  作為 API 使用者
  我希望能查詢現有的資源
  以便 取得資源詳情

  Background:
    Given API 基底 URL 設定為 "{base_url}"
    And 認證令牌已設定
    And 系統已準備好以下測試資源
      | id | name | email |
      | CUST-001 | John Doe | john@example.com |
      | CUST-002 | Jane Smith | jane@example.com |

  # =========== 正向 Scenario ===========
  Scenario: 成功查詢 - 指定 ID
    When 發送 GET 請求到 "{endpoint}/CUST-001"
    Then HTTP 狀態碼應為 200
    And 回應包含 ID 為 "CUST-001" 的資源
    And 回應的 name 應為 "John Doe"
    And 回應的 email 應為 "john@example.com"

  # =========== 反向 Scenario ===========
  Scenario: 查詢失敗 - 資源不存在
    When 發送 GET 請求到 "{endpoint}/NONEXISTENT-ID"
    Then HTTP 狀態碼應為 404
    And 錯誤訊息應包含 "not found"

  Scenario: 查詢失敗 - 無效的資源 ID 格式
    When 發送 GET 請求到 "{endpoint}/invalid_format"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid resource ID format"
```

#### UPDATE 操作

```gherkin
Feature: 更新資源
  作為 API 使用者
  我希望能更新現有的資源
  以便 保持資源資訊最新

  Background:
    Given API 基底 URL 設定為 "{base_url}"
    And 認證令牌已設定
    And 系統已存在以下資源
      | id | name | email |
      | CUST-001 | John Doe | john@example.com |

  # =========== 正向 Scenario ===========
  Scenario: 成功更新 - 更新部分欄位
    Given 準備更新資源的請求 (ID: CUST-001)
      | 欄位 | 值 |
      | name | John Updated |
    When 發送 PUT 請求到 "{endpoint}/CUST-001"
    Then HTTP 狀態碼應為 200
    And 回應的 name 應為 "John Updated"
    And 回應的 email 應為 "john@example.com" (未改變)

  Scenario: 成功更新 - 更新所有欄位
    Given 準備更新資源的請求 (ID: CUST-001)
      | 欄位 | 值 |
      | name | Jane Doe |
      | email | jane.doe@example.com |
      | phone | 987-654-3210 |
    When 發送 PUT 請求到 "{endpoint}/CUST-001"
    Then HTTP 狀態碼應為 200
    And 回應的 name 應為 "Jane Doe"
    And 回應的 email 應為 "jane.doe@example.com"

  # =========== 反向 Scenario ===========
  Scenario: 更新失敗 - 資源不存在
    Given 準備更新資源的請求 (ID: NONEXISTENT)
      | 欄位 | 值 |
      | name | New Name |
    When 發送 PUT 請求到 "{endpoint}/NONEXISTENT"
    Then HTTP 狀態碼應為 404
    And 錯誤訊息應包含 "not found"

  Scenario: 更新失敗 - 無效的欄位值
    Given 準備更新資源的請求 (ID: CUST-001)
      | 欄位 | 值 |
      | email | invalid-email |
    When 發送 PUT 請求到 "{endpoint}/CUST-001"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid email format"

  Scenario: 更新失敗 - 嘗試更新為已存在的 email
    Given 系統已存在 email 為 "existing@example.com" 的資源
    And 準備更新資源的請求 (ID: CUST-001)
      | 欄位 | 值 |
      | email | existing@example.com |
    When 發送 PUT 請求到 "{endpoint}/CUST-001"
    Then HTTP 狀態碼應為 409
    And 錯誤訊息應包含 "email already exists"
```

#### DELETE 操作

```gherkin
Feature: 刪除資源
  作為 API 使用者
  我希望能刪除現有的資源
  以便 清理不需要的資源

  Background:
    Given API 基底 URL 設定為 "{base_url}"
    And 認證令牌已設定
    And 系統已存在以下資源
      | id | name |
      | CUST-001 | John Doe |
      | CUST-002 | Jane Smith |

  # =========== 正向 Scenario ===========
  Scenario: 成功刪除 - 指定資源
    When 發送 DELETE 請求到 "{endpoint}/CUST-001"
    Then HTTP 狀態碼應為 204
    And 系統不再包含 ID 為 "CUST-001" 的資源

  Scenario: 驗證刪除後無法查詢
    When 發送 DELETE 請求到 "{endpoint}/CUST-001"
    And 發送 GET 請求到 "{endpoint}/CUST-001"
    Then HTTP 狀態碼應為 404

  # =========== 反向 Scenario ===========
  Scenario: 刪除失敗 - 資源不存在
    When 發送 DELETE 請求到 "{endpoint}/NONEXISTENT-ID"
    Then HTTP 狀態碼應為 404
    And 錯誤訊息應包含 "not found"

  Scenario: 刪除失敗 - 無效的資源 ID
    When 發送 DELETE 請求到 "{endpoint}/invalid_format"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid"
```

---

## 特殊場景模板

### 查詢列表 (List/Search)

```gherkin
Feature: 查詢資源列表
  作為 API 使用者
  我希望能查詢資源列表並進行過濾
  以便 找到所需資源

  Background:
    Given API 基底 URL 設定為 "{base_url}"
    And 系統已存在以下資源
      | id | name | status |
      | RES-001 | Resource A | active |
      | RES-002 | Resource B | active |
      | RES-003 | Resource C | inactive |

  Scenario: 獲取所有資源
    When 發送 GET 請求到 "{endpoint}"
    Then HTTP 狀態碼應為 200
    And 回應應包含 3 個資源

  Scenario: 篩選資源 - 按 status
    When 發送 GET 請求到 "{endpoint}?status=active"
    Then HTTP 狀態碼應為 200
    And 回應應包含 2 個 active 資源
    And 回應不應包含 status 為 inactive 的資源

  Scenario: 分頁查詢
    When 發送 GET 請求到 "{endpoint}?page=1&limit=2"
    Then HTTP 狀態碼應為 200
    And 回應應包含 2 個資源
    And 回應應包含分頁信息 (total, page, limit)

  Scenario: 空結果查詢
    When 發送 GET 請求到 "{endpoint}?status=nonexistent"
    Then HTTP 狀態碼應為 200
    And 回應應包含 0 個資源
```

### 批量操作

```gherkin
Feature: 批量建立資源
  作為 API 使用者
  我希望能一次建立多個資源
  以便 提高效率

  Scenario: 成功批量建立
    Given 準備批量建立請求
      | name | email |
      | User 1 | user1@example.com |
      | User 2 | user2@example.com |
      | User 3 | user3@example.com |
    When 發送 POST 請求到 "{endpoint}/batch"
    Then HTTP 狀態碼應為 201
    And 回應應包含 3 個建立的資源 IDs

  Scenario: 批量建立部分失敗
    Given 準備批量建立請求 (包含無效資料)
      | name | email |
      | Valid User | valid@example.com |
      | Invalid User | invalid-email |
    When 發送 POST 請求到 "{endpoint}/batch"
    Then HTTP 狀態碼應為 207 (Multi-Status)
    And 第一個資源應成功建立 (status 201)
    And 第二個資源應失敗 (status 400)
```

---

## 最佳實踐

### ✅ Scenario 命名原則

```
✅ 好的命名
- 成功建立 - 所有必填欄位
- 建立失敗 - 缺少 name 欄位
- 驗證 email 邊界值 - 1 到 100 字
- 無效令牌導致 401 響應

❌ 不好的命名
- TC001
- POST /api/customers
- Create test
- Error handling
```

### ✅ Step 的顆粒度

```gherkin
✅ 好的 Step
Given 系統已存在 email 為 "existing@example.com" 的客戶
When 發送 POST 請求到 "/api/customers"
Then HTTP 狀態碼應為 409

❌ 不好的 Step
Given 系統已初始化
When 執行 API 呼叫
Then 檢查結果
```

### ✅ 資料表格使用

```gherkin
✅ 使用 Scenario Outline 處理多個
