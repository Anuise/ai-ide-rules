# 1. 強制設定編碼 (解決外部程式如 Git 的輸出亂碼)
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 2. 設定 PowerShell 內建指令的預設編碼
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'

# 設定日誌資料夾
$logDir = Join-Path $PSScriptRoot "log"
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force }

# 產生檔案名稱
$logFile = Join-Path $logDir "$((Get-Date).ToString('yyyy-MM-dd'))_git_pull.log"

# 定義路徑
$repoPaths = @(
    "C:\Users\User\.gemini\skills",
    "C:\Users\User\.cursor\skills"
)

# 啟動更新
"--- 啟動更新: $((Get-Date).ToString()) ---" | Out-File $logFile -Append

foreach ($path in $repoPaths) {
    if (Test-Path "$path\.git") {
        Add-Content $logFile "[$((Get-Date).ToString('HH:mm:ss'))] 正在更新: $path"
        Set-Location -Path $path
        
        # 執行 git pull (2>&1 確保錯誤訊息也能正確編碼寫入)
        git pull 2>&1 | Out-File $logFile -Append
        
        Add-Content $logFile "------------------------------------"
    } else {
        Add-Content $logFile "[$((Get-Date).ToString('HH:mm:ss'))] 錯誤: $path 不是有效的 Git 倉庫"
    }
}

"--- 更新結束: $((Get-Date).ToString()) ---" | Out-File $logFile -Append