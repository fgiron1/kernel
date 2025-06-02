#!/bin/bash
set -e

echo "📦 Building minimal root filesystem with busybox..."

cd /workspace

# Check if busybox exists
if [ ! -d "busybox" ]; then
    echo "❌ Busybox source not found. Run init-workspace.sh first."
    exit 1
fi

cd busybox

# Configure busybox for static build
echo "🔧 Configuring busybox..."
make defconfig

# Enable static linking (important for initramfs)
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config

# Build busybox
echo "🏗️ Building busybox..."
make -j$(nproc)

# Create rootfs directory structure
echo "📁 Creating rootfs structure..."
cd /workspace
rm -rf rootfs
mkdir -p rootfs/{bin,sbin,etc,proc,sys,dev,tmp,usr/bin,usr/sbin,root}

# Install busybox
cd busybox
make CONFIG_PREFIX=/workspace/rootfs install

# Create essential device nodes
cd /workspace/rootfs
mknod -m 600 dev/console c 5 1
mknod -m 666 dev/null c 1 3
mknod -m 666 dev/zero c 1 5
mknod -m 666 dev/random c 1 8

# Create init script
cat > init << 'INITEOF'
#!/bin/sh

# Mount essential filesystems
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev || mount -t tmpfs none /dev

# Create additional device nodes if devtmpfs failed
[ -c /dev/console ] || mknod -m 600 /dev/console c 5 1
[ -c /dev/null ] || mknod -m 666 /dev/null c 1 3

# Set up basic environment
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export HOME=/root
cd /root

# Print welcome message
echo ""
echo "🐧 Welcome to Kernel Development Environment!"
echo "   Kernel: $(uname -r)"
echo "   Available commands: $(ls /bin | wc -w) busybox utilities"
echo ""
echo "💡 Useful commands:"
echo "   - ps          # Show processes"
echo "   - dmesg       # Show kernel messages"
echo "   - cat /proc/* # Explore kernel interfaces"
echo "   - poweroff    # Shutdown cleanly"
echo ""

# Start shell
exec /bin/sh
INITEOF

chmod +x init

# Create a simple fstab
cat > etc/fstab << 'FSTABEOF'
proc /proc proc defaults 0 0
sysfs /sys sysfs defaults 0 0
devtmpfs /dev devtmpfs defaults 0 0
FSTABEOF

# Create passwd file
cat > etc/passwd << 'PASSWDEOF'
root:x:0:0:root:/root:/bin/sh
PASSWDEOF

# Create initramfs image
echo "📦 Creating initramfs image..."
find . | cpio -H newc -o | gzip > ../rootfs.img

cd ..
echo "✅ Root filesystem built successfully"
echo "📍 Location: /workspace/rootfs.img"
echo "📏 Size: $(du -h rootfs.img | cut -f1)"