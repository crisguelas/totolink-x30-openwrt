# TOTOLINK X30 OpenWrt Custom Build & Flashing Guide

Custom OpenWrt firmware builder and installation tools for the **TOTOLINK X30** (STC Wi-Fi 6 Smart Mesh AX3000) on the MediaTek Filogic (MT7981B) platform.

Current Target Release: **OpenWrt 25.12.5 (Stable)**

[![Latest Release](https://img.shields.io/github/v/release/crisguelas/totolink-x30-openwrt?include_prereleases&label=Latest%20Release&logo=github)](https://github.com/crisguelas/totolink-x30-openwrt/releases)
[![Build Status](https://img.shields.io/github/actions/workflow/status/crisguelas/totolink-x30-openwrt/build.yml?branch=main&label=Build%20Status)](https://github.com/crisguelas/totolink-x30-openwrt/actions)

> 📥 **Download Ready-to-Flash Firmware:**  
> Pre-compiled `.fip` bootloader and `sysupgrade.bin` images are published on the **[GitHub Releases Page](https://github.com/crisguelas/totolink-x30-openwrt/releases)**.

---

## Downloads & GitHub Releases

You can download pre-compiled firmware directly from GitHub without compiling:

👉 **[Go to Releases (Download .fip & .bin)](https://github.com/crisguelas/totolink-x30-openwrt/releases)**

### How to Find Releases Manually on GitHub:
1. Open the repository: [github.com/crisguelas/totolink-x30-openwrt](https://github.com/crisguelas/totolink-x30-openwrt)
2. In the **right-hand sidebar** on desktop (or scrolled down on mobile), look for **Releases**.
3. Click on the latest release tag (e.g. `TOTOLINK X30 OpenWrt 25.12.5`).
4. Under **Assets**, click to download:
   - `openwrt-...-bl31-uboot.fip` (Bootloader for initial flash)
   - `openwrt-...-squashfs-sysupgrade.bin` (Firmware for initial flash & future web updates)

---

## Hardware Specifications

| Component | Specification |
| :--- | :--- |
| **Model** | TOTOLINK X30 / STC AX3000 Smart Mesh |
| **SoC** | MediaTek MT7981B (Filogic 820) Dual-Core ARM Cortex-A53 @ 1.3 GHz |
| **RAM** | 256 MB DDR3 |
| **Flash** | 128 MB SPI-NAND |
| **Switch** | MediaTek MT7531 (5x Gigabit Ethernet: 4x LAN, 1x WAN) |
| **Wireless** | MediaTek MT7976CN (Wi-Fi 6 802.11ax 2x2 2.4 GHz & 3x3 5 GHz) |

---

## OpenWrt 25.12.5 Highlights for MediaTek Filogic

- **Linux Kernel 6.6 LTS:** Enhanced stability, power efficiency, and security patches.
- **Wi-Fi 6 & WPA3:** Native MT7976C / MT7915 wireless driver optimizations with full WPA3-SAE encryption support.
- **Firewall4 & nftables:** High-throughput hardware offloading for full gigabit routing at minimal CPU usage.
- **Modern Package System:** Includes support for `apk` package management alongside standard `opkg`.
- **Responsive LuCI:** Clean, modern web interface with SSL/TLS encryption.

---

## Built-in Packages & Clean Philosophy

Unlike third-party images or community builders that bake in unnecessary bloat, third-party VPN accounts, or background telemetry, this repository follows a **strict, minimal, and bloat-free philosophy**. You get a pure, high-performance OpenWrt foundation with only essential, audited components:

- **LuCI Web Interface (`luci`, `luci-ssl`):** The official OpenWrt web interface with HTTPS encryption enabled out of the box for secure web browser management (`https://192.168.1.1`).
- **Wi-Fi 6 Hardware Drivers (`kmod-mt7915e`, `kmod-mt7981-firmware`, `mt7981-wo-firmware`):** Official MediaTek radio drivers and wireless offload firmware, unlocking full AX3000 dual-band speeds with WPA3 encryption.
- **SSL Certificates & Internet Tools (`ca-bundle`, `ca-certificates`, `curl`):** Internet SSL root authority certificates and `curl`. This ensures your router can immediately and securely connect to HTTPS websites and download packages without SSL errors.
- **Terminal Editor (`nano`):** A friendly, easy-to-use command-line text editor for editing configs over SSH without needing to memorize `vi` commands.

> **Maximum Free Flash Storage:** By avoiding bloatware, your router retains nearly **~95 MB of free NAND flash storage**, giving you plenty of space to install whatever extra packages you want later on directly through the web interface (**System $\rightarrow$ Software**).

---

## Repository Structure

```text
├── .github/workflows/
│   └── build.yml               # Automated GitHub Actions workflow to build firmware
├── INSTALLATION.md             # Complete step-by-step PuTTY to OpenWrt installation guide
├── config/
│   └── x30.config              # Custom OpenWrt seed configuration (Clean & Minimal)
├── patches/
│   ├── ad67960-mediatek-add-TOTOLINK-X30-support.patch   # Official upstream board patch
│   └── 0002-mediatek-filogic-add-totolink-x30-fit-upgrade.patch  # FIT sysupgrade patch
└── tools/
    ├── download-firmware.ps1   # 1-Click firmware downloader from GitHub Releases
    ├── set-static-ip.ps1       # 1-Click Ethernet configurator (192.168.1.254)
    ├── restore-dhcp.ps1        # 1-Click DHCP & Wi-Fi restore
    └── verify-firmware.ps1     # SHA256 checksum & file integrity verifier
```

---

## Initial Flashing Instructions

For the complete, detailed step-by-step walkthrough from PuTTY setup to first login, see:  
👉 **[INSTALLATION.md](file:///d:/web-dev/openwrt/INSTALLATION.md)**

### Quick Summary:

1. **Hardware Connection:**
   - Connect USB-to-TTL (3.3V) to router UART (`GND` -> `GND`, `RX` -> `TX`, `TX` -> `RX`). Do **NOT** connect VCC.
   - Connect PC to router LAN port via Ethernet cable.
2. **Identify COM Port:**
   - Press `Win + R`, type `devmgmt.msc`, and press Enter to open **Device Manager**.
   - Expand **Ports (COM & LPT)** to find the assigned port for your USB-to-TTL adapter (e.g. `COM3`, `COM4`, `COM6`).
3. **Serial Console:**
   - Open PuTTY: Select Connection type `Serial`, enter your Serial line (e.g. `COM6`), and set Speed to `115200`.
4. **Network Configuration:**
   - Run `tools/set-static-ip.ps1` to set PC Ethernet to `192.168.1.254`.
5. **TFTP Server:**
   - Run Tftpd64 bound to `192.168.1.254` serving the built `.fip` and `sysupgrade.bin` files.
6. **Flash Step 1 (Bootloader):**
   - In U-Boot menu, select `Upgrade ATF FIP` and flash `openwrt-mediatek-filogic-totolink_X30-bl31-uboot.fip`. Reboot.
7. **Flash Step 2 (Firmware):**
   - In the new OpenWrt U-Boot menu, select `Load production system via TFTP then write to NAND` and flash `openwrt-mediatek-filogic-totolink_X30-squashfs-sysupgrade.bin`.
8. **First Login:**
   - Run `tools/restore-dhcp.ps1`, open browser to `http://192.168.1.1`, login with `root` (no password) and set a new password.

---

## Future Upgrades (No Disassembly Needed!)

Once OpenWrt is running on your TOTOLINK X30, you **never need to open the case, touch UART, or use TFTP again**:

1. **Automated Cloud Builds:** When OpenWrt releases a new version (e.g., 25.12.6 or future releases), go to the **Actions** tab on GitHub and click **Run workflow**. It will automatically compile the newest release using your recipe.
2. **Web Sysupgrade:** Download the newly compiled `openwrt-...-sysupgrade.bin` file, open your browser to `http://192.168.1.1`, navigate to **System $\rightarrow$ Backup / Flash Firmware**, upload the image, and click **Flash**!
