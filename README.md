# TOTOLINK X30 OpenWrt Custom Build & Flashing Guide

Custom OpenWrt firmware builder and installation tools for the **TOTOLINK X30** (STC Wi-Fi 6 Smart Mesh AX3000) on the MediaTek Filogic (MT7981B) platform.

Current Target Release: **OpenWrt 25.12.5 (Stable)**

[![Latest Release](https://img.shields.io/github/v/release/crisguelas/totolink-x30-openwrt?include_prereleases&label=Latest%20Release&logo=github)](https://github.com/crisguelas/totolink-x30-openwrt/releases)
[![Build Status](https://img.shields.io/github/actions/workflow/status/crisguelas/totolink-x30-openwrt/build.yml?branch=main&label=Build%20Status)](https://github.com/crisguelas/totolink-x30-openwrt/actions)

> 📥 **Download Ready-to-Flash Firmware:**  
> Pre-compiled `.fip` bootloader and `sysupgrade.bin` images are published on the **[GitHub Releases Page](https://github.com/crisguelas/totolink-x30-openwrt/releases)**.

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
    └── verify-firmware.ps1     # SHA256 checksum & file integrity verifier
```

---

## Pre-Flashing Checklist & Requirements

Before starting the installation, ensure you have the following ready:

#### 1. Hardware Needed:
- **TOTOLINK X30 / STC AX3000** router + 12V power adapter.
- **USB-to-TTL Adapter** (3.3V logic level, PL2303 / CP2102 / CH340 / FT232).
- **3x Female-to-Female Jumper Wires** connecting adapter to router UART (`GND` $\rightarrow$ `GND`, `RX` $\rightarrow$ `TX`, `TX` $\rightarrow$ `RX`). **Do NOT connect VCC.**
- **RJ45 Ethernet Cable** connecting your computer to any router **LAN port** (1, 2, 3, or 4).

#### 2. Software Needed:
- **PuTTY** (or serial terminal emulator, configured for `115200` baud, `8-N-1`).
- **Tftpd64** (portable TFTP server, located in `tftp/tftpd64.exe`).

#### 3. Files Needed (in `tftp/` directory or from [Releases](https://github.com/crisguelas/totolink-x30-openwrt/releases)):
- `openwrt-mediatek-filogic-totolink_X30-bl31-uboot.fip` (OpenWrt U-Boot Bootloader)
- `openwrt-mediatek-filogic-totolink_X30-squashfs-sysupgrade.bin` (OpenWrt System Firmware)

---

## Future Upgrades (No Disassembly Needed!)

Once OpenWrt is running on your TOTOLINK X30, you **never need to open the case, touch UART, or use TFTP again**:

1. **Automated Cloud Builds:** When OpenWrt releases a new version (e.g., 25.12.6 or future releases), go to the **Actions** tab on GitHub and click **Run workflow**. It will automatically compile the newest release using your recipe.
2. **Web Sysupgrade:** Download the newly compiled `openwrt-...-sysupgrade.bin` file, open your browser to `http://192.168.1.1`, navigate to **System $\rightarrow$ Backup / Flash Firmware**, upload the image, and click **Flash**!
