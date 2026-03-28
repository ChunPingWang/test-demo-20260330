Feature: 建立新客戶 (Create Customer)
  作為 API 使用者
  我希望能建立新的客戶記錄
  以便 將新客戶加入系統

  Background:
    Given API 基底 URL 為環境變數 "BASE_URL"
    And Content-Type 設定為 "application/json"

  # =========== 正向測試 (Happy Path) ===========
  Scenario: 成功建立客戶 - 所有欄位
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | John Doe |
      | email | john@example.com |
      | phone | 0912345678 |
      | address | Taipei, Taiwan |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 201
    And 回應應包含有效的 Customer ID
    And 回應的 name 應為 "John Doe"
    And 回應的 email 應為 "john@example.com"
    And 回應的 phone 應為 "0912345678"
    And 回應的 address 應為 "Taipei, Taiwan"
    And 回應應包含 "createdAt" 時間戳記
    And 回應應包含 "updatedAt" 時間戳記

  Scenario: 成功建立客戶 - 僅必填欄位
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | Jane Smith |
      | email | jane@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 201
    And 回應應包含有效的 Customer ID
    And 回應的 name 應為 "Jane Smith"
    And 回應的 email 應為 "jane@example.com"

  Scenario: 成功建立客戶 - 部分選用欄位
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | Bob Wilson |
      | email | bob@example.com |
      | phone | 0987654321 |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 201
    And 回應應包含有效的 Customer ID

  # =========== 反向測試 (Negative Cases) ===========
  Scenario: 建立客戶失敗 - 缺少 name 欄位
    Given 準備建立客戶的請求 (缺少 name)
      | 欄位 | 值 |
      | email | test@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Name is required"

  Scenario: 建立客戶失敗 - 缺少 email 欄位
    Given 準備建立客戶的請求 (缺少 email)
      | 欄位 | 值 |
      | name | Test User |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Email is required"

  Scenario: 建立客戶失敗 - name 為空字符串
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | |
      | email | test@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Name is required"

  Scenario: 建立客戶失敗 - 無效的 Email 格式
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | Test User |
      | email | invalid-email |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Email format is invalid"

  Scenario: 建立客戶失敗 - Email 缺少 @ 符號
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | Test User |
      | email | testexample.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Email format is invalid"

  Scenario: 建立客戶失敗 - Email 缺少域名
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | Test User |
      | email | test@ |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Email format is invalid"

  Scenario: 建立客戶失敗 - Email 已存在
    Given 系統已存在 email 為 "existing@example.com" 的客戶
    And 準備建立客戶的請求
      | 欄位 | 值 |
      | name | Another User |
      | email | existing@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Email already exists"

  # =========== 邊界測試 (Boundary Cases) ===========
  Scenario Outline: 驗證 name 欄位長度限制
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | <name> |
      | email | test@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 <expected_status>
    And 錯誤訊息應為 "<expected_message>"

    Examples:
      | name | expected_status | expected_message |
      | A | 201 |  |
      | {'A'*50} | 201 |  |
      | {'A'*51} | 400 | Name must not exceed 50 characters |
      |  | 400 | Name is required |

  Scenario Outline: 驗證 email 欄位長度限制
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | Test User |
      | email | <email> |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 <expected_status>
    And 錯誤訊息應為 "<expected_message>"

    Examples:
      | email | expected_status | expected_message |
      | a@b.c | 201 |  |
      | {'a'*90}@example.com | 201 |  |
      | {'a'*95}@example.com | 400 | Email must not exceed 100 characters |

  Scenario: 建立客戶 - 特殊字符在 name
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | O'Brien-Smith |
      | email | test@example.com |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 201
    And 回應的 name 應為 "O'Brien-Smith"

  Scenario: 建立客戶 - 特殊字符在 email
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | Test User |
      | email | test+tag@example.co.uk |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 201
    And 回應的 email 應為 "test+tag@example.co.uk"

  Scenario: 建立客戶 - 電話號碼超過長度限制
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | Test User |
      | email | test@example.com |
      | phone | {'1'*21} |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Phone must not exceed 20 characters"

  Scenario: 建立客戶 - 地址超過長度限制
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | Test User |
      | email | test@example.com |
      | address | {'A'*201} |
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Address must not exceed 200 characters"

  # =========== 認證/授權測試 ===========
  Scenario: 建立客戶失敗 - 無效的 Content-Type
    Given 準備建立客戶的請求
      | 欄位 | 值 |
      | name | Test User |
      | email | test@example.com |
    And Content-Type 設定為 "text/plain"
    When 發送 POST 請求到 "/api/customers"
    Then HTTP 狀態碼應為 400
    And 錯誤訊息應包含 "Content-Type"
