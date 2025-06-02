#!/bin/bash

# Enable perf for non-root users in container
echo -1 > /proc/sys/kernel/perf_event_paranoid 2>/dev/null || true
echo 0 > /proc/sys/kernel/kptr_restrict 2>/dev/null || true

# Install additional performance tools
pip3 install pycparser

# Create performance analysis shortcuts
cat > /usr/local/bin/kernel-perf << 'EOF'
#!/bin/bash
# Kernel performance analysis wrapper

case "$1" in
    "profile")
        perf record -g --call-graph=dwarf -a sleep 10
        perf report
        ;;
    "trace")
        perf trace --duration 10
        ;;
    "top")
        perf top -g
        ;;
    "bpf")
        bpftrace -e 'BEGIN { printf("BPF tracing active\n"); }'
        ;;
    *)
        echo "Usage: kernel-perf [profile|trace|top|bpf]"
        ;;
esac
EOF

chmod +x /usr/local/bin/kernel-perf