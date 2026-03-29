# Customer Management API

Spring Boot RESTful API，提供客戶資料的 CRUD 操作，整合 Swagger UI 作為互動式 API 文件。

## 技術架構

| 技術 | 說明 |
|------|------|
| Java 21+ | 程式語言 |
| Spring Boot 3.4.4 | Web 框架 |
| Spring Data JPA | ORM / 資料存取層 |
| H2 Database | 預設記憶體資料庫 |
| PostgreSQL | 可切換的正式資料庫 |
| Bean Validation | 請求參數驗證 |
| SpringDoc OpenAPI 2.8.6 | Swagger UI / OpenAPI 3.0 文件 |
| JUnit 5 | 單元與整合測試 |
| Gradle | 建置工具 |

## 專案結構

```
src/main/java/com/example/customer/
├── CustomerManagementApplication.java   # 應用程式進入點
├── config/
│   └── GlobalExceptionHandler.java      # 全域例外處理
├── controller/
│   └── CustomerController.java          # REST API Controller
├── dto/
│   ├── CustomerRequest.java             # 請求 DTO（含驗證規則）
│   └── CustomerResponse.java            # 回應 DTO
├── entity/
│   └── Customer.java                    # JPA Entity
├── repository/
│   └── CustomerRepository.java          # Spring Data JPA Repository
└── service/
    └── CustomerService.java             # 商業邏輯層

src/main/resources/
└── application.yml                      # 應用程式設定

src/test/java/com/example/customer/
├── CustomerApiTest.java                 # API 整合測試（H2）
└── ApiDocumentGenerator.java            # API 文件產生器（Word/Excel/PDF）
```

## 快速啟動

```bash
# 編譯
gradle build

# 執行
gradle bootRun

# 執行測試
gradle test
```

啟動後預設運行於 `http://localhost:8080`。

## Swagger UI

啟動應用程式後，可透過以下路徑存取 API 文件：

| 路徑 | 說明 |
|------|------|
| http://localhost:8080/swagger-ui.html | Swagger UI 互動式介面 |
| http://localhost:8080/v3/api-docs | OpenAPI 3.0 JSON 規格 |

Swagger UI 提供所有 API 端點的互動式測試介面，可直接在瀏覽器中發送請求並查看回應。

## API 端點

Base URL: `http://localhost:8080`

| Method | Path | 說明 | Status Code |
|--------|------|------|-------------|
| GET | `/api/customers` | 取得所有客戶 | 200 |
| GET | `/api/customers/{id}` | 依 ID 取得客戶 | 200 / 404 |
| POST | `/api/customers` | 建立新客戶 | 201 / 400 |
| PUT | `/api/customers/{id}` | 更新客戶資料 | 200 / 404 |
| DELETE | `/api/customers/{id}` | 刪除客戶 | 204 / 404 |

## 資料模型

### Customer

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| id | Long | 自動產生 | 主鍵 |
| name | String(50) | 是 | 客戶姓名 |
| email | String(100) | 是 | Email（唯一） |
| phone | String(20) | 否 | 電話號碼 |
| address | String(200) | 否 | 地址 |
| createdAt | DateTime | 自動產生 | 建立時間 |
| updatedAt | DateTime | 自動產生 | 最後更新時間 |

### 驗證規則

- `name`：必填，最多 50 字元
- `email`：必填，需為合法 Email 格式，最多 100 字元，不可重複
- `phone`：選填，最多 20 字元
- `address`：選填，最多 200 字元

## API 使用範例

### 建立客戶

```bash
curl -X POST http://localhost:8080/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "0912345678",
    "address": "Taipei, Taiwan"
  }'
```

回應（201 Created）：

```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "0912345678",
  "address": "Taipei, Taiwan",
  "createdAt": "2026-03-28T10:00:00",
  "updatedAt": "2026-03-28T10:00:00"
}
```

### 取得所有客戶

```bash
curl http://localhost:8080/api/customers
```

### 取得單一客戶

```bash
curl http://localhost:8080/api/customers/1
```

### 更新客戶

```bash
curl -X PUT http://localhost:8080/api/customers/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated",
    "email": "john.updated@example.com",
    "phone": "0987654321",
    "address": "Kaohsiung, Taiwan"
  }'
```

### 刪除客戶

```bash
curl -X DELETE http://localhost:8080/api/customers/1
```

## 錯誤回應格式

當請求驗證失敗或發生錯誤時，回傳格式如下：

```json
{
  "error": "email: Email format is invalid"
}
```

## H2 Console

開發環境下可透過 http://localhost:8080/h2-console 存取 H2 資料庫管理介面。

| 設定 | 值 |
|------|-----|
| JDBC URL | `jdbc:h2:mem:customerdb` |
| Username | `sa` |
| Password | （空白） |

## SQL 驗證範例

透過 H2 Console 執行以下 SQL，可在每次 API 操作後驗證資料庫狀態是否正確。

### 建立客戶後 — 確認資料已寫入

執行 API 建立客戶後：

```bash
curl -X POST http://localhost:8080/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "0912345678",
    "address": "Taipei, Taiwan"
  }'
```

在 H2 Console 執行 SQL 確認：

```sql
-- 查詢所有客戶資料
SELECT * FROM customers;

-- 依 Email 查詢剛建立的客戶
SELECT id, name, email, phone, address, created_at, updated_at
FROM customers
WHERE email = 'john@example.com';
```

預期結果應包含一筆 `name = 'John Doe'` 的記錄，且 `created_at` 與 `updated_at` 時間相同。

### 建立多筆客戶後 — 確認資料筆數

連續呼叫 POST API 建立多筆客戶後：

```sql
-- 查詢目前客戶總數
SELECT COUNT(*) AS total_customers FROM customers;

-- 依建立時間排序列出所有客戶
SELECT id, name, email, created_at
FROM customers
ORDER BY created_at DESC;
```

### 更新客戶後 — 確認欄位已變更

執行 API 更新客戶後：

```bash
curl -X PUT http://localhost:8080/api/customers/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated",
    "email": "john.updated@example.com",
    "phone": "0987654321",
    "address": "Kaohsiung, Taiwan"
  }'
```

在 H2 Console 執行 SQL 確認：

```sql
-- 確認 id=1 的客戶資料已更新
SELECT id, name, email, phone, address, created_at, updated_at
FROM customers
WHERE id = 1;
```

預期結果：`name` 應為 `'John Updated'`、`email` 應為 `'john.updated@example.com'`，且 `updated_at` 時間晚於 `created_at`。

### 刪除客戶後 — 確認資料已移除

執行 API 刪除客戶後：

```bash
curl -X DELETE http://localhost:8080/api/customers/1
```

在 H2 Console 執行 SQL 確認：

```sql
-- 確認 id=1 的客戶已不存在
SELECT * FROM customers WHERE id = 1;

-- 查詢剩餘客戶數量
SELECT COUNT(*) AS remaining_customers FROM customers;
```

預期結果：第一個查詢應回傳空結果（0 筆），第二個查詢的數量應比刪除前少 1。

### 其他實用查詢

```sql
-- 查詢 Email 是否重複（驗證唯一性約束）
SELECT email, COUNT(*) AS cnt
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- 查詢特定時間區間內建立的客戶
SELECT * FROM customers
WHERE created_at BETWEEN '2026-03-28 00:00:00' AND '2026-03-28 23:59:59';

-- 模糊搜尋客戶姓名
SELECT * FROM customers
WHERE name LIKE '%John%';

-- 查看資料表結構
SHOW COLUMNS FROM customers;
```

## GitHub Copilot Prompt vs Claude Code Skill 比較

GitHub Copilot 與 Claude Code 都提供了可擴充的指令機制，讓開發者能以 `/command` 的方式快速觸發預定義的操作流程。以下針對兩者的核心觀念與使用方式進行比較。

### 核心觀念

| 面向 | GitHub Copilot — Prompt (Custom Instructions) | Claude Code — Skill |
|------|----------------------------------------------|---------------------|
| 定義方式 | 在 `.github/copilot-instructions.md` 或 `.github/prompts/*.prompt.md` 中以 Markdown 撰寫 | 在 `.claude/commands/*.md` 中以 Markdown 撰寫，或透過 MCP Server 動態提供 |
| 觸發方式 | 在 Copilot Chat 中輸入 `/` 加上檔名（如 `/my-prompt`） | 在 Claude Code 中輸入 `/` 加上檔名（如 `/commit`、`/simplify`） |
| 作用範圍 | 專案層級（`.github/`）或使用者層級 | 專案層級（`.claude/commands/`）或使用者層級（`~/.claude/commands/`） |
| 參數支援 | 支援 `$selection`、`$file` 等內建變數 | 支援 `$ARGUMENTS` 佔位符接收使用者輸入 |
| 上下文引用 | 可透過 `#file`、`#selection` 等方式附加上下文 | 自動存取工作目錄的檔案，可搭配工具（Read、Grep、Bash 等）蒐集上下文 |
| 工具整合 | 可觸發 VS Code 內建操作（如產生測試、修正程式碼） | 可呼叫所有已註冊的工具（Bash、Git、MCP Server 等）執行實際操作 |
| 執行能力 | 主要為對話式建議，需人工確認後套用 | 可自主執行多步驟操作（讀檔、改檔、執行指令、Git 操作等） |

### 使用範例對照

#### 1. 產生 Commit Message

**GitHub Copilot（`.github/prompts/commit.prompt.md`）：**

```markdown
---
description: "Generate a commit message"
---
Based on the current git diff, generate a concise commit message
following Conventional Commits format.
```

在 Copilot Chat 中輸入 `/commit`，Copilot 會根據 diff 建議 commit message，由使用者手動複製貼上。

**Claude Code（`.claude/commands/commit.md`）：**

```markdown
Based on the current git diff, generate a concise commit message
following Conventional Commits format, then execute the commit.
```

在 Claude Code 中輸入 `/commit`，Claude 會讀取 diff、產生 message、並直接執行 `git commit`。

#### 2. 程式碼審查

**GitHub Copilot（`.github/prompts/review.prompt.md`）：**

```markdown
---
description: "Review code for issues"
---
Review #selection for potential bugs, security issues,
and suggest improvements.
```

使用者選取程式碼後輸入 `/review`，Copilot 提供文字建議。

**Claude Code（`.claude/commands/review.md`）：**

```markdown
Review the current branch changes compared to main.
Check for bugs, security issues, and code style.
Provide actionable feedback with file paths and line numbers.
Use $ARGUMENTS as focus area if provided.
```

輸入 `/review security` 後，Claude 會自動執行 `git diff`、逐一檔案分析、並以結構化格式輸出結果。

### 關鍵差異總結

| 差異點 | GitHub Copilot Prompt | Claude Code Skill |
|--------|----------------------|-------------------|
| 執行模式 | 建議導向（Suggestion-based） | 行動導向（Action-based） |
| 自主程度 | 低 — 需使用者手動套用建議 | 高 — 可自主執行完整工作流程 |
| 工具鏈整合 | 限於 IDE 內建功能與 MCP 擴充 | 完整 CLI 工具鏈（Shell、Git、MCP 等） |
| 多步驟流程 | 需使用者逐步引導 | 可一次完成多步驟任務（分析 → 修改 → 測試 → 提交） |
| 適用場景 | IDE 內即時輔助、程式碼補全與建議 | 複雜的自動化工作流程、跨檔案重構、CI/CD 整合 |
| 定義複雜度 | 簡潔，以 Prompt 文字為主 | 可結合工具呼叫邏輯，支援更複雜的編排 |

### 何時選用

- **GitHub Copilot Prompt**：適合在 IDE 中快速取得程式碼建議、片段生成、即時問答等輕量場景。
- **Claude Code Skill**：適合需要自主執行多步驟操作的場景，例如自動化提交、批次重構、程式碼審查並直接修正、跨檔案搜尋與替換等。

兩者並非互斥，可依團隊工作流程搭配使用：在 IDE 內開發時透過 Copilot 取得即時建議，在終端機或 CI 環境中透過 Claude Code 執行自動化任務。
