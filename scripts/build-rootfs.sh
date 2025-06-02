#!/bin/bash
set -e

cd /workspace/buildroot

# Configure buildroot for minimal system
make qemu_x86_64_defconfig

# Customize configuration
cat >> .config << EOF
# Enable additional tools for debugging
CONFIG_PACKAGE_GDB=y
CONFIG_PACKAGE_STRACE=y
CONFIG_PACKAGE_TCPDUMP=y
CONFIG_PACKAGE_DROPBEAR=y
CONFIG_PACKAGE_BUSYBOX_SHOW_OTHERS=y

# Enable networking
CONFIG_PACKAGE_IPTABLES=y
CONFIG_PACKAGE_BRIDGE_UTILS=y

# Development tools
CONFIG_PACKAGE_PYTHON3=y
CONFIG_PACKAGE_BASH=y
CONFIG_PACKAGE_VIM=y
EOF

# Build the rootfs
make -j$(nproc)

echo "Root filesystem built successfully"
echo "Location: output/images/rootfs.ext2"