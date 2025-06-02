#!/bin/bash

K="/workspace/linux/arch/x86/boot/bzImage"
R="/workspace/rootfs.img"

[ -f "$K" ] || { echo "❌ Build kernel first: ./run.sh build"; exit 1; }
[ -f "$R" ] || { echo "❌ Build rootfs first: ./run.sh build"; exit 1; }

# QEMU args
ARGS=(-kernel "$K" -initrd "$R" -m 1G -smp 2 -nographic 
      -append "root=/dev/ram rdinit=/init console=ttyS0 nokaslr")

# Add KVM if available
[ -e /dev/kvm ] && ARGS+=(-enable-kvm -cpu host) || echo "⚠️ No KVM"

# Debug mode
if [ "$1" = "debug" ]; then
    ARGS+=(-s -S)
    echo "🐛 Debug mode - attach GDB with: ./scripts/debug-kernel.sh"
fi

echo "🚀 Starting QEMU (Ctrl+A X to exit)"
exec qemu-system-x86_64 "${ARGS[@]}"