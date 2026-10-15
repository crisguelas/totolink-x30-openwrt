#!/usr/bin/env bash
# ==============================================================================
# OpenWrt Local Build Script for TOTOLINK X30
# Run this inside Ubuntu (WSL2 or Native Linux)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build/openwrt-build"
OUT_DIR="$PROJECT_ROOT/tftp"
PATCH_FILE="$PROJECT_ROOT/patches/ad67960-mediatek-add-TOTOLINK-X30-support.patch"
CONFIG_FILE="$PROJECT_ROOT/config/x30.config"

# OpenWrt Git Branch / Tag to build from
OPENWRT_TAG="openwrt-23.05" # or main / master / v23.05.5

echo "=========================================================="
echo "   Building OpenWrt for TOTOLINK X30 (MT7981B / Filogic)  "
echo "=========================================================="
echo "Project Root : $PROJECT_ROOT"
echo "Target Tag   : $OPENWRT_TAG"
echo "Patch File   : $PATCH_FILE"
echo "Config File  : $CONFIG_FILE"
echo "Output Dir   : $OUT_DIR"
echo "=========================================================="

# 1. Install prerequisites (Debian / Ubuntu)
if command -v apt-get >/dev/null 2>&1; then
    echo "[+] Updating system packages and installing build prerequisites..."
    sudo apt-get update -y
    sudo apt-get install -y \
        build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
        gettext git libncurses-dev libssl-dev libelf-dev python3 \
        rsync swig unzip zlib1g-dev file wget curl jq time
fi

# 2. Clone official OpenWrt source if not already present
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -d ".git" ]; then
    echo "[+] Cloning official OpenWrt repository ($OPENWRT_TAG)..."
    git clone --branch "$OPENWRT_TAG" --single-branch https://github.com/openwrt/openwrt.git .
else
    echo "[+] OpenWrt repository already cloned. Resetting to clean state..."
    git clean -fd
    git reset --hard HEAD
fi

# 3. Apply the official upstream TOTOLINK X30 patches
echo "[+] Applying board support and sysupgrade patches..."
for p in "$PROJECT_ROOT"/patches/*.patch; do
    if [ -f "$p" ]; then
        echo "  -> Applying patch: $(basename "$p")"
        git apply "$p" || git am --3way "$p" || true
    fi
done

# 4. Update and install feeds
echo "[+] Updating and installing package feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 5. Apply custom config
echo "[+] Applying custom device configuration..."
cp "$CONFIG_FILE" .config
make defconfig

# 6. Download source packages
echo "[+] Pre-downloading source packages..."
make download -j"$(nproc)"

# 7. Compile firmware
echo "[+] Compiling firmware (using $(nproc) jobs)..."
make -j"$(nproc)" V=s

# 8. Copy resulting firmware images to TFTP folder
mkdir -p "$OUT_DIR"
TARGET_DIR="bin/targets/mediatek/filogic"

echo "[+] Copying build artifacts to $OUT_DIR..."
cp -v "$TARGET_DIR"/openwrt*totolink_X30*.fip "$OUT_DIR/" 2>/dev/null || true
cp -v "$TARGET_DIR"/openwrt*totolink_X30*sysupgrade.bin "$OUT_DIR/" 2>/dev/null || true

echo "=========================================================="
echo "                   BUILD COMPLETED!                       "
echo "=========================================================="
ls -lh "$OUT_DIR"
echo ""
echo "Checksums of generated files:"
sha256sum "$OUT_DIR"/openwrt*totolink_X30* || true
echo "=========================================================="
