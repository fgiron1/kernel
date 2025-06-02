#!/bin/bash
set -e

echo "🚀 Linux Kernel Dev Environment 2025 - Lightweight Setup"

# Check Docker
command -v docker >/dev/null || { echo "❌ Install Docker first"; exit 1; }

# Build container
echo "📦 Building container..."
docker build -t kernel-dev .

# Create simple runner
cat > run.sh << 'EOF'
#!/bin/bash
# Single script to rule them all

ACTION=${1:-help}

case "$ACTION" in
    "start"|"dev")
        echo "🐧 Starting development environment..."
        exec docker run -it --rm --privileged \
            $([ -e /dev/kvm ] && echo "--device=/dev/kvm") \
            -v "$(pwd)/workspace:/workspace" \
            -v "$(pwd)/scripts:/scripts" \
            -v "$(pwd)/configs:/configs" \
            -p 2222:2222 -p 56741:56741 \
            kernel-dev
        ;;
    "setup")
        echo "🔧 Setting up workspace..."
        docker run --rm \
            -v "$(pwd)/workspace:/workspace" \
            -v "$(pwd)/scripts:/scripts" \
            kernel-dev setup
        ;;
    "build")
        echo "🏗️ Building kernel..."
        docker run --rm \
            -v "$(pwd)/workspace:/workspace" \
            -v "$(pwd)/scripts:/scripts" \
            kernel-dev build
        ;;
    "clean")
        echo "🧹 Cleaning workspace..."
        rm -rf workspace/{linux,busybox,syzkaller,rootfs*}
        docker system prune -f
        ;;
    *)
        echo "Usage: $0 [start|setup|build|clean]"
        echo "  start  - Enter development container"
        echo "  setup  - Download kernel sources"
        echo "  build  - Build kernel and rootfs (includes configuration)"
        echo "  clean  - Clean everything"
        ;;
esac
EOF

chmod +x run.sh
mkdir -p workspace

echo "✅ Setup complete!"
echo ""
echo "🎯 Quick start:"
echo "  ./run.sh setup    # Download sources"
echo "  ./run.sh start    # Enter dev environment"
echo "  ./run.sh build    # Build everything (auto-configures kernel)"
echo ""
echo "🐛 Inside container:"
echo "  ./scripts/run-qemu.sh         # Test kernel"
echo "  ./scripts/run-qemu.sh debug   # Debug mode"