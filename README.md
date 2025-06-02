# Linux Kernel Development Environment

Docker-based setup for Linux kernel development with C and Rust support.

## Quick Start

```bash
# 1. Deploy environment
./deploy.sh

# 2. Download kernel sources  
./run.sh setup

# 3. Build kernel and rootfs
./run.sh build

# 4. Enter development environment
./run.sh start

# 5. Test your kernel (inside container)
./scripts/run-qemu.sh
```

## Features

- ✅ **Toolchain**: LLVM/Clang + GCC fallback
- ✅ **Rust support**: Full Rust-for-Linux development
- ✅ **QEMU testing**: Safe kernel testing environment  
- ✅ **GDB debugging**: Kernel-aware debugging setup
- ✅ **Performance tools**: perf, ftrace, bpftrace, eBPF
- ✅ **Syzkaller**: Automated kernel fuzzing (optional)
- ✅ **Portable**: Works on Linux, macOS, Windows (Docker)

## Development Workflow

```bash
# Edit kernel code
vim workspace/linux/drivers/your_driver.c

# Rebuild (inside container)
./scripts/build-all.sh

# Test changes
./scripts/run-qemu.sh

# Debug issues
./scripts/run-qemu.sh debug    # Terminal 1
./scripts/debug-kernel.sh      # Terminal 2
```

## Rust Development

```bash
# Inside container, setup Rust helpers
./scripts/rust-kernel-setup.sh

# Use Rust development commands
./rust-dev.sh check    # Run Clippy
./rust-dev.sh fmt      # Format code  
./rust-dev.sh doc      # Generate docs
```

## Commands

- `./run.sh start` - Enter development container
- `./run.sh setup` - Download kernel sources
- `./run.sh build` - Build kernel and rootfs
- `./run.sh clean` - Clean everything

## Inside Container

- `./scripts/run-qemu.sh` - Test kernel
- `./scripts/run-qemu.sh debug` - Debug mode
- `./scripts/debug-kernel.sh` - Attach GDB
- `./scripts/build-all.sh` - Rebuild everything