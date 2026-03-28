# Feature 到 Bruno 轉換對應規則

## Given 步驟 (Setup & Context)

### API 基底 URL 配置

**Feature 語法 1: 環境變數**
```gherkin
Given API 基底 URL 為環境變數 "BASE_URL"
```

**轉換結果 (Bruno)**
```bru
vars {
  base_url: {{BASE_URL}}
}

POST {{base_url}}/api/customers
```

**說明**: 使用 `{{}}` 語法引用環境變數，Bruno 會在執行時替換。

---

**Feature 語法 2: 直接 URL**
```gherkin
Given API 基底 URL 為 "http://localhost:8080"
```

**轉換結果 (Bruno)**
```bru
vars {
  base_url: http://localhost:8080
}

POST {{base_url}}/api/customers
```

---

### Content-Type 設定

**Feature 語法**
```gherkin
And Content-Type 設定為 "application/json"
And Content-Type 設定為 "application/x-www-form-urlencoded"
And Content-Type 設定為 "multipart/form-data"
```

**轉換結果 (Bruno)**
```bru
POST {{base_url}}/api/customers
Content-Type: application/json

# 或
Content-Type: application/x-www-form-urlencoded

# 或
Content-Type: multipart/form-data
```

---

### Authorization/認證

**Feature 語法 1: Bearer Token**
```gherkin
And Authorization 設定為 Bearer token "{{authToken}}"
And Authorization 設定為 Bearer token "eyJhbGc..."
```

**轉換結果 (Bruno)**
```bru
POST {{base_url}}/api/customers
Authorization: Bearer {{authToken}}
```

---

**Feature 語法 2: Basic Auth**
```gherkin
And Authorization 設定為 Basic auth username "user" password "pass"
```

**轉換結果 (Bruno)**
```bru
POST {{base_url}}/api/customers
Authorization: Basic dXNlcjpwYXNz
```

---

**Feature 語法 3: API Key**
```gherkin
And Authorization 設定為 API Key "x-api-key" value "sk_test_123456"
```

**轉換結果 (Bruno)**
```bru
POST {{base_url}}/api/customers
x-api-key: sk_test_123456
```

---

### 請求 Body - Data Table

**Feature 語法**
```gherkin
And 準備建立客戶的請求
  | 欄位 | 值 |
  | name | John Doe |
  | email | john@example.com |
  | phone | 0912345678 |
  | address | Taipei, Taiwan |
```

**轉換結果 (Bruno)**
```bru
POST {{base_url}}/api/customers
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "0912345678",
  "address": "Taipei, Taiwan"
}
```

**說明**: 
- Data Table 直接轉換為 JSON 物件
- 欄位名稱不變
- 值保留原始格式 (字符串、數字、布爾值)

---

**Feature 語法 (複雜 JSON 結構)**
```gherkin
And 準備建立訂單的請求
  | 欄位 | 值 |
  | customer.name | John Doe |
  | customer.email | john@example.com |
  | items[0].productId | 123 |
  | items[0].quantity | 2 |
  | items[1].productId | 456 |
  | items[1].quantity | 1 |
```

**轉換結果 (Bruno)**
```bru
{
  "customer": {
    "name": "John Doe",
    "email": "john@example.com"
  },
  "items": [
    {
      "productId": 123,
      "quantity": 2
    },
    {
      "productId": 456,
      "quantity": 1
    }
  ]
}
```

---

### 請求 Body - 固定 JSON

**Feature 語法**
```gherkin
And 準備以下 JSON 請求體
  """
  {
    "user": {
      "name": "John Doe",
      "email": "john@example.com",
      "roles": ["admin", "user"]
    }
  }
  """
```

**轉換結果 (Bruno)**
```bru
{
  "user": {
    "name": "John Doe",
    "email": "john@example.com",
    "roles": ["admin", "user"]
  }
}
```

---

## When 步驟 (Action)

### HTTP 方法與路徑

**Feature 語法 1: 基本請求**
```gherkin
When 發送 POST 請求到 "/api/customers"
When 發送 GET 請求到 "/api/customers/123"
When 發送 PUT 請求到 "/api/customers/123"
When 發送 DELETE 請求到 "/api/customers/123"
When 發送 PATCH 請求到 "/api/customers/123"
```

**轉換結果 (Bruno)**
```bru
POST {{base_url}}/api/customers
GET {{base_url}}/api/customers/123
PUT {{base_url}}/api/customers/123
DELETE {{base_url}}/api/customers/123
PATCH {{base_url}}/api/customers/123
```

---

**Feature 語法 2: 帶路徑參數**
```gherkin
When 發送 GET 請求到 "/api/customers/{{customerId}}"
When 發送 DELETE 請求到 "/api/users/{{userId}}/posts/{{postId}}"
```

**轉換結果 (Bruno)**
```bru
GET {{base_url}}/api/customers/{{customerId}}
DELETE {{base_url}}/api/users/{{userId}}/posts/{{postId}}
```

---

**Feature 語法 3: 帶查詢參數**
```gherkin
When 發送 GET 請求到 "/api/customers?page=1&limit=10"
When 發送 GET 請求到 "/api/customers?filter=active&sort=name&order=asc"
```

**轉換結果 (Bruno)**
```bru
GET {{base_url}}/api/customers?page=1&limit=10
GET {{base_url}}/api/customers?filter=active&sort=name&order=asc
```

---

**Feature 語法 4: Header 在 When**
```gherkin
When 帶著 Authorization 頭發送 DELETE 請求到 "/api/customers/123"
When 帶著自訂 Header "X-Request-ID" 值為 "req-{{$uuid}}" 發送 POST 請求到 "/api/orders"
```

**轉換結果 (Bruno)**
```bru
DELETE {{base_url}}/api/customers/123
Authorization: Bearer {{authToken}}

# 或
POST {{base_url}}/api/orders
X-Request-ID: req-{{$uuid}}
```

---

## Then 步驟 (Assertions & Verification)

### 狀態碼驗證

**Feature 語法**
```gherkin
Then HTTP 狀態碼應為 201
Then HTTP 狀態碼應為 200
Then HTTP 狀態碼應為 400
Then HTTP 狀態碼應為 401
Then HTTP 狀態碼應為 403
Then HTTP 狀態碼應為 404
Then HTTP 狀態碼應為 500
```

**轉換結果 (Bruno)**
```bru
tests {
  test("HTTP 狀態碼應為 201", function() {
    expect(res.status).to.equal(201);
  });
}
```

---

### 響應欄位存在性

**Feature 語法**
```gherkin
And 回應應包含有效的 Customer ID
And 回應應包含 "createdAt" 時間戳記
And 回應中應存在 "data" 欄位
And 回應不應包含 "password" 欄位
```

**轉換結果 (Bruno)**
```bru
tests {
  test("回應應包含有效的 Customer ID", function() {
    expect(res.body.id).to.be.a('string');
    expect(res.body.id).to.not.be.empty;
  });
  
  test("回應應包含 createdAt 時間戳記", function() {
    expect(res.body.createdAt).to.exist;
  });
  
  test("回應中應存在 data 欄位", function() {
    expect(res.body.data).to.exist;
  });
  
  test("回應不應包含 password 欄位", function() {
    expect(res.body.password).to.not.exist;
  });
}
```

---

### 響應欄位值驗證

**Feature 語法 1: 字符串相等**
```gherkin
And 回應的 name 應為 "John Doe"
And 回應的 email 應為 "john@example.com"
And 回應的 status 應為 "active"
```

**轉換結果 (Bruno)**
```bru
tests {
  test("回應的 name 應為 John Doe", function() {
    expect(res.body.name).to.equal("John Doe");
  });
  
  test("回應的 email 應為 john@example.com", function() {
    expect(res.body.email).to.equal("john@example.com");
  });
  
  test("回應的 status 應為 active", function() {
    expect(res.body.status).to.equal("active");
  });
}
```

---

**Feature 語法 2: 數字比較**
```gherkin
And 回應的 age 應為 30
And 回應的 count 應大於 0
And 回應的 limit 應小於等於 100
```

**轉換結果 (Bruno)**
```bru
tests {
  test("回應的 age 應為 30", function() {
    expect(res.body.age).to.equal(30);
  });
  
  test("回應的 count 應大於 0", function() {
    expect(res.body.count).to.be.greaterThan(0);
  });
  
  test("回應的 limit 應小於等於 100", function() {
    expect(res.body.limit).to.be.lessThanOrEqual(100);
  });
}
```

---

**Feature 語法 3: 字符串包含**
```gherkin
And 回應應包含 "success message"
And 錯誤訊息應包含 "Email already exists"
And 訊息應包含 "created successfully"
```

**轉換結果 (Bruno)**
```bru
tests {
  test("回應應包含 success message", function() {
    expect(JSON.stringify(res.body)).to.include("success message");
  });
  
  test("錯誤訊息應包含 Email already exists", function() {
    expect(res.body.message || res.body.error).to.include("Email already exists");
  });
  
  test("訊息應包含 created successfully", function() {
    expect(res.body.message).to.include("created successfully");
  });
}
```

---

**Feature 語法 4: 陣列驗證**
```gherkin
And 回應的 items 應包含 3 個元素
And 回應的 tags 陣列不應為空
And 回應的 data[0].id 應為 123
```

**轉換結果 (Bruno)**
```bru
tests {
  test("回應的 items 應包含 3 個元素", function() {
    expect(res.body.items).to.be.an('array');
    expect(res.body.items).to.have.lengthOf(3);
  });
  
  test("回應的 tags 陣列不應為空", function() {
    expect(res.body.tags).to.be.an('array');
    expect(res.body.tags.length).to.be.greaterThan(0);
  });
  
  test("回應的 data[0].id 應為 123", function() {
    expect(res.body.data[0].id).to.equal(123);
  });
}
```

---

### 響應頭驗證

**Feature 語法**
```gherkin
And 響應頭中 Content-Type 應為 "application/json"
And 響應頭中應包含 "X-Request-ID"
And 響應頭中 Authorization 應包含 "Bearer"
```

**轉換結果 (Bruno)**
```bru
tests {
  test("響應頭中 Content-Type 應為 application/json", function() {
    expect(res.headers['content-type']).to.include('application/json');
  });
  
  test("響應頭中應包含 X-Request-ID", function() {
    expect(res.headers['x-request-id']).to.exist;
  });
  
  test("響應頭中 Authorization 應包含 Bearer", function() {
    expect(res.headers['authorization']).to.include('Bearer');
  });
}
```

---

## 特殊情況處理

### 變數與動態值

**Feature 語法**
```gherkin
Given 準備建立客戶的請求
  | 欄位 | 值 |
  | name | {{randomName}} |
  | timestamp | {{$now}} |
  | uuid | {{$uuid}} |
  | email | test+{{$timestamp}}@example.com |
```

**轉換結果 (Bruno)**
```bru
{
  "name": "{{randomName}}",
  "timestamp": "{{$now}}",
  "uuid": "{{$uuid}}",
  "email": "test+{{$timestamp}}@example.com"
}
```

**Bruno 內建動態變數**:
- `{{$uuid}}` - 生成 UUID
- `{{$timestamp}}` - 當前時間戳
- `{{$now}}` - 當前 ISO 時間
- `{{$randomInt}}` - 隨機整數
- `{{$randomAlphaNumeric}}` - 隨機字符串

---

### Scenario Outline (參數化)

**Feature 語法**
```gherkin
Scenario Outline: 驗證 name 欄位長度限制
  Given 準備建立客戶的請求
    | 欄位 | 值 |
    | name | <name> |
    | email | test@example.com |
  When 發送 POST 請求到 "/api/customers"
  Then HTTP 狀態碼應為 <expected_status>

  Examples:
    | name | expected_status |
    | A | 201 |
    | John Doe | 201 |
    | {'A'*51} | 400 |
```

**轉換結果 (Bruno - 3 個檔案)**
```
驗證 name 欄位長度限制 - A.bru
驗證 name 欄位長度限制 - John Doe.bru
驗證 name 欄位長度限制 - A*51.bru
```

每個 .bru 檔案是獨立的完整測試。

---

### Background (背景設定)

**Feature 語法**
```gherkin
Feature: 建立新客戶

Background:
  Given API 基底 URL 為 "http://localhost:8080"
  And Content-Type 設定為 "application/json"

Scenario: 成功建立客戶
  Given 準備建立客戶的請求
    | 欄位 | 值 |
    | name | John Doe |
  When 發送 POST 請求到 "/api/customers"
  Then HTTP 狀態碼應為 201
```

**轉換結果 (Bruno)**

Background 中的步驟被應用到每個 Scenario：
```bru
# Background 中的配置被自動應用
vars {
  base_url: http://localhost:8080
}

POST {{base_url}}/api/customers
Content-Type: application/json

{
  "name": "John Doe"
}

tests {
  test("HTTP 狀態碼應為 201", function() {
    expect(res.status).to.equal(201);
  });
}
```

---

## 對應關鍵字總結

| Feature 關鍵字 | Bruno 對應 | 說明 |
|-------------|---------|------|
| `Given API 基底 URL` | `vars { base_url: }` | 設定 URL 變數 |
| `And Content-Type` | Header 中 Content-Type | 請求 Content-Type |
| `And Authorization` | Header 中 Authorization | 認證令牌 |
| `And 準備...請求` | 請求 Body | JSON 物件 |
| `When 發送 METHOD 請求到` | `METHOD {{base_url}}/path` | HTTP 方法與路徑 |
| `Then HTTP 狀態碼應為` | `expect(res.status)` | 狀態碼驗證 |
| `And 回應應包含` | `expect(res.body.field)` | 欄位存在驗證 |
| `And 回應的 X 應為 Y` | `expect(res.body.X).to.equal(Y)` | 欄位值驗證 |
| `And 錯誤訊息應包含` | `expect(res.body.message)` | 錯誤訊息驗證 |

