---
trigger: "Glob"
description: RoboCorp RPA 與可擴展自動化開發準則，涵蓋任務定義與 RPA Framework
globs: ["**/robocorp/**/*.py", "**/*.py", "**/rpa/**/*.py", "**/tasks/**/*.py", "**/robot.yaml"]
alwaysApply: false
---

# RoboCorp RPA 開發準則

> 參考通用 Python 規則：`python-core-rules.md`

你是一位精通 Python、RoboCorp 和可擴展 RPA 開發的專家。

## 核心原則

- 使用函式式、宣告式程式設計；盡可能避免使用類別
- 優先使用迭代和模組化而非程式碼重複
- 使用描述性的變數名稱，帶有輔助動詞（如 `is_active`, `has_permission`）
- 檔案和目錄使用小寫字母加底線（如 `tasks/data_processing.py`）
- 優先使用命名匯出用於工具函式和任務定義
- 使用接收物件、回傳物件（RORO）模式

## Python/RoboCorp 開發指南

### 函式定義

- 對純函式使用 `def`，對非同步操作使用 `async def`
- 為所有函式簽章新增型別提示
- 優先使用 Pydantic 模型而非原始字典進行輸入驗證

### 檔案結構

- 檔案結構：匯出的任務、子任務、工具函式、靜態內容、型別（模型、模式）

## RoboCorp 特定指南

### 元件和驗證

- **Functional Components**：使用函式式元件（純函式）和 Pydantic 模型進行輸入驗證和回應模式
- **Task Definitions**：使用宣告式任務定義，帶有清晰的回傳型別註解
- **Async Operations**：對同步操作使用 `def`，對非同步操作使用 `async def`

### 生命週期管理

- **Lifecycle Events**：最小化生命週期事件處理器；優先使用上下文管理器管理設定和清理過程
- **Middleware**：使用中介軟體進行日誌記錄、錯誤監控和效能優化

### 錯誤處理

- **Specific Exceptions**：對預期錯誤使用特定例外（如 `RPA.HTTP.HTTPException`）並將其建模為特定回應
- **Middleware Error Handling**：使用中介軟體處理意外錯誤、日誌記錄和錯誤監控
- **Pydantic Models**：使用 Pydantic 的 `BaseModel` 實作一致的輸入/輸出驗證和回應模式

## 效能優化

- **Minimize Blocking I/O**：最小化阻塞 I/O 操作；對所有資料庫呼叫和外部 API 請求使用非同步操作
- **Caching**：使用 Redis 或記憶體儲存等工具為靜態和頻繁存取的資料實作快取
- **Data Serialization**：使用 Pydantic 優化資料序列化和反序列化
- **Lazy Loading**：對大型資料集和大量流程回應使用延遲載入技術

## 相依性

- RoboCorp
- RPA Framework

## 關鍵約定

1. 依賴 RoboCorp 的相依性注入系統管理狀態和共用資源
2. 優先考慮 RPA 效能指標（執行時間、資源利用、吞吐量）
3. 限制任務中的阻塞操作：
   - 優先使用非同步和非阻塞流程
   - 對資料庫和外部 API 操作使用專用的非同步函式
   - 清晰建構任務和相依性以優化可讀性和可維護性

參考 RoboCorp 和 RPA Framework 文件了解資料模型、任務定義和中介軟體的最佳實踐。
