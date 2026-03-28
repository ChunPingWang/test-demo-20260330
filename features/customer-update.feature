Feature: 更新客戶 (Update Customer)
  作為 API 使用者
  我希望能更新現有客戶的資訊
  以便 保持客戶資料最新

  Background:
    Given API 基底 URL 為環境變數 "BASE_URL"
    And Content-Type 設定為 "application/json"
    And 系統已存在以下客戶
      | id | name | email | phone | address |
      | 1 | John Doe | john@example.com | 0912345678 | Taipei, Taiwan |
      | 2 | Jane Smith | jane@example.com | 0987654321 | Kaohsiung, Taiwan |

  # =========== 正向測試 (Happy Path) ===========
  Scenario: 成功更新客戶 - 更新所有欄位
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | John Doe Updated |
      | email | john.updated@example.com |
      | phone | 0912345679 |
      | address | Taipei, Taiwan - Updated |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 200
    And 回應的 ID 應為 1
    And 回應的 name 應為 "John Doe Updated"
    And 回應的 email 應為 "john.updated@example.com"
    And 回應的 phone 應為 "0912345679"
    And 回應的 address 應為 "Taipei, Taiwan - Updated"
    And 回應的 "createdAt" 應該未改變
    And 回應的 "updatedAt" 應該比之前更新

  Scenario: 成功更新客戶 - 僅更新 name
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | John Smith |
      | email | john@example.com |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 200
    And 回應的 name 應為 "John Smith"
    And 回應的 email 應為 "john@example.com" (未改變)
    And 回應的 phone 應為 "0912345678" (未改變)

  Scenario: 成功更新客戶 - 清空選用欄位
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | John Doe |
      | email | john@example.com |
      | phone | |
      | address | |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 200
    And 回應的 phone 應為 null 或空字符串
    And 回應的 address 應為 null 或空字符串

  # =========== 反向測試 (Negative Cases) ===========
  Scenario: 更新失敗 - 客戶不存在
    Given 準備更新客戶 ID 9999 的請求
      | 欄位 | 值 |
      | name | Test User |
      | email | test@example.com |
    When 發送 PUT 請求到 "/api/customers/9999"
    Then HTTP 狀態碼應為 404
    And 錯誤訊息應包含 "Customer not found"

  Scenario: 更新失敗 - 缺少 name 欄位
    Given 準備更新客戶 ID 1 的請求 (缺少 name)
      | 欄位 | 值 |
      | email | test@example.com |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Name is required"

  Scenario: 更新失敗 - 缺少 email 欄位
    Given 準備更新客戶 ID 1 的請求 (缺少 email)
      | 欄位 | 值 |
      | name | Test User |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Email is required"

  Scenario: 更新失敗 - 無效的 Email 格式
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | John Doe |
      | email | invalid-email |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Email format is invalid"

  Scenario: 更新失敗 - Email 已被其他客戶使用
    Given 系統已存在客戶 2 使用 email "jane@example.com"
    And 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | John Doe |
      | email | jane@example.com |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Email already exists"

  Scenario: 更新失敗 - 無效的客戶 ID 格式
    Given 準備更新客戶的請求
      | 欄位 | 值 |
      | name | Test User |
      | email | test@example.com |
    When 發送 PUT 請求到 "/api/customers/invalid-id"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "invalid"

  # =========== 邊界測試 (Boundary Cases) ===========
  Scenario: 更新客戶 - name 達到最大長度
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | {'A'*50} |
      | email | john@example.com |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 200

  Scenario: 更新失敗 - name 超過最大長度
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | {'A'*51} |
      | email | john@example.com |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Name must not exceed 50 characters"

  Scenario: 更新客戶 - email 達到最大長度
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | John Doe |
      | email | {'a'*90}@example.com |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 200

  Scenario: 更新失敗 - email 超過最大長度
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | John Doe |
      | email | {'a'*95}@example.com |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Email must not exceed 100 characters"

  Scenario: 更新客戶 - 電話號碼超過長度限制
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | John Doe |
      | email | john@example.com |
      | phone | {'1'*21} |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Phone must not exceed 20 characters"

  Scenario: 更新客戶 - 地址超過長度限制
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | John Doe |
      | email | john@example.com |
      | address | {'A'*201} |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Address must not exceed 200 characters"

  Scenario: 更新客戶 - 特殊字符在 name
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | O'Brien-Smith Jr. |
      | email | john@example.com |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 200
    And 回應的 name 應為 "O'Brien-Smith Jr."

  Scenario: 更新客戶 - 特殊字符在 email
    Given 準備更新客戶 ID 1 的請求
      | 欄位 | 值 |
      | name | John Doe |
      | email | john+work@example.co.uk |
    When 發送 PUT 請求到 "/api/customers/1"
    Then HTTP 狀態碼應為 200
    And 回應的 email 應為 "john+work@example.co.uk"
