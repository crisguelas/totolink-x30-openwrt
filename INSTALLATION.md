# TOTOLINK X30 / STC AX3000 OpenWrt Installation & Flashing Guide

This document is the definitive, step-by-step flashing manual for installing official OpenWrt 25.12.5 onto the **TOTOLINK X30 / STC AX3000 Smart Mesh Wi-Fi 6** router.

---

## Prerequisites Checklist

Before starting, confirm you have:
1. **USB-to-TTL Adapter:** Connected to router UART pins (`GND` -> `GND`, `RX` -> `TX`, `TX` -> `RX`). **No VCC connected.**
2. **COM Port:** Identified in Device Manager (e.g., `COM6`).
3. **Ethernet Cable:** Connected between laptop Ethernet port and any **LAN port (1, 2, 3, or 4)** of the router.
4. **Compiled Files:** Verified in `d:\web-dev\openwrt\tftp\`:
   - `openwrt-mediatek-filogic-totolink_X30-bl31-uboot.fip` (Bootloader)
   - `openwrt-mediatek-filogic-totolink_X30-squashfs-sysupgrade.bin` (Firmware)
   - `tftpd64.exe` (Portable TFTP server)

---

## Step 1: Configure Laptop Static IP (`192.168.1.254`)

The router's bootloader expects your computer to be at `192.168.1.254`.

1. Open **PowerShell as Administrator**.
2. Run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File d:\web-dev\openwrt\tools\set-static-ip.ps1
   ```
3. Your Ethernet adapter is now set to `192.168.1.254 / 255.255.255.0`. *(Your Wi-Fi remains active).*

---

## Step 2: Launch TFTP Server

1. Open File Explorer to `d:\web-dev\openwrt\tftp\`.
2. Double-click **`tftpd64.exe`**.
3. If a Windows Defender Firewall popup appears:
   - Check **both** Private and Public networks.
   - Click **Allow access**.
4. Confirm the window displays:
   - **Current Directory:** `D:\web-dev\openwrt\tftp`
   - **Server interfaces:** `192.168.1.254` *(automatically pre-configured)*
5. **Leave Tftpd64 open in the background.**

---

## Step 3: Connect PuTTY Serial Console

1. Open **PuTTY**.
2. Select **Serial** connection type.
3. Configure settings:
   - **Serial line:** `COM6` *(or your adapter's COM port)*
   - **Speed:** `115200`
   - **Data bits:** `8`
   - **Stop bits:** `1`
   - **Parity:** `None`
   - **Flow control:** `None`
4. Click **Open** to bring up the black terminal window.

---

## Step 4: Freeze Stock U-Boot Menu & Flash Bootloader (`.fip`)

1. With the PuTTY window active, **unplug the router power barrel plug and plug it back in**.
2. Immediately press the **Up / Down arrow keys** repeatedly inside PuTTY until the countdown stops.
3. You will see the factory bootloader menu:
   ```text
   *** U-Boot Boot Menu ***
      1. Startup system (Default)
      2. Upgrade firmware
      3. Upgrade ATF FIP
      4. Upgrade ATF BL2
      ...
   ```
4. Use the arrow keys (or type the number) to select:
   ```text
   Upgrade ATF FIP
   ```
   and press **Enter**.
5. When prompted for filename:
   - If it displays a default filename or prompts:
     ```text
     openwrt-mediatek-filogic-totolink_X30-bl31-uboot.fip
     ```
   - Enter `openwrt-mediatek-filogic-totolink_X30-bl31-uboot.fip` and press **Enter**.
6. **Watch Tftpd64:** A small progress bar will flash across Tftpd64 as the file transfers (~1 second).
7. In PuTTY, U-Boot will write the FIP to SPI-NAND flash and display:
   ```text
   Success! / Done
   ```

---

## Step 5: Reboot into OpenWrt U-Boot & Flash Firmware (`.bin`)

1. **Unplug the router power jack, wait 3 seconds, and plug it back in.**
2. Immediately press the **Up / Down arrow keys** in PuTTY again.
3. You will now see the new **OpenWrt U-Boot Menu**:
   ```text
   *** OpenWrt U-Boot Boot Menu ***
      1. Startup system (Default)
      2. Load production system via TFTP then write to NAND
      3. Load recovery system via TFTP then write to NAND
      4. Load initramfs image via TFTP and boot
      ...
   ```
4. Select:
   ```text
   Load production system via TFTP then write to NAND
   ```
   and press **Enter**.
5. When prompted for filename:
   - Type or confirm:
     ```text
     openwrt-mediatek-filogic-totolink_X30-squashfs-sysupgrade.bin
     ```
   - Press **Enter**.
6. **Watch Tftpd64:** You will see the ~11 MB file transferring over Ethernet (takes ~5–10 seconds).
7. PuTTY will show:
   - Erasing NAND...
   - Writing NAND...
   - Verifying...
   - **Success!**
8. The router will automatically reboot (or select option `1. Startup system`).

---

## Step 6: First Boot & Access OpenWrt Web Interface (LuCI)

1. Watch PuTTY: You will see the Linux 6.6 kernel boot messages, followed by the OpenWrt banner:
   ```text
    _______                     ________        __
   |       |.-----.-----.-----.|  |  |  |.----.|  |_
   |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
   |_______||   __|_____|__|__||________||__|  |____|
            |__| W I R E L E S S   F R E E D O M
   -----------------------------------------------------
   OpenWrt 25.12.5, r0-xxxxxxxx
   -----------------------------------------------------
   ```
2. When the logs stop scrolling and you see `Please press Enter to activate this console`, press **Enter** to get a root shell.
3. **Restore your laptop's network:**
   Open PowerShell as Administrator and run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File d:\web-dev\openwrt\tools\restore-dhcp.ps1
   ```
4. Your laptop will receive an automatic DHCP IP address (e.g., `192.168.1.150`).
5. Open your web browser and navigate to:
   👉 **`http://192.168.1.1`** (or `https://192.168.1.1`)
6. **First Login:**
   - **Username:** `root`
   - **Password:** *(leave blank / empty)*
   - Click **Log in**.
7. Navigate to **System $\rightarrow$ Administration** and set a strong router password!

---

## 🎉 Finished! Put Away the Screwdriver

OpenWrt is now permanently installed:
* You can safely disconnect the USB-to-TTL serial wires.
* Close and screw the router's plastic casing back together.
* For all future updates, simply upload the new `.bin` file via **System $\rightarrow$ Backup / Flash Firmware** from your browser!
