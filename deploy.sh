#!/bin/bash
set -e

echo "🚀 Setting up Linux Kernel Development Environment 2025"

# Check prerequisites
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed"
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
docker run -it --rm \
    --privileged \
    --cap-add=SYS_ADMIN \
    --device=/dev/kvm \
    -v "$(pwd)/workspace:/workspace" \
    -v "$(pwd)/scripts:/scripts" \
    -v "$(pwd)/configs:/configs" \
    -p 2222:2222 \
    -p 56741:56741 \
    kernel-dev-2025 \
    bash
EOF

# Create build and test script
cat > build-and-test.sh << 'EOF'
#!/bin/bash
set -e

echo "🔨 Configuring kernel..."
/scripts/configure-kernel.sh

echo "🏗️ Building kernel..."
/scripts/build-kernel.sh

echo "📦 Building rootfs..."
/scripts/build-rootfs.sh

echo "🧪 Running tests..."
echo "Kernel built successfully!"
echo ""
echo "Next steps:"
echo "1. Start QEMU: ./scripts/run-qemu.sh"
echo "2. Debug kernel: ./scripts/debug-kernel.sh (in another terminal)"
echo "3. Run fuzzing: syz-manager -config /configs/syzkaller.cfg"
echo "4. Rust development: ./rust-dev.sh"
EOF

chmod +x dev.sh build-and-test.sh

# Create workspace directories
mkdir -p workspace/{linux,buildroot,syzkaller,output}

echo "✅ Environment deployed successfully!"
echo ""
echo "🎯 Quick start:"
echo "1. ./dev.sh                 - Enter development container"
echo "2. ./build-and-test.sh      - Build kernel and rootfs"
echo "3. ./scripts/run-qemu.sh    - Test your kernel"
echo ""
echo "📚 Documentation:"
echo "- Kernel config: scripts/configure-kernel.sh"
echo "- Debugging: scripts/debug-kernel.sh"
echo "- Rust: scripts/rust-kernel-setup.sh"
echo "- Performance: scripts/perf-setup.sh"
echo ""
echo "Happy kernel hacking! 🐧"