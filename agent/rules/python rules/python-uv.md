---
trigger: "Glob"
description: Python UV 相依性管理器使用準則，定義使用 uv 管理 Python 相依性的嚴格指南
globs: ["**/pyproject.toml", "**/uv.lock", "**/requirements.txt", "**/uv.toml"]
alwaysApply: false
---

# Python UV 套件管理

> 參考通用 Python 規則：`python-core-rules.md`

這些規則定義了使用 `uv` 相依性管理器在此專案中管理 Python 相依性的嚴格指南。

**✅ 僅使用 `uv`**

- 所有 Python 相依性**必須使用 `uv` 安裝、同步和鎖定**。
- 永遠不要直接使用 `pip`、`pip-tools` 或 `poetry` 進行相依性管理。

**🔁 管理相依性**
始終使用這些命令：

```bash
# 新增或升級相依性
uv add <package>

# 移除相依性
uv remove <package>

# 從鎖定檔案重新安裝所有相依性
uv sync
```

**🔁 腳本**
使用這些命令：

```bash
# 使用適當的相依性執行腳本
uv run script.py
```

你可以手動編輯內嵌元資料：

```python
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "torch",
#     "torchvision",
#     "opencv-python",
#     "numpy",
#     "matplotlib",
#     "Pillow",
#     "timm",
# ]
# ///

print("some python code")
```

或使用 uv cli：

```bash
# 新增或升級腳本相依性
uv add package-name --script script.py

# 移除腳本相依性
uv remove package-name --script script.py

# 從鎖定檔案重新安裝所有腳本相依性
uv sync --script script.py
```
