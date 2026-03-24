---
name: doc-pipeline
description: >
  手動觸發的文件產生流水線。輸入專案/功能需求後，一次產出六份標準化技術文件：
  README、PRD、TDD、API Doc、Operations Guide、Changelog。
  使用方式：在 Agent 聊天中輸入 /doc-pipeline。
disable-model-invocation: true
---

# 文件產生流水線 (Doc Pipeline)

## 概述

本技能將使用者提供的需求轉化為六份結構化技術文件。每份文件遵循固定模板與品質閘門，確保跨文件一致性。

## 觸發方式

在 Cursor Agent 聊天中輸入 `/doc-pipeline`，並附上你的需求描述。

## 前置條件

- 確保 `doc-governance` 與 `doc-quality-gate` 規則已存在於 `cursor/rules/`。
- 本技能會讀取 `assets/templates/` 下的六份模板作為骨架。
- 詳細流程邏輯請參閱 `references/workflow.md`。

---

## 執行流程

### Phase 1：需求正規化

1. 讀取使用者輸入的需求描述。
2. 若資訊不足以填充模板必填欄位，**最多提問 2 個關鍵問題**：
   - 問題 1：專案的核心目標用戶與要解決的問題是什麼？
   - 問題 2：預計使用的技術棧（語言/框架/資料庫/部署平台）？
3. 將需求拆解為以下維度：
   - **商業維度**：目標、用戶、痛點、價值主張。
   - **功能維度**：功能清單、Use Cases、優先級。
   - **技術維度**：架構、資料庫、API、演算法。
   - **運維維度**：CI/CD、環境、監控、DR。

### Phase 2：依序產出六份文件

嚴格按照以下順序產出，後續文件可引用前序文件的內容：

| 順序 | 文件       | 模板路徑                         | 輸出位置             |
| ---- | ---------- | -------------------------------- | -------------------- |
| 1    | README     | `assets/templates/README.md`     | `README.md`          |
| 2    | PRD        | `assets/templates/PRD.md`        | `docs/PRD.md`        |
| 3    | TDD        | `assets/templates/TDD.md`        | `docs/TDD.md`        |
| 4    | API Doc    | `assets/templates/API.md`        | `docs/API.md`        |
| 5    | Operations | `assets/templates/OPERATIONS.md` | `docs/OPERATIONS.md` |
| 6    | Changelog  | `assets/templates/CHANGELOG.md`  | `CHANGELOG.md`       |

### Phase 3：跨文件一致性檢查

產出所有文件後，執行以下驗證並修正不一致：

- PRD 功能名稱 ↔ TDD 模組名稱。
- TDD API 端點 ↔ API Doc 端點列表。
- README 環境依賴 ↔ Operations 環境變數。
- Changelog 版本號 ↔ README 版本號。
- 所有文件中的專案名稱拼寫一致。

### Phase 4：最終輸出

將六份文件依指定路徑輸出，並以摘要表格呈現結果：

```
✅ 文件產出完成

| 文件 | 路徑 | 狀態 |
|------|------|------|
| README | README.md | ✅ |
| PRD | docs/PRD.md | ✅ |
| TDD | docs/TDD.md | ✅ |
| API Doc | docs/API.md | ✅ |
| Operations | docs/OPERATIONS.md | ✅ |
| Changelog | CHANGELOG.md | ✅ |
```

---

## 約束

- **全文繁體中文**，技術名詞保留英文。
- **禁止產出可執行程式碼**，偽代碼與設定範例除外。
- 每份文件必須通過 `doc-quality-gate` 規則定義的 DoD 檢查。
- 章節切換處必須有銜接段落。

---
