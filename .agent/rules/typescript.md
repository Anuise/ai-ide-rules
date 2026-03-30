---
trigger: glob
description: 適用於 TypeScript 專案的全面編碼準則與最佳實踐，涵蓋架構、命名與性能。
globs: ["**/*.{ts,tsx}"]
alwaysApply: false
---

# TypeScript 專家開發準則

在編寫代碼時，請務必遵循以下準則。

## 1. 代碼風格與結構 (Code Style & Structure)

- **編寫簡潔且技術化**的 TypeScript 代碼，並提供準確的範例。
- **優先使用函數式與聲明式程式設計模式**；除非絕對必要，否則避免使用「類別 (Classes)」。
- **模組化與乾燥原則 (DRY)**：優先考慮代碼的疊代與模組化，而非重複代碼。
- **文件結構**：
  - 檔案頂部存放 `import`。
  - 接著是導出的主組件/函數。
  - 底部分放輔助函數、靜態內容及型別定義。
- **早返原則 (Early Returns)**：儘早處理邊界情況，減少過度嵌套的 `if` 語句。

## 2. 命名規範 (Naming Conventions)

- **目錄命名**：使用小寫字母配以連字號（例如：`components/auth-wizard`）。
- **組件命名**：使用大寫駝峰式 (PascalCase)（例如：`UserCard.tsx`）。
- **變數與函數**：使用小寫駝峰式 (camelCase)（例如：`isLoading`, `fetchData`）。
- **具義命名**：
  - 變數名稱應包含助動詞（如：`isLoaded`, `hasError`, `shouldRender`）。
  - 事件處理函數應以 `handle` 開頭（如：`handleClick`, `handleSubmit`）。
- **導出方式**：優先使用具名導出 (Named Exports) 而非預設導出 (Default Exports)。

## 3. TypeScript 使用準則 (TypeScript Usage)

- **嚴格模式**：始終以 TypeScript 編寫，並啟用嚴格型別檢查。
- **避免使用 `any`**：嚴禁使用 `any`，應儘量使用精確的型別定義。如果無法確定，請使用 `unknown`。
- **介面 vs 型別 (Interfaces vs Types)**：
  - 組件的 Props 與物件定義優先使用 `interface`。
  - 聯集型別 (Union Types) 或複雜映射使用 `type`。
- **禁止使用 Enums**：使用物件 (Object literals) 加 `as const` 或聯集型別替代（例如：`type Status = 'active' | 'inactive'`）。
- **顯式返回型別**：為所有導出的函數與複雜邏輯明確標註返回型別。

## 4. 語法與格式化 (Syntax and Formatting)

- **Utility/Helper 函數**：使用 `function` 關鍵字定義純函數邏輯（例如：`function calculateTotal(items: Item[]): number { ... }`）。
- **React 組件/Hooks**：使用 `const` 箭頭函數定義 React 組件與 Hooks（例如：`const UserProfile = ({ userId }: Props) => { ... }`）。
- **簡潔條件句**：對於簡單的賦值或返回，避免不必要的大括號。
- **解構賦值**：在適當情況下使用解構賦值來提高代碼可讀性。

## 5. 性能優化 (Performance Optimization)

- **減少 Hook 開銷**：最小化 `useEffect`、`useState` 與重型計算的數量。
- **記憶化 (Memoization)**：對於 Props 不常變動的組件，使用 `React.memo`；對於昂貴計算使用 `useMemo`。
- **動態載入**：針對非關鍵路徑的組件使用動態導入 (Dynamic Imports)。
- **圖片優化**：始終標註寬高尺寸，並實作延遲載入 (Lazy Loading)。

## 6. 錯誤處理與安全 (Error Handling & Security)

- **防禦性編程**：實作 `try-catch` 區塊處理 API 調用與潛在崩潰點。
- **輸入驗證**：使用 `Zod` 或類似工具進行執行時型別驗證。
- **錯誤邊界**：為組件樹設定全域錯誤邊界 (Error Boundaries)。
- **安全防範**：防止 XSS 攻擊，不直接使用 `dangerouslySetInnerHTML`。

## 7. 測試要求 (Testing)

- **單元測試**：為關鍵業務邏輯與工具函數編寫單元測試。
- **測試庫**：優先使用 Jest 與 React Testing Library。
- **代碼覆蓋率**：確保測試涵蓋了主要的成功路徑與邊界情況。

## 8. 關鍵提醒 (Critical Reminders)

- **嚴禁留白**：生成的代碼中不應包含 `// TODO` 或未完成的占位符。
- **完整性**：確保提供的代碼是功能齊全且可直接運行的。
- **驗證**：在回應前，請再次檢查代碼是否符合最新的 TypeScript 版本特性。
