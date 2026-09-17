#!/bin/bash
# Build flashable artifacts from a compiled kernel Image.
#
#   ./repack-boot.sh v4      -> Spacewar-boot-resukisu.img  + Spacewar-ReSukiSU-SUSFSv2-<kver>.zip
#   ./repack-boot.sh v155    -> Spacewar-boot-sukisu.img    + Spacewar-SukiSU-SUSFS-<kver>.zip
#
# Kernel source:   build/Image   (copied there by build_5.4_*.sh)
# Base ramdisk:    stock/<stock boot image>  (provide your own extraction of the
#                  Nothing OS 3.2 boot partition; it is NOT distributed here)
# AnyKernel3:      cloned on demand from osm0sis/AnyKernel3 into build/ak3
#
# Env overrides:
#   STOCK_BOOT=/path/to/stock_boot.img
#   MAGISKBOOT=/path/to/magiskboot      (defaults to AnyKernel3/tools/magiskboot)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VARIANT="${1:-v4}"
IMAGE="$ROOT/build/Image"
STOCK="${STOCK_BOOT:-$ROOT/stock/Spacewar_V3.2_stock_boot.img}"
KVER="$(make -s -C "$ROOT" kernelversion 2>/dev/null || echo 5.4.289)"
WORK="$(mktemp -d /tmp/spacewar-repack.XXXXXX)"

AK3_SRC="$ROOT/build/ak3/AnyKernel3"

case "$VARIANT" in
    v4)   BOOT="$ROOT/Spacewar-boot-resukisu.img"; ZIP="$ROOT/Spacewar-ReSukiSU-SUSFSv2-${KVER}.zip" ;;
    v155) BOOT="$ROOT/Spacewar-boot-sukisu.img";   ZIP="$ROOT/Spacewar-SukiSU-SUSFS-${KVER}.zip" ;;
    *) echo "usage: $0 {v4|v155}" >&2; exit 1 ;;
esac

[ -f "$IMAGE" ] || { echo "missing $IMAGE (build first)" >&2; exit 1; }
[ -f "$STOCK" ] || { echo "missing stock boot image: $STOCK" >&2; exit 1; }

if [ ! -d "$AK3_SRC" ]; then
    mkdir -p "$(dirname "$AK3_SRC")"
    git clone --depth 1 https://github.com/osm0sis/AnyKernel3.git "$AK3_SRC"
fi

MAGISKBOOT="${MAGISKBOOT:-$AK3_SRC/tools/magiskboot}"
[ -x "$MAGISKBOOT" ] || { echo "missing magiskboot at $MAGISKBOOT" >&2; exit 1; }

echo "[1/4] unpacking stock boot image"
cp "$STOCK" "$WORK/boot.img"
( cd "$WORK" && "$MAGISKBOOT" unpack boot.img >/dev/null )

echo "[2/4] replacing kernel"
cp "$IMAGE" "$WORK/kernel"
( cd "$WORK" && "$MAGISKBOOT" repack boot.img new-boot.img >/dev/null )
cp "$WORK/new-boot.img" "$BOOT"

echo "[3/4] building AnyKernel3 zip"
cp "$IMAGE" "$AK3_SRC/Image"
cp "$ROOT/ak3/anykernel.sh" "$AK3_SRC/anykernel.sh"
( cd "$AK3_SRC" && rm -f "$ZIP" && zip -r9 "$ZIP" . -x "*.git*" >/dev/null )

rm -rf "$WORK"
echo "[4/4] done:"
ls -lh "$BOOT" "$ZIP"
