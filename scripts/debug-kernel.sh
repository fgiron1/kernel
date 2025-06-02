#!/bin/bash
set -e

cd /workspace/linux

# Create GDB initialization script
cat > .gdbinit << EOF
set confirm off
set pagination off
add-auto-load-safe-path $(pwd)

# Connect to QEMU
target remote :1234

# Load kernel debugging scripts
source scripts/gdb/vmlinux-gdb.py

# Useful debugging commands
define reload-symbols
  symbol-file vmlinux
end

define kernel-bt
  bt
  lx-dmesg
end

define show-tasks
  lx-ps
end

# Break on kernel panic
break panic

echo "Kernel debugging environment ready"
echo "Useful commands:"
echo "  lx-ps       - Show process list"
echo "  lx-dmesg    - Show kernel messages"
echo "  lx-lsmod    - Show loaded modules"
echo "  reload-symbols - Reload kernel symbols"
EOF

echo "Starting GDB for kernel debugging"
echo "Make sure QEMU is running with debug flags: ./run-qemu.sh debug"
gdb -x .gdbinit vmlinux