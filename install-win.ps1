param(
  [string]$Owner = "bthien235",
  [string]$Repo = "Tool_IECS",
  [string]$AssetName = "ZaloTool.exe",
  [string]$InstallDir = "$env:LOCALAPPDATA\ZaloTool"
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

if (-not (Test-Path $InstallDir)) {
  New-Item -Path $InstallDir -ItemType Directory | Out-Null
}

$url = Get-LatestReleaseAssetUrl -Owner $Owner -Repo $Repo -AssetName $AssetName
$target = Join-Path $InstallDir "ZaloTool.exe"

Write-Host "Downloading $url"
Invoke-WebRequest -Uri $url -OutFile $target -Headers @{ "User-Agent" = "ZaloToolInstaller" }
Unblock-File -Path $target -ErrorAction SilentlyContinue

Write-Host "Installed to: $target"
Write-Host "Run it with: $target"
