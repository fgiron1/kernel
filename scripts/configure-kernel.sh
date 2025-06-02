#!/bin/bash
set -e

cd /workspace/linux

# Base configuration for development and debugging
make defconfig

# Enable debugging features
scripts/config --enable CONFIG_DEBUG_KERNEL
scripts/config --enable CONFIG_DEBUG_INFO
scripts/config --enable CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
scripts/config --enable CONFIG_GDB_SCRIPTS
scripts/config --enable CONFIG_FRAME_POINTER
scripts/config --enable CONFIG_KASAN
scripts/config --enable CONFIG_KASAN_INLINE
scripts/config --enable CONFIG_UBSAN
scripts/config --enable CONFIG_KCOV
scripts/config --enable CONFIG_DEBUG_FS
scripts/config --enable CONFIG_CONFIGFS_FS
scripts/config --enable CONFIG_SECURITYFS

# Enable kernel hacking features
scripts/config --enable CONFIG_MAGIC_SYSRQ
scripts/config --enable CONFIG_DEBUG_KERNEL
scripts/config --enable CONFIG_KALLSYMS
scripts/config --enable CONFIG_KALLSYMS_ALL
scripts/config --enable CONFIG_DEBUG_BUGVERBOSE

# Enable Rust support
scripts/config --enable CONFIG_RUST
scripts/config --enable CONFIG_RUST_IS_AVAILABLE
scripts/config --enable CONFIG_SAMPLES
scripts/config --enable CONFIG_SAMPLES_RUST

# Enable networking for debugging
scripts/config --enable CONFIG_NET
scripts/config --enable CONFIG_INET
scripts/config --enable CONFIG_NETDEVICES
scripts/config --enable CONFIG_NET_CORE
scripts/config --enable CONFIG_VIRTIO_NET

# Enable filesystems
scripts/config --enable CONFIG_EXT4_FS
scripts/config --enable CONFIG_TMPFS
scripts/config --enable CONFIG_PROC_FS
scripts/config --enable CONFIG_SYSFS

# Enable virtualization support
scripts/config --enable CONFIG_VIRTIO
scripts/config --enable CONFIG_VIRTIO_PCI
scripts/config --enable CONFIG_VIRTIO_BALLOON
scripts/config --enable CONFIG_VIRTIO_BLK
scripts/config --enable CONFIG_VIRTIO_CONSOLE

# Performance and tracing
scripts/config --enable CONFIG_PERF_EVENTS
scripts/config --enable CONFIG_FTRACE
scripts/config --enable CONFIG_FUNCTION_TRACER
scripts/config --enable CONFIG_DYNAMIC_FTRACE
scripts/config --enable CONFIG_BPF
scripts/config --enable CONFIG_BPF_SYSCALL
scripts/config --enable CONFIG_BPF_JIT
scripts/config --enable CONFIG_HAVE_EBPF_JIT

# Disable security features that interfere with debugging
scripts/config --disable CONFIG_RANDOMIZE_BASE  # Disable KASLR
scripts/config --disable CONFIG_RETPOLINE

echo "Kernel configured for development and debugging"