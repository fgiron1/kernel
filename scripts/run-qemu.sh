#!/bin/bash

KERNEL="/workspace/linux/arch/x86/boot/bzImage"
ROOTFS="/workspace/buildroot/output/images/rootfs.ext2"
APPEND="root=/dev/vda console=ttyS0 nokaslr earlyprintk=serial,ttyS0,115200"

# QEMU arguments for kernel development
QEMU_ARGS=(
    -kernel "$KERNEL"
    -drive "file=$ROOTFS,format=raw,if=virtio"
    -append "$APPEND"
    -m 2G
    -smp 2
    -nographic
    -netdev user,id=net0,hostfwd=tcp::2222-:22
    -device virtio-net-pci,netdev=net0
    -enable-kvm
    -cpu host
)

# Add debugging support if requested
if [ "$1" = "debug" ]; then
    QEMU_ARGS+=(-s -S)
    echo "QEMU started in debug mode. Attach GDB with:"
    echo "  gdb /workspace/linux/vmlinux"
    echo "  (gdb) target remote :1234"
    echo "  (gdb) continue"
fi

echo "Starting QEMU with kernel: $KERNEL"
qemu-system-x86_64 "${QEMU_ARGS[@]}"