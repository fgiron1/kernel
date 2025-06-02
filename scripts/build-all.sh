#!/bin/bash
set -e

echo "🏗️ Building complete kernel development environment..."

cd /workspace

# Ensure sources exist
if [ ! -d "linux" ] || [ ! -d "busybox" ]; then
    echo "📥 Sources missing, downloading first..."
    /scripts/init-workspace.sh
fi

# Configure kernel
echo "🔧 Configuring kernel..."
cd linux
make defconfig

# Essential kernel config for development
scripts/config --enable CONFIG_DEBUG_KERNEL CONFIG_DEBUG_INFO CONFIG_GDB_SCRIPTS \
                --enable CONFIG_FRAME_POINTER CONFIG_KALLSYMS CONFIG_KALLSYMS_ALL \
                --enable CONFIG_RUST CONFIG_SAMPLES CONFIG_SAMPLES_RUST \
                --enable CONFIG_VIRTIO CONFIG_VIRTIO_NET CONFIG_NET \
                --enable CONFIG_BPF CONFIG_BPF_SYSCALL CONFIG_FTRACE \
                --disable CONFIG_RANDOMIZE_BASE

# Build kernel
echo "🏗️ Building kernel..."
make LLVM=1 -j$(nproc) || make -j$(nproc)  # Fallback to GCC if LLVM fails

# Build minimal rootfs
echo "📦 Building rootfs..."
cd /workspace/busybox
make defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
make -j$(nproc)

# Create minimal initramfs
rm -rf /workspace/rootfs
mkdir -p /workspace/rootfs/{bin,sbin,etc,proc,sys,dev,root}
make CONFIG_PREFIX=/workspace/rootfs install

cd /workspace/rootfs
# Minimal init
cat > init << 'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev 2>/dev/null || mount -t tmpfs none /dev
export PATH=/bin:/sbin:/usr/bin:/usr/sbin HOME=/root
cd /root
echo "🐧 Kernel $(uname -r) ready! Use 'poweroff' to exit."
exec /bin/sh
EOF
chmod +x init

# Create initramfs
find . | cpio -H newc -o | gzip > /workspace/rootfs.img

echo "✅ Build complete!"
echo "📍 Kernel: /workspace/linux/arch/x86/boot/bzImage"
echo "📍 Rootfs: /workspace/rootfs.img"
echo ""
echo "🎯 Test with: ./scripts/run-qemu.sh"