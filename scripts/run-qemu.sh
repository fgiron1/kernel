#!/bin/bash

KERNEL="/workspace/linux/arch/x86/boot/bzImage"
ROOTFS="/workspace/rootfs.img"
APPEND="root=/dev/ram rdinit=/init console=ttyS0 nokaslr earlyprintk=serial,ttyS0,115200"

# Check if kernel exists
if [ ! -f "$KERNEL" ]; then
    echo "❌ Kernel not found at $KERNEL"
    echo "Build the kernel first with: /scripts/build-kernel.sh"
    exit 1
fi

# Check if rootfs exists
if [ ! -f "$ROOTFS" ]; then
    echo "❌ Root filesystem not found at $ROOTFS"
    echo "Build the rootfs first with: /scripts/build-rootfs.sh"
    exit 1
fi

# QEMU arguments for kernel development
QEMU_ARGS=(
    -kernel "$KERNEL"
    -initrd "$ROOTFS"
    -append "$APPEND"
    -m 2G
    -smp 2
    -nographic
    -netdev user,id=net0,hostfwd=tcp::2222-:22
    -device virtio-net-pci,netdev=net0
)

# Add KVM if available
if [ -e /dev/kvm ]; then
    QEMU_ARGS+=(-enable-kvm -cpu host)
    echo "✅ Using KVM acceleration"
else
    echo "⚠️ KVM not available, using slower emulation"
fi

# Add debugging support if requested
if [ "$1" = "debug" ]; then
    QEMU_ARGS+=(-s -S)
    echo "🐛 QEMU started in debug mode"
    echo ""
    echo "📝 To attach GDB:"
    echo "   1. Open another terminal"
    echo "   2. Run: ./scripts/debug-kernel.sh"
    echo "   3. In GDB: (gdb) continue"
    echo ""
fi

echo "🚀 Starting QEMU with kernel: $KERNEL"
echo "💾 Using rootfs: $ROOTFS"
echo "💡 To exit QEMU: Ctrl+A then X"
echo ""

exec qemu-system-x86_64 "${QEMU_ARGS[@]}"