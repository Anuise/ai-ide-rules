# {{專案名稱}} — API 介面文件

> **版本：** {{版本號}}  
> **最後更新：** {{YYYY-MM-DD}}  
> **負責人：** {{後端 Lead / 負責人}}

---

## 1. 概覽與認證方式

<!-- 必填：Base URL、Auth 機制 -->

| 項目                  | 值                                           |
| --------------------- | -------------------------------------------- |
| Base URL (Production) | `https://api.{{domain}}/v1`                  |
| Base URL (Staging)    | `https://api-staging.{{domain}}/v1`          |
| 認證方式              | {{Bearer Token (JWT) / API Key / OAuth 2.0}} |
| Content-Type          | `application/json`                           |
| 字元編碼              | UTF-8                                        |

### 認證範例

```http
GET /v1/resource HTTP/1.1
Host: api.{{domain}}
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

---

## 2. 端點列表

<!-- 必填：HTTP Method + Path + 簡述 -->

| Method | Path                    | 說明             | 認證 |
| ------ | ----------------------- | ---------------- | ---- |
| GET    | `/v1/{{resources}}`     | 取得{{資源}}列表 | 必要 |
| GET    | `/v1/{{resources}}/:id` | 取得單筆{{資源}} | 必要 |
| POST   | `/v1/{{resources}}`     | 建立{{資源}}     | 必要 |
| PUT    | `/v1/{{resources}}/:id` | 更新{{資源}}     | 必要 |
| DELETE | `/v1/{{resources}}/:id` | 刪除{{資源}}     | 必要 |

---

## 3. 端點詳細規格

### 3.1 GET `/v1/{{resources}}`

**說明：** 取得{{資源}}列表，支援分頁與篩選。

#### 請求參數 (Query Params)

| 參數       | 類型     | 必填 | 預設值     | 說明                 |
| ---------- | -------- | ---- | ---------- | -------------------- |
| page       | integer  | 否   | 1          | 頁碼                 |
| per_page   | integer  | 否   | 20         | 每頁筆數（上限 100） |
| sort       | string   | 否   | created_at | 排序欄位             |
| order      | string   | 否   | desc       | 排序方向 (asc/desc)  |
| {{filter}} | {{type}} | 否   | —          | {{篩選條件}}         |

#### 成功回應 (200 OK)

```json
{
  "data": [
    {
      "id": "uuid-example",
      "{{field_1}}": "{{value}}",
      "{{field_2}}": "{{value}}",
      "created_at": "2025-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_count": 100
  }
}
```

### 3.2 POST `/v1/{{resources}}`

**說明：** 建立新的{{資源}}。

#### 請求參數 (Request Body)

| 欄位        | 類型    | 必填 | 說明     |
| ----------- | ------- | ---- | -------- |
| {{field_1}} | string  | 是   | {{說明}} |
| {{field_2}} | integer | 否   | {{說明}} |

#### 請求範例

```json
{
  "{{field_1}}": "{{value}}",
  "{{field_2}}": {{value}}
}
```

#### 成功回應 (201 Created)

```json
{
  "data": {
    "id": "uuid-new",
    "{{field_1}}": "{{value}}",
    "{{field_2}}": {{value}},
    "created_at": "2025-01-01T00:00:00Z"
  }
}
```

---

## 4. 錯誤碼定義

<!-- 必填：HTTP Status + 業務錯誤碼對照表 -->

### 4.1 HTTP 狀態碼

| HTTP Status | 含義           |
| ----------- | -------------- |
| 200         | 成功           |
| 201         | 建立成功       |
| 400         | 請求格式錯誤   |
| 401         | 未認證         |
| 403         | 無權限         |
| 404         | 資源不存在     |
| 422         | 驗證失敗       |
| 429         | 請求過於頻繁   |
| 500         | 伺服器內部錯誤 |

### 4.2 業務錯誤碼

| 錯誤碼      | HTTP Status | 訊息              | 說明         |
| ----------- | ----------- | ----------------- | ------------ |
| {{ERR_001}} | 400         | {{error message}} | {{觸發條件}} |
| {{ERR_002}} | 422         | {{error message}} | {{觸發條件}} |

### 4.3 錯誤回應格式

```json
{
  "error": {
    "code": "ERR_001",
    "message": "描述性錯誤訊息",
    "details": [
      {
        "field": "{{field_name}}",
        "reason": "{{具體原因}}"
      }
    ]
  }
}
```

---

## 5. 速率限制

<!-- 必填：Rate Limit 策略說明 -->

| 層級     | 限制     | 時間窗口 | 超限回應              |
| -------- | -------- | -------- | --------------------- |
| 全域     | {{n}} 次 | 每分鐘   | 429 Too Many Requests |
| 單一用戶 | {{n}} 次 | 每分鐘   | 429 Too Many Requests |

回應 Header：

```
X-RateLimit-Limit: {{n}}
X-RateLimit-Remaining: {{n}}
X-RateLimit-Reset: {{unix-timestamp}}
```

---

## 附錄：OpenAPI 規格片段

```yaml
openapi: 3.1.0
info:
  title: "{{專案名稱}} API"
  version: "{{版本號}}"
servers:
  - url: https://api.{{domain}}/v1
    description: Production
  - url: https://api-staging.{{domain}}/v1
    description: Staging
paths:
  /{{resources}}:
    get:
      summary: "取得{{資源}}列表"
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        "200":
          description: "成功"
    post:
      summary: "建立{{資源}}"
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/{{Resource}}Create"
      responses:
        "201":
          description: "建立成功"
```

---

<!-- 驗收清單（產出後自行核對，核對完畢後刪除此區塊）
- [ ] 概覽含 Base URL 與認證方式
- [ ] 端點列表完整（與 TDD 一致）
- [ ] 每個端點有 Request/Response 範例
- [ ] 錯誤碼表涵蓋常見場景
- [ ] 速率限制策略已定義
- [ ] OpenAPI 片段與端點列表一致
-->
