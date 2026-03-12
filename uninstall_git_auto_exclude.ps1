param(
    [string]$ScanRoot = 'C:\'
)

# 統一主控台與輸出為 UTF-8（部分 Host 可能不支援，失敗時不終止）
$utf8 = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$OutputEncoding = $utf8
try { [Console]::InputEncoding = $utf8 } catch {}
try { [Console]::OutputEncoding = $utf8 } catch {}

# 與安裝腳本一致，避免回滾目標不一致
$GlobalExcludeList = @('.cursor/', '.agent/')

$hookDir = "$HOME\git-hooks"
$hookFiles = @("exclude_rules.ps1", "post-checkout", "pre-commit")

function Normalize-GitPath {
    param([string]$PathValue)
    if ([string]::IsNullOrWhiteSpace($PathValue)) { return "" }
    $normalized = $PathValue -replace "\\", "/"
    $normalized = $normalized -replace "/+$", ""
    return $normalized.ToLowerInvariant()
}

function Remove-ManagedExcludeRules {
    param(
        [string]$RepoRoot,
        [string[]]$ExcludePaths
    )

    $excludeFile = Join-Path $RepoRoot ".git\info\exclude"
    if (-not (Test-Path -LiteralPath $excludeFile)) {
        return @{ Changed = $false; RemovedRules = 0 }
    }

    $lines = Get-Content -LiteralPath $excludeFile -ErrorAction SilentlyContinue
    if ($null -eq $lines) {
        return @{ Changed = $false; RemovedRules = 0 }
    }

    $output = New-Object System.Collections.Generic.List[string]
    $removedRules = 0
    $i = 0

    while ($i -lt $lines.Count) {
        $line = $lines[$i]
        $trimmed = $line.Trim()

        if ($trimmed -eq "# Auto-added IDE Rules") {
            $nextIndex = $i + 1
            if ($nextIndex -lt $lines.Count) {
                $nextTrimmed = $lines[$nextIndex].Trim()
                if ($ExcludePaths -contains $nextTrimmed) {
                    $removedRules++
                    $i += 2
                    continue
                }
            }

            # 僅移除本機制留下的標記，避免殘留雜訊
            $i++
            continue
        }

        $output.Add($line)
        $i++
    }

    $changed = ($output.Count -ne $lines.Count)
    if ($changed) {
        Set-Content -LiteralPath $excludeFile -Value $output -Encoding UTF8
    }

    return @{ Changed = $changed; RemovedRules = $removedRules }
}

function Restore-TrackedPaths {
    param(
        [string]$RepoRoot,
        [string[]]$ExcludePaths
    )

    $restored = 0
    $restoreFailed = 0

    foreach ($path in $ExcludePaths) {
        $localPath = $path.TrimEnd('/','\').Replace('/','\')
        $absolutePath = Join-Path $RepoRoot $localPath
        if (-not (Test-Path -LiteralPath $absolutePath)) { continue }

        & git -C $RepoRoot ls-files --error-unmatch -- "$path" *> $null
        if ($LASTEXITCODE -eq 0) { continue }

        & git -C $RepoRoot add -- "$path" *> $null
        if ($LASTEXITCODE -eq 0) { $restored++ } else { $restoreFailed++ }
    }

    return @{ Restored = $restored; RestoreFailed = $restoreFailed }
}

function Get-GitRepos {
    param([string]$RootPath)

    $gitDirs = Get-ChildItem -LiteralPath $RootPath -Directory -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq ".git" }

    $repoSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($gitDir in $gitDirs) {
        $repoRoot = Split-Path -Parent $gitDir.FullName
        if (-not [string]::IsNullOrWhiteSpace($repoRoot)) {
            [void]$repoSet.Add($repoRoot)
        }
    }

    return @($repoSet) | Sort-Object
}

# 僅在目前值由安裝腳本設定時才還原，避免覆蓋使用者自訂設定
$expectedHooksPath = Normalize-GitPath $hookDir
$currentHooksPath = (& git config --global --get core.hooksPath 2>$null)

if ((Normalize-GitPath $currentHooksPath) -eq $expectedHooksPath) {
    & git config --global --unset core.hooksPath 2>$null
    Write-Host "Global: restored core.hooksPath" -ForegroundColor Green
} else {
    Write-Host "Global: core.hooksPath unchanged (not set by this script)" -ForegroundColor Yellow
}

foreach ($name in $hookFiles) {
    $path = Join-Path $hookDir $name
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
    }
}

if (Test-Path -LiteralPath $hookDir) {
    $remaining = Get-ChildItem -LiteralPath $hookDir -Force -ErrorAction SilentlyContinue
    if ($remaining.Count -eq 0) {
        Remove-Item -LiteralPath $hookDir -Force -ErrorAction SilentlyContinue
    }
}

$repos = Get-GitRepos -RootPath $ScanRoot
$report = New-Object System.Collections.Generic.List[object]

foreach ($repo in $repos) {
    try {
        $excludeResult = Remove-ManagedExcludeRules -RepoRoot $repo -ExcludePaths $GlobalExcludeList
        $restoreResult = Restore-TrackedPaths -RepoRoot $repo -ExcludePaths $GlobalExcludeList

        $entry = [PSCustomObject]@{
            Repo          = $repo
            ExcludeChanged = $excludeResult.Changed
            RemovedRules  = $excludeResult.RemovedRules
            Restored      = $restoreResult.Restored
            RestoreFailed = $restoreResult.RestoreFailed
            Error         = ""
        }
        $report.Add($entry) | Out-Null

        Write-Host "Repo: $repo | removed=$($entry.RemovedRules) restored=$($entry.Restored) failed=$($entry.RestoreFailed)" -ForegroundColor Cyan
    } catch {
        $report.Add([PSCustomObject]@{
            Repo          = $repo
            ExcludeChanged = $false
            RemovedRules  = 0
            Restored      = 0
            RestoreFailed = 0
            Error         = $_.Exception.Message
        }) | Out-Null

        Write-Host "Repo: $repo | error=$($_.Exception.Message)" -ForegroundColor Red
    }
}

$totalRepos = $report.Count
$totalRemoved = (0 + (($report | Measure-Object -Property RemovedRules -Sum).Sum))
$totalRestored = (0 + (($report | Measure-Object -Property Restored -Sum).Sum))
$totalFailed = (0 + (($report | Measure-Object -Property RestoreFailed -Sum).Sum))
$totalErrors = ($report | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Error) }).Count

Write-Host ""
Write-Host "[Uninstall completed]" -ForegroundColor White -BackgroundColor DarkGreen
Write-Host "Scanned repos: $totalRepos"
Write-Host "Removed rules: $totalRemoved"
Write-Host "Restored tracked paths: $totalRestored"
Write-Host "Restore failed: $totalFailed"
Write-Host "Repo errors: $totalErrors"
