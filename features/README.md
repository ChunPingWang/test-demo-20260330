# Customer Management API - Gherkins BDD 測試案例

歡迎使用本專案的 API 測試套件！本目錄包含完整的 Gherkins BDD 測試案例，涵蓋 Customer Management API 的所有端點。

---

## 📂 目錄結構

```
./features/
├── customer-list.feature      # GET /api/customers - 取得所有客戶
├── customer-get.feature       # GET /api/customers/{id} - 取得指定客戶
├── customer-create.feature    # POST /api/customers - 建立新客戶
├── customer-update.feature    # PUT /api/customers/{id} - 更新客戶
├── customer-delete.feature    # DELETE /api/customers/{id} - 刪除客戶
├── API-INVENTORY.md           # API 清單及統計資訊
├── REVIEW-CHECKLIST.md        # BA/SA 審查檢查清單
└── README.md                  # 本文檔
```

---

## 📊 統計概覽

| 指標 | 數值 |
|------|------|
| **總 API 數** | 5 |
| **總 Feature 檔** | 5 |
| **總 Scenario 數** | 56 |
| **正向 Scenario** | 13 (23%) |
| **反向 Scenario** | 21 (38%) |
| **邊界值 Scenario** | 21 (38%) |

---

## 🚀 快速開始

### 1️⃣ 前置條件

確保您的系統已安裝：
- **Java 11+** (如果使用 Cucumber-JVM)
- **Maven 3.6+** 或 **Gradle 6+**
- **API Server** 運行於指定的 BASE_URL (默認 `http://localhost:8080`)

或使用其他 BDD 框架：
- **Python**: Behave
- **.NET**: SpecFlow
- **JavaScript**: Cucumber.js

---

### 🔧 環境變數配置

**Base URL 設定** (透過環境變數參數化)

所有 feature 檔案都從 `BASE_URL` 環境變數讀取 API 伺服器位址。

#### 設定方式：

**方式 1: 命令行設定**
```bash
# 開發環境
export BASE_URL="http://localhost:8080"

# 測試環境
export BASE_URL="http://test-api.example.com"

# 生產環境
export BASE_URL="http://prod-api.example.com"
```

**方式 2: .env 檔案** (推薦用於 CI/CD)
```bash
# 建立 .env 檔
cat > .env << EOF
BASE_URL=http://localhost:8080
EOF

# 使用 dotenv 載入 (Python/Node.js)
```

**方式 3: Maven 屬性**
```bash
mvn test -DBASE_URL="http://test-api.example.com"
```

**方式 4: Behave 環境配置**
```python
# features/environment.py
import os

def before_all(context):
    context.base_url = os.getenv('BASE_URL', 'http://localhost:8080')
```

---

打開任意 `.feature` 檔案查看測試場景：

```bash
less features/customer-create.feature
```

### 3️⃣ 實現 Step Definitions

根據你的框架選擇實現步驟：

#### **使用 Cucumber (Java)**
```java
package com.example.customer.steps;

import io.cucumber.java.en.*;
import static org.junit.Assert.*;

public class CustomerStepDefinitions {
    
    private String baseUrl;
    private String contentType;
    
    @Given("API 基底 URL 為環境變數 {string}")
    public void setBaseUrlFromEnv(String envVarName) {
        // 從環境變數讀取 BASE_URL
        this.baseUrl = System.getenv(envVarName);
        if (this.baseUrl == null) {
            this.baseUrl = "http://localhost:8080"; // 預設值
        }
    }
    
    @When("發送 POST 請求到 {string}")
    public void sendPostRequest(String endpoint) {
        // 使用 baseUrl + endpoint 發送請求
        String url = this.baseUrl + endpoint;
        // ... 發送 POST 請求
    }
    
    @Then("HTTP 狀態碼應為 {int}")
    public void verifyStatusCode(int statusCode) {
        // 驗證 HTTP 狀態碼
    }
}
```

#### **使用 Behave (Python)**
```python
from behave import given, when, then
import requests
import os

@given('API 基底 URL 為環境變數 "{env_var_name}"')
def set_base_url_from_env(context, env_var_name):
    # 從環境變數讀取 BASE_URL
    context.base_url = os.getenv(env_var_name, "http://localhost:8080")

@when('發送 POST 請求到 "{endpoint}"')
def send_post_request(context, endpoint):
    url = context.base_url + endpoint
    context.response = requests.post(
        url, 
        json=context.request_body,
        headers={"Content-Type": "application/json"}
    )

@then('HTTP 狀態碼應為 {status_code}')
def verify_status_code(context, status_code):
    assert context.response.status_code == int(status_code)
```

### 4️⃣ 運行測試

#### 使用 Maven (Java)
```bash
# 設定環境變數後運行所有測試
export BASE_URL="http://localhost:8080"
mvn test

# 在命令行中直接設定 BASE_URL (一行命令)
BASE_URL="http://localhost:8080" mvn test

# 運行特定 feature
BASE_URL="http://localhost:8080" mvn test -Dcucumber.filter.name="建立客戶"

# 測試環境
BASE_URL="http://test-api.example.com" mvn test

# 運行特定標籤
BASE_URL="http://localhost:8080" mvn test -Dcucumber.filter.tags="@create"
```

#### 使用 Behave (Python)
```bash
# 設定環境變數後運行所有特性
export BASE_URL="http://localhost:8080"
behave features/

# 在命令行中直接設定 BASE_URL
BASE_URL="http://localhost:8080" behave features/

# 運行特定 feature
BASE_URL="http://localhost:8080" behave features/customer-create.feature

# 测试環境運行
BASE_URL="http://test-api.example.com" behave features/

# 生成 HTML 報告
BASE_URL="http://localhost:8080" behave --format html -o report.html features/
```

---

## 📖 Feature 檔案說明

### customer-list.feature
**API**: `GET /api/customers`  
**功能**: 取得所有客戶列表  
**場景數**: 4 個

```gherkin
Scenario: 成功取得所有客戶列表
```

### customer-get.feature
**API**: `GET /api/customers/{id}`  
**功能**: 根據 ID 取得新建客戶  
**場景數**: 7 個

```gherkin
Scenario: 成功取得存在的客戶資訊
```

### customer-create.feature
**API**: `POST /api/customers`  
**功能**: 建立新客戶記錄  
**場景數**: 18 個

✅ 測試項目：
- 所有欄位、最小欄位、部分欄位
- Email 格式驗證、唯一性檢查
- 長度限制 (name 50, email 100)
- 特殊字符處理

### customer-update.feature
**API**: `PUT /api/customers/{id}`  
**功能**: 更新客戶資訊  
**場景數**: 17 個

✅ 測試項目：
- 全部更新、部分更新、清空欄位
- Email 唯一性檢查
- 驗證 createdAt 不變、updatedAt 更新
- 長度限制和格式驗證

### customer-delete.feature
**API**: `DELETE /api/customers/{id}`  
**功能**: 刪除客戶記錄  
**場景數**: 10 個

✅ 測試項目：
- 成功刪除驗證
- 刪除後資源不存在 (404)
- 冪等性測試 (重複刪除)

---

## 🎯 常見場景說明

### 場景 1: 建立客戶 - 所有欄位

```gherkin
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
```

**預期結果**:
- HTTP Status: 201 Created
- 回應包含 Customer ID
- 所有欄位值正確保存

### 場景 2: 建立客戶失敗 - Email 已存在

```gherkin
Scenario: 建立客戶失敗 - Email 已存在
  Given 系統已存在 email 為 "existing@example.com" 的客戶
  And 準備建立客戶的請求
    | 欄位 | 值 |
    | name | Another User |
    | email | existing@example.com |
  When 發送 POST 請求到 "/api/customers"
  Then HTTP 狀態碼應為 400
  And 錯誤訊息應包含 "Email already exists"
```

**預期結果**:
- HTTP Status: 400 Bad Request
- 錯誤訊息提示 Email 已存在

### 場景 3: 邊界值測試 - 名稱長度

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

**預期結果**:
- 1 個字符: 201 Created
- 50 個字符: 201 Created
- 51 個字符: 400 Bad Request

---

## 🔍 測試覆蓋分析

### 按 API 端點分類

| API | 場景數 | Happy Path | Error Cases | Boundary |
|-----|--------|-----------|-------------|----------|
| GET /customers | 4 | 2 | 1 | 1 |
| GET /customers/{id} | 7 | 2 | 3 | 2 |
| POST /customers | 18 | 3 | 7 | 8 |
| PUT /customers/{id} | 17 | 3 | 6 | 8 |
| DELETE /customers/{id} | 10 | 3 | 4 | 2 |
| **總計** | **56** | **13** | **21** | **21** |

### 按驗證類型分類

| 驗證類型 | 場景數 |
|--------|--------|
| 必填欄位驗證 | 6 |
| 格式驗證 (Email) | 5 |
| 唯一性約束 | 2 |
| 長度限制 | 12 |
| 特殊字符 | 4 |
| HTTP 狀態碼 | 10 |
| 資源不存在 (404) | 5 |
| 時間戳記驗證 | 2 |

---

## ✅ 執行測試的建議順序

### 第 1 階段: 煙霧測試 (Smoke Test)
運行所有 Happy Path 場景，確保基本功能正常：

```bash
# 運行標籤為 @smoke 或 positive 的場景
behave --tags=@positive
```

預期: **100% 通過**

### 第 2 階段: 功能測試
運行所有負向和邊界值測試：

```bash
# 運行所有場景
behave features/
```

預期: **>95% 通過**

### 第 3 階段: 迴歸測試
集成到 CI/CD 每次 commit 運行：

```bash
# 在 CI/CD 中執行
mvn clean test
```

---

## 🐛 常見問題 (FAQ)

### Q1: 如何修改測試資料？

在各 feature 檔案的 `Background` 或 `Given` 語句中修改：

```gherkin
Background:
  Given 系統已存在以下客戶
    | id | name | email |
    | 1 | John Doe | john@example.com |  # ← 修改這裡
```

### Q2: 如何添加新的 Scenario？

1. 打開對應的 `.feature` 檔案
2. 在 `Scenario:` 後遵循 Given-When-Then 結構
3. 參考 [Gherkins 場景模板](../.github/skills/01-api-to-gherkin/templates/gherkin-scenario-template.md)

### Q3: 如何跳過某些 Scenario？

使用 `@skip` 或 `@wip` 標籤：

```gherkin
@skip
Scenario: 暫未實現的場景
  ...
```

然後運行時排除：

```bash
behave --tags="not @skip"
```

### Q4: 如何生成測試報告？

#### Cucumber (Java)
```bash
mvn test -Dplugin="html:target/cucumber-reports"
```

#### Behave (Python)
```bash
behave --format html -o test-results/report.html
```

### Q5: API 服務器運行在不同的 URL？

所有 feature 檔案都從 `BASE_URL` 環境變數讀取伺服器位址，**不需修改 feature 檔案**。

**設定方式 (選擇一種):**

**✅ 方式 1: 命令行執行**
```bash
# 開發環境
BASE_URL="http://localhost:8080" mvn test
BASE_URL="http://localhost:8080" behave

# 測試環境
BASE_URL="http://test-api.example.com" mvn test

# 生產環境
BASE_URL="http://prod-api.example.com" behave
```

**✅ 方式 2: 導出環境變數**
```bash
export BASE_URL="http://your-server:8080"
mvn test      # 或 behave
```

**✅ 方式 3: .env 檔案** (推薦 CI/CD)
```bash
# 建立 .env
echo "BASE_URL=http://your-server:8080" > .env

# Python Behave 用
python -m behave
```

---

## 📚 相關文件參考

| 文件 | 目的 |
|------|------|
| [API-INVENTORY.md](./API-INVENTORY.md) | API 清單、統計、複雜度分析 |
| [REVIEW-CHECKLIST.md](./REVIEW-CHECKLIST.md) | BA/SA 審查檢查項 |
| [Gherkins 模板](../.github/skills/01-api-to-gherkin/templates/gherkin-scenario-template.md) | Scenario 寫作參考 |
| [API 定義](../docs/api-documentation.pdf) | 原始 API 規格 |

---

## 🔄 維護和更新

### 添加新 API 時

1. 在 `features/` 目錄建立新 `{api-name}.feature`
2. 更新 `API-INVENTORY.md` 統計資訊
3. 更新 `REVIEW-CHECKLIST.md` 檢查項
4. 實現對應的 Step Definitions

### 修改現有 API 時

1. 更新對應的 `.feature` 檔案
2. 添加新的 Scenario 覆蓋變更
3. 更新 `API-INVENTORY.md` 統計
4. 通知 QA team 重新實現

### 修復失敗的 Scenario

1. 確認 API 實現是否正確
2. 修改 Scenario 期望值或步驟
3. 記錄修改原因在 Git commit message
4. 重新運行測試驗證

---

## 📞 聯絡方式

如有問題或建議，請：

- 📧 聯絡 QA Team
- 💬 提交 GitHub Issue
- 📋 更新本 REVIEW-CHECKLIST.md

---

## 📄 授權與版本

| 項目 | 說明 |
|------|------|
| **專案** | Customer Management API |
| **API 版本** | v1 |
| **生成日期** | 2026-03-29 |
| **生成工具** | 01-api-to-gherkin Skill |
| **總 Scenario** | 56 個 |
| **預計自動化時間** | 40-60 小時 (含 Step Definitions 實現) |

---

## 🎉 下一步

1. ✅ 閱讀本 README
2. ✅ 瀏覽 Feature 檔案
3. ✅ 檢查 [API-INVENTORY.md](./API-INVENTORY.md)
4. ✅ 進行 [REVIEW-CHECKLIST.md](./REVIEW-CHECKLIST.md) 審查
5. ✅ 實現 Step Definitions
6. ✅ 運行測試
7. ✅ 集成到 CI/CD

---

**Happy Testing! 🧪**
