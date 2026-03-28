Feature: 取得指定客戶 (Get Customer by ID)
  作為 API 使用者
  我希望能根據客戶 ID 取得單個客戶的詳細資訊
  以便 查看該客戶的完整資料

  Background:
    Given API 基底 URL 為環境變數 "BASE_URL"
    And Content-Type 設定為 "application/json"
    And 系統已存在以下客戶
      | id | name | email | phone | address |
      | 1 | John Doe | john@example.com | 0912345678 | Taipei, Taiwan |
      | 2 | Jane Smith | jane@example.com | 0987654321 | Kaohsiung, Taiwan |

  # =========== 正向測試 (Happy Path) ===========
  Scenario: 成功取得存在的客戶資訊
    When 發送 GET 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 200
    And 回應的客戶 ID 應為 1
    And 回應的 name 應為 "John Doe"
    And 回應的 email 應為 "john@example.com"
    And 回應的 phone 應為 "0912345678"
    And 回應的 address 應為 "Taipei, Taiwan"

  Scenario: 驗證回應包含時間戳記
    When 發送 GET 請求到 "/api/customers/2"
    Then HTTP 狀態碼應為 200
    And 回應應包含 "createdAt" 欄位
    And 回應應包含 "updatedAt" 欄位
    And "createdAt" 應為有效的 ISO 8601 時間格式
    And "updatedAt" 應為有效的 ISO 8601 時間格式

  # =========== 反向測試 (Negative Cases) ===========
  Scenario: 取得不存在的客戶失敗
    When 發送 GET 請求到 "/api/customers/9999"
    Then HTTP 狀態碼應為 404
    And 錯誤訊息應包含 "Customer not found"

  Scenario: 取得客戶 - 無效的 ID 格式
    When 發送 GET 請求到 "/api/customers/invalid-id"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid"

  Scenario: 取得客戶 - 負數 ID
    When 發送 GET 請求到 "/api/customers/-1"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid"

  # =========== 邊界測試 (Boundary Cases) ===========
  Scenario: 取得 ID 為 1 的最小值客戶
    When 發送 GET 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 200
    And 回應的客戶 ID 應為 1

  Scenario: 取得 ID 為最大值的客戶
    When 發送 GET 請求到 "/api/customers/9223372036854775807"
    Then HTTP 狀態碼應為 404
    And 錯誤訊息應包含 "Customer not found"

  Scenario: 取得客戶 - 浮點數 ID
    When 發送 GET 請求到 "/api/customers/1.5"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid"
