param(
  [string]$Owner = "bthien235",
  [string]$Repo = "Tool_IECS",
  [string]$AssetName = "ZaloTool.exe",
  [string]$InstallDir = "$env:LOCALAPPDATA\ZaloTool",
  [switch]$NoDesktopShortcut,
  [switch]$NoStartMenuShortcut
)

$ErrorActionPreference = "Stop"

function Get-LatestReleaseAssetUrl {
  param(
    [string]$Owner,
    [string]$Repo,
    [string]$AssetName
  )

  $api = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
  $resp = Invoke-RestMethod -Uri $api -Headers @{ "User-Agent" = "ZaloToolInstaller" }
  if (-not $resp.assets) {
    throw "No assets found in latest release"
  }

  $asset = $resp.assets | Where-Object { $_.name -eq $AssetName } | Select-Object -First 1
  if (-not $asset) {
    $names = ($resp.assets | ForEach-Object { $_.name }) -join ", "
    throw "Asset '$AssetName' not found. Available: $names"
  }

  return $asset.browser_download_url
}

function New-AppShortcut {
  param(
    [Parameter(Mandatory = $true)][string]$ShortcutPath,
    [Parameter(Mandatory = $true)][string]$TargetPath
  )

  $shell = New-Object -ComObject WScript.Shell
  $shortcut = $shell.CreateShortcut($ShortcutPath)
  $shortcut.TargetPath = $TargetPath
  $shortcut.WorkingDirectory = Split-Path -Path $TargetPath -Parent
  $shortcut.IconLocation = "$TargetPath,0"
  $shortcut.Save()
}

if (-not (Test-Path $InstallDir)) {
  New-Item -Path $InstallDir -ItemType Directory | Out-Null
}

$url = Get-LatestReleaseAssetUrl -Owner $Owner -Repo $Repo -AssetName $AssetName
$target = Join-Path $InstallDir "ZaloTool.exe"

Write-Host "Downloading $url"
Invoke-WebRequest -Uri $url -OutFile $target -Headers @{ "User-Agent" = "ZaloToolInstaller" }
Unblock-File -Path $target -ErrorAction SilentlyContinue

$desktopLink = Join-Path ([Environment]::GetFolderPath("Desktop")) "ZaloTool.lnk"
$startMenuDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\ZaloTool"
$startMenuLink = Join-Path $startMenuDir "ZaloTool.lnk"

if (-not $NoDesktopShortcut) {
  New-AppShortcut -ShortcutPath $desktopLink -TargetPath $target
  Write-Host "Desktop shortcut: $desktopLink"
}

if (-not $NoStartMenuShortcut) {
  if (-not (Test-Path $startMenuDir)) {
    New-Item -Path $startMenuDir -ItemType Directory | Out-Null
  }
  New-AppShortcut -ShortcutPath $startMenuLink -TargetPath $target
  Write-Host "Start Menu shortcut: $startMenuLink"
}

Write-Host "Installed to: $target"
Write-Host "Run it with: $target"
