# 測試執行指南

## 概述

本指南詳細說明如何自動化執行 Bruno 測試並收集執行結果。

## 執行流程

### 第 1 步：前置準備

#### 1.1 驗證 Bruno 安裝

```bash
bruno --version
# 輸出：bruno/1.x.x
```

若未安裝，執行：

```bash
npm install -g @usebruno/cli
```

#### 1.2 準備環境變數檔案

```bash
# 創建 Local 開發環境
cat > .env << EOF
BASE_URL=http://localhost:8080
USERNAME=testuser
PASSWORD=testpass
DEBUG=true
EOF

# 創建 Testing 環境
cat > .env.testing << EOF
BASE_URL=https://api-testing.company.com
USERNAME=qa_user
PASSWORD=qa_pass
DEBUG=false
EOF

# 創建 Production 環境
cat > .env.production << EOF
BASE_URL=https://api.company.com
USERNAME=prod_user
PASSWORD=prod_pass
DEBUG=false
EOF
```

#### 1.3 驗證 Bruno 專案結構

```bash
tree bruno/ -L 2
# 預期輸出：
# bruno/
# ├── bruno.json
# ├── Customer Management/
# │   ├── Create Customer/
# │   ├── Get All Customers/
# │   ├── Get Customer/
# │   ├── Update Customer/
# │   └── Delete Customer/
# └── README.md
```

### 第 2 步：測試發現

#### 2.1 自動發現測試

系統自動掃描 Bruno 專案目錄，發現所有 `.bru` 檔案：

```javascript
// 偽代碼：發現邏輯
function discoverTests(brunoDirPath) {
  const testFiles = [];
  
  // 遞迴掃描所有目錄
  recursiveReadDir(brunoDirPath, (filePath) => {
    if (filePath.endsWith('.bru')) {
      // 解析 .bru 檔案的元數據
      const metadata = parseBruFile(filePath);
      testFiles.push({
        filePath: filePath,
        name: metadata.name,
        method: metadata.request.method,
        endpoint: metadata.request.url,
        seq: metadata.seq || getSequenceNumber(filePath)
      });
    }
  });
  
  // 按序號排序
  return testFiles.sort((a, b) => a.seq - b.seq);
}
```

#### 2.2 測試計數

根據映射檔，統計應執行的測試數量：

```
發現的測試：
- 總計：34 個 .bru 檔案
- 篩選後：28 個（跳過已標記為「跳過」的測試）
- 應執行：28 個測試
```

### 第 3 步：測試執行

#### 3.1 順序執行

逐一執行每個測試，前一個完成後再執行下一個：

```bash
# 執行邏輯
for each testFile in testFiles:
  result = executeTest(testFile)
  saveResult(result)
  if result.failed and (not continue-on-failure):
    break  # 終止執行
```

#### 3.2 並行執行

同時執行多個測試（預設為 4 個並行）：

```bash
# 執行邏輯
parallelCount = 4
for batch in chunks(testFiles, parallelCount):
  promises = []
  for each testFile in batch:
    promise = executeTestAsync(testFile)
    promises.push(promise)
  
  awaitAll(promises)  # 等待批次完成
```

#### 3.3 按優先級執行

先執行高優先級，再執行中等優先級，最後低優先級：

```bash
# 執行邏輯
highPriority = filter(testFiles, priority == "High")
mediumPriority = filter(testFiles, priority == "Medium")
lowPriority = filter(testFiles, priority == "Low")

execute(highPriority)
execute(mediumPriority)
execute(lowPriority)
```

#### 3.4 單個測試執行流程

每個測試執行時經歷以下步驟：

```
1. 加載測試檔案 (.bru)
   └─> 解析 meta, vars, request, tests 區塊

2. 設置環境變數
   └─> 注入 .env 中的變數
   └─> 注入自訂變數 (來自映射檔)

3. 發送 HTTP 請求
   └─> 組建完整 URL ({{BASE_URL}} 參數化)
   └─> 設置 Headers (Content-Type, Authorization 等)
   └─> 設置 Request Body (JSON/Form 格式)
   └─> 發送請求並等待回應

4. 捕捉回應
   └─> 狀態碼
   └─> 回應頭
   └─> 回應體 (JSON/HTML/Text)
   └─> 響應時間

5. 執行斷言 (expect statements)
   └─> 狀態碼驗證
   └─> JSON 欄位驗證
   └─> 正規表達式匹配
   └─> 部分失敗時記錄失敗原因

6. 記錄結果
   └─> PASS / FAIL / TIMEOUT
   └─> 詳細的測試數據
```

### 第 4 步：結果捕捉

#### 4.1 測試結果結構

每個測試執行後捕捉以下數據：

```json
{
  "id": 1,
  "testFile": "01-成功建立客戶 - 所有欄位.bru",
  "endpoint": "POST /api/customers",
  "environment": "Local",
  "status": "PASS",
  "duration": 245,
  "startTime": "2026-03-30T10:30:00Z",
  "endTime": "2026-03-30T10:30:00.245Z",
  "request": {
    "method": "POST",
    "url": "http://localhost:8080/api/customers",
    "headers": {
      "Content-Type": "application/json"
    },
    "body": "{\"name\": \"John Doe\", \"email\": \"john@example.com\"}"
  },
  "response": {
    "statusCode": 201,
    "statusText": "Created",
    "headers": {
      "Content-Type": "application/json; charset=utf-8",
      "Content-Length": "512"
    },
    "body": "{\"id\": \"123e4567-e89b-12d3-a456-426614174000\", ...}",
    "size": 512
  },
  "assertions": {
    "total": 5,
    "passed": 5,
    "failed": 0,
    "details": [
      { "assertion": "expect(response.status).to.equal(201)", "result": "PASS" },
      { "assertion": "expect(response.body.id).to.exist", "result": "PASS" }
    ]
  },
  "error": null
}
```

#### 4.2 失敗結果結構

```json
{
  "id": 2,
  "testFile": "04-建立客戶失敗 - 缺少 name 欄位.bru",
  "endpoint": "POST /api/customers",
  "environment": "Local",
  "status": "FAIL",
  "duration": 1200,
  "request": { ... },
  "response": {
    "statusCode": 500,
    "statusText": "Internal Server Error",
    "body": "{\"error\": \"Internal Server Error\"}"
  },
  "assertions": {
    "total": 3,
    "passed": 1,
    "failed": 2,
    "details": [
      { "assertion": "expect(response.status).to.equal(400)", "result": "FAIL", "actual": 500 },
      { "assertion": "expect(response.body.message).to.include('name is required')", "result": "FAIL" }
    ]
  },
  "error": "Assertion failed: Expected response.status to equal 400, but got 500"
}
```

#### 4.3 超時結果結構

```json
{
  "id": 3,
  "testFile": "04-重複刪除同一客戶失敗.bru",
  "endpoint": "DELETE /api/customers/{id}",
  "environment": "Local",
  "status": "TIMEOUT",
  "duration": 30000,
  "startTime": "2026-03-30T10:45:00Z",
  "request": { ... },
  "response": null,
  "error": "Test execution exceeded timeout limit of 30000ms"
}
```

### 第 5 步：結果彙總

執行完所有測試後，彙總統計結果：

```
批量執行統計：
├─ 總計：34 個測試
├─ 通過：32 個 (94.1%)
├─ 失敗：2 個 (5.9%)
├─ 超時：0 個 (0%)
├─ 跳過：0 個 (0%)
├─ 執行時間：15 分 30 秒
├─ 平均每個測試：27.4 秒
├─ 最快測試：120ms
├─ 最慢測試：380ms
└─ API 端點統計：
    ├─ POST /api/customers：18 個 (17 通過, 1 失敗)
    ├─ GET /api/customers：2 個 (2 通過)
    ├─ GET /api/customers/{id}：5 個 (5 通過)
    ├─ PUT /api/customers/{id}：5 個 (5 通過)
    └─ DELETE /api/customers/{id}：4 個 (3 通過, 1 失敗)
```

## 進階執行策略

### 策略 1：失敗自動重試

當測試失敗時，自動重試指定次數：

```bash
# 配置
retry-count: 2
retry-delay: 1000  # 重試前等待 1 秒

# 執行邏輯
for attempt in (1..retry-count):
  result = executeTest(testFile)
  if result.passed:
    break
  if attempt < retry-count:
    sleep(retry-delay)
```

### 策略 2：測試依賴順序

某些測試有前置條件（例：刪除前必須建立），按依賴順序執行：

```bash
# 映射檔配置
API 端點,測試檔案,依賴
POST /api/customers,01-建立.bru,
DELETE /api/customers/{id},01-刪除.bru,POST /api/customers/01-建立.bru

# 執行邏輯
1. 先執行 POST /api/customers 的所有測試
2. 取得響應中的 ID
3. 再執行 DELETE 的測試，使用步驟 2 的 ID
```

### 策略 3：資料驅動執行

使用不同的測試數據執行同一個測試檔案：

```bash
# 映射檔配置
API 端點,測試檔案,測試數據
POST /api/customers,01-建立.bru,data/customer-1.json
POST /api/customers,01-建立.bru,data/customer-2.json
POST /api/customers,01-建立.bru,data/customer-3.json

# 執行邏輯
for dataFile in [customer-1.json, customer-2.json, customer-3.json]:
  variables = loadJSON(dataFile)
  result = executeTest(testFile, variables)
  saveResult(result)
```

### 策略 4：環境變數注入

執行測試前，將環境變數和自訂變數注入到 Bruno 上下文：

```bash
# .env 環境變數
BASE_URL=http://localhost:8080
API_KEY=your-api-key-here

# 映射檔自訂變數 (若支援)
API 端點,HTTP 方法,自訂變數
POST /api/customers,POST,{"tenant_id": "123"}
GET /api/customers/{id},GET,{"customer_id": "456"}

# 注入邏輯
context = mergeVariables({
  ...loadEnvFile('.env'),
  ...customVariables
})
result = executeTest(testFile, context)
```

## 性能優化

### 優化 1：並行執行

```bash
# 配置
parallel-count: 4

# 性能提升
- 順序執行：34 測試 × 27.4 秒 / 測試 ≈ 15 分鐘
- 並行 4 個：34 測試 / 4 並行 × 27.4 秒 ≈ 4 分鐘（加速 3.75 倍）

# 注意：
- 測試必須獨立，無數據依賴
- 需注意 API 速率限制
- 可能導致資料庫衝突
```

### 優化 2：選擇性執行

只執行必要的測試子集：

```bash
# 只執行 High 優先級
--priority High

# 只執行特定 API
--api-filter "POST /api/customers"

# 執行時間
- 完整測試：15 分鐘
- 僅 High 優先級 (9 個)：~4 分鐘
- 僅 POST /api/customers (18 個)：~8 分鐘
```

### 優化 3：測試快取

快取頻繁使用的資源（如靜態數據）：

```javascript
// 偽代碼：快取邏輯
const cache = {};

function getOrCreateResource(type, id) {
  const key = `${type}:${id}`;
  if (!cache[key]) {
    cache[key] = createResource(type);
  }
  return cache[key];
}
```

## 故障排除

### 故障 1：連接失敗

**症狀**：
```
Error: connect ECONNREFUSED 127.0.0.1:8080
```

**原因**：API 伺服器未啟動或地址錯誤

**解決**：
```bash
# 確認伺服器運行
curl http://localhost:8080/health

# 檢查 .env 中的 BASE_URL
cat .env | grep BASE_URL

# 確認防火牆未阻止連接
```

### 故障 2：認證失敗

**症狀**：
```
Error: 401 Unauthorized
```

**原因**：API Key 或認證令牌過期或錯誤

**解決**：
```bash
# 確認 .env 中的認證信息
cat .env | grep -E "API_KEY|TOKEN|PASSWORD"

# 更新認證信息
export API_KEY="new-key-here"
```

### 故障 3：超時

**症狀**：
```
Test execution exceeded timeout limit of 30000ms
```

**原因**：API 響應慢或網路不穩定

**解決**：
```bash
# 增加超時時間
--timeout 60

# 檢查 API 伺服器性能
curl -w "Response time: %{time_total}s\n" http://localhost:8080/api/customers

# 檢查網路連接
ping api-server.com
```

## 監控和日誌

### 日誌級別

```bash
# 級別 1：簡化日誌（預設）
✅ Test 1 PASSED
❌ Test 2 FAILED: Assertion error
⏱️ Test 3 TIMEOUT

# 級別 2：詳細日誌 (--verbose)
→ Sending POST http://localhost:8080/api/customers
  Headers: { Content-Type: application/json }
  Body: { "name": "John Doe" }
← Response: 201 Created (245ms)
  Headers: { Content-Type: application/json }
  Body: { "id": "123..." }
✅ Assertion 1: expect(response.status).to.equal(201) PASSED
✅ Assertion 2: expect(response.body.id).to.exist PASSED

# 級別 3：調試日誌 (--debug)
[DEBUG] Loading test file: /path/to/01-create.bru
[DEBUG] Parsed request: POST http://localhost:8080/api/customers
[DEBUG] Setting environment variables from .env
[DEBUG] BASE_URL = http://localhost:8080
[DEBUG] Executing request...
...
```

### 實時監控

```bash
# 在另一個終端監控日誌
tail -f test-reports/execution.log | grep -E "PASSED|FAILED|TIMEOUT"

# 统計通過/失敗比例
tail -f test-reports/execution.log | \
  grep -oE "(PASSED|FAILED|TIMEOUT)" | sort | uniq -c
```

---

**版本**：1.0  
**最後更新**：2026-03-30
