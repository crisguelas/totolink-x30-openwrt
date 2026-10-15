#Requires -Version 5.1
<#
.SYNOPSIS
    Downloads official TOTOLINK X30 OpenWrt build artifacts from GitHub Releases into the tftp folder.
.DESCRIPTION
    Queries https://api.github.com/repos/crisguelas/totolink-x30-openwrt/releases/latest,
    downloads the bootloader (.fip), sysupgrade image (.bin), recovery image, and SHA256SUMS.txt.
#>

[CmdletBinding()]
param(
    [string]$Repo = "crisguelas/totolink-x30-openwrt",
    [string]$TargetDir = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($TargetDir)) {
    $TargetDir = Join-Path (Split-Path $PSScriptRoot -Parent) "tftp"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " TOTOLINK X30 OpenWrt Firmware Downloader" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$ResolvedTarget = [System.IO.Path]::GetFullPath($TargetDir)
if (-not (Test-Path -Path $ResolvedTarget)) {
    New-Item -ItemType Directory -Path $ResolvedTarget -Force | Out-Null
}

Write-Host "`n[1/3] Querying GitHub Releases for $Repo..." -ForegroundColor Yellow
$Uri = "https://api.github.com/repos/$Repo/releases/latest"
try {
    $Release = Invoke-RestMethod -Uri $Uri -Headers @{ "User-Agent" = "PowerShell-Downloader" }
} catch {
    Write-Error "Failed to fetch releases from $($Uri): $_"
    exit 1
}

Write-Host "Latest Release: $($Release.name) ($($Release.tag_name))" -ForegroundColor Green
Write-Host "Published At  : $($Release.published_at)" -ForegroundColor Gray

Write-Host "`n[2/3] Downloading Artifacts into $ResolvedTarget..." -ForegroundColor Yellow
foreach ($Asset in $Release.assets) {
    $DestFile = Join-Path $ResolvedTarget $Asset.name
    Write-Host "  -> Downloading $($Asset.name) ($([math]::Round($Asset.size / 1MB, 2)) MB)..." -NoNewline
    Invoke-WebRequest -Uri $Asset.browser_download_url -OutFile $DestFile
    Write-Host " [OK]" -ForegroundColor Green
}

Write-Host "`n[3/3] Files in $($ResolvedTarget):" -ForegroundColor Yellow
Get-ChildItem -Path $ResolvedTarget | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize

Write-Host "`nDownload complete! You can now run tools\verify-firmware.ps1 to verify integrity." -ForegroundColor Green
