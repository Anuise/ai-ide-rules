$utf8 = [System.Text.UTF8Encoding]::new($false)
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

$repoPath = $PSScriptRoot
$logFile = Join-Path $repoPath "logs\AutoUpdateCli.log"
$logDir = Split-Path -Parent $logFile

if (-not (Test-Path -LiteralPath $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message)

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$timestamp] $Message"
    Write-Host $line
    Add-Content -Path $logFile -Value $line -Encoding UTF8
}

Write-Log "===== Start updating AI CLIs ====="
Write-Log ""

# 依序執行各 CLI 的 update 指令
$targets = @(
    @{ Command = "claude"; DisplayName = "Claude Code" }
    @{ Command = "codex"; DisplayName = "Codex CLI" }
    @{ Command = "agy"; DisplayName = "Antigravity" }
)

foreach ($target in $targets) {
    Write-Log "$($target.DisplayName):"

    if (-not (Get-Command -Name $target.Command -ErrorAction SilentlyContinue)) {
        Write-Log "  Skipped: $($target.Command) was not found in PATH."
        Write-Log ""
        continue
    }

    try {
        Write-Log "  Running: $($target.Command) update"
        $output = & $target.Command update 2>&1
        foreach ($line in $output) {
            Write-Log "  $([string]$line)"
        }

        if ($LASTEXITCODE -ne 0) {
            Write-Log "  Failed: exit code $LASTEXITCODE"
        }
        else {
            Write-Log "  Done."
        }
    }
    catch {
        Write-Log "  Error: $($_.Exception.Message)"
    }
    Write-Log ""
}

Write-Log "===== All updates finished ====="
