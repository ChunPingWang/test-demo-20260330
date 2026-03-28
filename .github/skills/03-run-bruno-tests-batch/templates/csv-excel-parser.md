# CSV/Excel 映射清單解析指南

## 概述

本指南說明如何創建和解析 CSV/Excel 格式的 API 清單與 Bruno 測試檔案的對應映射表。

## CSV 格式規範

### 基本格式

```csv
欄位1,欄位2,欄位3,...
值1,值2,值3,...
```

### 字符編碼

- **推薦**：UTF-8 (無 BOM)
- **支援**：UTF-16, GB2312 (簡體中文), Big5 (繁體中文)
- **自動偵測**：Yes (根據檔案頭推斷編碼)

### 分隔符

- **預設**：逗號 (`,`)
- **支援**：分號 (`;`)、製表符 (`\t`)
- **自動偵測**：Yes (根據檔案內容推斷)

### 轉義規則

| 情況 | 處理方式 | 範例 |
|------|--------|------|
| 欄位包含逗號 | 使用雙引號包圍 | `"POST, GET",api/customers` |
| 欄位包含雙引號 | 雙引號加倍 | `"He said ""hello"""` → `He said "hello"` |
| 欄位包含換行 | 雙引號包圍 + 真實換行 | `"Line1\nLine2"` |
| 空欄位 | 留空 | `,,` (中間一個空值) |

### 欄位名稱規範

欄位名稱應該：
- 精確匹配（大小寫敏感）
- 可有前後空白（自動去除）
- 必填欄位必須存在

#### 簡化格式欄位

| 欄位名稱 | 類型 | 必填 | 说明 |
|---------|------|------|------|
| `API 端點` | 字串 | ✅ | RESTful API 端點，格式：`METHOD /path` |
| `HTTP 方法` | 列表 | ✅ | GET, POST, PUT, DELETE, PATCH 或結合 |
| `測試目錄` | 路徑 | ✅ | Bruno 測試所在目錄相對路徑 |
| `測試描述` | 字串 | ❌ | 人類可讀的測試描述 |

#### 詳細格式欄位

| 欄位名稱 | 類型 | 必填 | 說明 |
|---------|------|------|------|
| `API 端點` | 字串 | ✅ | `POST /api/customers` |
| `HTTP 方法` | 列表 | ✅ | GET, POST, PUT, DELETE, PATCH |
| `環境` | 列表 | ❌ | Local, Testing, Production |
| `測試目錄` | 路徑 | ✅ | `bruno/Customer Management/Create Customer` |
| `測試檔案` | 檔名 | ❌ | `01-成功建立客戶.bru` |
| `優先級` | 列表 | ❌ | High, Medium, Low |
| `跳過` | 布林 | ❌ | true/false, yes/no, Y/N |
| `超時(秒)` | 數字 | ❌ | 1-300 秒 |
| `預期狀態碼` | 數字 | ❌ | `200` 或 `200,201` (逗號分隔多個) |

### 資料型別驗證

#### 字串型別

```csv
API 端點
POST /api/customers
GET /api/customers/{id}
```

- 支援任意字符
- 自動去除前後空白

#### 列表型別

```csv
HTTP 方法,優先級,環境
POST,High,Local
GET,Medium,Testing
```

- 預定義值：必須來自指定清單
- 大小寫敏感
- 前後空白自動去除

#### 布林型別

```csv
跳過
true
false
Y
N
yes
no
1
0
```

- 支援多種表示法
- 自動轉換為 true/false
- 大小寫不敏感

#### 數字型別

```csv
超時(秒),預期狀態碼
30,200
45,201
```

- 支援整數
- 不支援小數點
- 前後空白自動去除

#### 路徑型別

```csv
測試目錄
bruno/Customer Management/Create Customer
./bruno/Customer Management
```

- 支援相對路徑和絕對路徑
- Windows 反斜線 (`\`) 自動轉換為正斜線 (`/`)
- 前後空白自動去除
- 檔案存在驗證

## Excel 格式規範

### 檔案格式

- **推薦**：`.xlsx` (Excel 2007+)
- **支援**：`.xls` (Excel 2003)

### Sheet 選擇

- 預設讀取第一個 Sheet
- 可透過參數指定其他 Sheet：`--excel-sheet "Sheet2"`

### 儲存格要求

- **首列為欄位名稱**
- **不支援合併儲存格**（若存在，行為未定義）
- **支援儲存格格式化**（顏色、字體等被忽略）

### 資料型別對應

| Excel 型別 | 解釋方式 | 範例 |
|-----------|--------|------|
| 文字 | 字串 | "POST /api/customers" |
| 數字 | 數字或字串 | 30, 200 |
| 日期 | ISO 8601 格式字串 | 2026-03-30 |
| 布林 | 布林值 | TRUE, FALSE |
| 空儲存格 | 空值 | (留空) |

## 常見格式示例

### 示例 1：最小化映射清單（3 個必填欄位）

```csv
API 端點,HTTP 方法,測試目錄
POST /api/customers,POST,bruno/Customer Management/Create Customer
GET /api/customers,GET,bruno/Customer Management/Get All Customers
GET /api/customers/{id},GET,bruno/Customer Management/Get Customer
PUT /api/customers/{id},PUT,bruno/Customer Management/Update Customer
DELETE /api/customers/{id},DELETE,bruno/Customer Management/Delete Customer
```

### 示例 2：包含優先級和描述

```csv
API 端點,HTTP 方法,測試目錄,優先級,測試描述
POST /api/customers,POST,bruno/Customer Management/Create Customer,High,建立新客戶
GET /api/customers,GET,bruno/Customer Management/Get All Customers,High,取得所有客戶列表
GET /api/customers/{id},GET,bruno/Customer Management/Get Customer,High,取得單一客戶詳情
PUT /api/customers/{id},PUT,bruno/Customer Management/Update Customer,Medium,更新客戶信息
DELETE /api/customers/{id},DELETE,bruno/Customer Management/Delete Customer,Medium,刪除客戶記錄
```

### 示例 3：詳細映射（包含環境、超時、狀態碼）

```csv
API 端點,HTTP 方法,環境,優先級,超時(秒),預期狀態碼,測試目錄,測試檔案,跳過,測試描述
POST /api/customers,POST,Local,High,30,201,bruno/Customer Management/Create Customer,01-成功建立客戶.bru,false,建立客戶 - 所有欄位
POST /api/customers,POST,Local,High,30,201,bruno/Customer Management/Create Customer,02-成功建立客戶.bru,false,建立客戶 - 必填欄位
POST /api/customers,POST,Local,Medium,30,400,bruno/Customer Management/Create Customer,04-建立失敗.bru,false,建立客戶 - 驗證失敗
GET /api/customers/{id},GET,Local,High,20,200,bruno/Customer Management/Get Customer,01-成功取得.bru,false,取得存在的客戶
GET /api/customers/{id},GET,Local,Medium,20,404,bruno/Customer Management/Get Customer,03-不存在.bru,false,取得不存在的客戶
```

### 示例 4：多環境配置

```csv
API 端點,HTTP 方法,環境,測試目錄,超時(秒)
POST /api/customers,POST,Local,bruno/Customer Management/Create Customer,30
POST /api/customers,POST,Testing,bruno/Customer Management/Create Customer,45
POST /api/customers,POST,Production,bruno/Customer Management/Create Customer,60
GET /api/customers,GET,Local,bruno/Customer Management/Get All Customers,20
GET /api/customers,GET,Testing,bruno/Customer Management/Get All Customers,30
GET /api/customers,GET,Production,bruno/Customer Management/Get All Customers,40
```

## 驗證和錯誤處理

### 自動驗證檢查

1. **欄位驗證**
   - 必填欄位是否齊全
   - 欄位名稱是否正確拼寫

2. **資料型別驗證**
   - HTTP 方法是否有效（GET/POST/PUT/DELETE/PATCH）
   - 優先級是否有效（High/Medium/Low）
   - 路徑是否存在

3. **邏輯驗證**
   - 測試目錄是否包含 .bru 檔案
   - API 端點格式是否符合 `METHOD /path`

### 錯誤報告

驗證失敗時，會返回以下信息：

```
Error: Validation failed for test-mapping.csv
  Line 3: Invalid HTTP method 'GETT' (expected: GET, POST, PUT, DELETE, PATCH)
  Line 5: Test directory 'bruno/invalid' not found
  Line 7: Missing required field 'API 端點'
  
Fix the above errors and try again.
```

## 特殊場景

### 場景 1：欄位包含特殊字符

若欄位值包含逗號、引號或換行符，使用雙引號包圍：

```csv
API 端點,測試描述
POST /api/customers,"建立客戶，返回 ID 和狀態碼"
PUT /api/customers/{id},"更新客戶信息，包括:
  - 姓名
  - 郵箱
  - 電話"
```

### 場景 2：欄位值為空

```csv
API 端點,HTTP 方法,測試檔案,測試描述
POST /api/customers,POST,,建立客戶測試（執行目錄下所有 .bru）
GET /api/customers/{id},GET,,
```

空欄位表示使用預設值或執行所有匹配的檔案。

### 場景 3：API 端點包含查詢參數

```csv
API 端點,HTTP 方法,測試目錄
GET /api/customers?page=1&limit=10,GET,bruno/Customer Management/Get All Customers
POST /api/customers?notify=true,POST,bruno/Customer Management/Create Customer
```

查詢參數會被保留但不作特殊處理。

### 場景 4：預期狀態碼為多個

```csv
API 端點,HTTP 方法,預期狀態碼,測試目錄
DELETE /api/customers/{id},DELETE,200;204;404,bruno/Customer Management/Delete Customer
```

支援分號 (`;`) 或逗號 (`,`) 分隔多個狀態碼。

## 工具和支援

### 推薦工具

- **Microsoft Excel** / **Google Sheets**：GUI 編輯器
- **VS Code** 搭配 **Excel Viewer** 擴充：VS Code 中查看 Excel
- **CSV Editor**：輕量級 CSV 編輯器

### 轉換工具

若您已有其他格式的測試列表，可轉換為 CSV：

- **Excel → CSV**：File > Save As > CSV (逗號分隔)
- **JSON → CSV**：使用線上工具或編寫轉換腳本

## 最佳實踐

1. **使用標準欄位名稱**
   - 確保欄位名稱完全匹配（大小寫敏感）
   - 避免多餘的空格或特殊字符

2. **版本控制**
   - 將映射檔納入 Git 版本控制
   - 追蹤文件變更歷史

3. **定期審查**
   - 檢查是否有未運行的測試
   - 移除過時或重複的映射
   - 新增新 API 終點的測試

4. **文檔維護**
   - 在「測試描述」欄位中記錄測試的業務背景
   - 保持描述簡潔明了

5. **環境分離**
   - 為不同環境創建單獨的映射檔：
     - `api-tests-mapping-local.csv`
     - `api-tests-mapping-testing.csv`
     - `api-tests-mapping-production.csv`
   - 或在同一檔案中使用「環境」欄位區分

---

**版本**：1.0  
**最後更新**：2026-03-30
