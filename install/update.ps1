# update.ps1 — self-updater for the Affiliaters Deal Converter extension (Windows).
#
# Lives in install\ inside the extension folder. Updates the parent extension
# folder (wherever the user put it). Run by the scheduled task that install.bat
# registers (or manually: right-click -> Run with PowerShell). No git required.
#
# PowerShell parses the whole file before executing, so overwriting this script
# mid-run (during the sync) is safe — no relaunch trick needed.

$VersionUrl     = 'https://raw.githubusercontent.com/Affiliaters/chrome-extension/main/config/version.json'
$FallbackZipUrl = 'https://github.com/Affiliaters/chrome-extension/archive/refs/heads/main.zip'

$InstallDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ExtDir     = Split-Path -Parent $InstallDir
$LogFile    = Join-Path $ExtDir 'last-update.log'
$WorkDir    = $null

function Write-Log([string]$Message) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -Path $LogFile -Value $line
}

# Fresh log each run so it never grows unbounded.
Set-Content -Path $LogFile -Value ''
Write-Log "updater started (folder: $ExtDir, os: Windows)"

try {
    if (-not (Test-Path (Join-Path $ExtDir 'manifest.json'))) {
        Write-Log 'ERROR: no manifest.json in extension folder - aborting (folder moved or corrupted?)'
        exit 1
    }

    # Older Windows PowerShell defaults to TLS 1.0, which GitHub rejects.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $localManifest = Get-Content (Join-Path $ExtDir 'manifest.json') -Raw | ConvertFrom-Json
    $localVer = [string]$localManifest.version
    Write-Log "installed version: $localVer"

    try {
        $remote = Invoke-RestMethod -Uri $VersionUrl -TimeoutSec 30 -UseBasicParsing
    } catch {
        Write-Log 'version check failed (offline?) - will retry on next scheduled run'
        exit 0
    }

    $remoteVer = [string]$remote.latest_version
    $zipUrl = if ($remote.download_url) { [string]$remote.download_url } else { $FallbackZipUrl }
    Write-Log "latest version: $remoteVer"

    if (-not $remoteVer -or -not $localVer -or ([version]$localVer -ge [version]$remoteVer)) {
        Write-Log 'already up to date - nothing to do'
        exit 0
    }

    Write-Log "updating $localVer -> $remoteVer"
    $WorkDir = Join-Path $env:TEMP ("aff-update-" + [IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $WorkDir | Out-Null

    $zipPath = Join-Path $WorkDir 'ext.zip'
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -TimeoutSec 300 -UseBasicParsing

    $unzipDir = Join-Path $WorkDir 'unzipped'
    Expand-Archive -Path $zipPath -DestinationPath $unzipDir -Force

    # GitHub zips wrap everything in a "<repo>-<branch>\" folder — locate the
    # root by finding manifest.json rather than assuming the folder name.
    $srcManifest = Get-ChildItem -Path $unzipDir -Recurse -Filter 'manifest.json' -Depth 3 | Select-Object -First 1
    if (-not $srcManifest) {
        Write-Log 'ERROR: downloaded ZIP has no manifest.json - aborting'
        exit 1
    }
    $srcDir = $srcManifest.DirectoryName

    # Sync IN PLACE (never delete/recreate the folder — Chrome holds this path).
    Copy-Item -Path (Join-Path $srcDir '*') -Destination $ExtDir -Recurse -Force

    $newManifest = Get-Content (Join-Path $ExtDir 'manifest.json') -Raw | ConvertFrom-Json
    Write-Log ("updated to {0} - Chrome will switch over automatically (or on next browser restart)" -f $newManifest.version)
    exit 0
} catch {
    Write-Log ("ERROR: " + $_.Exception.Message)
    exit 1
} finally {
    if ($WorkDir -and (Test-Path $WorkDir)) {
        Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
