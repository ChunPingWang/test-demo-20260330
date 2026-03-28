Feature: 刪除客戶 (Delete Customer)
  作為 API 使用者
  我希望能刪除不需要的客戶記錄
  以便 清理系統中的舊資料

  Background:
    Given API 基底 URL 為環境變數 "BASE_URL"
    And Content-Type 設定為 "application/json"
    And 系統已存在以下客戶
      | id | name | email |
      | 1 | John Doe | john@example.com |
      | 2 | Jane Smith | jane@example.com |
      | 3 | Bob Wilson | bob@example.com |

  # =========== 正向測試 (Happy Path) ===========
  Scenario: 成功刪除存在的客戶
    When 發送 DELETE 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 204
    And 回應體應該為空

  Scenario: 驗證刪除後客戶不存在
    When 發送 DELETE 請求到 "/api/customers/2"
    And 發送 GET 請求到 "/api/customers/2"
    Then GET 請求的 HTTP 狀態碼應為 404
    And GET 請求的錯誤訊息應包含 "Customer not found"

  Scenario: 成功刪除客戶後，列表更新
    Given 系統中共有 3 個客戶
    When 發送 DELETE 請求到 "/api/customers/3"
    And 發送 GET 請求到 "/api/customers"
    Then HTTP 狀態碼應為 200
    And 回應應包含 2 個客戶記錄
    And 回應不應包含已刪除的客戶 ID 3

  # =========== 反向測試 (Negative Cases) ===========
  Scenario: 刪除失敗 - 客戶不存在
    When 發送 DELETE 請求到 "/api/customers/9999"
    Then HTTP 狀態碼應為 404
    And 錯誤訊息應包含 "Customer not found"

  Scenario: 刪除失敗 - 無效的客戶 ID 格式
    When 發送 DELETE 請求到 "/api/customers/invalid-id"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid"

  Scenario: 刪除失敗 - 負數 ID
    When 發送 DELETE 請求到 "/api/customers/-1"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid"

  Scenario: 刪除失敗 - 浮點數 ID
    When 發送 DELETE 請求到 "/api/customers/1.5"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid"

  # =========== 邊界測試 (Boundary Cases) ===========
  Scenario: 刪除 ID 為 1 的客戶
    When 發送 DELETE 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 204

  Scenario: 刪除 ID 為最大值的客戶
    When 發送 DELETE 請求到 "/api/customers/9223372036854775807"
    Then HTTP 狀態碼應為 404
    And 錯誤訊息應包含 "Customer not found"

  # =========== 冪等性測試 (Idempotency) ===========
  Scenario: 重複刪除同一客戶失敗
    Given 已成功刪除客戶 ID 1
    When 發送 DELETE 請求到 "/api/customers/1" (二次)
    Then HTTP 狀態碼應為 404
    And 錯誤訊息應包含 "Customer not found"

  Scenario: 刪除後立即再查詢失敗
    When 發送 DELETE 請求到 "/api/customers/2"
    And 立即發送 GET 請求到 "/api/customers/2"
    Then GET 請求應失敗
    And HTTP 狀態碼應為 404
