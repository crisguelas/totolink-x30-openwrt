# TOTOLINK X30 OpenWrt Custom Build & Flashing Guide

Custom OpenWrt firmware builder and installation tools for the **TOTOLINK X30** (STC Wi-Fi 6 Smart Mesh AX3000) on the MediaTek Filogic (MT7981B) platform.

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

## Repository Structure

```text
├── .github/workflows/
│   └── build.yml               # Automated GitHub Actions workflow to build firmware
├── config/
│   └── x30.config              # Custom OpenWrt seed configuration (Clean & Minimal)
├── patches/
│   ├── ad67960-mediatek-add-TOTOLINK-X30-support.patch   # Official upstream board patch
│   └── 0002-mediatek-filogic-add-totolink-x30-fit-upgrade.patch  # FIT sysupgrade patch
├── tools/
│   ├── set-static-ip.ps1       # 1-Click Ethernet configurator (192.168.1.254)
│   ├── restore-dhcp.ps1        # 1-Click DHCP & Wi-Fi restore
│   └── verify-firmware.ps1     # SHA256 checksum & file integrity verifier
```

---

## Flashing Instructions (Quick Summary)

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
