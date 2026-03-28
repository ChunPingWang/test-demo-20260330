Feature: 取得所有客戶列表 (Get All Customers)
  作為 API 使用者
  我希望能取得所有客戶的列表
  以便 查看系統中的所有客戶資料

  Background:
    Given API 基底 URL 為環境變數 "BASE_URL"
    And Content-Type 設定為 "application/json"

  # =========== 正向測試 (Happy Path) ===========
  Scenario: 成功取得所有客戶列表
    Given 系統已存在以下客戶
      | id | name | email | phone |
      | 1 | John Doe | john@example.com | 0912345678 |
      | 2 | Jane Smith | jane@example.com | 0987654321 |
    When 發送 GET 請求到 "/api/customers"
    Then HTTP 狀態碼應為 200
    And 回應應包含 2 個客戶記錄
    And 回應應包含客戶 "John Doe"
    And 回應應包含客戶 "Jane Smith"

  Scenario: 成功取得空的客戶列表
    Given 系統中沒有客戶記錄
    When 發送 GET 請求到 "/api/customers"
    Then HTTP 狀態碼應為 200
    And 回應應該是空陣列

  Scenario: 驗證回應的客戶欄位完整性
    Given 系統已存在客戶 "John Doe"
      | 欄位 | 值 |
      | email | john@example.com |
      | phone | 0912345678 |
      | address | Taipei, Taiwan |
    When 發送 GET 請求到 "/api/customers"
    Then HTTP 狀態碼應為 200
    And 回應中的第一個客戶應包含以下欄位
      | id | name | email | phone | address | createdAt | updatedAt |

  # =========== 反向測試沒有預期的失敗 ===========
  Scenario: 伺服器錯誤處理
    Given 系統發生伺服器錯誤
    When 發送 GET 請求到 "/api/customers"
    Then HTTP 狀態碼應為 500
    And 錯誤訊息應包含 "server error"
