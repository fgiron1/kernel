#!/bin/bash

K="/workspace/linux/vmlinux"
[ -f "$K" ] || { echo "❌ Build kernel first"; exit 1; }

# Simple GDB setup
cat > /tmp/gdb.init << EOF
set confirm off
set pagination off
target remote :1234
# Load kernel scripts if available
python
try:
    exec(open('/workspace/linux/scripts/gdb/vmlinux-gdb.py').read())
    print("✅ Kernel GDB scripts loaded")
except:
    print("⚠️ Basic GDB mode (kernel scripts not available)")
end
break panic
echo "🐛 Ready! Use 'continue' to start kernel\n"
EOF

echo "🐛 Starting GDB (make sure QEMU runs with: ./scripts/run-qemu.sh debug)"
exec gdb -q -x /tmp/gdb.init "$K"