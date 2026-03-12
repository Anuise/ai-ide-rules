# AutoGitPull.ps1 - Update antigravity-awesome-skills
$utf8 = [System.Text.UTF8Encoding]::new($false)
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

# Variables
$repoPath = $PSScriptRoot
$logFile  = Join-Path $repoPath "logs\AutoGitPull.log"
$logDir   = Split-Path -Parent $logFile

# Helper: write to console + log
function Write-Log {
    param([string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$timestamp] $Message"
    Write-Host $line
    Add-Content -Path $logFile -Value $line -Encoding UTF8
}

if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Update targets
$updateTargets = @(
    "--cursor"
    "--antigravity"
    # "--claude"             # 取消註解可啟用
)

# Ensure working directory
if (-not (Test-Path (Join-Path $repoPath ".git"))) {
    Write-Log "Warning: $repoPath is not a Git repository. Continue anyway."
}

Set-Location -Path $repoPath

Write-Log "===== Start updating antigravity-awesome-skills ====="

# Resolve npx executable once to avoid pipeline invocation issues.
$npxCommand = Get-Command -Name "npx.cmd" -ErrorAction SilentlyContinue
if (-not $npxCommand) {
    $npxCommand = Get-Command -Name "npx" -ErrorAction SilentlyContinue
}

if (-not $npxCommand) {
    Write-Log "Error: npx was not found in PATH."
    Write-Log "===== Update stopped ====="
    exit 1
}

$npxPath = $npxCommand.Source
Write-Log "Using npx executable: $npxPath"

# Run each target sequentially
foreach ($target in $updateTargets) {
    Write-Log "Run: npx antigravity-awesome-skills $target"
    try {
        $outputLines = & $npxPath "antigravity-awesome-skills" $target 2>&1
        foreach ($line in $outputLines) {
            Write-Log ([string]$line)
        }

        if ($LASTEXITCODE -ne 0) {
            Write-Log "Failed: $target (exit code: $LASTEXITCODE)"
        } else {
            Write-Log "Done: $target (exit code: 0)"
        }
    } catch {
        Write-Log "Error ($target): $($_.Exception.Message)"
    }
}

Write-Log "===== All updates finished ====="
