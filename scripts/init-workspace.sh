#!/bin/bash
set -e

echo "🔧 Initializing kernel development workspace..."

cd /workspace

# Clone Linux kernel if not exists
if [ ! -d "linux" ]; then
    echo "📥 Downloading Linux kernel source (this may take 5-10 minutes)..."
    git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
    echo "✅ Linux kernel source downloaded"
else
    echo "✅ Linux kernel source already exists"
fi

# Clone syzkaller if not exists
if [ ! -d "syzkaller" ]; then
    echo "📥 Downloading and building syzkaller..."
    git clone --depth=1 https://github.com/google/syzkaller.git
    cd syzkaller
    make
    cd ..
    echo "✅ Syzkaller built successfully"
else
    echo "✅ Syzkaller already exists"
fi

# Clone busybox for simple rootfs creation
if [ ! -d "busybox" ]; then
    echo "📥 Downloading busybox for rootfs..."
    git clone --depth=1 https://github.com/mirror/busybox.git
    echo "✅ Busybox source downloaded"
else
    echo "✅ Busybox source already exists"
fi

echo "✅ Workspace initialization complete"
echo ""
echo "📁 Workspace contents:"
echo "- /workspace/linux/     - Linux kernel source"
echo "- /workspace/syzkaller/ - Kernel fuzzer"
echo "- /workspace/busybox/   - For creating minimal rootfs"