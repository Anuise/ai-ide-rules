---
trigger: glob
description: 綜合 REST API 開發與設計最佳實踐，適用於所有 API 相關開發工作，確保一致性、安全與效能。
globs: ["**/api/**/*", "**/routes/**/*", "**/controllers/**/*", "**/services/**/*", "**/*.dto.ts", "**/models/**/*", "**/handlers/**/*"]
alwaysApply: false
---

# REST API 開發綜合規範

在開發 RESTful API 時，請嚴格遵守以下綜合準則，以確保程式碼的模組化、可擴展性與安全性。

## 1. 核心設計原則 (Core Principles)

- **資源導向 (Resource-Oriented)**：API 應該圍繞資源而非動作設計。
- **無狀態性 (Statelessness)**：每個請求必須包含處理該請求所需的所有資訊，伺服器不儲存客戶端上下文。
- **一致性**：確保路徑、參數、回應格式在整個專案中保持高度統一。

## 2. 命名與路由路徑 (Naming & Routing)

- **URL 格式**：使用小寫與連字號 (`kebab-case`)，例如 `/user-profiles`。
- **資源命名**：使用「複數名詞」來代表資源集合（如 `/users`, `/orders`）。
- **階層關係**：使用子路徑表示從屬關係，例如 `/users/{id}/orders`。
- **版本控制**：API 必須包含版本號，建議使用 URL 版本化（如 `/api/v1/...`）。
- **避開動詞**：不要在路徑中使用 `get`, `create`, `update`, `delete` 等動詞（改用 HTTP Methods）。

## 3. HTTP 方法與狀態碼 (Methods & Status Codes)

請正確使用 HTTP 語意：

- **GET**：讀取資源（安全且冪等）。
- **POST**：建立新資源。
- **PUT**：完全替換現有資源（冪等）。
- **PATCH**：局部更新現有資源（推薦用於效能優化）。
- **DELETE**：刪除資源（冪等）。

應返回適當的狀態碼：

- `200 OK`：成功。
- `201 Created`：成功建立（POST）。
- `204 No Content`：成功處理但無回傳內容（如 DELETE）。
- `400 Bad Request`：請求參數錯誤或格式不正確。
- `401 Unauthorized`：未驗證或 Token 失效。
- `403 Forbidden`：已驗證但無權限。
- `404 Not Found`：找不到資源。
- `429 Too Many Requests`：觸發頻率限制。
- `500 Internal Server Error`：伺服器內部錯誤。

## 4. 回應格式與 JSON 規範 (Response & JSON)

- **欄位命名**：JSON 內的 Key 一律使用 `camelCase`（小駝峰命名法）。
- **日期格式**：一律使用 `ISO 8601` 格式（如 `2024-01-01T12:00:00Z`）。
- **標準成功結構**：

  ```json
  {
    "success": true,
    "data": { ... }
  }
