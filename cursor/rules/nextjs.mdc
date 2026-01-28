---
trigger: glob
description: 適用於 Next.js App Router、TypeScript、Tailwind CSS 的綜合開發指南與規則，涵蓋性能、SEO 與架構最佳實踐。
globs: ["**/*.{ts,tsx,js,jsx}"]
alwaysApply: false
---

# Next.js 綜合開發規範 (Comprehensive Next.js Rules)

## 代碼風格與結構 (Code Style and Structure)

- **簡潔與技術性**：編寫簡潔、技術性的 TypeScript 代碼，並提供精確的範例。
- **程式設計範式**：優先使用函數式和聲明式編程模式；嚴格禁止使用類 (Classes)。
- **DRY 原則**：優先考慮迭代和模組化，避免代碼重複。
- **命名規範**：
  - 變數名：使用描述性名稱，布林值使用輔助動詞 (例如：`isLoading`, `hasError`)。
  - 目錄名：使用小寫並以連字號分隔 (例如：`components/auth-wizard`)。
  - 組件導出：組件和工具函數優先使用具名導出 (Named Exports)。
- **檔案組織**：檔案結構應包含：導出的主要組件、子組件、輔助函數、靜態內容、類型定義。

## TypeScript 使用 (TypeScript Usage)

- **全方位 TS**：所有代碼必須使用 TypeScript。
- **類型定義**：優先使用 `interface` 而非 `type`（除非需要聯集類型）。
- **避免列舉**：禁止使用 `enum`；改用 `const map` 或 `const對象 + as const`。
- **類型安全**：避免使用 `as` 或 `!` 進行類型斷言，除非是處理無法更改的外部類型。

## Next.js 與 React 最佳實踐 (Next.js & React Best Practices)

- **App Router 優先**：始終優先考慮使用 Next.js App Router 功能。
- **Server Components (RSC)**：
  - 盡可能將組件作為 Server Components 使用。
  - 盡量減少 `'use client'` 的使用。僅在需要 Web API (如 `localStorage`)、Hooks (`useState`, `useEffect`) 或交互事件時使用。
- **數據獲取 (Data Fetching)**：
  - 在 Server Components 中使用 `async/await` 獲取數據。
  - 對於資料庫或 API 請求，實作適當的錯誤處理和 loading 狀態。
- **Server Actions**：
  - 將數據變更邏輯封裝在 Server Actions 中。
  - 推薦搭配 `next-safe-action` 進行類型安全驗證。
  - 對於預期錯誤（如驗證失敗），將錯誤作為返回值而不是拋出異常。
- **性能優化**：
  - 使用 `next/image` 優化圖片：提供 WebP 格式、設定寬高、實作懶加載。
  - 非關鍵組件使用 `dynamic` 導入進行程式碼拆分 (Code Splitting)。
  - 盡量減少 `useEffect` 和 `useState` 的過度依賴，優先使用路徑參數 (URL Search Params) 管理狀態。

## UI 與樣式 (UI & Styling)

- **Tailwind CSS**：所有樣式必須使用 Tailwind CSS 類。避免寫原始 CSS。
- **移動優先**：採用移動優先 (Mobile-first) 的響應式設計。
- **組件庫**：優先選用 Shadcn UI、Radix UI 或 Headless UI。
- **可訪問性 (a11y)**：
  - 使用語義化 HTML 標籤（如 `<main>`, `<section>`, `<nav>`）。
  - 確保所有交互元素具備正確的 ARIA 屬性及鍵盤導航支持。

## 錯誤處理與驗證 (Error Handling & Validation)

- **早返原則 (Early Returns)**：在函數開始處處理錯誤和邊際情況，避免深層巢狀結構。
- **防禦性編程**：使用 Guard Clauses (守衛語句) 處理先決條件。
- **客戶端驗證**：使用 Zod 或類似庫進行 Runtime 類型驗證。
- **錯誤邊界**：實作 `error.tsx` 和 `global-error.tsx` 來捕獲未預期的異常。

## 開發哲學 (Development Philosophy)

- **完整實作**：代碼必須是功能完整的，不留 `TODO`、佔位符或缺失的部分。
- **可讀性**：清晰優雅的代碼優於過度複雜的性能優化。
- **安全性**：始終考慮安全性風險（XSS, CSRF, 輸入過濾）。

---
**提示**：在生成代碼前，請先思考步驟並詳細描述你的計劃。如果問題模糊，請先詢問釐清。
