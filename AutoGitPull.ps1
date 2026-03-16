$utf8 = [System.Text.UTF8Encoding]::new($false)
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

$repoPath = $PSScriptRoot
$logFile = Join-Path $repoPath "logs\AutoGitPull.log"
$logDir = Split-Path -Parent $logFile
$repoUrl = "https://github.com/sickn33/antigravity-awesome-skills.git"
$runId = Get-Date -Format "yyyyMMdd-HHmmss"

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

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Test-IsDirectory {
    param([string]$Path)

    return Test-Path -LiteralPath $Path -PathType Container
}

function Move-ToBackup {
    param(
        [string]$Path,
        [string]$Reason
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    $parent = Split-Path -Parent $Path
    $name = Split-Path -Leaf $Path
    $backupName = "{0}.__backup__.{1}" -f $name, $runId
    $backupPath = Join-Path $parent $backupName
    $index = 1

    while (Test-Path -LiteralPath $backupPath) {
        $backupName = "{0}.__backup__.{1}.{2}" -f $name, $runId, $index
        $backupPath = Join-Path $parent $backupName
        $index++
    }

    Move-Item -LiteralPath $Path -Destination $backupPath -Force
    Write-Log "Backed up: $Path -> $backupPath ($Reason)"
}

function Sync-Path {
    param(
        [string]$Source,
        [string]$Destination
    )

    $sourceIsDirectory = Test-IsDirectory -Path $Source
    $destinationExists = Test-Path -LiteralPath $Destination

    if ($destinationExists) {
        $destinationIsDirectory = Test-IsDirectory -Path $Destination
        if ($sourceIsDirectory -ne $destinationIsDirectory) {
            Move-ToBackup -Path $Destination -Reason "type-conflict"
            $destinationExists = $false
        }
    }

    if ($sourceIsDirectory) {
        Ensure-Directory -Path $Destination
        Sync-DirectoryContents -SourceDir $Source -DestinationDir $Destination
        return
    }

    Ensure-Directory -Path (Split-Path -Parent $Destination)
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

function Sync-DirectoryContents {
    param(
        [string]$SourceDir,
        [string]$DestinationDir
    )

    Ensure-Directory -Path $DestinationDir

    $sourceItems = @(Get-ChildItem -LiteralPath $SourceDir -Force)
    $sourceMap = @{}

    foreach ($item in $sourceItems) {
        if ($item.Name -eq ".git") {
            continue
        }
        $sourceMap[$item.Name] = $true
    }

    $destinationItems = @(Get-ChildItem -LiteralPath $DestinationDir -Force -ErrorAction SilentlyContinue)
    foreach ($item in $destinationItems) {
        if ($item.Name -like ".__backup__.*" -or $item.Name -match "\.__backup__\.") {
            continue
        }
        if (-not $sourceMap.ContainsKey($item.Name)) {
            Move-ToBackup -Path $item.FullName -Reason "removed-in-latest"
        }
    }

    foreach ($item in $sourceItems) {
        if ($item.Name -eq ".git") {
            continue
        }
        Sync-Path -Source $item.FullName -Destination (Join-Path $DestinationDir $item.Name)
    }
}

function Install-RepoToTarget {
    param(
        [string]$SourceRoot,
        [string]$TargetPath,
        [string]$DisplayName
    )

    Write-Log "${DisplayName}:"
    if (Test-Path -LiteralPath $TargetPath) {
        Write-Log "  Updating existing install at $TargetPath..."
    } else {
        Write-Log "  Creating install at $TargetPath..."
    }

    Ensure-Directory -Path $TargetPath

    $repoSkills = Join-Path $SourceRoot "skills"
    if (-not (Test-Path -LiteralPath $repoSkills)) {
        throw "Cloned repo has no skills directory."
    }

    Sync-DirectoryContents -SourceDir $repoSkills -DestinationDir $TargetPath

    $repoDocs = Join-Path $SourceRoot "docs"
    if (Test-Path -LiteralPath $repoDocs) {
        Sync-Path -Source $repoDocs -Destination (Join-Path $TargetPath "docs")
    }

    Write-Log "Installed to $TargetPath"
}

$targets = @(
    @{ Name = "Cursor"; TargetPath = (Join-Path $HOME ".cursor\skills") }
    @{ Name = "Antigravity"; TargetPath = (Join-Path $HOME ".gemini\antigravity\skills") }
    @{ Name = "Codex CLI"; TargetPath = (Join-Path $HOME ".codex\skills") }
)

if (-not (Test-Path (Join-Path $repoPath ".git"))) {
    Write-Log "Warning: $repoPath is not a Git repository. Continue anyway."
}

Set-Location -Path $repoPath
Write-Log "===== Start updating antigravity-awesome-skills ====="
Write-Log "Source repository: $repoUrl"

$gitCommand = Get-Command -Name "git.exe" -ErrorAction SilentlyContinue
if (-not $gitCommand) {
    $gitCommand = Get-Command -Name "git" -ErrorAction SilentlyContinue
}

if (-not $gitCommand) {
    Write-Log "Error: git was not found in PATH."
    Write-Log "===== Update stopped ====="
    exit 1
}

$gitPath = $gitCommand.Source
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("ag-skills-" + [guid]::NewGuid().ToString("N"))
$tempRepo = Join-Path $tempRoot "repo"

try {
    Ensure-Directory -Path $tempRoot
    Write-Log "Cloning latest repository..."
    $cloneOutput = & $gitPath clone --depth 1 $repoUrl $tempRepo 2>&1
    foreach ($line in $cloneOutput) {
        Write-Log ([string]$line)
    }

    if ($LASTEXITCODE -ne 0) {
        throw "git clone failed with exit code $LASTEXITCODE"
    }

    Write-Log ""
    Write-Log "Installing for $($targets.Count) target(s):"
    Write-Log ""

    foreach ($target in $targets) {
        try {
            Install-RepoToTarget -SourceRoot $tempRepo -TargetPath $target.TargetPath -DisplayName $target.Name
            Write-Log ""
        } catch {
            Write-Log "  Failed: $($target.Name) - $($_.Exception.Message)"
            Write-Log ""
        }
    }

    Write-Log "Pick a bundle in docs/users/bundles.md and use @skill-name in your AI assistant."
    Write-Log "===== All updates finished ====="
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
