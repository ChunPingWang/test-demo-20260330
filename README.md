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
