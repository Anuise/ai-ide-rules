---
trigger: glob
description: 適用於 .NET 與 ASP.NET Core 開發的全方位程式碼準則，涵蓋 C# 12+、Minimal APIs、Clean Architecture 與效能優化。
globs: ["**/*.cs", "**/*.cshtml", "**/*.razor", "**/*.csproj", "**/appsettings.json"]
alwaysApply: false
---

# .NET & ASP.NET Core 開發全面準則

## 1. 程式碼風格與結構 (C# 12+)

- **慣用語法**：使用簡潔且具慣用性的 C# 程式碼（如：Primary Constructors、Collection expressions）。
- **類型推斷**：當類型明顯時，優先使用 `var`。
- **命名規範**：
  - `PascalCase`：類別名、方法名、公開屬性、Namespace。
  - `camelCase`：區域變數、私有欄位（私有欄位建議加底線前綴，如 `_userService`）。
  - `I` 前綴：介面命名（如 `IUserRepository`）。
- **檔案組織**：
  - 使用 **File-scoped namespaces** 減少縮排。
  - 遵循關注點分離（SoC），將邏輯拆分為 Controllers、Services、Models、DTOs。
  - 優先使用 `record` 定義不可變的資料傳輸物件（DTOs）。

## 2. ASP.NET Core 核心實作

- **API 設計**：
  - 一律使用傳統的 **Controller** 架構，禁止使用 Minimal APIs。
  - 遵循 RESTful 原則，使用正確的 HTTP Verb（GET, POST, PUT, DELETE）。
  - 使用 **Attribute Routing** 明確定義路由路徑。
- **依賴注入 (DI)**：
  - 嚴格使用 DI 進行解耦。
  - 正確選擇生命週期：`Transient` (輕量), `Scoped` (每請求一次, 常用於 DbContext), `Singleton` (全局唯一)。
- **中介軟體 (Middleware)**：
  - 使用全域異常處理中介軟體 (Global Exception Handling Middleware)。
  - 封裝跨切面邏輯（如日誌、驗證）至自定義 Middleware 或 Action Filters。

## 3. 資料存取與 EF Core

- **效能優化**：
  - 使用 `async/await` 進行所有 I/O 密集型操作。
  - 避免 N+1 查詢問題，適時使用 `.Include()` 預先載入或 `.Select()` 投射需要的欄位。
  - 對於唯讀查詢，使用 `.AsNoTracking()` 以提高效能。
- **模式應用**：
  - 根據專案複雜度決定是否使用 Repository 模式，簡單場景可直接在 Service 使用 DbContext。
  - 使用實體設定類別（`IEntityTypeConfiguration<T>`）保持 `OnModelCreating` 整潔。

## 4. 錯誤處理與驗證

- **驗證**：優先使用 **FluentValidation** 進行複雜驗證，簡單驗證使用 Data Annotations。
- **異常處理**：不要使用 Exception 進行流程控制，應返回適當的 `Result<T>` 模式或 HTTP 狀態碼。
- **日誌**：使用 `ILogger` 記錄關鍵執行路徑與錯誤資訊，避免記錄敏感個人資料。

## 5. 測試與調試

- **單元測試**：使用 **xUnit** 作為測試框架。
- **模擬物件**：使用 **NSubstitute** 或 **Moq** 進行依賴模擬。
- **整合測試**：使用 `WebApplicationFactory` 進行端到端 API 測試。
- **除錯**：利用 Visual Studio 的診斷工具 (Diagnostic Tools) 進行記憶體與效能分析。

## 6. 安全性與文件

- **身份驗證**：實作 JWT 進行無狀態 API 驗證，或使用 ASP.NET Core Identity。
- **通訊安全**：強制執行 HTTPS、配置 HSTS 並設定正確的 CORS 策略。
- **文件化**：整合 **Swagger/OpenAPI** (Swashbuckle)，並為公開 API 編寫 XML 註釋，以便自動生成文件。

## 7. 效能優化策略

- **快取**：頻繁讀取且變動低的資料使用 `IMemoryCache`；分散式系統使用 Redis。
- **非同步**：確保非同步方法一律以 `Async` 結尾，並傳遞 `CancellationToken` 以支援請求取消。
- **分頁**：對大型資料集強制執行分頁回傳。

## 互動要求

- 當我要求實作功能時，請優先考慮 **Clean Architecture** 的分層邏輯。
- 提供範例程式碼時，請確保包含必要的 `using` 陳述句。
- 如果建議的邏輯可能影響效能，請主動提出優化建議。
