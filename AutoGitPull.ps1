# 定義所有需要更新的資料夾路徑
$repoPaths = @(
    "C:\Users\User\.gemini\skills",
    "C:\Users\User\.cursor\skills"
)

foreach ($path in $repoPaths) {
    if (Test-Path "$path\.git") {
        Write-Host "正在更新: $path" -ForegroundColor Cyan
        Set-Location -Path $path
        git pull
    } else {
        Write-Warning "跳過：$path 不是有效的 Git 倉庫"
    }
}

Write-Host "所有任務已完成！" -ForegroundColor Green
# 若要在排程執行時看到結果，可取消下一行註解
# Start-Sleep -Seconds 5