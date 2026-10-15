<#
.SYNOPSIS
    Configures the physical Ethernet adapter to 192.168.1.254 for OpenWrt TFTP recovery / flashing.
.DESCRIPTION
    1. Identifies physical Ethernet adapter (excluding Wi-Fi / Bluetooth / VirtualBox).
    2. Checks for active Wi-Fi and warns about potential 192.168.1.x subnet conflicts.
    3. Sets Static IP: 192.168.1.254 / Subnet Mask 255.255.255.0.
    4. Omits Default Gateway to prevent Windows internet routing confusion.
#>

# Requires Administrator privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsPrincipal]::Administrator)) {
    Write-Warning "This script requires Administrator privileges. Re-launching in an elevated window..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath)
    exit
}

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   OpenWrt Flashing Helper: Set Static IP (192.168.1.254)  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Identify Physical Ethernet Adapter
$ethAdapter = Get-NetAdapter -Physical | Where-Object { 
    $_.InterfaceDescription -notmatch "Wireless|Wi-Fi|Bluetooth|Virtual|VMware" 
} | Select-Object -First 1

if (-not $ethAdapter) {
    Write-Error "No physical Ethernet adapter found! Please ensure your Ethernet cable or USB-Ethernet adapter is connected."
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host "[+] Found Ethernet Adapter: $($ethAdapter.Name) ($($ethAdapter.InterfaceDescription))" -ForegroundColor Green

# 2. Check for active Wi-Fi connection
$wifiAdapter = Get-NetAdapter | Where-Object { $_.InterfaceDescription -match "Wireless|Wi-Fi" -and $_.Status -eq "Up" }
if ($wifiAdapter) {
    Write-Host ""
    Write-Warning "[!] An active Wi-Fi connection was detected ($($wifiAdapter.Name))."
    Write-Host "    If your home Wi-Fi also uses the 192.168.1.x subnet, TFTP flashing will fail due to routing conflict." -ForegroundColor Yellow
    $disableWifi = Read-Host "    Do you want to temporarily disable Wi-Fi during flashing? (Recommended) [Y/N]"
    if ($disableWifi -match "^[Yy]") {
        Disable-NetAdapter -Name $wifiAdapter.Name -Confirm:$false
        Write-Host "    [+] Wi-Fi temporarily disabled. Run restore-dhcp.ps1 when done to re-enable it." -ForegroundColor Green
    }
}

# 3. Apply Static IP (192.168.1.254 / 24)
Write-Host ""
Write-Host "[+] Configuring $($ethAdapter.Name) to 192.168.1.254 / 255.255.255.0 ..." -ForegroundColor Cyan

# Remove old IPs on this interface
Get-NetIPAddress -InterfaceAlias $ethAdapter.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue

# Set static IP (Leaving gateway blank prevents conflict)
New-NetIPAddress -InterfaceAlias $ethAdapter.Name -IPAddress "192.168.1.254" -PrefixLength 24 -ErrorAction SilentlyContinue | Out-Null

Write-Host "[✓] Successfully configured Ethernet adapter!" -ForegroundColor Green
Write-Host "    IP Address : 192.168.1.254" -ForegroundColor White
Write-Host "    Subnet Mask: 255.255.255.0 (/24)" -ForegroundColor White
Write-Host "    Gateway    : (None - Direct link)" -ForegroundColor White
Write-Host ""
Write-Host "You are now ready to launch Tftpd64 and bind to 192.168.1.254." -ForegroundColor Yellow
Write-Host "After flashing is complete, run 'restore-dhcp.ps1' to restore normal settings." -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter to finish..."
