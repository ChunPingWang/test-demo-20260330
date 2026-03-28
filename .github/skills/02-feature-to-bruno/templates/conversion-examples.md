# Feature to Bruno 轉換範例

本文件展示實際的轉換過程：從 Feature 檔 → Bruno 測試腳本。

## 範例 1: 簡單的 POST 請求

### Input: customer-create.feature (摘錄)

```gherkin
Feature: 建立新客戶 (Create Customer)
  作為 API 使用者
  我希望能建立新的客戶記錄

  Background:
    Given API 基底 URL 為 "http://localhost:8080"
    And Content-Type 設定為 "application/json"

  Scenario: 成功建立客戶 - 所有欄位
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | John Doe |
      | email | john@example.com |
      | phone | 0912345678 |
      | address | Taipei, Taiwan |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 201
    And 回應應包含有效的 Customer ID
    And 回應的 name 應為 "John Doe"
    And 回應的 email 應為 "john@example.com"
    And 回應應包含 "createdAt" 時間戳記
    And 回應應包含 "updatedAt" 時間戳記
```

### Output: 成功建立客戶 - 所有欄位.bru

```bru
meta {
  name: 成功建立客戶 - 所有欄位
  type: http
  seq: 1
}

# ===== 說明 =====
# Feature: 建立新客戶 (Create Customer)
# Scenario: 成功建立客戶 - 所有欄位
# Source: features/customer-create.feature
# ============

vars {
  base_url: http://localhost:8080
}

POST {{base_url}}/api/customers
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "0912345678",
  "address": "Taipei, Taiwan"
}

tests {
  test("HTTP 狀態碼應為 201", function() {
    expect(res.status).to.equal(201);
  });
  
  test("回應應包含有效的 Customer ID", function() {
    // 驗證 id 欄位存在且為字符串
    expect(res.body.id).to.be.a('string');
    expect(res.body.id).to.not.be.empty;
  });
  
  test("回應的 name 應為 John Doe", function() {
    expect(res.body.name).to.equal("John Doe");
  });
  
  test("回應的 email 應為 john@example.com", function() {
    expect(res.body.email).to.equal("john@example.com");
  });
  
  test("回應應包含 createdAt 時間戳記", function() {
    expect(res.body.createdAt).to.exist;
  });
  
  test("回應應包含 updatedAt 時間戳記", function() {
    expect(res.body.updatedAt).to.exist;
  });
}
```

---

## 範例 2: 帶錯誤驗證的 POST 請求

### Input: customer-create.feature (摘錄)

```gherkin
  Scenario: 建立客戶失敗 - 缺少 name 欄位
    Given 準備建立客戶的請求 (缺少 name)
      | 欄位 | 值 |
      | email | test@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Name is required"
```

### Output: 建立客戶失敗 - 缺少 name 欄位.bru

```bru
meta {
  name: 建立客戶失敗 - 缺少 name 欄位
  type: http
  seq: 2
}

vars {
  base_url: http://localhost:8080
}

POST {{base_url}}/api/customers
Content-Type: application/json

{
  "email": "test@example.com"
}

tests {
  test("HTTP 狀態碼應為 400", function() {
    expect(res.status).to.equal(400);
  });
  
  test("錯誤訊息應包含 Name is required", function() {
    // 檢查訊息在 message 或 error 欄位中
    const message = res.body.message || res.body.error || '';
    expect(message).to.include("Name is required");
  });
}
```

---

## 範例 3: Scenario Outline (參數化測試)

### Input: customer-create.feature (摘錄)

```gherkin
  Scenario Outline: 驗證 name 欄位長度限制
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | <name> |
      | email | test@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 <expected_status>
    And 錯誤訊息應為 "<expected_message>"

    Examples:
      | name | expected_status | expected_message |
      | A | 201 |  |
      | JohnDoe | 201 |  |
      | {'A'*51} | 400 | Name must not exceed 50 characters |
```

### Output: 3 個獨立 .bru 檔案

**輸出1: 驗證 name 欄位長度限制 - A.bru**
```bru
meta {
  name: 驗證 name 欄位長度限制 - A
  type: http
  seq: 3
}

vars {
  base_url: http://localhost:8080
}

POST {{base_url}}/api/customers
Content-Type: application/json

{
  "name": "A",
  "email": "test@example.com"
}

tests {
  test("HTTP 狀態碼應為 201", function() {
    expect(res.status).to.equal(201);
  });
  
  test("錯誤訊息應為", function() {
    // 預期為空訊息 (成功狀態)
    expect(res.status).to.equal(201);
  });
}
```

**輸出2: 驗證 name 欄位長度限制 - JohnDoe.bru**
```bru
meta {
  name: 驗證 name 欄位長度限制 - JohnDoe
  type: http
  seq: 4
}

vars {
  base_url: http://localhost:8080
}

POST {{base_url}}/api/customers
Content-Type: application/json

{
  "name": "JohnDoe",
  "email": "test@example.com"
}

tests {
  test("HTTP 狀態碼應為 201", function() {
    expect(res.status).to.equal(201);
  });
}
```

**輸出3: 驗證 name 欄位長度限制 - A*51.bru**
```bru
meta {
  name: 驗證 name 欄位長度限制 - A*51
  type: http
  seq: 5
}

vars {
  base_url: http://localhost:8080
}

POST {{base_url}}/api/customers
Content-Type: application/json

{
  "name": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "email": "test@example.com"
}

tests {
  test("HTTP 狀態碼應為 400", function() {
    expect(res.status).to.equal(400);
  });
  
  test("錯誤訊息應為 Name must not exceed 50 characters", function() {
    const message = res.body.message || res.body.error || '';
    expect(message).to.equal("Name must not exceed 50 characters");
  });
}
```

---

## 範例 4: GET 請求與路徑參數

### Input: customer-get.feature (摘錄)

```gherkin
Feature: 取得客戶詳情 (Get Customer)

  Background:
    Given API 基底 URL 為環境變數 "BASE_URL"
    And Content-Type 設定為 "application/json"

  Scenario: 成功取得客戶詳情
    Given 系統已存在客戶，其 Customer ID 為 "{{customerId}}"
    When 發送 GET 請求到 "/api/customers/{{customerId}}"
    Then HTTP 狀態碼應為 200
    And 回應的 id 應為 "{{customerId}}"
    And 回應的 email 欄位應存在
```

### Output: 成功取得客戶詳情.bru

```bru
meta {
  name: 成功取得客戶詳情
  type: http
  seq: 1
}

# Feature: 取得客戶詳情 (Get Customer)
# Scenario: 成功取得客戶詳情
# Source: features/customer-get.feature

vars {
  base_url: {{BASE_URL}}
}

GET {{base_url}}/api/customers/{{customerId}}
Content-Type: application/json

tests {
  test("HTTP 狀態碼應為 200", function() {
    expect(res.status).to.equal(200);
  });
  
  test("回應的 id 應為 {{customerId}}", function() {
    expect(res.body.id).to.equal(bru.getEnvVariable("customerId"));
  });
  
  test("回應的 email 欄位應存在", function() {
    expect(res.body.email).to.exist;
  });
}
```

---

## 範例 5: DELETE 請求與授權

### Input: customer-delete.feature (摘錄)

```gherkin
Feature: 刪除客戶 (Delete Customer)

  Background:
    Given API 基底 URL 為 "http://localhost:8080"
    And Content-Type 設定為 "application/json"
    And Authorization 設定為 Bearer token "{{authToken}}"

  Scenario: 成功刪除客戶
    When 帶著 Authorization 頭發送 DELETE 請求到 "/api/customers/{{customerId}}"
    Then HTTP 狀態碼應為 204
```

### Output: 成功刪除客戶.bru

```bru
meta {
  name: 成功刪除客戶
  type: http
  seq: 1
}

vars {
  base_url: http://localhost:8080
}

DELETE {{base_url}}/api/customers/{{customerId}}
Content-Type: application/json
Authorization: Bearer {{authToken}}

tests {
  test("HTTP 狀態碼應為 204", function() {
    expect(res.status).to.equal(204);
  });
}
```

---

## 範例 6: 複雜 JSON 結構

### Input: order-create.feature (摘錄)

```gherkin
  Scenario: 成功建立訂單
    Given 準備建立訂單的請求
      | 欄位 | 值 |
      | customer.name | John Doe |
      | customer.email | john@example.com |
      | items[0].productId | 123 |
      | items[0].quantity | 2 |
      | items[0].price | 99.99 |
      | items[1].productId | 456 |
      | items[1].quantity | 1 |
      | items[1].price | 49.99 |
      | totalAmount | 249.97 |
    When 發送 POST 請求到 "/api/orders"
    Then HTTP 狀態碼應為 201
```

### Output: 成功建立訂單.bru

```bru
meta {
  name: 成功建立訂單
  type: http
  seq: 1
}

vars {
  base_url: http://localhost:8080
}

POST {{base_url}}/api/orders
Content-Type: application/json

{
  "customer": {
    "name": "John Doe",
    "email": "john@example.com"
  },
  "items": [
    {
      "productId": 123,
      "quantity": 2,
      "price": 99.99
    },
    {
      "productId": 456,
      "quantity": 1,
      "price": 49.99
    }
  ],
  "totalAmount": 249.97
}

tests {
  test("HTTP 狀態碼應為 201", function() {
    expect(res.status).to.equal(201);
  });
}
```

---

## 範例 7: 後置處理與變數保存

### Input: auth.feature

```gherkin
Feature: 認證 (Authentication)

  Scenario: 成功登入
    Given 準備登入請求
      | 欄位 | 值 |
      | username | admin |
      | password | password123 |
    When 發送 POST 請求到 "/api/auth/login"
    Then HTTP 狀態碼應為 200
    And 回應應包含 "token" 欄位
```

### Output: 成功登入.bru

```bru
meta {
  name: 成功登入
  type: http
  seq: 1
}

vars {
  base_url: http://localhost:8080
}

POST {{base_url}}/api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "password123"
}

tests {
  test("HTTP 狀態碼應為 200", function() {
    expect(res.status).to.equal(200);
  });
  
  test("回應應包含 token 欄位", function() {
    expect(res.body.token).to.exist;
  });
}

# 保存認證令牌供後續請求使用
tests:post-response {
  set('authToken', res.body.token);
}
```

後續測試會自動使用保存的 `{{authToken}}`。

---

## 目錄結構輸出

### 轉換前 (Features)
```
features/
├── customer-create.feature (包含 6+ scenarios)
├── customer-get.feature
├── customer-update.feature
├── customer-delete.feature
└── auth.feature
```

### 轉換後 (Bruno)
```
bruno/
├── bruno.json (環境配置)
├── README.md (使用說明)
├── API-INVENTORY.md (API 索引)
├── Auth/
│   └── 成功登入.bru
├── Customer Management/
│   ├── Create Customer/
│   │   ├── 成功建立客戶 - 所有欄位.bru (seq: 1)
│   │   ├── 成功建立客戶 - 僅必填欄位.bru (seq: 2)
│   │   ├── 建立客戶失敗 - 缺少 name.bru (seq: 3)
│   │   ├── 驗證 name 欄位長度限制 - A.bru (seq: 4)
│   │   ├── 驗證 name 欄位長度限制 - JohnDoe.bru (seq: 5)
│   │   └── 驗證 name 欄位長度限制 - A*51.bru (seq: 6)
│   ├── Get Customer/
│   │   ├── 成功取得客戶詳情.bru (seq: 1)
│   │   └── 取得不存在的客戶.bru (seq: 2)
│   ├── Update Customer/
│   │   ├── 成功更新客戶.bru (seq: 1)
│   │   └── ...
│   └── Delete Customer/
│       ├── 成功刪除客戶.bru (seq: 1)
│       └── 刪除不存在的客戶.bru (seq: 2)
└── conversion-report.json
```

---

## 轉換統計

基於上述範例：

| 指標 | 數值 |
|------|------|
| **輸入 Feature 檔案** | 5 個 |
| **Scenario 總數** | 15+ 個 |
| **輸出 .bru 檔案** | 15+ 個 |
| **資料夾層級** | 3 層 |
| **時間戳記** | 完整（createdAt, updatedAt） |
| **驗證數量** | ~50 個 tests |
| **環境變數** | 3 個預設環境 |

