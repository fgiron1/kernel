#!/bin/bash
set -e

cd /workspace/linux

# Check if vmlinux exists
if [ ! -f "vmlinux" ]; then
    echo "❌ vmlinux not found. Build the kernel first with:"
    echo "   /scripts/build-kernel.sh"
    exit 1
fi

echo "🐛 Setting up kernel debugging environment..."

# Create GDB initialization script
cat > .gdbinit << 'GDBEOF'
set confirm off
set pagination off
add-auto-load-safe-path /workspace/linux

# Connect to QEMU
echo "Connecting to QEMU on localhost:1234..."
target remote :1234

# Try to load kernel debugging scripts
python
try:
    exec(open('scripts/gdb/vmlinux-gdb.py').read())
    print("✅ Kernel GDB scripts loaded successfully")
except Exception as e:
    print("⚠️ Kernel GDB scripts not available:", str(e))
    print("   This is normal for older kernels")
end

# Useful debugging commands
define reload-symbols
  symbol-file vmlinux
  echo "Symbols reloaded\n"
end

define kernel-bt
  bt
  echo "\n--- Kernel Messages ---\n"
  python
try:
    gdb.execute("lx-dmesg")
except:
    print("lx-dmesg not available")
  end
end

define show-tasks
  python
try:
    gdb.execute("lx-ps")
except:
    print("lx-ps not available - use 'info threads' instead")
  end
end

define kernel-info
  echo "=== Kernel Debug Info ===\n"
  printf "Current task: "
  python
try:
    gdb.execute("p $current")
except:
    print("$current not available")
  end
  echo "\nCPU info:\n"
  info threads
  echo "\n"
end

# Set useful breakpoints
break panic if $_streq((char*)0, "")

echo "🐛 Kernel debugging environment ready!"
echo ""
echo "📝 Useful commands:"
echo "  bt               - Show backtrace"
echo "  kernel-bt        - Show backtrace + dmesg"
echo "  show-tasks       - Show running tasks"
echo "  kernel-info      - Show kernel debug info"
echo "  info threads     - Show all CPU threads"
echo "  reload-symbols   - Reload kernel symbols"
echo ""
echo "📍 Breakpoints set:"
echo "  panic            - Break on kernel panic"
echo ""
echo "🎯 Ready to debug! Use 'continue' to start the kernel"
GDBEOF

echo "🐛 Starting GDB for kernel debugging..."
echo ""
echo "⚠️ Make sure QEMU is running with debug mode:"
echo "   ./scripts/run-qemu.sh debug"
echo ""

# Start GDB
gdb -x .gdbinit vmlinux