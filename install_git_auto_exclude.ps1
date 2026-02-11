# =================================================================
# 配置區域：在此新增或修改你想要排除的資料夾或檔案
# =================================================================
$GlobalExcludeList = @(
    ".cursor/", 
    ".agent/"
)

# =================================================================
# 自動化安裝邏輯
# =================================================================
$hookDir = "$HOME\git-hooks"
$logicScript = "$hookDir\exclude_rules.ps1"
$hooks = @("post-checkout", "pre-commit")

# 1. 建立掛鉤目錄
if (-not (Test-Path $hookDir)) {
    New-Item -Path $hookDir -ItemType Directory -Force | Out-Null
}

# 2. 封裝排除邏輯至核心腳本
$excludeItemsString = ($GlobalExcludeList | ForEach-Object { "'$_'" }) -join ", "

$logicContent = @"
# 自動產生的排除清單
`$excludePaths = @($excludeItemsString)

# 取得目前 Git 專案根目錄
`$gitRoot = git rev-parse --show-toplevel 2>`$null
if (-not `$gitRoot) { exit }

`$gitRoot = `$gitRoot.Replace('/', '\')
`$excludeFile = "`$gitRoot\.git\info\exclude"

if (Test-Path "`$gitRoot\.git") {
    # 確保排除檔案存在，避免 Select-String 報錯
    if (-not (Test-Path `$excludeFile)) {
        New-Item -Path `$excludeFile -ItemType File -Force | Out-Null
    }

    foreach (`$path in `$excludePaths) {
        # A. 寫入本地排除文件
        # 修正點：將 Regex 處理結果存入變數，確保 Select-String 參數正確
        `$escapedPath = [Regex]::Escape(`$path)
        `$alreadyExists = Select-String -Path `$excludeFile -Pattern `$escapedPath -Quiet
        
        if (-not `$alreadyExists) {
            Add-Content -Path `$excludeFile -Value "`n`# Auto-added IDE Rules`n`$path"
            Write-Host "Local: 已將 `$path 加入排除清單" -ForegroundColor Green
        }

        # B. 從 Git 快取中移除
        Set-Location `$gitRoot
        `$isTracked = git ls-files `$path
        if (`$isTracked) {
            git rm -r --cached `$path --ignore-unmatch 2>`$null
            Write-Host "Cache: 偵測到 `$path 已被追蹤，已從索引移除" -ForegroundColor Yellow
        }
    }
}
"@

Set-Content -Path $logicScript -Value $logicContent -Encoding UTF8
Write-Host "核心邏輯已更新於: $logicScript" -ForegroundColor Cyan

# 3. 建立 Git Hook 包裝器 (Shell 格式)
foreach ($hookName in $hooks) {
    $hookPath = Join-Path $hookDir $hookName
    $hookContent = @"
#!/bin/sh
powershell.exe -ExecutionPolicy Bypass -File "$($logicScript.Replace('\', '/'))"
"@
    Set-Content -Path $hookPath -Value $hookContent -Encoding ascii
}

# 4. 配置 Git 全域設定
git config --global core.hooksPath "$($hookDir.Replace('\', '/'))"

# 5. 立即執行一次初始化
Write-Host "正在對當前專案執行首次掃描..." -ForegroundColor Magenta
& $logicScript

Write-Host "`n[安裝成功] 全域自動排除機制已啟動。" -ForegroundColor White -BackgroundColor DarkGreen