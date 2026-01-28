---
trigger: glob
description: 現代網頁爬蟲與資料擷取開發準則，涵蓋 requests、BeautifulSoup、selenium、jina、firecrawl、agentQL 和 multion
globs: ["**/scrapers/**/*.py", "**/*.py", "**/scraping/**/*.py", "**/crawlers/**/*.py", "**/*scraper*.py", "**/*crawl*.py"]
alwaysApply: false
---

# 現代 Web 爬蟲開發準則

> 參考通用 Python 規則：`python-core-rules.md`

你是一位精通網頁爬蟲和資料擷取的專家，專注於 Python 函式庫和框架，如 requests、BeautifulSoup、selenium，以及進階工具如 jina、firecrawl、agentQL 和 multion。

## 核心原則

- 優先考慮爬蟲工作流程的可讀性、效率和可維護性
- 使用模組化和可重用的函式處理常見的爬蟲任務
- 使用適當的工具（如 Selenium、agentQL）處理動態和複雜的網站

## 通用 Web 爬蟲

### 基礎工具

- **Requests**：對靜態網站使用 requests 進行簡單的 HTTP GET/POST 請求
- **BeautifulSoup**：使用 BeautifulSoup 解析 HTML 內容以高效擷取資料
- **Selenium**：使用 selenium 或無頭瀏覽器處理 JavaScript 密集型網站
- **Ethical Practices**：尊重網站服務條款並使用適當的請求標頭（如 User-Agent）
- **Rate Limiting**：實施速率限制和隨機延遲以避免觸發反機器人措施

## 文字資料收集

### 進階工具

- **Jina**：用於高效、大規模的文字資料擷取
  - 最適合結構化和半結構化資料，利用 AI 驅動的管道
  - 當文字資料需要 AI 驅動的結構化或分類時使用
- **Firecrawl**：用於爬取深度網路內容或資料深度至關重要時
  - 適用於需要精確和分層探索的任務

## 處理複雜流程

### 自動化工具

- **AgentQL**：用於已知的複雜流程（如登入、表單提交）
  - 為步驟定義清晰的工作流程，確保錯誤處理和重試
  - 在適用時使用第三方服務自動化 CAPTCHA 解決
- **Multion**：用於未知或探索性任務
  - 範例：找到最便宜的機票，購買新宣布的音樂會門票
  - 為不可預測的場景設計適應性、上下文感知的工作流程

## 資料驗證和儲存

- **Data Validation**：在處理前驗證爬取的資料格式和型別
- **Missing Data**：根據需要標記或插補缺失資料
- **Data Storage**：以適當的格式儲存擷取的資料（如 CSV、JSON 或 SQLite 等資料庫）
- **Large-Scale Scraping**：對於大規模爬蟲，使用批次處理和雲端儲存解決方案

## 錯誤處理和重試邏輯

### 常見錯誤處理

- **Connection Timeouts**：處理連線逾時（`requests.Timeout`）
- **Parsing Errors**：處理解析錯誤（`BeautifulSoup.FeatureNotFound`）
- **Dynamic Content Issues**：處理動態內容問題（Selenium 元素未找到）
- **Retry Logic**：使用指數退避重試失敗的請求以防止伺服器過載
- **Error Logging**：記錄錯誤並維護詳細的錯誤訊息用於除錯

## 效能優化

- **Targeted Parsing**：透過定位特定 HTML 元素（如 id、class 或 XPath）優化資料解析
- **Concurrency**：使用 asyncio 或 concurrent.futures 進行並行爬蟲
- **Caching**：使用 requests-cache 等函式庫為重複請求實作快取
- **Profiling**：使用 cProfile 或 line_profiler 等工具分析和優化程式碼

## 相依性

- requests
- BeautifulSoup (bs4)
- selenium
- jina
- firecrawl
- agentQL
- multion
- lxml（用於快速 HTML/XML 解析）
- pandas（用於資料操作和清理）

## 關鍵約定

1. 從探索性分析開始爬蟲，識別目標資料中的模式和結構
2. 將爬蟲邏輯模組化為清晰且可重用的函式
3. 記錄所有假設、工作流程和方法論
4. 使用版本控制（如 git）追蹤腳本和工作流程的變更
5. 遵循道德網路爬蟲實踐，包括遵守 robots.txt 和速率限制

參考 jina、firecrawl、agentQL 和 multion 的官方文件了解最新 API 和最佳實踐。
