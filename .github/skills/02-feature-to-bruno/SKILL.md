---
name: 02-feature-to-bruno
description: "自動化 Feature 文件轉換為 Bruno 測試腳本。支援單一 .feature 檔或整個特性目錄。產出 Bruno .bru 測試腳本，可直接在 Bruno 編輯器中執行。使用此技能來：將 Gherkin scenario 轉換為可執行的 REST API 測試、自動生成 Bruno 測試集合、組織測試資料夾結構、支援環境變數配置、批量轉換多個 feature 檔。"
argument-hint: "提供 feature 檔案路徑或特性目錄（./features），輸出目錄預設為 ./bruno"
---

# Feature 轉換成 Bruno 測試腳本技能

## 概述

本 skill 自動化將 Gherkin `.feature` 文件轉換為 Bruno 測試腳本 (`.bru` 檔案)，助力團隊快速執行 API 測試，無需手動編寫 REST 調用。

**輸入格式**：Gherkin Feature 檔案 (`.feature`)  
**輸出格式**：Bruno 測試腳本 (`.bru`)  
**輸入來源**：`./features` 目錄或指定的 feature 檔  
**輸出位置**：`./bruno` 目錄  

## 應用場景

- 🚀 **快速執行測試**：將 BDD 場景直接轉換為可執行的 API 測試
- 📊 **團隊協作**：Bruno 版本控制友善，易於在 Git 中追蹤
- 🔄 **自動化轉換**：無需手動逐個編寫 .bru 檔案
- 🌍 **環境管理**：支援多環境配置（開發、測試、生產）
- 📝 **測試文檔**：Feature 檔即文檔，bruno 檔即可執行代碼
- ⚡ **快速反覆**：修改 feature 後自動重新生成 bruno 測試

## 工作流程

### 步驟 1：準備 Feature 檔案

使用 01-api-to-gherkin 技能生成的 feature 檔案，確保包含以下 HTTP 相關資訊：

```gherkin
Feature: 建立新客戶 (Create Customer)
  Scenario: 成功建立客戶 - 所有必填欄位
    Given API 基底 URL 為環境變數 "BASE_URL"
    And Content-Type 設定為 "application/json"
    And 準備建立客戶的請求
      | 欄位 | 值 |
      | name | John Doe |
      | email | john@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 201
    And 回應應包含有效的 Customer ID
    And 回應的 name 應為 "John Doe"
```

### 步驟 2：執行轉換

在終端機執行轉換命令：

```bash
# 方式 1：轉換單一 feature 檔
copilot --skill 02-feature-to-bruno --input ./features/customer-create.feature --output ./bruno

# 方式 2：轉換整個 features 目錄
copilot --skill 02-feature-to-bruno --input ./features --output ./bruno

# 方式 3：在聊天中提供以下資訊讓 Copilot 進行轉換
# 1. Feature 檔案路徑 (./features/customer-create.feature 或 ./features)
# 2. 輸出目錄 (預設: ./bruno)
# 3. 基底 URL (可選: http://localhost:8080)
# 4. 環境配置 (可選: 開發/測試/生產)
```

### 步驟 3：轉換邏輯

轉換過程遵循以下規則：

#### 3.1 目錄結構對應

Feature 檔案結構 → Bruno 目錄結構

```
features/
├── customer-create.feature      →  bruno/
├── customer-get.feature         │   ├── Customer Management/
├── customer-update.feature      │   │   ├── Create Customer/
└── customer-delete.feature      │   │   │   ├── 成功建立客戶 - 所有欄位.bru
                                 │   │   │   ├── 成功建立客戶 - 僅必填欄位.bru
                                 │   │   │   └── 建立客戶失敗 - 缺少 name.bru
                                 │   │   ├── Get Customer/
                                 │   │   └── ...
```

#### 3.2 Scenario 轉換規則

每個 `Scenario` 轉換為一個 `.bru` 檔案：

| Feature 部分 | Bruno 對應 | 說明 |
|-----------|---------|------|
| Scenario 標題 | 檔案名稱 & meta name | scenario-name.bru |
| Given API 基底 URL | 請求 URL 前綴 | http://localhost:8080/api/... |
| And Content-Type | 請求 Header | Content-Type: application/json |
| And 準備...請求 | 請求 Body | JSON 格式的請求數據 |
| When 發送 METHOD 請求到 PATH | HTTP 方法 + 路徑 | POST /api/customers |
| Then HTTP 狀態碼應為 201 | @assertEqualStatus | 驗證響應狀態碼 |
| And 回應應包含... | @assertIsNotNull 或 @assert | 驗證響應欄位存在 |
| And 回應的 X 應為 Y | @assertEqual | 驗證響應欄位值 |

#### 3.3 步驟解析詳解

##### Given 步驟
```gherkin
Given API 基底 URL 為環境變數 "BASE_URL"
Given API 基底 URL 為 "http://localhost:8080"
And Content-Type 設定為 "application/json"
And Authorization 設定為 Bearer token "{{authToken}}"
And 準備建立客戶的請求
  | 欄位 | 值 |
  | name | John Doe |
  | email | john@example.com |
```

對應 Bruno：
```bru
meta {
  name: Create Customer - All Fields
  type: http
  seq: 1
}

vars {
  base_url: {{BASE_URL:http://localhost:8080}}
}

@setAuthToken {{authToken}}

POST {{base_url}}/api/customers
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com"
}
```

##### When 步驟
```gherkin
When 發送 POST 請求到 "/api/customers"
When 發送 GET 請求到 "/api/customers/{{customerId}}"
When 帶著 Authorization 頭發送 DELETE 請求到 "/api/customers/{{customerId}}"
```

對應 Bruno：
```bru
POST {{base_url}}/api/customers
GET {{base_url}}/api/customers/{{customerId}}
DELETE {{base_url}}/api/customers/{{customerId}}
  Authorization: Bearer {{authToken}}
```

##### Then 步驟 - 驗證
```gherkin
Then HTTP 狀態碼應為 201
And 回應應包含有效的 Customer ID
And 回應的 name 應為 "John Doe"
And 回應的 email 欄位應存在
And 回應應包含 "createdAt" 時間戳記
And 錯誤訊息應包含 "Email already exists"
```

對應 Bruno Tests：
```bru
tests {
  test("狀態碼為 201", function() {
    expect(res.status).to.equal(201);
  });
  
  test("包含有效的 Customer ID", function() {
    expect(res.body.id).to.be.a('string');
    expect(res.body.id).to.not.be.empty;
  });
  
  test("name 應為 John Doe", function() {
    expect(res.body.name).to.equal("John Doe");
  });
  
  test("email 欄位應存在", function() {
    expect(res.body.email).to.exist;
  });
  
  test("包含 createdAt 時間戳記", function() {
    expect(res.body.createdAt).to.exist;
  });
  
  test("錯誤訊息包含 Email already exists", function() {
    expect(res.body.message).to.include("Email already exists");
  });
}
```

### 步驟 4：支援特殊語法

轉換器支援以下特殊 Gherkin 語法：

#### 4.1 環境變數
```gherkin
Given API 基底 URL 為環境變數 "BASE_URL"
Given API 基底 URL 為環境變數 "{{BASE_URL}}"
And Authorization 設定為 Bearer token "{{authToken}}"
```

轉換為 Bruno 變數替換：`{{BASE_URL}}`、`{{authToken}}`

#### 4.2 Data Table - 轉換為 JSON 物件
```gherkin
And 準備建立客戶的請求
  | 欄位 | 值 |
  | name | John Doe |
  | email | john@example.com |
  | phone | 0912345678 |
```

轉換為：
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "0912345678"
}
```

#### 4.3 Scenario Outline - 轉換為多個 .bru 檔案
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
    | {'A'*50} | 201 |
    | {'A'*51} | 400 |
```

轉換為多個檔案：
- `驗證 name 欄位長度限制 - A.bru`
- `驗證 name 欄位長度限制 - {'A'*50}.bru`
- `驗證 name 欄位長度限制 - {'A'*51}.bru`

#### 4.4 特殊值處理
```gherkin
And 準備建立客戶的請求
  | 欄位 | 值 |
  | name | {{randomName}} |
  | createdDate | {{$now}} |
  | email | test+{{$timestamp}}@example.com |
```

轉換時保留變數標記，Bruno 執行時進行動態替換。

### 步驟 5：生成 Bruno 配置檔

自動生成 `./bruno/bruno.json` 環境配置：

```json
{
  "version": "1",
  "name": "Customer API Tests",
  "type": "collection",
  "environments": [
    {
      "name": "Local Development",
      "BASE_URL": "http://localhost:8080",
      "authToken": ""
    },
    {
      "name": "Testing",
      "BASE_URL": "https://test-api.example.com",
      "authToken": ""
    },
    {
      "name": "Production",
      "BASE_URL": "https://api.example.com",
      "authToken": ""
    }
  ]
}
```

使用者可在 Bruno 編輯器中選擇環境執行測試。

### 步驟 6：生成 README 文檔

自動生成 `./bruno/README.md` 使用說明：

```markdown
# Bruno API 測試集合

## 快速開始

1. 安裝 Bruno：https://www.usebruno.com/downloads
2. 開啟此專案：File → Open Collection → 選擇 ./bruno 目錄
3. 設定環境：右上角環境選擇器 → 選擇 "Local Development"
4. 執行測試：選擇測試並點擊 Send 或執行完整集合 Run

## 目錄結構

- `Customer Management/`
  - `Create Customer/` - POST /api/customers 相關測試
  - `Get Customer/` - GET /api/customers/{id} 相關測試
  - `Update Customer/` - PUT /api/customers/{id} 相關測試
  - `Delete Customer/` - DELETE /api/customers/{id} 相關測試

## 環境配置

| 環境 | BASE_URL | 用途 |
|-----|---------|------|
| Local Development | http://localhost:8080 | 本機開發測試 |
| Testing | https://test-api.example.com | 測試伺服器 |
| Production | https://api.example.com | 生產環境 |

## 變數

全域變數可在環境設定中配置：
- `BASE_URL` - API 基底 URL
- `authToken` - 認證令牌
- 其他自訂變數

## 執行方式

1. **單一測試**：點擊要執行的 .bru 檔案，點擊 Send
2. **集合執行**：Collections → Run → 選擇要執行的資料夾 → Run
3. **命令行執行** (使用 bruno CLI)：
   ```bash
   bruno run ./bruno --environment "Local Development"
   ```

## 測試結果

執行完成後，Bruno 會顯示：
- ✅ 通過測試
- ❌ 失敗測試（含具體失敗原因）
- ⏱️ 執行時間

## Feature 檔更新流程

1. 更新 `./features/*.feature` 檔案
2. 執行轉換命令：`copilot --skill 02-feature-to-bruno --input ./features --output ./bruno`
3. Bruno 會自動重新載入更新的 .bru 檔案
4. 重新執行測試驗證

## 故障排除

### 環境變數未替換
- 檢查環境設定中是否定義了變數
- 確保變數使用 `{{variableName}}` 格式

### 驗證失敗
- 檢查 API 服務是否在運行
- 驗證 BASE_URL 設定正確
- 查看響應內容是否符合預期

## 支援

如有問題或建議，請參考：
- [Bruno 官方文檔](https://docs.usebruno.com/)
- [本專案 Feature 檔案](../features/README.md)
```

## Bruno 編輯器中的執行

### 在 Bruno 中執行測試

1. **打開 Collection**
   ```
   Bruno → File → Open Collection → 選擇 ./bruno 文件夾
   ```

2. **選擇環境**
   ```
   右上角環境下拉菜單 → 選擇 "Local Development" 等環境
   ```

3. **執行單一測試**
   ```
   點擊左側測試項目 → 檢查 HTTP 方法、URL、Body
   點擊 Send 按鈕 → 查看響應 (Response)
   ```

4. **執行完整集合**
   ```
   左側 Collections 視圖 → 滑鼠右鍵資料夾 → Run
   或頂部菜單 Collections → Run
   ```

5. **查看測試結果**
   ```
   下方面板 Tests 標籤 → 檢視各測試的通過/失敗狀態
   ```

### 命令行執行 (CI/CD 集成)

使用 Bruno CLI 在自動化流程中執行：

```bash
# 安裝 Bruno CLI
npm install -g @usebruno/cli

# 執行完整集合
bruno run ./bruno --environment "Local Development"

# 執行特定資料夾
bruno run ./bruno/Customer\ Management --environment "Testing"

# 輸出結果為 JSON
bruno run ./bruno --output results.json

# 在 CI/CD 中使用 (exit code: 0=全過, 1=有失敗)
if bruno run ./bruno --environment "Testing"; then
  echo "✅ 所有測試通過"
else
  echo "❌ 部分測試失敗"
  exit 1
fi
```

## 轉換輸出示例

### 輸入：customer-create.feature

```gherkin
Feature: 建立新客戶 (Create Customer)
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

  Scenario: 建立客戶失敗 - 缺少 name 欄位
    Given 準備建立客戶的請求 (缺少 name)
      | 欄位 | 值 |
      | email | test@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Name is required"
```

### 輸出：bruno/Customer Management/Create Customer/成功建立客戶 - 所有欄位.bru

```bru
meta {
  name: 成功建立客戶 - 所有欄位
  type: http
  seq: 1
}

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
    expect(res.body.id).to.be.a('string');
    expect(res.body.id).to.not.be.empty;
  });
  
  test("回應的 name 應為 John Doe", function() {
    expect(res.body.name).to.equal("John Doe");
  });
}
```

### 輸出：bruno/Customer Management/Create Customer/建立客戶失敗 - 缺少 name 欄位.bru

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
    expect(res.body.message).to.include("Name is required");
  });
}
```

## 進階配置

### 自訂開始序號和命名規則

編輯轉換配置以自訂測試序號和檔案命名：

```yaml
# .github/skills/02-feature-to-bruno/config.yml
naming_convention: "{scenario_title}"  # 預設
# 其他選項: "{feature_title}_{scenario_title}", "{index}_{scenario_title}"

seq_start: 1  # 開始序號

# 路徑映射規則
path_mapping:
  feature_to_folder: true  # 根據 feature 檔名建立資料夾
  keep_feature_title: true  # 保留 feature 作為子資料夾
```

### 自訂驗證規則對應

定義 Feature 步驟到 Bruno 測試語句的映射：

```yaml
# .github/skills/02-feature-to-bruno/assertions.yml
assertions:
  "HTTP 狀態碼應為": "expect(res.status).to.equal({value});"
  "回應應包含有效的": "expect(res.body.{field}).to.be.a('string');"
  "回應的 (.+) 應為": "expect(res.body.{field}).to.equal({value});"
  "錯誤訊息應包含": "expect(res.body.message).to.include({value});"
  "(.+) 欄位應存在": "expect(res.body.{field}).to.exist;"
```

## 參考資源

- [Bruno 官方網站](https://www.usebruno.com/)
- [Bruno 文檔](https://docs.usebruno.com/)
- [Bruno CLI](https://github.com/usebruno/bruno-cli)
- [測試腳本語法](./templates/bruno-syntax-guide.md)
- [從 Postman 遷移到 Bruno](./templates/postman-to-bruno-migration.md)

## 常見問題

### Q: 如何在 CI/CD 流程中執行 Bruno 測試？
A: 使用 Bruno CLI：
```bash
npm install -g @usebruno/cli
bruno run ./bruno --environment "Testing"
```

### Q: 如何處理需要認證的 API？
A: 在環境設定中配置 `authToken` 變數，步驟中使用：
```gherkin
And Authorization 設定為 Bearer token "{{authToken}}"
```

### Q: 如何重新執行某一個 .bru 檔案？
A: 在 Bruno 編輯器中選擇該檔案，點擊 Send 按鈕或按 Cmd/Ctrl + Enter

### Q: Feature 檔案更新後如何同步到 Bruno？
A: 重新執行轉換命令：
```
copilot --skill 02-feature-to-bruno --input ./features --output ./bruno
```
更新後的 .bru 檔案會直接覆蓋舊版本。

### Q: 如何在多個環境間切換？
A: 在 Bruno 編輯器右上角選擇不同的環境，所有變數會自動替換。

## 工具鏈推薦

| 工具 | 用途 | 備註 |
|-----|------|------|
| 01-api-to-gherkin | 生成 Feature 檔 | 從 API 規格轉換 |
| 02-feature-to-bruno | 生成 Bruno 測試 | 本技能 |
| Bruno CLI | 命令行執行測試 | CI/CD 集成 |
| Git | 版本控制 | 追蹤 .bru 變更 |
| GitHub Actions | 自動化測試 | 執行 bruno run |

