---
name: doc-pipeline
description: 將產品與技術文件產出流程標準化，依序建立 README、PRD、TDD、API 文件、維運文件與 Changelog，並確保文件之間的內容一致性與交叉驗證。
---

# Doc Pipeline

此技能用於把零散的需求或專案資訊整理成一條可執行的文件產線，避免 README、PRD、TDD、API 文件、維運文件與 Changelog 各自為政。

## 何時使用

當使用者有以下需求時使用此技能：

- 要建立新專案或新模組的完整文件集
- 要補齊既有專案缺漏的核心文件
- 要把需求、技術設計、API 與維運資訊整理成一致文件
- 要規劃文件產出順序與相依關係
- 要產出可交付的文件清單與落點路徑

## 產出順序

依下列順序產出或補齊文件：

| 順序 | 文件 | 模板 | 預設輸出 |
| --- | --- | --- | --- |
| 1 | README | `assets/templates/README.md` | `README.md` |
| 2 | PRD | `assets/templates/PRD.md` | `docs/PRD.md` |
| 3 | TDD | `assets/templates/TDD.md` | `docs/TDD.md` |
| 4 | API Doc | `assets/templates/API.md` | `docs/API.md` |
| 5 | Operations | `assets/templates/OPERATIONS.md` | `docs/OPERATIONS.md` |
| 6 | Changelog | `assets/templates/CHANGELOG.md` | `CHANGELOG.md` |

## 執行方式

### Phase 1：補齊最小輸入

先整理出足夠的輸入資訊，再進入寫作：

1. 專案名稱或模組名稱
2. 問題背景與目標
3. 核心使用者或使用情境
4. 功能範圍與非功能需求
5. 技術棧、部署環境或已知限制
6. 版本或發版節點

若資訊不足，優先補齊以下兩組問題：

- 問題組 1：為什麼要做、替誰做、成功條件是什麼
- 問題組 2：系統如何落地、API 怎麼提供、部署與維運條件是什麼

### Phase 2：依序產出文件

每份文件都應從對應模板開始，避免自由發散：

- README：說明專案定位、價值、安裝、使用與快速開始
- PRD：定義需求、目標、範圍、驗收與版本影響
- TDD：把 PRD 轉成技術設計、資料流、模組責任與實作策略
- API Doc：把 TDD 中的介面整理成可讀的 API 契約
- Operations：整理部署、監控、告警、回滾與維運程序
- Changelog：整理版本變更，反映新增、修改與修復

### Phase 3：做交叉驗證

產出後必做一致性檢查：

- PRD 的需求與驗收條件必須能在 TDD 找到落點
- TDD 的 API 設計必須能在 API Doc 找到對應介面
- README 的使用方式必須與 Operations 的部署與執行條件一致
- Changelog 的版本與變更項目必須能回扣 README 或 PRD 的更新
- 所有文件的命名、路徑、版本號與術語要一致

### Phase 4：回報交付結果

最後輸出文件清單，明確列出是否已建立：

```text
文件產出結果

| 文件 | 路徑 | 狀態 |
|------|------|------|
| README | README.md | 完成/待補 |
| PRD | docs/PRD.md | 完成/待補 |
| TDD | docs/TDD.md | 完成/待補 |
| API Doc | docs/API.md | 完成/待補 |
| Operations | docs/OPERATIONS.md | 完成/待補 |
| Changelog | CHANGELOG.md | 完成/待補 |
```

## 參考資料

- 先讀 `references/workflow.md`，理解文件管線的前後依賴
- 使用 `assets/templates/` 下的模板作為每份文件的起點

## 執行原則

- 只補必要內容，不為了看起來完整而虛構細節
- 若使用者只要其中幾份文件，仍遵守相依順序處理
- 若已有既有文件，先延續既有內容與結構，不重寫整套
- 若缺少關鍵事實，明確標記待補，不自行編造
