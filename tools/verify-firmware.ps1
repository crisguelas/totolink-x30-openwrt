<#
.SYNOPSIS
    Verifies firmware files for TOTOLINK X30, computing SHA256 hashes and validating required file names for U-Boot.
#>

param (
    [string]$Directory = "$PSScriptRoot\..\tftp"
)

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     OpenWrt TOTOLINK X30 Firmware Integrity Verifier      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$resolvedDir = Resolve-Path $Directory -ErrorAction SilentlyContinue
if (-not $resolvedDir) {
    $resolvedDir = $Directory
}

Write-Host "Checking directory: $resolvedDir" -ForegroundColor White
Write-Host ""

$files = Get-ChildItem -Path $resolvedDir -Filter "*.bin" -ErrorAction SilentlyContinue
$files += Get-ChildItem -Path $resolvedDir -Filter "*.fip" -ErrorAction SilentlyContinue

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
    $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
    $sizeMB = [math]::Round($file.Length / 1MB, 2)
    
    Write-Host "File : $($file.Name)" -ForegroundColor Green
    Write-Host "Size : $($file.Length) bytes ($sizeMB MB)" -ForegroundColor White
    Write-Host "SHA256: $hash" -ForegroundColor Cyan
    
    if ($file.Name -eq $expectedFip) {
        $foundFip = $true
        Write-Host "  -> Matches expected U-Boot FIP name [OK]" -ForegroundColor Green
    } elseif ($file.Name -eq $expectedBin) {
        $foundBin = $true
        Write-Host "  -> Matches expected Sysupgrade NAND name [OK]" -ForegroundColor Green
    } else {
        Write-Warning "  -> Non-standard file name! U-Boot looks specifically for:"
        Write-Warning "     '$expectedFip' or '$expectedBin'"
    }
    Write-Host ""
}

Write-Host "----------------------------------------------------------" -ForegroundColor Gray
if ($foundFip -and $foundBin) {
    Write-Host "[✓] All required flashing files are present with correct naming!" -ForegroundColor Green
} else {
    Write-Warning "[!] Missing one or more required files for flashing:"
    if (-not $foundFip) { Write-Host "    - Missing: $expectedFip" -ForegroundColor Red }
    if (-not $foundBin) { Write-Host "    - Missing: $expectedBin" -ForegroundColor Red }
}
Write-Host ""
