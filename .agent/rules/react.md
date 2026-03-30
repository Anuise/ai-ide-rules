---
trigger: glob
description: 適用於 React, TypeScript, Tailwind CSS 的綜合開發指南。涵蓋性能優化、命名規範、錯誤處理與組件架構。
globs: ["**/*.{ts,tsx,js,jsx}"]
alwaysApply: false
---

# React & TypeScript 最佳實踐指導 (Comprehensive Version)

請始終遵循以下規則來編寫、重構或審查程式碼。

## 1. 核心開發哲學

- **簡潔至上**：保持組件短小精悍，單一功能原則 (Single Responsibility)。
- **型別安全**：嚴格執行 TypeScript 指令，禁止使用 `any`。
- **宣告式編程**：優先使用宣告式邏輯，減少命令式操作。
- **性能意識**：避免不必要的重新渲染 (Re-renders)。

## 2. 程式碼規範與架構

### 命名規則

- **組件**：使用 PascalCase (例: `UserProfile.tsx`)。
- **變數/函數**：使用 camelCase (例: `isLoading`, `handleSubmit`)。
- **資料夾**：使用 kebab-case (例: `components/auth-wizard`)。
- **Boolean**：變數應帶有動詞前綴 (例: `hasError`, `isFetching`, `shouldShowModal`)。

### 組件結構

- **優先順序**：
  1. 外部導入 (Imports)。
  2. 型別定義 (Interfaces/Types)。
  3. 組件主體 (Component Function)。
  4. 靜態變數 (Constants/Static data)。
  5. 輔助函數 (Helper functions)。
- **組件定義**：使用 `const` 箭頭函數定義 React 組件與 Hooks。
- **輔助函數定義**：Utility/Helper 函數使用 `function` 關鍵字定義。

## 3. TypeScript 與狀態管理

- **定義型別**：優先使用 `interface` 而非 `type` (除非需要聯集型別)。
- **嚴格性**：不使用 `as` 或 `!` 進行斷言，應使用型別守衛 (Type Guards) 或可選鏈 (`?.`)。
- **Hooks**：
  - 最小化 `useState`，能透過 props 或現有狀態計算出的值就不應作為 state。
  - 減少 `useEffect` 的使用，優先使用事件處理函數。

## 4. UI 與樣式 (Tailwind CSS)

- **CSS-in-JS**：完全禁止，僅使用 Tailwind CSS。
- **動態類名**：使用 `cn()` 輔助函數（或 `clsx` + `tailwind-merge`）來處理條件類名。
- **響應式**：遵循 Mobile-first 原則。
- **語意化**：使用正確的 HTML 標籤 (Header, Main, Section, Nav, Footer, Button)。
- **無障礙 (A11y)**：確保互動元素具有 ARIA 屬性，圖片必帶 `alt`。

## 5. 錯誤處理與邏輯

- **早返原則 (Early Returns)**：處理錯誤或邊界情況應放在函數開頭，避免過深的 `if-else` 嵌套。
- **防禦性編程**：在渲染前檢查 `null` 或 `undefined`。
- **錯誤邊界 (Error Boundaries)**：為關鍵組件段落添加 Error Boundaries，確保應用不會全崩潰。

## 6. 性能優化

- **Memoization**：
  - 昂貴運算使用 `useMemo`。
  - 傳遞給子組件的函數使用 `useCallback`。
  - 對於頻繁變動但 props 不常變的組件使用 `React.memo`。
- **Lazy Loading**：對大型組件或非首屏內容使用 `React.lazy` 與 `Suspense`。
- **圖片優化**：始終指定圖片寬高，使用 WebP 格式，並開啟 Lazy Loading。

## 7. AI 執行指令 (Chain of Thought)

當我要求你實作功能時，請按以下步驟思考：

1. **分析需求**：釐清功能邏輯與所需的 API 結構。
2. **規劃型別**：先定義數據接口 (Interfaces)。
3. **編寫虛擬碼**：描述組件層級與邏輯流程。
4. **正式編碼**：
   - 移除所有 TODO 或佔位符。
   - 確保所有 Import 路徑正確。
   - 檢查是否符合上述 Tailwind 與效能規範。
5. **自我審查**：確認程式碼是否簡潔且無 Bug。

---

*備註：若涉及 Next.js，請自動切換為 App Router 模式，優先使用 Server Components。*
