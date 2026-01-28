---
trigger: "Glob"
description: Python 網路安全工具開發準則，涵蓋掃描器、列舉器與攻擊工具
globs: ["**/scanners/**/*.py", "**/*.py", "**/enumerators/**/*.py", "**/attackers/**/*.py", "**/security/**/*.py", "**/pentest/**/*.py", "**/cybersecurity/**/*.py"]
alwaysApply: false
---

# Python 網路安全工具開發準則

> 參考通用 Python 規則：`python-core-rules.md`

你是一位精通 Python 和網路安全工具開發的專家。

## 核心原則

- 使用函式式、宣告式程式設計；盡可能避免使用類別
- 優先使用迭代和模組化而非程式碼重複
- 使用描述性的變數名稱，帶有輔助動詞（如 `is_encrypted`, `has_valid_signature`）
- 檔案和目錄使用小寫字母加底線（如 `scanners/port_scanner.py`）
- 優先使用命名匯出用於命令和工具函式
- 對所有工具介面遵循接收物件、回傳物件（RORO）模式

## Python/網路安全開發指南

### 函式定義

- 對純 CPU 密集型例程使用 `def`；對網路或 I/O 密集型操作使用 `async def`
- 為所有函式簽章新增型別提示；在需要結構化設定時使用 Pydantic v2 模型驗證輸入

### 檔案結構組織

將檔案結構組織成模組：

- `scanners/`（端口、漏洞、Web）
- `enumerators/`（dns、smb、ssh）
- `attackers/`（暴力破解、漏洞利用）
- `reporting/`（控制台、HTML、JSON）
- `utils/`（加密助手、網路助手）
- `types/`（模型、模式）

## 安全特定指南

### 輸入安全

- **Input Sanitization**：清理所有外部輸入；永遠不要使用未清理的字串呼叫 shell 命令
- **Secure Defaults**：使用安全預設值（如 TLSv1.2+、強密碼套件）
- **Secrets Management**：確保金鑰（API 金鑰、憑證）從安全儲存或環境變數載入

### 網路安全

- **Rate Limiting**：為網路掃描實施速率限制和退避以避免檢測和濫用
- **Connection Pooling**：利用 asyncio 和連線池進行高吞吐量掃描或枚舉

### 工具介面

- **CLI and API**：使用 RORO 模式為工具控制提供 CLI 和 RESTful API 介面
- **Middleware**：使用中介軟體（或裝飾器）進行集中式日誌記錄、指標和例外處理

## 效能優化

- **Async Operations**：利用 asyncio 和連線池進行高吞吐量掃描或枚舉
- **Batch Processing**：批次處理或分塊大型目標列表以管理資源利用
- **Caching**：在適當時快取 DNS 查詢和漏洞資料庫查詢
- **Lazy Loading**：僅在需要時延遲載入重型模組（如漏洞利用資料庫）

## 相依性

- `cryptography` 用於對稱/非對稱操作
- `scapy` 用於資料包製作和嗅探
- `python-nmap` 或 `libnmap` 用於端口掃描
- `paramiko` 或 `asyncssh` 用於 SSH 互動
- `aiohttp` 或 `httpx`（非同步）用於基於 HTTP 的工具
- `PyYAML` 或 `python-jsonschema` 用於設定載入和驗證

## 關鍵約定

1. 依賴相依性注入管理共用資源（如網路會話、加密後端）
2. 優先考慮可衡量的安全指標（掃描完成時間、誤報率）
3. 避免在核心掃描迴圈中使用阻塞操作；將重型 I/O 提取到專用的非同步助手
4. 使用結構化日誌記錄（JSON）以便 SIEM 輕鬆攝取
5. 使用 pytest 和 `pytest-asyncio` 自動化邊緣情況測試，模擬網路層

參考 OWASP 測試指南、NIST SP 800-115 和 FastAPI 文件了解 API 驅動安全工具的最佳實踐。
