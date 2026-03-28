# Bruno 批量測試執行與報告生成 - 快速開始指南

## 5 分鐘快速上手

### 第 1 步：準備映射清單檔

在專案根目錄創建 `api-tests-mapping.csv`：

```csv
API 端點,HTTP 方法,測試目錄,測試描述
POST /api/customers,POST,bruno/Customer Management/Create Customer,建立客戶測試
GET /api/customers,GET,bruno/Customer Management/Get All Customers,取得客戶列表測試
GET /api/customers/{id},GET,bruno/Customer Management/Get Customer,取得單一客戶測試
PUT /api/customers/{id},PUT,bruno/Customer Management/Update Customer,更新客戶測試
DELETE /api/customers/{id},DELETE,bruno/Customer Management/Delete Customer,刪除客戶測試
```

### 第 2 步：執行測試

在 Copilot 中執行：

```
提供以下資訊，我會自動執行批量測試並生成報告：
1. 映射清單檔路徑：./api-tests-mapping.csv
2. 輸出報告目錄：./test-reports
3. 執行環境：Local Development
```

### 第 3 步：檢視報告

執行完成後，報告會生成在 `./test-reports/test-report.md`：

```bash
cat test-reports/test-report.md
```

或直接在 VS Code 中打開 `test-report.md`。

## 常見任務

### 任務 1：執行所有測試，生成完整報告

指定映射檔和輸出目錄：

```
執行批量測試：
- 映射清單檔：./api-tests-mapping.csv
- 輸出目錄：./test-reports
- 環境：Local
```

### 任務 2：執行高優先級測試（快速驗證）

如果映射檔有「優先級」欄位，指定只執行 High：

```
執行批量測試：
- 映射清單檔：./api-tests-mapping.csv
- 優先級篩選：High
- 環境：Local
```

### 任務 3：執行特定 API 的測試

只執行與某個 API 相關的測試：

```
執行批量測試：
- 映射清單檔：./api-tests-mapping.csv
- API 端點篩選：POST /api/customers
- 環境：Local
```

### 任務 4：在多個環境執行

依次執行 Local、Testing、Production 環境：

```
執行批量測試（多環境）：
- 映射清單檔：./api-tests-mapping.csv
- 環境：Local, Testing, Production
- 比較結果：是
```

### 任務 5：並行執行提升速度

同時執行多個測試（適合測試獨立、無冠依賴的場景）：

```
執行批量測試：
- 映射清單檔：./api-tests-mapping.csv
- 並行數量：4
- 環境：Local
```

## 報告示例

### 簡化報告示例

```markdown
# 批量測試執行報告

## 執行摘要
- 執行時間：2026-03-30 10:30 ~ 10:45 (15 分鐘)
- 執行環境：Local Development
- 測試總數：34
- ✅ 通過：32
- ❌ 失敗：2
- ⏭️ 跳過：0
- **成功率：94.1%**

## API 端點統計

| API 端點 | HTTP 方法 | 測試數 | 通過 | 失敗 | 成功率 |
|---------|---------|-------|------|------|--------|
| /api/customers | POST | 18 | 17 | 1 | 94.4% |
| /api/customers | GET | 2 | 2 | 0 | 100% |
| /api/customers/{id} | GET | 5 | 5 | 0 | 100% |
| /api/customers/{id} | PUT | 5 | 5 | 0 | 100% |
| /api/customers/{id} | DELETE | 4 | 3 | 1 | 75% |

## ✅ 通過的測試 (32 個)

1. **01-成功建立客戶 - 所有欄位.bru** ✅ (245ms)
   - 端點：POST /api/customers
   - 狀態碼：201
2. **02-成功建立客戶 - 僅必填欄位.bru** ✅ (198ms)
   ...

## ❌ 失敗的測試 (2 個)

1. **04-建立客戶失敗 - 缺少 name 欄位.bru** ❌
   - 端點：POST /api/customers
   - 預期狀態碼：400, 實際：500
   - 錯誤：伺服器內部錯誤

2. **04-重複刪除同一客戶失敗.bru** ❌
   - 端點：DELETE /api/customers/{id}
   - 預期狀態碼：404, 實際：500
   - 錯誤：測試超時 (超過 30 秒)

## 性能分析

### 最快的 5 個測試
1. 02-成功建立客戶 - 僅必填欄位.bru - 120ms
2. 01-成功取得存在的客戶資訊.bru - 135ms
3. 02-驗證回應包含時間戳記.bru - 145ms
4. 01-成功取得所有客戶列表.bru - 155ms
5. 01-成功更新客戶 - 更新所有欄位.bru - 165ms

### 最慢的 5 個測試
1. 01-建立客戶失敗 - 缺少 name 欄位.bru - 1200ms（超時失敗）
2. 03-成功更新客戶 - 更新所有欄位.bru - 380ms
3. 05-更新失敗 - 無效的 Email 格式.bru - 320ms
4. 04-重複刪除同一客戶失敗.bru - 15000ms（超時失敗）
5. 03-刪除失敗 - 無效的客戶 ID 格式.bru - 285ms

## 問題分析

### 失敗原因統計
- 伺服器內部錯誤 (500)：1 次
- 測試超時：1 次

### 建議
1. **檢查 POST /api/customers 必填欄位驗證**
   - 當缺少 name 欄位時，API 應返回 400 而不是 500
   - 相關測試：`04-建立客戶失敗 - 缺少 name 欄位.bru`

2. **優化 DELETE 操作的性能**
   - 刪除操作響應時間過長，考慮添加 DB 索引

3. **檢查網路連接**
   - 02:45 時出現超時，可能是網路抖動
   - 建議重新執行失敗的測試

---
報告生成時間：2026-03-30 10:45:30 UTC
Bruno CLI 版本：latest
映射檔案：api-tests-mapping.csv
```

## 參數說明

### 基本參數

| 參數 | 說明 | 範例 | 必填 |
|------|------|------|------|
| `--mapping` 或 `-m` | 映射清單檔路徑 (CSV/Excel) | `./api-tests-mapping.csv` | ✅ |
| `--output` 或 `-o` | 輸出報告目錄 | `./test-reports` | ❌ 預設：./test-reports |
| `--environment` 或 `-e` | 執行環境 | `Local`, `Testing`, `Production` | ❌ 預設：Local |

### 進階參數

| 參數 | 說明 | 範例 | 預設值 |
|------|------|------|--------|
| `--priority` | 優先級篩選 | `High`, `Medium`, `Low` | 全部 |
| `--api-filter` 或 `-a` | API 端點篩選 | `POST /api/customers` | 全部 |
| `--parallel-count` | 並行執行數 | `1-8` | 1 (順序) |
| `--timeout` | 全局超時(秒) | `60` | 30 |
| `--bruno-path` | Bruno 專案根目錄 | `./bruno` | 自動偵測 |
| `--skip-missing` | 跳過不存在的檔案 | `true`/`false` | `false` |
| `--format` | 報告格式 | `markdown`, `json`, `html` | `markdown,json` |

## 環境變數配置

### 位置
- `.env` - Local Development 環境
- `.env.testing` - Testing 環境
- `.env.production` - Production 環境

### 範本

**.env** (Local Development)：
```
BASE_URL=http://localhost:8080
USERNAME=testuser
PASSWORD=testpass
DEBUG=true
```

**.env.testing** (Testing)：
```
BASE_URL=https://api-testing.company.com
USERNAME=qa_user
PASSWORD=qa_pass
DEBUG=false
```

**.env.production** (Production)：
```
BASE_URL=https://api.company.com
USERNAME=prod_user
PASSWORD=prod_pass
DEBUG=false
```

## 故障排除

### 問題 1：「映射檔不存在」

**原因**：路徑錯誤或檔案未創建  
**解決**：
```bash
# 檢查檔案是否存在
ls -la api-tests-mapping.csv

# 確認路徑
pwd
```

### 問題 2：「Bruno CLI 未找到」

**原因**：未安裝 Bruno CLI  
**解決**：
```bash
npm install -g @usebruno/cli
# 驗證安裝
bruno --version
```

### 問題 3：「測試超時」

**原因**：API 響應慢或網路不穩定  
**解決**：
- 增加 timeout 參數：`--timeout 60`
- 檢查網路連接
- 檢查 API 伺服器狀態

### 問題 4：「報告未生成」

**原因**：輸出目錄無寫入權限  
**解決**：
```bash
# 檢查目錄擁有權和權限
ls -la test-reports/

# 如果目錄不存在，自動創建
mkdir -p test-reports
chmod 755 test-reports
```

## 檔案結構

```
.github/skills/03-run-bruno-tests-batch/
├── SKILL.md .......................... 完整技能文檔 (這個檔案)
├── README.md ......................... 快速開始指南
├── config.yml ........................ 配置檔案
├── templates/
│   ├── csv-excel-parser.md ........... CSV/Excel 解析指南
│   ├── test-execution-guide.md ....... 測試執行指南
│   ├── report-templates.md ........... Markdown 報告模板
│   └── example-mapping-list.md ....... 映射清單示例
```

## 下一步

✅ 已準備好執行批量測試！

### 建議的後續步驟

1. **創建映射清單檔**
   - 根據您的 API 和測試檔案結構，修改 `api-tests-mapping.csv`

2. **配置環境變數**
   - 為各環境創建 `.env`, `.env.testing`, `.env.production` 檔案

3. **執行第一次測試**
   - 在 Copilot 中提供映射檔路徑，執行批量測試

4. **檢視和分析報告**
   - 打開生成的 `test-reports/test-report.md` 文檔

5. **集成到 CI/CD**
   - 參考 SKILL.md 中的 GitHub Actions / GitLab CI 示例

## 相關資源

- **Skill 01-api-to-gherkin**：自動將 API 文檔轉換為 Feature 檔案
- **Skill 02-feature-to-bruno**：自動將 Feature 檔案轉換為 Bruno 測試腳本
- **Bruno 官方文檔**：https://docs.usebruno.com/
- **Git 版本控制**：推薦將映射檔和 Bruno 專案納入版本控制

---

**有任何問題？**  
在 Copilot 中描述您的需求，我會幫您：
- 創建或修改映射檔
- 執行批量測試
- 分析和解決測試失敗的問題
- 優化測試執行策略
