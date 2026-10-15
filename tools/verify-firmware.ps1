#Requires -Version 5.1
<#
.SYNOPSIS
    Verifies firmware files for TOTOLINK X30, computing SHA256 hashes and validating required file names for U-Boot.
#>

[CmdletBinding()]
param (
    [string]$Directory = ""
)

if ([string]::IsNullOrWhiteSpace($Directory)) {
    $Directory = Join-Path (Split-Path $PSScriptRoot -Parent) "tftp"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     OpenWrt TOTOLINK X30 Firmware Integrity Verifier      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$resolvedDir = [System.IO.Path]::GetFullPath($Directory)
Write-Host "Checking directory: $resolvedDir" -ForegroundColor White
Write-Host ""

$files = @(Get-ChildItem -Path $resolvedDir -Filter "*.bin" -ErrorAction SilentlyContinue)
$files += @(Get-ChildItem -Path $resolvedDir -Filter "*.fip" -ErrorAction SilentlyContinue)

if ($files.Count -eq 0) {
    Write-Warning "No .bin or .fip firmware files found in $resolvedDir!"
    Write-Host "Place your compiled firmware files in this directory and re-run." -ForegroundColor Yellow
    exit 0
}

$expectedFip = "openwrt-mediatek-filogic-totolink_X30-bl31-uboot.fip"
$expectedBin = "openwrt-mediatek-filogic-totolink_X30-squashfs-sysupgrade.bin"

$foundFip = $false
$foundBin = $false

foreach ($file in $files) {
    $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash.ToLower()
    $sizeMB = [math]::Round($file.Length / 1MB, 2)
    
    Write-Host "File  : $($file.Name)" -ForegroundColor Green
    Write-Host "Size  : $($file.Length) bytes ($sizeMB MB)" -ForegroundColor White
    Write-Host "SHA256: $hash" -ForegroundColor Cyan
    
    if ($file.Name -eq $expectedFip) {
        $foundFip = $true
        Write-Host "  -> Matches expected U-Boot FIP name [OK]" -ForegroundColor Green
    } elseif ($file.Name -eq $expectedBin) {
        $foundBin = $true
        Write-Host "  -> Matches expected Sysupgrade NAND name [OK]" -ForegroundColor Green
    } else {
        Write-Host "  -> Optional / Recovery image" -ForegroundColor Gray
    }
    Write-Host ""
}

# Check against SHA256SUMS.txt if present
$sumsFile = Join-Path $resolvedDir "SHA256SUMS.txt"
if (Test-Path $sumsFile) {
    Write-Host "Validating against SHA256SUMS.txt..." -ForegroundColor Yellow
    $expectedSums = Get-Content $sumsFile
    foreach ($line in $expectedSums) {
        if ($line -match '^([a-fA-F0-9]{64})\s+\*?(.+)$') {
            $expectedHash = $matches[1].ToLower()
            $fileName = $matches[2].Trim()
            $targetPath = Join-Path $resolvedDir $fileName
            if (Test-Path $targetPath) {
                $actualHash = (Get-FileHash -Path $targetPath -Algorithm SHA256).Hash.ToLower()
                if ($actualHash -eq $expectedHash) {
                    Write-Host "  [MATCH] $fileName" -ForegroundColor Green
                } else {
                    Write-Host "  [MISMATCH!] $fileName" -ForegroundColor Red
                }
            }
        }
    }
    Write-Host ""
}

Write-Host "----------------------------------------------------------" -ForegroundColor Gray
if ($foundFip -and $foundBin) {
    Write-Host "[OK] All required flashing files are present with correct naming!" -ForegroundColor Green
} else {
    Write-Warning "[!] Missing one or more required files for flashing:"
    if (-not $foundFip) { Write-Host "    - Missing: $expectedFip" -ForegroundColor Red }
    if (-not $foundBin) { Write-Host "    - Missing: $expectedBin" -ForegroundColor Red }
}
Write-Host ""
