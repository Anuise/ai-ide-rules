# 映射規則

## 正規化欄位

轉換前先把來源內容整理成以下欄位：

| 欄位 | 說明 |
| --- | --- |
| `artifact_family` | `skill` / `instruction_rule` / `exec_rule` |
| `platform` | 來源平台 |
| `name` | 名稱或標題 |
| `description` | 觸發條件與用途說明 |
| `trigger_mode` | `implicit` / `explicit` / `always_on` / `model_decision` / `glob` / `manual` |
| `required_metadata` | 目標格式必需欄位 |
| `optional_metadata` | 可選欄位與原始語義 |
| `directory_layout` | 支援目錄結構 |
| `manual_invocation` | 手動呼叫方式 |
| `auto_invocation` | 自動呼叫方式 |
| `context_loading` | 先載 metadata、按需載完整內容、或整份直接讀取 |
| `side_effects` | 是否可能觸發外部行為或執行政策 |

## Skill -> Skill

### 通用規則

- 保留 `name` 與 `description`
- 優先保留 instruction-first 結構
- 可執行程式碼維持在 `scripts/`
- 背景文件放在目標平台的文件目錄
- 可重用模板放在目標平台的資源目錄

### 目錄映射

| 來源語義 | Codex | Cursor | Claude Code | Antigravity |
| --- | --- | --- | --- | --- |
| 指南文件 | `references/` | `references/` | `references/` 或同層文件 | `resources/` |
| 可執行腳本 | `scripts/` | `scripts/` | `scripts/` | `scripts/` |
| 模板/資產 | `assets/` | `assets/` | `assets/` 或同層文件 | `examples/` 或 `resources/` |

### 觸發語義映射

| 來源 | 目標 | 處理方式 |
| --- | --- | --- |
| Cursor `disable-model-invocation: true` | Codex | 無精確欄位；在 `description` 說明需手動呼叫，並標記 `lossy: true` |
| Cursor `disable-model-invocation: true` | Claude Code | 改寫為僅在明確 `/skill-name` 或明確請求時使用，標記 `lossy: true` |
| Codex 隱式匹配 | Cursor / Claude / Antigravity | 保留為描述式觸發，重寫 `description` 以提高可匹配性 |
| Claude `allowed-tools` | Codex / Cursor / Antigravity | 只有目標支援近似工具限制時才保留；否則標記 `lossy: true` |
| Codex `agents/openai.yaml` UI metadata | 其他平台 | 視為附加資訊；可轉成註解或說明，但不當成目標必要欄位 |

## Instruction Rule -> Instruction Rule

### Cursor Rule -> Antigravity Rule

- 保留規則正文
- `description` 保留為規則摘要
- `alwaysApply: true` 轉成 `Always On`
- `globs` 轉成檔案範圍說明
- 若來源是 `Apply Intelligently`，目標改寫為 `Model Decision`

### Antigravity Rule -> Cursor Rule

- 規則目的轉成 `description`
- `Always On` 轉 `alwaysApply: true`
- `Model Decision` 轉成一般 project rule，保留描述觸發
- `Glob` 轉成 `.mdc` frontmatter 的 `globs`
- 若來源只是自由文字 Markdown，缺少結構欄位時，補成最小 `.mdc` 包裝並標記 `lossy`

### Cursor AGENTS.md

- 視為純文字 instruction rule
- 沒有 metadata 可保留時，不臆造 `globs` 或 `alwaysApply`
- 若轉成結構化 rule，需要把觸發模式標記為推定，並在 report 說明

### Antigravity Workflow

- 視為 `instruction_rule` 的流程型變體
- 保留標題、描述、步驟
- 目標若不支援 slash workflow，改寫成一般 instruction rule，並標記 `lossy`

## Exec Rule -> Exec Rule

### Codex `.rules`

- 只允許輸出為 Codex `.rules`
- 保留 Starlark `prefix_rule()` 與執行決策語義
- 允許重排、重命名註解、補上 `match` / `not_match` 驗證樣本
- 不得改寫成單純自然語言規則

## Report 規則

每次轉換都要回傳：

| 欄位 | 說明 |
| --- | --- |
| `supported` | 目標轉換是否被正式支援 |
| `lossy` | 是否有資訊或語義損失 |
| `unsupported_reason` | 不支援時的具體原因 |
| `docs_used` | 實際讀取的官方文件清單 |

可選補充：

- `source_platform`
- `target_platform`
- `artifact_type`
- `notes`
