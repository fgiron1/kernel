#!/bin/bash
set -e

echo "🚀 Setting up Linux Kernel Development Environment 2025"

# Check prerequisites
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Build the development container
echo "📦 Building development container..."
docker build -t kernel-dev-2025 .

# Create development scripts
echo "📝 Setting up development scripts..."

# Create container runner script
cat > dev.sh << 'EOF'
#!/bin/bash
echo "🐧 Entering kernel development environment..."

# Check if /dev/kvm exists for faster virtualization
KVM_DEVICE=""
if [ -e /dev/kvm ]; then
    KVM_DEVICE="--device=/dev/kvm"
    echo "✅ KVM acceleration available"
else
    echo "⚠️ KVM not available - QEMU will be slower"
fi

docker run -it --rm \
    --privileged \
    --cap-add=SYS_ADMIN \
    $KVM_DEVICE \
    -v "$(pwd)/workspace:/workspace" \
    -v "$(pwd)/scripts:/scripts" \
    -v "$(pwd)/configs:/configs" \
    -p 2222:2222 \
    -p 56741:56741 \
    kernel-dev-2025 \
    bash
EOF

# Create build and test script that works inside container
cat > build-and-test.sh << 'EOF'
#!/bin/bash
set -e

echo "🔧 Initializing workspace..."
if [ ! -f "/scripts/init-workspace.sh" ]; then
    echo "❌ Missing init-workspace.sh script"
    echo "Make sure you're running this inside the container with: ./dev.sh"
    exit 1
fi

# Initialize workspace (download sources if needed)
/scripts/init-workspace.sh

echo "🔨 Configuring kernel..."
/scripts/configure-kernel.sh

echo "🏗️ Building kernel..."
/scripts/build-kernel.sh

echo "📦 Building rootfs..."
/scripts/build-rootfs.sh

echo "✅ Build completed successfully!"
echo ""
echo "🎯 Next steps:"
echo "1. Test kernel:       ./scripts/run-qemu.sh"
echo "2. Debug kernel:      ./scripts/run-qemu.sh debug"
echo "3. In another term:   ./scripts/debug-kernel.sh"
echo "4. Run fuzzing:       cd /workspace/syzkaller && ./bin/syz-manager -config /configs/syzkaller.cfg"
echo ""
echo "📝 Development workflow:"
echo "- Edit kernel code in: /workspace/linux/"
echo "- Rebuild with:       /scripts/build-kernel.sh"
echo "- Test changes:       ./scripts/run-qemu.sh"
EOF

chmod +x dev.sh build-and-test.sh

# Create workspace directories
mkdir -p workspace

echo "✅ Environment deployed successfully!"
echo ""
echo "🎯 Quick start:"
echo "1. ./dev.sh                 - Enter development container"
echo "2. ./build-and-test.sh      - Build kernel and rootfs (inside container)"
echo "3. ./scripts/run-qemu.sh    - Test your kernel (inside container)"
echo ""
echo "🐛 Debugging workflow:"
echo "- Terminal 1 (inside container): ./scripts/run-qemu.sh debug"
echo "- Terminal 2 (inside container): ./scripts/debug-kernel.sh"
echo ""
echo "📚 What's included:"
echo "- Complete Linux kernel source with Rust support"
echo "- QEMU-based testing environment"
echo "- GDB debugging with kernel scripts"
echo "- Syzkaller for automated testing"
echo "- Modern build tools (LLVM/Clang + Rust)"
echo ""
echo "Happy kernel hacking! 🐧🦀"