# 平台矩陣

## 官方文件

- Codex skills: <https://developers.openai.com/codex/skills>
- Codex rules: <https://developers.openai.com/codex/rules>
- Cursor skills: <https://cursor.com/docs/skills>
- Cursor rules: <https://cursor.com/docs/rules>
- Antigravity skills: <https://antigravity.google/docs/skills>
- Antigravity rules/workflows: <https://antigravity.google/docs/rules-workflows>
- Claude Code skills: <https://code.claude.com/docs/en/best-practices#create-skills>

## Skill 差異

| 平台 | 主要檔案 | 必要欄位 | 常見輔助目錄 | 呼叫方式 | 備註 |
| --- | --- | --- | --- | --- | --- |
| Codex | `SKILL.md` | `name`, `description` | `scripts/`, `references/`, `assets/`, `agents/openai.yaml` | 明確提及 skill 或由 `description` 隱式匹配 | 支援 progressive disclosure |
| Cursor | `SKILL.md` | `description`，實務上可含 `name` | `scripts/`, `references/`, `assets/` | Agent 依描述自動選用，或手動呼叫 | `disable-model-invocation: true` 可強制手動 |
| Claude Code | `SKILL.md` | `name`, `description` | `scripts/`, 其他輔助檔 | 自動選用或 `/skill-name` | 屬 Agent Skills open standard |
| Antigravity | `SKILL.md` | `description`，可含 `name` | `scripts/`, `resources/`, `examples/` | 自動選用或明確指定 | 支援 `.agents/skills` 與舊版 `.agent/skills` |

## Instruction Rule 差異

| 平台 | 類型 | 主要檔案 | 觸發語義 | 備註 |
| --- | --- | --- | --- | --- |
| Cursor | Project Rule | `.cursor/rules/*.mdc` | Always On / Apply Intelligently / Glob / Manual | 可用 metadata 控制套用 |
| Cursor | AGENTS | `AGENTS.md` | 依所在目錄自動合併 | 純 Markdown，無 metadata |
| Antigravity | Rule | Markdown 檔 | Manual / Always On / Model Decision / Glob | 官方文件描述為 Markdown 規則 |
| Antigravity | Workflow | Markdown 檔 | 以 slash command 啟動 | 屬指令式流程，不等於一般 rule |

## Exec Rule 差異

| 平台 | 類型 | 主要檔案 | 語義 | 備註 |
| --- | --- | --- | --- | --- |
| Codex | `.rules` | `*.rules` | 執行政策 | 使用 Starlark `prefix_rule()`，控制 `allow` / `prompt` / `forbidden` |

## 關鍵不等價

- Codex `.rules` 是執行政策，不是一般自然語言 instruction rule
- Cursor `AGENTS.md` 是純 Markdown 指令，不含結構化 metadata
- Antigravity workflow 是步驟化流程，不能直接視為所有平台的 rule
- Cursor `disable-model-invocation: true` 沒有所有平台都能精確對應的等價欄位
