# Bruno 測試腳本語法指南

## Bruno .bru 檔案結構

```bru
# Meta 信息 - 定義測試的基本屬性
meta {
  name: 測試名稱
  type: http
  seq: 1
}

# 變數定義 - 在此測試中使用的變數
vars {
  base_url: http://localhost:8080
  api_key: sk_test_123456
  user_id: 12345
}

# 環境變數引用
vars:pre-request {
  set('custom_var', 'value');
}

# HTTP 請求定義
POST {{base_url}}/api/endpoint
Content-Type: application/json
Authorization: Bearer {{api_key}}

{
  "key": "value",
  "nested": {
    "field": "data"
  }
}

# 測試驗證
tests {
  # 驗證狀態碼
  test("狀態碼為 200", function() {
    expect(res.status).to.equal(200);
  });
  
  # 驗證響應欄位存在
  test("響應包含 id 欄位", function() {
    expect(res.body.id).to.exist;
  });
  
  # 驗證響應值
  test("name 應為期望值", function() {
    expect(res.body.name).to.equal("John Doe");
  });
  
  # 驗證響應欄位型態
  test("data 應為陣列", function() {
    expect(res.body.data).to.be.an('array');
  });
  
  # 驗證包含字符串
  test("訊息包含特定文本", function() {
    expect(res.body.message).to.include("success");
  });
}

# 後置處理 - 保存變數供後續測試使用
tests:post-response {
  set('userId', res.body.id);
  set('token', res.headers['x-auth-token']);
}
```

## HTTP 方法

```bru
# GET 請求
GET http://localhost:8080/api/users

# POST 請求
POST http://localhost:8080/api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com"
}

# PUT 請求 (更新完整資源)
PUT http://localhost:8080/api/users/123
Content-Type: application/json

{
  "name": "Jane Doe",
  "email": "jane@example.com"
}

# PATCH 請求 (部分更新)
PATCH http://localhost:8080/api/users/123
Content-Type: application/json

{
  "email": "newemail@example.com"
}

# DELETE 請求
DELETE http://localhost:8080/api/users/123

# HEAD 請求
HEAD http://localhost:8080/api/health

# OPTIONS 請求
OPTIONS http://localhost:8080/api/users
```

## Header 設定

```bru
POST http://localhost:8080/api/users
Content-Type: application/json
Authorization: Bearer {{authToken}}
X-Custom-Header: custom-value
Accept: application/json
User-Agent: Bruno/1.0

{
  "name": "John"
}
```

## 變數使用

### 全域變數 (環境中定義)
```bru
GET {{base_url}}/api/users/{{userId}}
Authorization: Bearer {{authToken}}
```

### 本地變數 (meta 區塊中定義)
```bru
vars {
  name: John
  age: 30
  tags: ["tag1", "tag2"]
}

POST {{base_url}}/api/users
Content-Type: application/json

{
  "name": "{{name}}",
  "age": "{{age}}"
}
```

### 動態變數 (Bruno 內建)
```bru
POST {{base_url}}/api/users

{
  "timestamp": {{$datetime}},
  "id": {{$randomInt}},
  "uuid": {{$uuid}},
  "random": {{$randomAlphaNumeric}}
}
```

## 測試驗證 (Assertions)

### 基本驗證
```javascript
tests {
  // 相等驗證
  expect(res.status).to.equal(200);
  expect(res.body.name).to.equal("John Doe");
  
  // 不相等驗證
  expect(res.status).to.not.equal(404);
  
  // 大小比較
  expect(res.status).to.be.greaterThan(200);
  expect(res.status).to.be.lessThan(300);
  
  // 包含/不包含
  expect(res.body.message).to.include("success");
  expect(res.body).to.not.include("error");
  
  // 存在性
  expect(res.body.id).to.exist;
  expect(res.body.deleted).to.not.exist;
}
```

### 型態驗證
```javascript
tests {
  expect(res.body.name).to.be.a('string');
  expect(res.body.age).to.be.a('number');
  expect(res.body.tags).to.be.an('array');
  expect(res.body.data).to.be.an('object');
  expect(res.body.active).to.be.a('boolean');
}
```

### 陣列驗證
```javascript
tests {
  expect(res.body.items).to.be.an('array');
  expect(res.body.items).to.have.lengthOf(3);
  expect(res.body.items[0].name).to.equal("Item 1");
  expect(res.body.items).to.include.something.that.has.property('id');
}
```

### 複雜驗證
```javascript
tests {
  // 驗證多個條件
  expect(res.status).to.equal(201);
  expect(res.body.id).to.be.a('string');
  expect(res.body.createdAt).to.exist;
  expect(res.body.name).to.equal("John Doe");
  
  // JSON Schema 驗證
  expect(res.body).to.have.all.keys('id', 'name', 'email');
  
  // 自訂驗證函數
  expect(res.body.email).to.satisfy(email => email.includes('@'));
}
```

## 前置&後置處理

### 前置處理 (Pre-request)
```bru
vars:pre-request {
  // 在發送請求前執行
  set('timestamp', new Date().getTime());
  
  // 計算簽名或加密
  const crypto = require('crypto');
  const signature = crypto.createHash('sha256').update('data').digest('hex');
  set('signature', signature);
}
```

### 後置處理 (Post-response)
```bru
tests:post-response {
  // 在測試後執行
  // 保存 response 數據供後續請求使用
  if(res.status === 201) {
    set('userId', res.body.id);
    set('userEmail', res.body.email);
  }
}
```

## 條件邏輯

```javascript
tests {
  // if 條件
  if(res.status === 201) {
    test("建立成功", function() {
      expect(res.body.id).to.exist;
    });
  } else {
    test("建立失敗", function() {
      expect(res.status).to.equal(400);
    });
  }
  
  // for 迴圈驗證陣列
  const items = res.body.data;
  for(let i = 0; i < items.length; i++) {
    test(`Item ${i} 有 id`, function() {
      expect(items[i].id).to.exist;
    });
  }
}
```

## 實際範例

### 範例 1: 建立資源
```bru
meta {
  name: 建立新用戶
  type: http
  seq: 1
}

vars {
  base_url: http://localhost:8080
}

POST {{base_url}}/api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30
}

tests {
  test("狀態碼為 201", function() {
    expect(res.status).to.equal(201);
  });
  
  test("響應包含 ID", function() {
    expect(res.body.id).to.be.a('string');
  });
  
  test("保存用戶 ID", function() {
    expect(res.body.id).to.exist;
  });
}

tests:post-response {
  set('userId', res.body.id);
}
```

### 範例 2: 獲取並驗證資源
```bru
meta {
  name: 獲取用戶詳情
  type: http
  seq: 2
}

vars {
  base_url: http://localhost:8080
}

GET {{base_url}}/api/users/{{userId}}
Authorization: Bearer {{authToken}}

tests {
  test("狀態碼為 200", function() {
    expect(res.status).to.equal(200);
  });
  
  test("用戶名稱正確", function() {
    expect(res.body.name).to.equal("John Doe");
  });
  
  test("包含所有必需欄位", function() {
    expect(res.body).to.have.all.keys(['id', 'name', 'email', 'age', 'createdAt']);
  });
}
```

### 範例 3: 錯誤處理驗證
```bru
meta {
  name: 驗證無效請求
  type: http
  seq: 3
}

vars {
  base_url: http://localhost:8080
}

POST {{base_url}}/api/users
Content-Type: application/json

{
  "email": "invalid-email"
}

tests {
  test("狀態碼為 400", function() {
    expect(res.status).to.equal(400);
  });
  
  test("錯誤訊息包含欄位驗證", function() {
    expect(res.body.errors).to.be.an('array');
    const hasNameError = res.body.errors.some(e => e.field === 'name');
    expect(hasNameError).to.be.true;
  });
}
```

## 最佳實踐

1. **使用有意義的測試名稱** - 清楚描述在測試什麼
2. **一個測試一個斷言** - 便於除錯失敗原因
3. **使用變數而非硬碼** - 方便在不同環境間切換
4. **保存必要的響應數據** - 供後續測試使用
5. **驗證狀態碼和內容** - 不只檢查成功，也檢查失敗情況
6. **組織測試順序** - 合理安排 seq 編號

