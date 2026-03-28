# 02-feature-to-bruno 技能

## 快速開始

本技能將 Gherkin `.feature` 檔案自動轉換為 Bruno 測試腳本 (`.bru` 檔案)。

### 使用場景

```bash
# 轉換單一 feature 檔
copilot --skill 02-feature-to-bruno --input ./features/customer-create.feature

# 轉換整個 features 目錄
copilot --skill 02-feature-to-bruno --input ./features

# 指定輸出目錄
copilot --skill 02-feature-to-bruno --input ./features --output ./bruno
```

## 文件結構

```
02-feature-to-bruno/
├── SKILL.md                      # 完整技能文檔
├── config.yml                    # 轉換配置文件
├── README.md                     # 本文件
└── templates/
    ├── bruno-syntax-guide.md     # Bruno 語法完整指南
    ├── feature-to-bruno-mapping.md # 轉換步驟對應規則
    ├── postman-to-bruno-migration.md # 從 Postman 遷移指南
    └── conversion-examples.md    # 實際轉換範例
```

## 核心文檔

| 檔案 | 用途 | 閱讀時機 |
|-----|------|--------|
| **SKILL.md** | 完整技能指南、工作流程、進階配置 | 初次使用、設置自訂配置 |
| **bruno-syntax-guide.md** | Bruno .bru 檔案的所有語法細節 | 理解 Bruno 文法、編寫複雜測試 |
| **feature-to-bruno-mapping.md** | Feature 步驟如何對應到 Bruno | 調試轉換問題、自訂轉換規則 |
| **postman-to-bruno-migration.md** | 從 Postman 遷移到 Bruno | 從其他工具遷移 |
| **conversion-examples.md** | 實際的轉換範例 | 了解轉換效果、複製模式 |
| **config.yml** | 轉換配置選項 | 自訂轉換行為 |

## 轉換流程圖

```
Feature 檔案 (.feature)
       ↓
   ┌─ 讀取 ─┐
   │        └→ 解析 Gherkin 語法
       ↓
   ┌─ 提取信息 ─┐
   │           ├→ Scenario 名稱
   │           ├→ Given (Setup)
   │           ├→ When (Action)
   │           └→ Then (Assertions)
       ↓
   ┌─ 轉換 ─┐
   │       ├→ HTTP 方法 & URL
   │       ├→ Header & Body
   │       └→ Assert tests
       ↓
   Bruno 測試腳本 (.bru)
       ↓
   ┌─ 輸出 ─┐
   │       ├→ .bru 檔案
   │       ├→ 目錄結構
   │       ├→ bruno.json 配置
   │       └→ README & 報告
       ↓
   在 Bruno 中執行測試
```

## 關鍵概念

### Feature 到 Bruno 的對應

| Feature 元素 | Bruno 對應 | 說明 |
|-----------|----------|------|
| Scenario | .bru 檔案 | 單一測試請求 |
| Given | vars, headers | 設置請求前置條件 |
| When | HTTP 方法 & URL | 發送 HTTP 請求 |
| Then | tests { } | 驗證回應 |

### 對應規則

**Given 步驟** → 設置變數和 Header：
```gherkin
Given API 基底 URL 為 "http://localhost:8080"
And Content-Type 設定為 "application/json"
And Authorization 設定為 Bearer token "{{token}}"
```

**When 步驟** → HTTP 請求：
```gherkin
When 發送 POST 請求到 "/api/customers"
```

**Then 步驟** → 測試驗證：
```gherkin
Then HTTP 狀態碼應為 201
And 回應的 name 應為 "John Doe"
```

## 常用命令

### VS Code + Copilot

```bash
# 在 VS Code 終端中
copilot --skill 02-feature-to-bruno --input ./features --output ./bruno
```

### 命令行參數

```bash
--input <path>      # Feature 檔案或目錄 (必須)
--output <path>     # 輸出目錄，預設 ./bruno
--config <file>     # 自訂配置檔，預設 ./config.yml
--overwrite         # 覆蓋現有檔案
--no-backup         # 不備份舊檔案
--verbose           # 詳細日誌
```

## 轉換配置

編輯 `config.yml` 来控制：

- **目錄結構** - 如何組織輸出的資料夾
- **命名規則** - .bru 檔案的命名方式
- **環境配置** - 預設的多環境設定
- **驗證規則** - feature 語法檢查
- **文檔生成** - README、索引等

詳見 `config.yml` 檔案。

## 支援的 Feature 語法

### 完全支持

✅ **Basic HTTP Methods**
```gherkin
When 發送 GET 請求到 "/api/users"
When 發送 POST 請求到 "/api/users"
When 發送 PUT 請求到 "/api/users/123"
When 發送 DELETE 請求到 "/api/users/123"
```

✅ **Request Setup**
```gherkin
Given API 基底 URL 為 "http://localhost:8080"
And Content-Type 設定為 "application/json"
And Authorization 設定為 Bearer token "{{authToken}}"
```

✅ **Request Body (Data Table)**
```gherkin
And 準備建立客戶的請求
  | 欄位 | 值 |
  | name | John |
  | email | john@example.com |
```

✅ **Assertions**
```gherkin
Then HTTP 狀態碼應為 201
And 回應的 name 應為 "John"
And 錯誤訊息應包含 "Email already exists"
```

✅ **Variables & Dynamics**
```gherkin
When 發送 GET 請求到 "/api/users/{{userId}}"
Given 準備請求 | timestamp | {{$now}} |
```

✅ **Scenario Outline**
```gherkin
Scenario Outline: 中英文標題支持
  When 發送 POST 請求到 "/api/users"
  Then HTTP 狀態碼應為 <status>

  Examples:
    | status |
    | 201 |
    | 400 |
```

## 轉換結果

執行轉換後會產生：

```
./bruno/
├── bruno.json              # 環境配置
├── README.md               # 使用說明
├── API-INVENTORY.md        # API 索引
├── conversion-report.json  # 轉換報告
└── Customer Management/
    ├── Create Customer/
    │   ├── 成功建立客戶 - 所有欄位.bru
    │   ├── 成功建立客戶 - 僅必填欄位.bru
    │   └── 建立客戶失敗 - 缺少 name.bru
    ├── Get Customer/
    └── Delete Customer/
```

## 下一步

1. **查看完整文檔** → [SKILL.md](./SKILL.md)
2. **了解 Bruno 語法** → [bruno-syntax-guide.md](./templates/bruno-syntax-guide.md)
3. **查看轉換範例** → [conversion-examples.md](./templates/conversion-examples.md)
4. **自訂轉換配置** → [config.yml](./config.yml)
5. **從 Postman 遷移** → [postman-to-bruno-migration.md](./templates/postman-to-bruno-migration.md)

## 技能整合

本技能可與其他技能配合使用：

```
01-api-to-gherkin          02-feature-to-bruno
(API → Feature)       →    (Feature → Bruno)
```

工作流程：
1. 使用 **01-api-to-gherkin** 從 API 文件生成 Feature 檔
2. 使用 **02-feature-to-bruno** 將 Feature 轉換為 Bruno 測試
3. 在 Bruno 中執行測試並驗證 API

## 故障排除

### Feature 檔案未被識別
- 確保檔案副檔名為 `.feature`
- 檢查 Feature 檔案路徑
- 驗證檔案編碼為 UTF-8

### 步驟未被正確轉換
- 查看 [feature-to-bruno-mapping.md](./templates/feature-to-bruno-mapping.md) 確認語法
- 檢查 config.yml 中的正則表達式 pattern
- 使用 `--verbose` 選項查看詳細日誌

### 環境變數未替換
- 確認環境中定義了變數
- 檢查變數名稱和大小寫
- 在 Bruno 中驗證環境配置

## 資源

- [Bruno 官方網站](https://www.usebruno.com/)
- [Bruno 文檔](https://docs.usebruno.com/)
- [Bruno GitHub](https://github.com/usebruno/bruno)
- [Gherkin 語言參考](https://cucumber.io/docs/gherkin/)

## 許可證

本技能遵循專案許可證。

