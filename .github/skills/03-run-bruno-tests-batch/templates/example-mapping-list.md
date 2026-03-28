# 映射清單使用示例

## 概述

本文件提供多個實際可用的映射清單範本和使用示例。  
您可以直接複製相應的內容到您的 CSV 或 Excel 檔案中使用。

---

## 範本 1：最小化映射清單

**用途**：快速開始，簡單場景  
**大小**：3 列，5 行資料  
**適用**：小型項目，無優先級或環境區分

### CSV 格式

```csv
API 端點,HTTP 方法,測試目錄
POST /api/customers,POST,bruno/Customer Management/Create Customer
GET /api/customers,GET,bruno/Customer Management/Get All Customers
GET /api/customers/{id},GET,bruno/Customer Management/Get Customer
PUT /api/customers/{id},PUT,bruno/Customer Management/Update Customer
DELETE /api/customers/{id},DELETE,bruno/Customer Management/Delete Customer
```

### Excel 格式

| API 端點 | HTTP 方法 | 測試目錄 |
|---------|---------|---------|
| POST /api/customers | POST | bruno/Customer Management/Create Customer |
| GET /api/customers | GET | bruno/Customer Management/Get All Customers |
| GET /api/customers/{id} | GET | bruno/Customer Management/Get Customer |
| PUT /api/customers/{id} | PUT | bruno/Customer Management/Update Customer |
| DELETE /api/customers/{id} | DELETE | bruno/Customer Management/Delete Customer |

### 使用方式

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --output ./test-reports
```

---

## 範本 2：標準映射清單

**用途**：大多數項目的推薦配置  
**大小**：5 列，20+ 行資料  
**適用**：中等規模項目，有優先級和描述

### CSV 格式

```csv
API 端點,HTTP 方法,優先級,測試目錄,測試描述
POST /api/customers,POST,High,bruno/Customer Management/Create Customer,建立客戶 - 所有欄位
POST /api/customers,POST,High,bruno/Customer Management/Create Customer,建立客戶 - 必填欄位
POST /api/customers,POST,Medium,bruno/Customer Management/Create Customer,建立客戶 - 驗證失敗
POST /api/customers,POST,Medium,bruno/Customer Management/Create Customer,建立客戶 - 邊界值測試
GET /api/customers,GET,High,bruno/Customer Management/Get All Customers,取得客戶列表
GET /api/customers/{id},GET,High,bruno/Customer Management/Get Customer,取得單個客戶
GET /api/customers/{id},GET,Medium,bruno/Customer Management/Get Customer,取得不存在的客戶
GET /api/customers/{id},GET,Low,bruno/Customer Management/Get Customer,邊界值測試
PUT /api/customers/{id},PUT,Medium,bruno/Customer Management/Update Customer,更新客戶 - 所有欄位
PUT /api/customers/{id},PUT,Medium,bruno/Customer Management/Update Customer,更新客戶 - 部分欄位
DELETE /api/customers/{id},DELETE,High,bruno/Customer Management/Delete Customer,刪除客戶
DELETE /api/customers/{id},DELETE,Medium,bruno/Customer Management/Delete Customer,重複刪除測試
```

### Excel 格式

| API 端點 | HTTP 方法 | 優先級 | 測試目錄 | 測試描述 |
|---------|---------|--------|---------|---------|
| POST /api/customers | POST | High | bruno/Customer Management/Create Customer | 建立客戶 - 所有欄位 |
| POST /api/customers | POST | High | bruno/Customer Management/Create Customer | 建立客戶 - 必填欄位 |
| POST /api/customers | POST | Medium | bruno/Customer Management/Create Customer | 建立客戶 - 驗證失敗 |
| ... | ... | ... | ... | ... |

### 執行示例

執行所有測試，按優先級排序：

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --output ./test-reports
```

執行高優先級測試：

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --output ./test-reports \
  --priority High
```

---

## 範本 3：多環境映射清單

**用途**：支援多環境測試（Local、Testing、Production）  
**大小**：6 列，15+ 行資料  
**適用**：企業級項目，需要在多個環境中執行

### CSV 格式

```csv
API 端點,HTTP 方法,環境,優先級,測試目錄,測試描述
POST /api/customers,POST,Local,High,bruno/Customer Management/Create Customer,建立客戶
POST /api/customers,POST,Testing,High,bruno/Customer Management/Create Customer,建立客戶
POST /api/customers,POST,Production,High,bruno/Customer Management/Create Customer,建立客戶
GET /api/customers,GET,Local,High,bruno/Customer Management/Get All Customers,取得列表
GET /api/customers,GET,Testing,High,bruno/Customer Management/Get All Customers,取得列表
GET /api/customers,GET,Production,High,bruno/Customer Management/Get All Customers,取得列表
GET /api/customers/{id},GET,Local,High,bruno/Customer Management/Get Customer,取得客戶
GET /api/customers/{id},GET,Testing,High,bruno/Customer Management/Get Customer,取得客戶
GET /api/customers/{id},GET,Production,High,bruno/Customer Management/Get Customer,取得客戶
PUT /api/customers/{id},PUT,Local,Medium,bruno/Customer Management/Update Customer,更新客戶
PUT /api/customers/{id},PUT,Testing,Medium,bruno/Customer Management/Update Customer,更新客戶
DELETE /api/customers/{id},DELETE,Local,Medium,bruno/Customer Management/Delete Customer,刪除客戶
DELETE /api/customers/{id},DELETE,Testing,Medium,bruno/Customer Management/Delete Customer,刪除客戶
```

### Excel 格式

| API 端點 | HTTP 方法 | 環境 | 優先級 | 測試目錄 | 測試描述 |
|---------|---------|-----|--------|---------|---------|
| POST /api/customers | POST | Local | High | bruno/Customer Management/Create Customer | 建立客戶 |
| POST /api/customers | POST | Testing | High | bruno/Customer Management/Create Customer | 建立客戶 |
| POST /api/customers | POST | Production | High | bruno/Customer Management/Create Customer | 建立客戶 |
| ... | ... | ... | ... | ... | ... |

### 執行示例

執行 Local 環境所有測試：

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --output ./test-reports \
  --environment Local
```

執行 Testing 環境高優先級測試：

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --output ./test-reports \
  --environment Testing \
  --priority High
```

---

## 範本 4：詳細映射清單

**用途**：完整的企業級配置，包含所有可選欄位  
**大小**：9 列，30+ 行資料  
**適用**：複雜項目，需要精細控制和詳細追蹤

### CSV 格式

```csv
API 端點,HTTP 方法,環境,優先級,超時(秒),預期狀態碼,測試目錄,測試檔案,測試描述
POST /api/customers,POST,Local,High,30,201,bruno/Customer Management/Create Customer,01-成功建立 - 所有欄位.bru,建立客戶，提供所有欄位
POST /api/customers,POST,Local,High,30,201,bruno/Customer Management/Create Customer,02-成功建立 - 必填欄位.bru,建立客戶，僅提供必填欄位
POST /api/customers,POST,Local,Medium,30,400,bruno/Customer Management/Create Customer,04-驗證失敗 - 缺少 name.bru,驗證失敗，缺少必填欄位
POST /api/customers,POST,Local,Low,30,400,bruno/Customer Management/Create Customer,07-驗證失敗 - 無效 email.bru,驗證失敗，Email 格式無效
POST /api/customers,POST,Testing,High,45,201,bruno/Customer Management/Create Customer,01-成功建立 - 所有欄位.bru,在 Testing 環境驗證建立
GET /api/customers,GET,Local,High,20,200,bruno/Customer Management/Get All Customers,01-成功取得列表.bru,取得客戶列表，檢查裝元素
GET /api/customers,GET,Local,High,20,200,bruno/Customer Management/Get All Customers,02-成功取得空列表.bru,取得空的客戶列表
GET /api/customers/{id},GET,Local,High,20,200,bruno/Customer Management/Get Customer,01-成功取得.bru,取得存在的客戶信息
GET /api/customers/{id},GET,Local,Medium,20,404,bruno/Customer Management/Get Customer,03-取得不存在.bru,取得不存在的客戶，應返回 404
GET /api/customers/{id},GET,Local,Low,20,400,bruno/Customer Management/Get Customer,04-無效 ID 格式.bru,邊界值測試，ID 格式無效
PUT /api/customers/{id},PUT,Local,Medium,30,200,bruno/Customer Management/Update Customer,01-成功更新 - 全部.bru,更新所有欄位
PUT /api/customers/{id},PUT,Local,Medium,30,200,bruno/Customer Management/Update Customer,02-成功更新 - 部分.bru,僅更新部分欄位
PUT /api/customers/{id},PUT,Local,Medium,30,404,bruno/Customer Management/Update Customer,03-更新不存在.bru,更新不存在的客戶
DELETE /api/customers/{id},DELETE,Local,High,30,204,bruno/Customer Management/Delete Customer,01-成功刪除.bru,成功刪除存在的客戶
DELETE /api/customers/{id},DELETE,Local,Medium,30,404,bruno/Customer Management/Delete Customer,02-刪除不存在.bru,刪除不存在的客戶，應返回 404
DELETE /api/customers/{id},DELETE,Local,Low,30,404,bruno/Customer Management/Delete Customer,04-重複刪除.bru,邊界值，重複刪除同一客戶
```

### Excel 格式

| API 端點 | HTTP 方法 | 環境 | 優先級 | 超時(秒) | 預期狀態碼 | 測試目錄 | 測試檔案 | 測試描述 |
|---------|---------|-----|--------|---------|-----------|---------|--------|---------|
| POST /api/customers | POST | Local | High | 30 | 201 | bruno/Customer Management/Create Customer | 01-成功建立 - 所有欄位.bru | 建立客戶，提供所有欄位 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

### 執行示例

執行本地環境所有高優先級測試，超時 30 秒：

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping-detailed.csv \
  --output ./test-reports \
  --environment Local \
  --priority High
```

---

## 範本 5：按 API 標籤分組

**用途**：組織相關的 API 測試，便於理解和維護  
**適用**：具有多個業務模塊的大型 API

### 分組策略

```
Customer Management
├── Create Customer (POST /api/customers)
├── Read Customer (GET /api/customers/{id})
├── List Customers (GET /api/customers)
├── Update Customer (PUT /api/customers/{id})
└── Delete Customer (DELETE /api/customers/{id})

Order Management
├── Create Order (POST /api/orders)
├── Read Order (GET /api/orders/{id})
├── List Orders (GET /api/orders)
├── Update Order (PUT /api/orders/{id})
└── Cancel Order (DELETE /api/orders/{id})

Payment Processing
├── Process Payment (POST /api/payments)
├── Get Payment Status (GET /api/payments/{id})
└── Refund Payment (POST /api/payments/{id}/refund)
```

### CSV 格式

```csv
模塊,API 端點,HTTP 方法,優先級,超時(秒),測試目錄,測試描述
Customer Management,POST /api/customers,POST,High,30,bruno/Customer Management/Create Customer,建立客戶
Customer Management,GET /api/customers,GET,High,20,bruno/Customer Management/Get All Customers,取得客戶列表
Customer Management,GET /api/customers/{id},GET,High,20,bruno/Customer Management/Get Customer,取得單個客戶
Customer Management,PUT /api/customers/{id},PUT,Medium,30,bruno/Customer Management/Update Customer,更新客戶
Customer Management,DELETE /api/customers/{id},DELETE,Medium,30,bruno/Customer Management/Delete Customer,刪除客戶
Order Management,POST /api/orders,POST,High,30,bruno/Order Management/Create Order,建立訂單
Order Management,GET /api/orders/{id},GET,High,20,bruno/Order Management/Get Order,取得訂單詳情
Payment Processing,POST /api/payments,POST,High,45,bruno/Payment Processing/Process Payment,處理支付
```

---

## 現成的實用映射清單範本

### 實用範本：簡化版（推薦使用）

直接複製以下內容到 `api-tests-mapping.csv`：

```csv
API 端點,HTTP 方法,測試目錄,優先級,測試描述
POST /api/customers,POST,bruno/Customer Management/Create Customer,High,建立客戶
GET /api/customers,GET,bruno/Customer Management/Get All Customers,High,取得列表
GET /api/customers/{id},GET,bruno/Customer Management/Get Customer,High,取得客戶
PUT /api/customers/{id},PUT,bruno/Customer Management/Update Customer,Medium,更新客戶
DELETE /api/customers/{id},DELETE,bruno/Customer Management/Delete Customer,Medium,刪除客戶
```

### 實用範本：完整版

複製以下內容到 `api-tests-mapping-complete.csv`，涵蓋所有 Bruno 測試：

```csv
API 端點,HTTP 方法,環境,優先級,超時(秒),預期狀態碼,測試目錄,測試檔案,測試描述
POST /api/customers,POST,Local,High,30,201,bruno/Customer Management/Create Customer,01-成功建立客戶 - 所有欄位.bru,成功建立客戶，提供所有欄位
POST /api/customers,POST,Local,High,30,201,bruno/Customer Management/Create Customer,02-成功建立客戶 - 僅必填欄位.bru,成功建立客戶，僅必填欄位
POST /api/customers,POST,Local,High,30,201,bruno/Customer Management/Create Customer,03-成功建立客戶 - 部分選用欄位.bru,成功建立客戶，部分選用欄位
POST /api/customers,POST,Local,Medium,30,400,bruno/Customer Management/Create Customer,04-建立客戶失敗 - 缺少 name 欄位.bru,驗證失敗，缺少 name
POST /api/customers,POST,Local,Medium,30,400,bruno/Customer Management/Create Customer,05-建立客戶失敗 - 缺少 email 欄位.bru,驗證失敗，缺少 email
POST /api/customers,POST,Local,Medium,30,400,bruno/Customer Management/Create Customer,06-建立客戶失敗 - name 為空字符串.bru,驗證失敗，name 為空
POST /api/customers,POST,Local,Medium,30,400,bruno/Customer Management/Create Customer,07-建立客戶失敗 - 無效的 Email 格式.bru,驗證失敗，Email 格式錯誤
POST /api/customers,POST,Local,Medium,30,400,bruno/Customer Management/Create Customer,08-建立客戶失敗 - Email 缺少@符號.bru,驗證失敗，Email 缺少 @
POST /api/customers,POST,Local,Medium,30,400,bruno/Customer Management/Create Customer,09-建立客戶失敗 - Email 缺少域名.bru,驗證失敗，Email 缺少域名
POST /api/customers,POST,Local,Medium,30,409,bruno/Customer Management/Create Customer,10-建立客戶失敗 - Email 已存在.bru,唯一性約束，Email 重複
POST /api/customers,POST,Local,Low,30,201,bruno/Customer Management/Create Customer,11-驗證 name 欄位長度限制 - A.bru,邊界值，name 長度 1
POST /api/customers,POST,Local,Low,30,201,bruno/Customer Management/Create Customer,12-驗證 name 欄位長度限制 - A50.bru,邊界值，name 長度 50
POST /api/customers,POST,Local,Low,30,400,bruno/Customer Management/Create Customer,13-驗證 name 欄位長度限制 - A51.bru,邊界值，name 長度超限 51
POST /api/customers,POST,Local,Low,30,400,bruno/Customer Management/Create Customer,14-驗證 name 欄位長度限制 - empty.bru,邊界值，name 為空
POST /api/customers,POST,Local,Low,30,201,bruno/Customer Management/Create Customer,15-驗證 email 欄位長度限制 - a@b.c.bru,邊界值，email 最短
POST /api/customers,POST,Local,Low,30,201,bruno/Customer Management/Create Customer,16-驗證 email 欄位長度限制 - a90.bru,邊界值，email 長度 90
POST /api/customers,POST,Local,Low,30,400,bruno/Customer Management/Create Customer,17-驗證 email 欄位長度限制 - a95.bru,邊界值，email 長度超限 95
POST /api/customers,POST,Local,Low,30,201,bruno/Customer Management/Create Customer,18-建立客戶 - 特殊字符在 name.bru,特殊字符支持
GET /api/customers,GET,Local,High,20,200,bruno/Customer Management/Get All Customers,01-成功取得所有客戶列表.bru,成功取得客戶列表
GET /api/customers,GET,Local,High,20,200,bruno/Customer Management/Get All Customers,02-成功取得空的客戶列表.bru,空列表處理
GET /api/customers/{id},GET,Local,High,20,200,bruno/Customer Management/Get Customer,01-成功取得存在的客戶資訊.bru,成功取得客戶詳情
GET /api/customers/{id},GET,Local,High,20,200,bruno/Customer Management/Get Customer,02-驗證回應包含時間戳記.bru,回應時間戳驗證
GET /api/customers/{id},GET,Local,Medium,20,404,bruno/Customer Management/Get Customer,03-取得不存在的客戶失敗.bru,404 客戶不存在
GET /api/customers/{id},GET,Local,Low,20,400,bruno/Customer Management/Get Customer,04-取得客戶 - 無效的 ID 格式.bru,邊界值，ID 格式無效
GET /api/customers/{id},GET,Local,Low,20,400,bruno/Customer Management/Get Customer,05-取得客戶 - 負數 ID.bru,邊界值，負數 ID
PUT /api/customers/{id},PUT,Local,Medium,30,200,bruno/Customer Management/Update Customer,01-成功更新客戶 - 更新所有欄位.bru,更新所有欄位
PUT /api/customers/{id},PUT,Local,Medium,30,200,bruno/Customer Management/Update Customer,02-成功更新客戶 - 僅更新 name.bru,部分更新，僅 name
PUT /api/customers/{id},PUT,Local,Medium,30,404,bruno/Customer Management/Update Customer,03-更新失敗 - 客戶不存在.bru,404 客戶不存在
PUT /api/customers/{id},PUT,Local,Medium,30,400,bruno/Customer Management/Update Customer,04-更新失敗 - 缺少 name 欄位.bru,驗證失敗，缺少 name
PUT /api/customers/{id},PUT,Local,Medium,30,400,bruno/Customer Management/Update Customer,05-更新失敗 - 無效的 Email 格式.bru,驗證失敗，Email 格式錯誤
DELETE /api/customers/{id},DELETE,Local,High,30,204,bruno/Customer Management/Delete Customer,01-成功刪除存在的客戶.bru,成功刪除客戶
DELETE /api/customers/{id},DELETE,Local,Medium,30,404,bruno/Customer Management/Delete Customer,02-刪除失敗 - 客戶不存在.bru,404 客戶不存在
DELETE /api/customers/{id},DELETE,Local,Low,30,400,bruno/Customer Management/Delete Customer,03-刪除失敗 - 無效的客戶 ID 格式.bru,邊界值，ID 格式無效
DELETE /api/customers/{id},DELETE,Local,Low,30,200,bruno/Customer Management/Delete Customer,04-重複刪除同一客戶失敗.bru,冪等性測試
```

---

## 使用建議

1. **快速開始**：使用「範本 1：最小化映射清單」
2. **標準項目**：使用「範本 2：標準映射清單」
3. **企業級**：使用「範本 4：詳細映射清單」或「實用範本：完整版」
4. **多環境**：使用「範本 3：多環境映射清單」

## 常見問題

**Q：如何選擇優先級？**  
A：
- **High**：核心功能，必須通過
- **Medium**：重要功能，應該通過  
- **Low**：邊界值或特殊場景，可選

**Q：超時時間建議多少？**  
A：
- **GET 請求**：20-30 秒
- **POST/PUT 請求**：30-45 秒  
- **DELETE 請求**：20-30 秒
- **Production 環境**：加長 50%

**Q：可以有多個測試檔案對應同一 API 嗎？**  
A：可以，用不同的測試檔案覆蓋不同的場景（正向、反向、邊界值）

---

**版本**：1.0  
**最後更新**：2026-03-30
