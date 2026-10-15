<#
.SYNOPSIS
    Restores Ethernet adapter back to automatic DHCP and re-enables Wi-Fi.
#>

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsPrincipal]::Administrator)) {
    Write-Warning "This script requires Administrator privileges. Re-launching in an elevated window..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath)
    exit
}

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     OpenWrt Helper: Restore Normal Network Settings      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Identify Physical Ethernet Adapter
$ethAdapter = Get-NetAdapter -Physical | Where-Object { 
    $_.InterfaceDescription -notmatch "Wireless|Wi-Fi|Bluetooth|Virtual|VMware" 
} | Select-Object -First 1

if ($ethAdapter) {
    Write-Host "[+] Restoring Ethernet adapter ($($ethAdapter.Name)) to automatic DHCP..." -ForegroundColor Cyan
    Set-NetIPInterface -InterfaceAlias $ethAdapter.Name -Dhcp Enabled -ErrorAction SilentlyContinue
    Set-DnsClientServerAddress -InterfaceAlias $ethAdapter.Name -ResetServerAddresses -ErrorAction SilentlyContinue
    Write-Host "[✓] Ethernet restored to Automatic (DHCP)." -ForegroundColor Green
} else {
    Write-Warning "No physical Ethernet adapter found."
}

# 2. Re-enable Wi-Fi if it was disabled
$disabledWifi = Get-NetAdapter | Where-Object { $_.InterfaceDescription -match "Wireless|Wi-Fi" -and $_.Status -eq "Disabled" }
if ($disabledWifi) {
    Write-Host "[+] Re-enabling Wi-Fi adapter ($($disabledWifi.Name))..." -ForegroundColor Cyan
    Enable-NetAdapter -Name $disabledWifi.Name -Confirm:$false
    Write-Host "[✓] Wi-Fi adapter re-enabled." -ForegroundColor Green
}

Write-Host ""
Write-Host "[✓] All network adapters restored to normal defaults!" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to finish..."
