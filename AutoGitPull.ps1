param(
    [bool]$Yes = $true
)

$utf8 = [System.Text.UTF8Encoding]::new($false)
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

$repoPath = $PSScriptRoot
$logFile = Join-Path $repoPath "logs\AutoGitPull.log"
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

function Invoke-NpxInstall {
    param(
        [string]$Flag,
        [string]$DisplayName,
        [bool]$Yes = $true
    )

    Write-Log "${DisplayName}:"
    $yesFlag = if ($Yes) { "-y" } else { "" }
    Write-Log "  Running: npx $yesFlag antigravity-awesome-skills $Flag"

    $output = if ($Yes) {
        & npx -y antigravity-awesome-skills $Flag 2>&1
    }
    else {
        & npx antigravity-awesome-skills $Flag 2>&1
    }
    foreach ($line in $output) {
        Write-Log "  $([string]$line)"
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Log "  Failed: exit code $LASTEXITCODE"
    }
    else {
        Write-Log "  Done."
    }
    Write-Log ""
}

# Check npx is available
$npxCommand = Get-Command -Name "npx" -ErrorAction SilentlyContinue
if (-not $npxCommand) {
    Write-Log "Error: npx was not found in PATH. Please install Node.js from https://nodejs.org/"
    Write-Log "===== Update stopped ====="
    exit 1
}

Write-Log "===== Start updating antigravity-awesome-skills ====="
Write-Log "Using: npx antigravity-awesome-skills (https://github.com/sickn33/antigravity-awesome-skills)"
Write-Log ""

$targets = @(
    @{ Flag = "--claude"; DisplayName = "Claude Code" }
    @{ Flag = "--cursor"; DisplayName = "Cursor" }
    @{ Flag = "--codex"; DisplayName = "Codex CLI" }
    @{ Flag = "--antigravity"; DisplayName = "Antigravity" }
)

Write-Log "Installing for $($targets.Count) target(s):"
Write-Log ""

foreach ($target in $targets) {
    try {
        Invoke-NpxInstall -Flag $target.Flag -DisplayName $target.DisplayName -Yes $Yes
    }
    catch {
        Write-Log "  Error: $($_.Exception.Message)"
        Write-Log ""
    }
}

Write-Log "Pick a bundle in docs/users/bundles.md and use @skill-name in your AI assistant."
Write-Log "===== All updates finished ====="
