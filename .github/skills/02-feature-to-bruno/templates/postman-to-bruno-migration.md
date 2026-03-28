# 從 Postman 遷移到 Bruno

如果你已在使用 Postman，這份指南幫助你快速遷移到 Bruno。

## 為什麼選擇 Bruno 而非 Postman？

| 特性 | Bruno | Postman |
|-----|-------|--------|
| **開源** | ✅ 完全開源 | ❌ 非開源 |
| **版本控制** | ✅ .bru 文本格式，Git 友善 | ⚠️ JSON 格式，難以追蹤變更 |
| **離線使用** | ✅ 完全離線 | ❌ 需要連線 |
| **數據隱私** | ✅ 本地存儲 | ⚠️ 雲端存儲 |
| **系統資源** | ✅ 輕량级 | ⚠️ 較重 |
| **CLI 工具** | ✅ 內建 bruno CLI | ✅ 有 newman CLI |
| **成本** | ✅ 免費 | ❌ 個人付費方案 + 團隊方案昂貴 |
| **IDE 整合** | ✅ VS Code 原生支持 | ⚠️ 需要插件 |

## 基本概念對應

| Postman | Bruno | 說明 |
|---------|-------|------|
| Collection | Collection (資料夾) | 測試集合 |
| Folder | Subfolder | 子資料夾分組 |
| Request | Request (.bru 檔案) | 單一請求 |
| Environment | Environment | 環境變數配置 |
| Variable | Variable | 變數 (全域或環境) |
| Pre-request Script | vars:pre-request | 前置處理 |
| Tests | tests | 後置驗證 |
| Global Variables | Global Scope | 全域變數 |

## 遷移步驟

### 步驟 1: 從 Postman 匯出

1. 在 Postman 中選擇 Collection
2. 點擊 ⋯ 菜單 → Export
3. 選擇 Collection v2.1 format
4. 儲存為 `collection.json`

### 步驟 2: 使用 Bruno CLI 進行轉換

```bash
# 安裝 bruno cli
npm install -g @usebruno/cli

# 建立新的 Bruno collection
bruno create collection ./my-api-tests

# 匯入 Postman collection (如果支持)
# 目前需要手動遷移或使用轉換工具
```

### 步驟 3: 手動遷移指南

#### 3.1 建立目錄結構

Postman Collection 結構：
```
My Collection/
├── Auth Endpoints/
│   ├── Login
│   ├── Logout
├── User Endpoints/
│   ├── Create User
│   ├── Get User
```

遷移為 Bruno：
```bash
mkdir -p ./bruno/Auth\ Endpoints
mkdir -p ./bruno/User\ Endpoints
```

#### 3.2 轉換單一請求

**Postman 請求範例**
```json
{
  "name": "Create User",
  "request": {
    "method": "POST",
    "url": "{{baseUrl}}/api/users",
    "header": [
      {
        "key": "Content-Type",
        "value": "application/json"
      },
      {
        "key": "Authorization",
        "value": "Bearer {{authToken}}"
      }
    ],
    "body": {
      "mode": "raw",
      "raw": "{\n  \"name\": \"John Doe\",\n  \"email\": \"john@example.com\"\n}"
    }
  },
  "event": [
    {
      "listen": "test",
      "script": {
        "exec": [
          "pm.test(\"Status should be 201\", function () {",
          "    pm.response.to.have.status(201);",
          "});",
          "pm.environment.set(\"userId\", pm.response.json().id);"
        ]
      }
    }
  ]
}
```

**轉換為 Bruno (.bru)**
```bru
meta {
  name: Create User
  type: http
  seq: 1
}

vars {
  baseUrl: {{baseUrl}}
  authToken: {{authToken}}
}

POST {{baseUrl}}/api/users
Content-Type: application/json
Authorization: Bearer {{authToken}}

{
  "name": "John Doe",
  "email": "john@example.com"
}

tests {
  test("Status should be 201", function() {
    expect(res.status).to.equal(201);
  });
}

tests:post-response {
  set('userId', res.body.id);
}
```

### 步驟 4: 轉換環境變數

**Postman Environments (JSON)**
```json
{
  "id": "12345",
  "name": "Local Development",
  "values": [
    {
      "key": "baseUrl",
      "value": "http://localhost:8080",
      "enabled": true
    },
    {
      "key": "authToken",
      "value": "token_123456",
      "enabled": true
    }
  ]
}
```

**Bruno Environments**

在 Bruno 中建立環境配置：
1. 點擊頂部 "Environments" 按鈕
2. 建立新環境 "Local Development"
3. 新增變數：
   - `baseUrl: http://localhost:8080`
   - `authToken: token_123456`

### 步驟 5: 轉換 Tests

**Postman Tests**
```javascript
// 狀態碼驗證
pm.test("Status is 200", function () {
    pm.response.to.have.status(200);
});

// 回應體驗證
pm.test("Response has user id", function () {
    let jsonData = pm.response.json();
    pm.expect(jsonData.id).to.exist;
});

// 設定變數
pm.environment.set("variable_key", "variable_value");

// 保存到全域
pm.globals.set("variable_key", "variable_value");
```

**Bruno Tests**
```javascript
// 狀態碼驗證
test("Status is 200", function () {
  expect(res.status).to.equal(200);
});

// 回應體驗證
test("Response has user id", function () {
  expect(res.body.id).to.exist;
});

// 設定環境變數
tests:post-response {
  set("variable_key", "variable_value");
}
```

**主要差異**:
- `pm.test()` → `test()`
- `pm.response.to.have.status()` → `expect(res.status).to.equal()`
- `pm.expect()` → `expect()`
- `pm.environment.set()` → `set()` (在 tests:post-response 中)

### 步驟 6: 轉換 Pre-request Scripts

**Postman Pre-request Script**
```javascript
// 產生隨機值
var randomId = pm.variables.replaceIn('{{$randomInt}}');
pm.environment.set("customId", randomId);

// 計算簽名
var crypto = require('crypto');
var signature = crypto.createHash('sha256').update('data').digest('hex');
pm.environment.set("signature", signature);

// 時間戳
pm.environment.set("timestamp", Date.now());
```

**Bruno Pre-request Script**
```javascript
// 產生隨機值
set("customId", Math.floor(Math.random() * 1000000));

// 計算簽名
const crypto = require('crypto');
const signature = crypto.createHash('sha256').update('data').digest('hex');
set("signature", signature);

// 時間戳
set("timestamp", Date.now());
```

## 常見轉換模式

### 模式 1: 認證流程

**Postman 流程**
```
1. Login (POST /auth/login)
   - 保存 authToken 到環境
2. Subsequent Requests (GET /api/users)
   - 使用 {{authToken}}
```

**Bruno 流程**

相同的流程，但使用 Bruno 的 `set()` 來保存令牌：

`auth-login.bru`:
```bru
POST {{baseUrl}}/auth/login

{
  "username": "user",
  "password": "pass"
}

tests:post-response {
  set('authToken', res.body.token);
}
```

後續請求自動使用保存的 token。

### 模式 2: 資料設定和清理

**Postman**
```javascript
// Tests 部分 - 記錄建立的 ID
pm.test("Save created user ID", function() {
  pm.environment.set("userId", pm.response.json().id);
});
```

**Bruno**
```bru
tests:post-response {
  set('userId', res.body.id);
}
```

### 模式 3: 條件邏輯

**Postman**
```javascript
pm.test("Conditional test", function () {
    if (pm.response.code === 201) {
        pm.expect(pm.response.json().id).to.exist;
    } else {
        pm.expect(pm.response.json().error).to.exist;
    }
});
```

**Bruno**
```javascript
tests {
  if (res.status === 201) {
    test("Response has ID", function() {
      expect(res.body.id).to.exist;
    });
  } else {
    test("Response has error", function() {
      expect(res.body.error).to.exist;
    });
  }
}
```

## 遷移檢查清單

- [ ] 所有 Collections 都已建立為 Bruno 資料夾結構
- [ ] 所有 Requests 都已轉換為 .bru 檔案
- [ ] 所有 Environment 變數都已配置
- [ ] 所有 Pre-request Scripts 都已遷移
- [ ] 所有 Tests 都已轉換
- [ ] 授權頭已正確配置
- [ ] 通過 Bruno CLI 執行並驗證所有測試
- [ ] Responses 與 Postman 中的行為一致
- [ ] 環境正確切換

## 文件對應清單

| 文件夾 | Postman | Bruno |
|--------|--------|-------|
| Collection 設定 | 導出 JSON | bruno.json |
| 環境 | Environments JSON | 環境設定面板 |
| 請求 | Request JSON | .bru 檔案 |
| 前置指令碼 | Pre-request Script | vars:pre-request |
| 測試 | Tests | tests |
| 版本控制 | Git JSON 有衝突 | Git .bru 無衝突 |

## 常見問題

### Q: Postman 中的 Dynamic Variables (如 $randomInt) 在 Bruno 中如何使用？
A: Bruno 有內建變數：
- `{{$uuid}}` - UUID
- `{{$timestamp}}` - 時間戳
- `{{$now}}` - ISO 時間
- `{{$randomInt}}` - 隨機整數
- `{{$randomAlphaNumeric}}` - 隨機字符串

### Q: Bruno 是否支持 Postman 的 Workflows？
A: Bruno 目前不支持 Workflows，但可使用 CLI 命令實現順序執行：
```bash
bruno run ./bruno/Auth --environment "Local"
bruno run ./bruno/Users --environment "Local"
```

### Q: 如何在 CI/CD 中執行 Bruno 測試？
A: 使用 Bruno CLI：
```bash
npm install -g @usebruno/cli
bruno run ./bruno --environment "Testing" --output test-results.json
```

### Q: Bruno 中如何共享 Collections？
A: 將 ./bruno 資料夾推送到 Git，團隊成員 Clone 後在 Bruno 中 Open Collection。

## 資源

- [Bruno 官方文檔](https://docs.usebruno.com/)
- [Bruno GitHub](https://github.com/usebruno/bruno)
- [Feature 到 Bruno 轉換](./feature-to-bruno-mapping.md)
- [Bruno 語法指南](./bruno-syntax-guide.md)

