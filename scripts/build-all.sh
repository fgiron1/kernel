#!/bin/bash
set -e

echo "🏗️ Building complete kernel development environment..."

cd /workspace

# Ensure sources exist
if [ ! -d "linux" ] || [ ! -d "busybox" ]; then
    echo "📥 Sources missing, downloading first..."
    /scripts/init-workspace.sh
fi

# Configure kernel with full development setup
echo "🔧 Configuring kernel for development and debugging..."
cd linux
make defconfig

# Apply all kernel configuration changes in grouped batches
echo "📝 Applying kernel configuration for development..."

# Debugging and development features
scripts/config \
    --enable CONFIG_DEBUG_KERNEL \
    --enable CONFIG_DEBUG_INFO \
    --enable CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT \
    --enable CONFIG_GDB_SCRIPTS \
    --enable CONFIG_FRAME_POINTER \
    --enable CONFIG_KASAN \
    --enable CONFIG_KASAN_INLINE \
    --enable CONFIG_UBSAN \
    --enable CONFIG_KCOV \
    --enable CONFIG_DEBUG_FS \
    --enable CONFIG_CONFIGFS_FS \
    --enable CONFIG_SECURITYFS \
    --enable CONFIG_MAGIC_SYSRQ \
    --enable CONFIG_KALLSYMS \
    --enable CONFIG_KALLSYMS_ALL \
    --enable CONFIG_DEBUG_BUGVERBOSE

# Rust support
scripts/config \
    --enable CONFIG_RUST \
    --enable CONFIG_RUST_IS_AVAILABLE \
    --enable CONFIG_SAMPLES \
    --enable CONFIG_SAMPLES_RUST

# Networking support
scripts/config \
    --enable CONFIG_NET \
    --enable CONFIG_INET \
    --enable CONFIG_NETDEVICES \
    --enable CONFIG_NET_CORE \
    --enable CONFIG_VIRTIO_NET

# Filesystem support
scripts/config \
    --enable CONFIG_EXT4_FS \
    --enable CONFIG_TMPFS \
    --enable CONFIG_PROC_FS \
    --enable CONFIG_SYSFS

# Virtualization support
scripts/config \
    --enable CONFIG_VIRTIO \
    --enable CONFIG_VIRTIO_PCI \
    --enable CONFIG_VIRTIO_BALLOON \
    --enable CONFIG_VIRTIO_BLK \
    --enable CONFIG_VIRTIO_CONSOLE

# Performance and tracing
scripts/config \
    --enable CONFIG_PERF_EVENTS \
    --enable CONFIG_FTRACE \
    --enable CONFIG_FUNCTION_TRACER \
    --enable CONFIG_DYNAMIC_FTRACE \
    --enable CONFIG_BPF \
    --enable CONFIG_BPF_SYSCALL \
    --enable CONFIG_BPF_JIT \
    --enable CONFIG_HAVE_EBPF_JIT

# Disable features that interfere with debugging
scripts/config \
    --disable CONFIG_RANDOMIZE_BASE \
    --disable CONFIG_RETPOLINE

echo "✅ Kernel configured for development and debugging"

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