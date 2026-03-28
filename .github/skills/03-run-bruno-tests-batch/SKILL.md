---
name: 03-run-bruno-tests-batch
description: "自動化批量執行 Bruno 測試並產出報告。支援 CSV/Excel 格式的 API 清單與 .bru 檔案對應表。自動執行測試工作、收集結果、產出 Markdown 測試報告。使用此技能來：批量執行 Bruno 測試集合、自動化集成測試、產生測試執行報告、追蹤測試結果、支援多環境測試。"
argument-hint: "提供映射清單檔路徑 (CSV/Excel)，指定輸出報告目錄（預設 ./test-reports），選擇執行環境（預設 Local）"
---

# Bruno 批量測試執行與報告生成技能

## 概述

本 Skill 自動化批量執行 Bruno REST API 測試，並根據執行結果生成詳細的 Markdown 測試報告。支援透過 CSV 或 Excel 文件輸入 API 清單與測試檔案的對應關係，實現高效的自動化測試工作流。

**輸入格式**：CSV 或 Excel 映射清單 (API ↔ .bru 檔案對應文件)  
**輸出格式**：Markdown 測試報告 + JSON 執行統計  
**支援環境**：Local Development、Testing、Production  
**執行方式**：順序執行、並行執行、按需求篩選  

## 應用場景

- ⚡ **自動化集成測試**：無需手動執行每個測試，直接批量運行
- 📊 **測試報告生成**：自動生成包含通過/失敗統計的詳細報告
- 🔄 **CI/CD 集成**：與 GitHub Actions、GitLab CI 無縫整合
- 🌍 **多環境測試**：同一測試集合在開發、測試、生產環境自動切換
- 📈 **質量追蹤**：保存每次執行的歷史記錄，追蹤測試品質趨勢
- 🎯 **選擇性執行**：按 API 端點、測試類型篩選執行特定測試
- 📋 **測試溯源**：將每個測試結果與原始 Feature 場景關聯

## 工作流程

### 步驟 1：準備映射清單檔

創建 CSV 或 Excel 檔案，記錄 API 端點與 Bruno 測試檔案的對應關係。

#### 格式 A：簡化版（推薦用於簡單場景）

**CSV 格式** (api-tests-mapping.csv)：
```csv
API 端點,HTTP 方法,測試目錄,測試描述
POST /api/customers,POST,bruno/Customer Management/Create Customer,建立客戶測試
GET /api/customers,GET,bruno/Customer Management/Get All Customers,取得客戶列表測試
GET /api/customers/{id},GET,bruno/Customer Management/Get Customer,取得單一客戶測試
PUT /api/customers/{id},PUT,bruno/Customer Management/Update Customer,更新客戶測試
DELETE /api/customers/{id},DELETE,bruno/Customer Management/Delete Customer,刪除客戶測試
```

**Excel 格式** (api-tests-mapping.xlsx)：
| API 端點 | HTTP 方法 | 測試目錄 | 測試描述 |
|---------|---------|---------|---------|
| POST /api/customers | POST | bruno/Customer Management/Create Customer | 建立客戶測試 |
| GET /api/customers | GET | bruno/Customer Management/Get All Customers | 取得客戶列表測試 |

#### 格式 B：詳細版（用於複雜場景）

**CSV 格式** (api-tests-mapping-detailed.csv)：
```csv
API 端點,HTTP 方法,環境,測試目錄,測試檔案,優先級,跳過,超時(秒),預期狀態碼
POST /api/customers,POST,Local,bruno/Customer Management/Create Customer,01-成功建立客戶 - 所有欄位.bru,High,false,30,201
POST /api/customers,POST,Local,bruno/Customer Management/Create Customer,02-成功建立客戶 - 僅必填欄位.bru,High,false,30,201
POST /api/customers,POST,Local,bruno/Customer Management/Create Customer,04-建立客戶失敗 - 缺少 name 欄位.bru,Medium,false,30,400
GET /api/customers/{id},GET,Local,bruno/Customer Management/Get Customer,01-成功取得存在的客戶資訊.bru,High,false,20,200
GET /api/customers/{id},GET,Local,bruno/Customer Management/Get Customer,03-取得不存在的客戶失敗.bru,Medium,false,20,404
```

**Excel 格式** (api-tests-mapping-detailed.xlsx)：
| API 端點 | HTTP 方法 | 環境 | 測試目錄 | 測試檔案 | 優先級 | 跳過 | 超時(秒) | 預期狀態碼 |
|---------|---------|-----|---------|--------|-------|------|---------|------------|
| POST /api/customers | POST | Local | bruno/Customer Management/Create Customer | 01-成功建立客戶 - 所有欄位.bru | High | false | 30 | 201 |

#### 映射清單說明

**必填欄位**：
- `API 端點`：RESTful API 端點路徑 (例：`POST /api/customers`)
- `HTTP 方法`：GET, POST, PUT, DELETE, PATCH 等
- `測試目錄`：Bruno 專案中的測試folder 路徑

**可選欄位**（詳細版）：
- `環境`：執行環境（Local Development、Testing、Production）
- `測試檔案`：具體的 .bru 檔案名稱（若不提供，則執行目錄下所有檔案）
- `優先級`：High、Medium、Low（用於篩選和排序）
- `跳過`：true/false，決定是否跳過該測試
- `超時(秒)`：測試執行時限，超時則標記為失敗
- `預期狀態碼`：預期的 HTTP 響應狀態碼，用於驗證

### 步驟 2：執行批量測試

在終端機或透過 Copilot 執行批量測試：

```bash
# 方式 1：指定映射清單檔和輸出目錄
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --output ./test-reports \
  --environment Local

# 方式 2：執行指定環境的所有測試
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.xlsx \
  --output ./test-reports \
  --environment Testing

# 方式 3：執行指定優先級的測試
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --output ./test-reports \
  --priority High \
  --environment Local

# 方式 4：只執行特定 API 的測試
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --output ./test-reports \
  --api-filter "POST /api/customers" \
  --environment Local

# 方式 5：在聊天中提供以下資訊讓 Copilot 執行
# 1. 映射清單檔路徑 (CSV 或 Excel)
# 2. 輸出報告目錄 (預設: ./test-reports)
# 3. 執行環境 (預設: Local)
# 4. Bruno 專案路徑 (預設: ./bruno)
# 5. 並行執行數量 (預設: 1，即順序執行)
```

### 步驟 3：執行邏輯和流程

#### 3.1 映射檔解析

1. **檢驗檔案格式**：
   - CSV 使用逗號分隔，支援 UTF-8 編碼
   - Excel 讀取第一個 Sheet，首列為欄位名稱

2. **欄位驗證**：
   - 檢查必填欄位是否齊全
   - 驗證 HTTP 方法有效性
   - 確認測試目錄/檔案存在

3. **資料標準化**：
   - 去除欄位前後空白
   - 轉換布林值 (Y/N/true/false → true/false)
   - 規範化路徑格式 (\ → /)

#### 3.2 測試執行策略

**執行模式**：

| 執行模式 | 說明 | 適用場景 |
|--------|------|--------|
| 順序執行 | 逐一執行，前一個完成後再執行下一個 | 測試間有依賴關係、需要序號執行 |
| 並行執行 | 同時執行多個測試（可配置並行數） | 測試獨立、需要快速完成 |
| 按優先級執行 | 先執行 High，再 Medium，最後 Low | 優先驗證核心功能 |
| 篩選執行 | 按 API、環境、優先級篩選後執行 | 只執行特定子集 |

**超時處理**：

```
- 預設超時：30 秒
- 若設定了超時欄位，使用設定值
- 超時後自動中斷，標記為「超時失敗」
- 超時不影響後續測試執行
```

**環境變數參數化**：

執行時自動注入環境變數到 Bruno：

```env
# .env (Local Development)
BASE_URL=http://localhost:8080
USERNAME=testuser
PASSWORD=testpass

# .env.testing (Testing)
BASE_URL=https://api-testing.company.com
USERNAME=qa_user
PASSWORD=qa_pass

# .env.production (Production)
BASE_URL=https://api.company.com
USERNAME=prod_user
PASSWORD=prod_pass
```

#### 3.3 結果捕捉和驗證

執行每個 .bru 測試後捕捉以下資訊：

```json
{
  "testFile": "01-成功建立客戶 - 所有欄位.bru",
  "endpoint": "POST /api/customers",
  "environment": "Local",
  "status": "PASS",
  "duration": 245,
  "assertions": {
    "total": 5,
    "passed": 5,
    "failed": 0
  },
  "responseData": {
    "statusCode": 201,
    "responseTime": 180,
    "bodySize": 512
  },
  "errorMessage": null,
  "timestamp": "2026-03-30T10:30:45Z"
}
```

**驗證規則**：

1. **狀態碼驗證**：
   - 驗證響應狀態碼是否符合預期
   - 與測試檔案中 `tests` 區塊的斷言邏輯有衝突時以實際結果為準

2. **回應內容驗證**：
   - 執行 .bru 檔中定義的所有 `expect()` 斷言
   - 部分斷言失敗標記為「部分失敗」

3. **超時驗證**：
   - 若響應時間超過設定的超時時間則標記為失敗

### 步驟 4：報告生成

執行完成後自動生成以下報告檔案：

#### 4.1 主報告 (test-report.md)

**報告結構**：
```markdown
# 批量測試執行報告

## 執行摘要
- 執行時間：2026-03-30 10:30 ~ 10:45
- 執行環境：Local Development
- 測試總數：34
- 通過：32
- 失敗：2
- 跳過：0
- 成功率：94.1%
- 平均響應時間：245ms

## API 端點統計
- POST /api/customers：18 個測試，通過 17 個
- GET /api/customers：2 個測試，通過 2 個
- GET /api/customers/{id}：5 個測試，通過 5 個
- PUT /api/customers/{id}：5 個測試，通過 5 個
- DELETE /api/customers/{id}：4 個測試，通過 3 個

## 詳細測試結果
### ✅ 通過的測試 (32)
...
### ❌ 失敗的測試 (2)
...
### ⏭️ 跳過的測試 (0)
...

## 性能分析
### 最快的測試
- 文件：02-成功建立客戶 - 僅必填欄位.bru
- 響應時間：120ms

### 最慢的測試
- 文件：03-成功更新客戶 - 更新所有欄位.bru
- 響應時間：380ms

## 問題分析
### 常見失敗原因
- 連接超時：1 次
- 資料驗證失敗：1 次

## 建議
- ...

---
報告生成時間：2026-03-30 10:45:30
```

#### 4.2 詳細結果 (test-results-detailed.json)

```json
{
  "executionSummary": {
    "startTime": "2026-03-30T10:30:00Z",
    "endTime": "2026-03-30T10:45:30Z",
    "totalDuration": 930000,
    "environment": "Local",
    "totalTests": 34,
    "passed": 32,
    "failed": 2,
    "skipped": 0,
    "successRate": 94.1
  },
  "testResults": [
    {
      "id": 1,
      "testFile": "01-成功建立客戶 - 所有欄位.bru",
      "endpoint": "POST /api/customers",
      "status": "PASS",
      "duration": 245,
      "assertions": {
        "total": 5,
        "passed": 5,
        "failed": 0
      },
      "responseData": {
        "statusCode": 201,
        "responseTime": 180,
        "bodySize": 512
      }
    }
  ]
}
```

#### 4.3 趨勢報告 (test-trends.md)（若有歷史記錄）

```markdown
# 測試趨勢分析

## 成功率趨勢
- 2026-03-30：94.1%
- 2026-03-29：90.2%
- 2026-03-28：88.5%

## 最近 7 天統計
...
```

### 步驟 5：報告檢視和分析

生成的報告支援以下檢視方式：

1. **命令行檢視**：
   ```bash
   cat test-reports/test-report.md
   ```

2. **Markdown 預覽**：
   在 VS Code 中打開 `test-report.md`，使用內建 Markdown 預覽

3. **Web 檢視**（可選）：
   生成 HTML 版本，在瀏覽器中檢視

4. **數據分析**：
   讀取 `test-results-detailed.json` 進行進階分析

## 進階配置

### 配置檔案說明

參考 `config.yml` 文件中的各項配置選項，支援以下自訂：

```yaml
# Bruno CLI 執行配置
bruno:
  cli-path: "bruno"
  timeout: 30
  parallel-count: 1
  env-file: ".env"

# 報告配置
reporting:
  output-dir: "./test-reports"
  formats: ["markdown", "json", "html"]
  include-trends: true
  history-days: 30

# 環境配置
environments:
  Local:
    base-url: "http://localhost:8080"
    env-file: ".env"
  Testing:
    base-url: "https://api-testing.company.com"
    env-file: ".env.testing"
  Production:
    base-url: "https://api.company.com"
    env-file: ".env.production"
```

### 特殊場景支援

#### 場景 A：有依賴的測試執行

若某些測試需要前置條件（例：刪除前必須建立），在映射檔中指定依賴：

```csv
API 端點,HTTP 方法,測試目錄,測試描述,依賴測試
POST /api/customers,POST,bruno/Customer Management/Create Customer,建立客戶測試,
DELETE /api/customers/{id},DELETE,bruno/Customer Management/Delete Customer,刪除客戶測試,POST /api/customers
```

執行邏輯：
1. 先執行 `POST /api/customers` 的所有測試
2. 取得 customerID
3. 再執行 `DELETE /api/customers/{id}` 的測試

#### 場景 B：資料驅動測試

透過映射檔指定多組資料執行同一測試：

```csv
API 端點,HTTP 方法,測試目錄,測試檔案,測試資料
POST /api/customers,POST,bruno/Create Customer,01-成功建立客戶.bru,testdata/customer-1.json
POST /api/customers,POST,bruno/Create Customer,01-成功建立客戶.bru,testdata/customer-2.json
POST /api/customers,POST,bruno/Create Customer,01-成功建立客戶.bru,testdata/customer-3.json
```

#### 場景 C：多環境平行測試

同時在多個環境執行測試集合，對比結果：

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --output ./test-reports \
  --environment-all \
  --compare-results
```

## 連接到 CI/CD

### GitHub Actions

```yaml
name: API Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Bruno Tests
        run: |
          copilot --skill 03-run-bruno-tests-batch \
            --mapping ./api-tests-mapping.csv \
            --output ./test-reports \
            --environment Testing
      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: test-reports
          path: test-reports/
```

### GitLab CI

```yaml
test-suite:
  image: node:18
  script:
    - copilot --skill 03-run-bruno-tests-batch \
        --mapping ./api-tests-mapping.csv \
        --output ./test-reports \
        --environment Testing
  artifacts:
    reports:
      junit: test-reports/test-results.xml
    paths:
      - test-reports/
```

## 故障排除

| 問題 | 原因 | 解決方案 |
|------|------|---------|
| 映射檔格式錯誤 | CSV/Excel 欄位格式不符 | 檢查映射檔範本，確保欄位名稱和格式正確 |
| 測試檔案不存在 | 指定的 .bru 路徑錯誤 | 驗證測試目錄路徑，確保檔案存在 |
| Bruno CLI 未找到 | Bruno 未安裝或不在 PATH | 安裝 Bruno CLI：`npm install -g @usebruno/cli` |
| 環境變數未生效 | .env 檔案路徑錯誤 | 檢查 `.env` 檔案位置，確保與 Bruno 專案在同一目錄 |
| 測試超時 | 網路或 API 響應慢 | 增加 config.yml 中的 `timeout` 設定 |
| 報告未生成 | 輸出目錄無寫入權限 | 確保輸出目錄存在並有寫入權限 |

## 最佳實踐

1. **版本控制映射檔**：
   - 將映射檔 (CSV/Excel) 納入 Git 版本控制
   - 追蹤測試集合的演進過程

2. **定期執行**：
   - 設定 CI/CD Pipeline 在每次 commit 自動執行測試
   - 在 GitHub/GitLab 中設定定時任務 (cron) 執行完整測試

3. **報告歸檔**：
   - 保存每次執行的報告，便於後續分析
   - 比對不同版本的測試結果

4. **環境管理**：
   - 分離不同環境的 .env 檔案
   - 避免提交含有敏感資訊（密碼、Token）的 .env
   - 使用 `.env.example` 作為模板

5. **測試維護**：
   - 定期審視失敗的測試，更新不符合當前 API 的測試
   - 移除過時的測試檔案
   - 新增 API 變更後的新測試

6. **效能優化**：
   - 使用並行執行加快測試速度
   - 但注意 API 速率限制和伺服器負載
   - 優先執行 High 優先級的測試，節省時間

7. **文檔維護**：
   - 保持 feature 檔案和 .bru 檔案的同步
   - 更新 bruno 測試時，同步更新 feature 檔案
   - 在映射檔中記錄測試的業務含義

## 常見使用示例

### 示例 1：執行所有測試，生成報告

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./docs/api-tests-mapping.csv
```

結果：
- ✅ 執行 34 個測試
- ✅ 生成 `./test-reports/test-report.md`
- ✅ 保存詳細結果 `./test-reports/test-results-detailed.json`

### 示例 2：執行高優先級測試，用於快速驗證

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --priority High
```

結果：
- ✅ 只執行 9 個 High 優先級的測試
- ✅ 快速驗證核心功能（~3 分鐘）

### 示例 3：測試新環境，驗證 API 可用性

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --environment Production
```

結果：
- ✅ 使用 Production 環境配置執行測試
- ✅ 報告中清楚標明環境為 Production

### 示例 4：執行特定 API 的測試，調試問題

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --api-filter "POST /api/customers"
```

結果：
- ✅ 只執行 18 個與「POST /api/customers」相關的測試
- ✅ 快速定位該 API 的問題

### 示例 5：並行執行測試，提升速度

```bash
copilot --skill 03-run-bruno-tests-batch \
  --mapping ./api-tests-mapping.csv \
  --parallel-count 4
```

結果：
- ✅ 同時執行 4 個測試
- ✅ 執行時間從 ~15 分鐘縮短至 ~4 分鐘

## 支援的 CSV/Excel 格式詳細說明

### CSV 編碼

- 推薦使用 UTF-8 編碼
- 支援 BOM (Byte Order Mark)
- 自動檢測常見編碼 (GB2312, UTF-16 等)

### Excel 讀取

- 支援 `.xlsx` (推薦) 和 `.xls` 格式
- 讀取第一個 Sheet（若有多個 Sheet，可透過參數指定）
- 支援合併儲存格，但不推薦使用

### 欄位驗證

- 欄位名稱大小寫敏感 (API 端點 ≠ api 端點)
- 若有拼寫錯誤，顯示警告並忽略該欄位
- 必填欄位缺失時，彙報錯誤並終止

### 資料類型

| 欄位 | 型態 | 範例 |
|-----|------|------|
| API 端點 | 字串 | `POST /api/customers` |
| HTTP 方法 | 列表 (GET/POST/PUT/DELETE/PATCH) | `POST` |
| 環境 | 列表 (Local/Testing/Production) | `Testing` |
| 優先級 | 列表 (High/Medium/Low) | `High` |
| 跳過 | 布林 (true/false/yes/no) | `false` |
| 超時(秒) | 數字 | `30` |
| 預期狀態碼 | 數字或逗號分隔的數字 | `201` 或 `200,201` |

## 擴展功能（未來規劃）

- [ ] 支援 Postman Collections 的自動轉換與執行
- [ ] 集成性能測試，追蹤 API 響應時間的歷史變化
- [ ] 自動生成 API 變更報告，對比舊版本測試結果
- [ ] 支援 GraphQL 測試
- [ ] 與 Slack/Teams 整合，自動發送測試報告通知
- [ ] Web UI 儀表板，實時顯示測試執行狀態
- [ ] AI 驅動的故障根因分析

---

**版本**：1.0  
**最後更新**：2026-03-30  
**維護者**：QA Team  
**相關技能**：[01-api-to-gherkin](../01-api-to-gherkin/SKILL.md)、[02-feature-to-bruno](../02-feature-to-bruno/SKILL.md)
