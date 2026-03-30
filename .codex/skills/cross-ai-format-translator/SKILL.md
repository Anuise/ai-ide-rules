---
name: cross-ai-format-translator
description: >
  在需要把 Codex、Cursor、Claude Code、Antigravity 的 skill 或 rule 類格式，
  依官方文件與最佳實踐轉成另一平台的同型格式時使用。
  只處理 skill -> skill、instruction_rule -> instruction_rule、
  以及 Codex exec_rule -> Codex exec_rule。
  不處理 skill 與 rule 互轉，也不把 Codex .rules 假裝成 Cursor 或 Antigravity 指令規則。
---

# Cross-AI Format Translator

## 何時使用

- 需要把某個 AI 平台的 `skill` 轉成另一個平台的 `skill`
- 需要把 Cursor 或 Antigravity 的 `instruction_rule` 互轉
- 需要整理或重寫 Codex `.rules`，但仍維持 `exec_rule`

## 何時不要使用

- 任何 `skill <-> rule` 跨類型互轉
- `Codex exec_rule -> Cursor/Antigravity instruction_rule`
- 沒有官方格式依據的 Claude rule 類輸出

## 支援矩陣

- `skill`: Codex、Cursor、Claude Code、Antigravity
- `instruction_rule`: Cursor rules / `AGENTS.md`、Antigravity rules / workflows
- `exec_rule`: Codex `.rules`

需要細節時再讀：

- `references/platform-matrix.md`
- `references/mapping-rules.md`
- `references/non-equivalences.md`

## 強制流程

1. 先辨識 `source_platform`、`target_platform`、`artifact_type`、`mode`、`source_content/source_path`
2. 先讀來源與目標平台的官方文件，再開始分析內容
3. 把來源內容正規化成內部中介模型，至少包含：
   - `trigger_mode`
   - `required_metadata`
   - `directory_layout`
   - `manual_invocation`
   - `auto_invocation`
   - `context_loading`
   - `side_effects`
4. 只依照同型映射規則轉換；遇到不等價語義時保留警告，不假造等價欄位
5. 從 `assets/templates/` 選最接近的目標模板生成結果
6. 同時輸出 conversion report

## 轉換原則

- 只以官方文件作為格式依據與最佳實踐依據
- 未讀 `source` 與 `target` 官方文件前，不得開始轉換
- 預設採保守轉換：能保留就保留，不能保留就標記 `lossy`
- 不確定是否等價時，優先拒絕或標記 `unsupported_reason`
- `description` 必須明確說明何時應觸發、何時不應觸發

## 內部中介模型

建立以下欄位後再映射：

```yaml
artifact_family: skill | instruction_rule | exec_rule
platform: codex | cursor | claude-code | antigravity
name: string
description: string
trigger_mode: implicit | explicit | always_on | model_decision | glob | manual
required_metadata: {}
optional_metadata: {}
directory_layout: []
manual_invocation: string
auto_invocation: string
context_loading: string
side_effects: none | possible | explicit
```

## 輸出契約

每次都輸出兩個區塊：

1. `artifact`
2. `conversion_report`

`conversion_report` 最少必須包含：

```yaml
supported: true
lossy: false
unsupported_reason: null
docs_used:
  - https://developers.openai.com/codex/skills
  - https://cursor.com/docs/skills
```

若不支援：

```yaml
supported: false
lossy: false
unsupported_reason: 具體原因
docs_used:
  - 來源文件
  - 目標文件
```

## 模式

- `faithful conversion`: 以結構保真優先，只做必要重排
- `best-practice adaptation`: 允許補上目標平台慣例，但必須在 report 標出調整點

## 拒絕條件

- 來源與目標不是同型 artifact
- 目標格式缺乏官方規格
- 來源語義屬於執行政策，但目標只支援一般指令文字
- 需要臆造不存在的觸發或權限語義才能完成轉換

## 模板位置

- `assets/templates/skills/codex/SKILL.md`
- `assets/templates/skills/cursor/SKILL.md`
- `assets/templates/skills/claude-code/SKILL.md`
- `assets/templates/skills/antigravity/SKILL.md`
- `assets/templates/rules/cursor-rule.mdc`
- `assets/templates/rules/cursor-AGENTS.md`
- `assets/templates/rules/antigravity-rule.md`
- `assets/templates/rules/antigravity-workflow.md`
- `assets/templates/rules/codex.rules`
