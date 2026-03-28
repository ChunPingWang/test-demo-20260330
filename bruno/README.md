# Customer API Test Suite - Bruno

這是透過 **02-feature-to-bruno** 技能從 Gherkin (.feature) 檔案自動轉換而成的 Bruno 測試套件。

## 📁 目錄結構

```
bruno/
├── Customer Management/
│   ├── Create Customer/          # POST /api/customers
│   │   ├── 01-成功建立客戶-所有欄位.bru
│   │   ├── 02-成功建立客戶-僅必填欄位.bru
│   │   └── ... (18 個測試)
│   ├── Get Customer/             # GET /api/customers/{id}
│   │   ├── 01-成功取得存在的客戶資訊.bru
│   │   ├── 02-驗證回應包含時間戳記.bru
│   │   └── ... (5 個測試)
│   ├── Get All Customers/        # GET /api/customers
│   │   ├── 01-成功取得所有客戶列表.bru
│   │   └── 02-成功取得空的客戶列表.bru
│   ├── Update Customer/          # PUT /api/customers/{id}
│   │   ├── 01-成功更新客戶-更新所有欄位.bru
│   │   ├── 02-成功更新客戶-僅更新name.bru
│   │   └── ... (5 個測試)
│   └── Delete Customer/          # DELETE /api/customers/{id}
│       ├── 01-成功刪除存在的客戶.bru
│       ├── 02-刪除失敗-客戶不存在.bru
│       └── ... (4 個測試)
├── bruno.json                      # 環境配置檔
└── README.md                       # 本檔案
```

## 🎯 測試覆蓋

| 功能 | 測試數 | 涵蓋範圍 |
|------|--------|---------|
| Create Customer | 18 | 正向(3個) + 錯誤(8個) + 邊界值(7個) |
| Get Customer | 5 | 正向(2個) + 錯誤(3個) |
| Get All Customers | 2 | 正向(2個) |
| Update Customer | 5 | 正向(2個) + 錯誤(3個) |
| Delete Customer | 4 | 正向(1個) + 錯誤(3個) |
| **總計** | **34** | **完整的 API 終端點覆蓋** |

## 🚀 快速開始

### 前置需求
- 已安裝 [Bruno](https://www.usebruno.com/)
- Customer API 伺服器正在運行

### 步驟 1：開啟集合

1. 在 Bruno 中，選擇 **File → Open Collection**
2. 選擇 `bruno` 目錄
3. 所有測試應會自動載入

### 步驟 2：設定環境

1. 點擊左上角環境下拉菜單
2. 選擇適當的環境：
   - **Local Development**（本地開發）- `http://localhost:8080`
   - **Testing** - `https://test-api.example.com`
   - **Production** - `https://api.example.com`

### 步驟 3：執行測試

#### 执行單個測試
1. 點擊想要的 .bru 檔案
2. 點擊 **Send** 按鈕

#### 執行整個資料夾
1. 右鍵點擊資料夾（如 "Create Customer"）
2. 選擇 **Run（執行）**
3. Bruno 會依序執行該資料夾中的所有測試

#### 執行全部測試
1. 右鍵點擊 **Customer Management**
2. 選擇 **Run（執行）**
3. 所有 34 個測試會依序執行

## 📊 執行結果

完成執行後，Bruno 會顯示：
- ✅ 通過的測試
- ❌ 失敗的測試
- ⏱️ 每個測試的執行時間
- 詳細的回應體和標頭資訊

## 🔧 環境設定

`bruno.json` 定義了 3 個環境環境及其 `BASE_URL` 變數：

```json
{
  "Local Development": "http://localhost:8080",
  "Testing": "https://test-api.example.com",
  "Production": "https://api.example.com"
}
```

### 自訂環境

若要新增或修改環境：

1. 在 Bruno 中，選擇 **Environments**
2. 點擊 **Create New**
3. 設定 `BASE_URL` 變數值
4. 保存

## 📝 測試命名規則

每個測試檔案遵循以下命名規則：

```
[序號]-[測試標題].bru

範例：
01-成功建立客戶-所有欄位.bru
04-建立客戶失敗-缺少name欄位.bru
11-驗證name欄位長度限制-A.bru
```

- **序號**（01-99）：定義執行順序（seq 欄位）
- **標題**：使用中文描述測試目的

## 🛠️ 測試結構

每個 .bru 測試檔案包含以下部分：

```bru
meta {
  name: 測試名稱
  type: http
  seq: 1              # 執行順序
}

vars {
  base_url: {{BASE_URL}}
}

# HTTP 請求
POST {{base_url}}/api/customers
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com"
}

# 測試斷言
tests {
  test("驗證狀態碼", function() {
    expect(res.status).to.equal(201);
  });
  
  test("驗證回應欄位", function() {
    expect(res.body.id).to.exist;
    expect(res.body.name).to.equal("John Doe");
  });
}
```

## 🎓 常見斷言

Bruno 支援以下斷言語法（基於 Chai）：

```javascript
// 狀態碼驗證
expect(res.status).to.equal(200);
expect(res.status).to.be.oneOf([200, 201]);

// 欄位存在性
expect(res.body.id).to.exist;
expect(res.body.email).to.not.be.empty;

// 型別驗證
expect(res.body.createdAt).to.be.a('string');
expect(res.body).to.be.an('array');

// 值比較
expect(res.body.name).to.equal("John Doe");
expect(res.body.email).to.include("@");

// 正規表達式
expect(res.body.createdAt).to.match(/^\d{4}-\d{2}-\d{2}T/);

// 陣列操作
expect(res.body.length).to.be.above(0);
expect(res.body).to.include.members([...]);
```

## 🐛 故障排除

### 問題 1：所有測試都失敗，顯示連接錯誤

**原因**：`BASE_URL` 不正確或伺服器未運行

**解決方案**：
1. 確認 Customer API 伺服器已啟動
2. 驗證環境中的 `BASE_URL` 是否正確
3. 檢查網路連接

### 問題 2：測試在執行過程中停止

**原因**：測試失敗或超時

**解決方案**：
1. 檢查失敗測試的詳細錯誤訊息
2. 確認 API 回應格式是否符合預期
3. 增加超時時間（在環境中設定 `timeout` 變數）

### 問題 3：取得 404 Not Found 錯誤

**原因**：API 端點不存在或路徑錯誤

**解決方案**：
1. 驗證 `BASE_URL` 是否指向正確的伺服器
2. 檢查 API 路由是否已部署
3. 檢查 Bruno 中是否有 Proxy 設定（Bruno → Settings）

### 問題 4：變數未正確替換

**原因**：變數名稱拼寫錯誤或環境未正確設定

**解決方案**：
1. 確認變數用 `{{變數名}}` 語法包裹
2. 驗證環境已正確選擇
3. 嘗試在 Bruno 中手動刷新環境

## 📚 相關資源

- [02-feature-to-bruno 技能文檔](../.github/skills/02-feature-to-bruno/SKILL.md)
- [Bruno 官方文檔](https://www.usebruno.com/docs)
- [Gherkin 語法參考](https://cucumber.io/docs/gherkin/)

## 📝 轉換資訊

- **來源**：`./features/` 目錄中的 Gherkin .feature 檔案
- **工具**：02-feature-to-bruno 技能
- **轉換日期**：自動生成
- **檔案數**：34 個 .bru 測試檔案

## 💡 提示

1. **批量執行前先測試單個**：先以單個環境測試，確保 API 連接正確
2. **查看詳細日誌**：Bruno 在運行測試時會顯示請求/回應詳情
3. **保存回應資料**：可使用 `set()` 函數保存值供後續測試使用
4. **環境隔離**：建議為不同環境（本地/測試/生產）使用不同的 Bruno 配置

## 📞 支援

如遇問題，請參考：
1. 本 README 中的故障排除部分
2. 原始特徵檔案 (`./features/`)
3. [02-feature-to-bruno 技能文檔](../.github/skills/02-feature-to-bruno/SKILL.md)

---

**自動生成的 Bruno 測試套件** ✨
由 02-feature-to-bruno 技能從 Gherkin 轉換
