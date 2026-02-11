# 設定日誌資料夾
$logDir = Join-Path $PSScriptRoot "log"
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir }

# 產生檔案名稱 (例如: 2026-02-11_git_pull.log)
$logFile = Join-Path $logDir "$((Get-Date).ToString('yyyy-MM-dd'))_git_pull.log"

# 定義所有需要更新的資料夾路徑
$repoPaths = @(
    "C:\Users\User\.gemini\skills",
    "C:\Users\User\.cursor\skills"
)

# 記錄開始時間
"--- 啟動更新: $((Get-Date).ToString()) ---" | Out-File $logFile -Append

foreach ($path in $repoPaths) {
    if (Test-Path "$path\.git") {
        Add-Content $logFile "[$((Get-Date).ToString('HH:mm:ss'))] 正在更新: $path"
        Set-Location -Path $path
        
        # 執行 git pull 並將標準輸出與錯誤訊息都導向 log
        git pull >> $logFile 2>&1
        Add-Content $logFile "------------------------------------"
    } else {
        Add-Content $logFile "[$((Get-Date).ToString('HH:mm:ss'))] 錯誤: $path 不是有效的 Git 倉庫"
    }
}

"--- 更新結束: $((Get-Date).ToString()) ---" | Out-File $logFile -Append
