# API 定義模板

## 格式 1：Markdown 格式（推薦用於單個 API）

```markdown
## API: 建立客戶

### 基本信息
- **HTTP 方法**：POST
- **端點**：`/api/customers`
- **功能描述**：建立新客戶記錄
- **版本**：v1
- **認證**：Bearer Token (Authorization header)

### 請求參數

| 欄位名 | 資料型 | 必須 | 說明 | 範例 |
|--------|--------|------|------|------|
| name | string | ✓ | 客戶名稱，1-100 字 | "John Doe" |
| email | string | ✓ | 電子郵件，必須唯一 | "john@example.com" |
| phone | string | | 電話號碼 | "123-456-7890" |
| company | string | | 公司名稱 | "Acme Corp" |
| address | string | | 地址 | "123 Main St" |

### 成功回應 (HTTP 201)

```json
{
  "id": "CUST-001",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "123-456-7890",
  "company": "Acme Corp",
  "address": "123 Main St",
  "createdAt": "2025-03-29T10:30:00Z",
  "status": "active"
}
```

### 失敗情況

| HTTP 狀態 | 錯誤代碼 | 錯誤訊息 | 原因 |
|----------|----------|---------|------|
| 400 | INVALID_INPUT | "name is required" | 缺少必填欄位 |
| 400 | INVALID_EMAIL | "invalid email format" | Email 格式不正確 |
| 409 | DUPLICATE_EMAIL | "email already exists" | Email 已被使用 |
| 401 | UNAUTHORIZED | "invalid token" | 認證失敗 |
| 500 | INTERNAL_ERROR | "fail to create customer" | 伺服器錯誤 |

### 邊界值測試

- **name 長度**：0 字（失敗）、1 字（成功）、100 字（成功）、101 字（失敗）
- **email**：特殊字符 (test+tag@example.com)、多區域名稱 (test@co.uk)、國際字符
- **phone**：各國電話號碼格式

### 備註

- Email 驗證採用簡易 regex，不支援所有 RFC 格式
- 建立時自動分配 Customer ID
- Status 預設為 active
```

## 格式 2：結構化表格（批量 API 定義）

```markdown
# API 規格清單

## 1. 建立客戶 POST /api/customers

| 項目 | 內容 |
|-----|------|
| 功能 | 建立新客戶記錄 |
| 認證 | Bearer Token |
| 請求體 | name (必), email (必), phone, company, address |
| 成功 | 201，返回 Customer 物件 |
| 失敗 | 400 (invalid), 409 (duplicate), 401 (auth), 500 (error) |
| 邊界 | name 1-100 字，email 唯一性檢查 |

## 2. 查詢客戶 GET /api/customers/{id}

| 項目 | 內容 |
|-----|------|
| 功能 | 根據 ID 查詢客戶詳情 |
| 認證 | Bearer Token |
| 路徑參數 | id (必) |
| 成功 | 200，返回 Customer 物件 |
| 失敗 | 404 (not found), 401 (auth), 500 (error) |
| 邊界 | ID 格式驗證 |

...
```

## 格式 3：Excel/CSV 格式（適合批量作業）

```csv
HTTP方法,端點,功能描述,認證,請求參數,必填,成功狀態,成功響應,失敗狀態1,失敗訊息1,失敗狀態2,失敗訊息2
POST,/api/customers,建立客戶,Token,"name,email,phone,company,address","name,email",201,"id,name,email,...",400,name is required,409,email already exists
GET,/api/customers/{id},查詢客戶,Token,id,id,200,"id,name,email,...",404,customer not found,401,invalid token
PUT,/api/customers/{id},更新客戶,Token,id;name;email,id,200,"id,name,email,...",404,customer not found,400,invalid input
DELETE,/api/customers/{id},刪除客戶,Token,id,id,204,,404,customer not found,401,invalid token
```

## 格式 4：Word/docx 式自由格式

只需確保文件中包含以下信息，轉換工具會自動提取：

- 🔹 **HTTP 方法** (GET, POST, PUT, DELETE, PATCH)
- 🔹 **端點 URL** (如 /api/customers)
- 🔹 **功能描述**
- 🔹 **認證方式**（如有）
- 🔹 **請求參數**（名稱、型別、是否必填）
- 🔹 **成功回應**（HTTP 狀態、回應體結構）
- 🔹 **失敗情況**（HTTP 狀態、錯誤訊息）
- 🔹 **邊界值/特殊情況**

---

## 轉換優化提示

### ✅ 什麼時候能更好的轉換成 Gherkins？

1. **明確的邊界條件**
   ```
   API 接受的 name 長度：1-100 字符
   → 生成邊界測試：1字、50字、100字、0字（失敗）、101字（失敗）
   ```

2. **清晰的替代流程 (Happy Path vs Error Path)**
   ```
   成功：201 + return customer ID
   失敗1：400 + "name is required"
   失敗2：409 + "email already exists"
   → 生成 3 個基礎 Scenario + 邊界變異
   ```

3. **依賴關係明確**
   ```
   "刪除客戶前，客戶必須存在"
   → 在 Given 中準備前置條件
   ```

### ⚠️ 轉換時可能需要補充

如果你的 API 文件缺少以下資訊，轉換時告知我：

- ❓ 邊界值範圍（如 name 長度限制）
- ❓ 特殊情況處理（如重複 email）
- ❓ 認證和授權邏輯
- ❓ 資料驗證規則
- ❓ 預期的錯誤狀態碼和訊息

---

## 範例：完整的 API 定義

```markdown
# Customer API Specification

## Endpoint: POST /api/customers
**Purpose:** Create a new customer record

### Authentication
- Type: Bearer Token
- Header: `Authorization: Bearer {token}`

### Request Body
```json
{
  "name": "string (required, 1-100 chars)",
  "email": "string (required, unique, valid email format)",
  "phone": "string (optional)",
  "company": "string (optional)",
  "address": "string (optional)"
}
```

### Successful Response (201 Created)
```json
{
  "id": "CUST-001",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "123-456-7890",
  "company": "Acme Corp",
  "address": "123 Main St",
  "createdAt": "2025-03-29T10:30:00Z",
  "status": "active"
}
```

### Error Responses

| Status | Code | Message | Condition |
|--------|------|---------|-----------|
| 400 | INVALID_INPUT | "name is required" | Missing name field |
| 400 | INVALID_EMAIL | "invalid email format" | Email doesn't match pattern |
| 409 | DUPLICATE_EMAIL | "email already exists" | Email already in database |
| 401 | UNAUTHORIZED | "invalid or missing token" | Auth header missing/invalid |
| 500 | INTERNAL_ERROR | "failed to create customer" | Server error |

### Test Cases
1. **Happy Path**: All fields provided → 201
2. **Minimal Required**: Only name + email → 201
3. **Missing name**: Request without name → 400
4. **Duplicate email**: Email already exists → 409
5. **Boundary**: name with 1 char, 100 chars → 201
6. **Boundary**: name with 101 chars → 400 (if validated)
7. **Special chars**: name="O'Brien", email="test+tag@example.com" → 201
```

---

**提示**：提供越詳細的 API 定義，生成的 Gherkins 與 test cases 品質越好！
