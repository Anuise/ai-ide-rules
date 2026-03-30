# 不等價清單

## 明確禁止

### 1. `Codex exec_rule -> Cursor/Antigravity instruction_rule`

原因：

- Codex `.rules` 是執行政策
- Cursor 與 Antigravity 的 rule/workflow 主要是自然語言或結構化指令
- 兩者控制層級不同，不能假裝等價

### 2. 任意 `skill <-> rule` 跨類型互轉

原因：

- `skill` 是可被挑選或呼叫的能力包
- `rule` 是持續性或條件性指令
- 生命周期、觸發點、上下文載入方式都不同

### 3. 未有官方規格依據的 Claude rule 輸出

原因：

- 目前本 skill v1 只以 Claude Code skill 官方文件為依據
- 沒有對應官方 rule 規格時，不輸出自創格式

## 需要標記為 lossy 的情況

### Cursor `disable-model-invocation: true`

- 不是每個平台都有精確等價欄位
- 可保留成文字約束，但不是完整語義等價

### Codex `agents/openai.yaml`

- 其中的 UI metadata、依賴或顯示設定不一定能映射到其他平台

### Claude `allowed-tools` / `agent`

- 若目標平台沒有近似能力，只能降級成說明文字

### Antigravity workflow -> 一般 instruction rule

- 會失去 slash workflow 的操作型入口

## 保守原則

- 不確定等價時，拒絕優先於猜測
- 能保留原文語義時，不做風格性過度改寫
- 任何新增欄位都必須能被官方文件支撐
