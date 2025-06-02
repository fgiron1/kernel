# Linux Kernel Development Environment 2025

🐧 **Modern Docker-based setup for Linux kernel development with C and Rust support.**

## ⚡ Quick Start

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

## 🚀 Features

| Feature | Description |
|---------|-------------|
| **🔧 Modern Toolchain** | LLVM/Clang + GCC fallback for optimal builds |
| **🦀 Rust Support** | Full Rust-for-Linux development environment |
| **🖥️ QEMU Testing** | Safe kernel testing with hardware virtualization |
| **🐛 GDB Debugging** | Kernel-aware debugging with Python extensions |
| **📊 Performance Tools** | perf, ftrace, bpftrace, eBPF for analysis |
| **🧪 Automated Testing** | Syzkaller kernel fuzzing (optional) |
| **📦 Portable** | Works on Linux, macOS, Windows via Docker |

## 🔄 Development Workflow

```bash
# Enter development environment
./run.sh start

# Edit kernel code
vim /workspace/linux/drivers/your_driver.c

# Rebuild everything
./scripts/build-all.sh

# Test your changes
./scripts/run-qemu.sh

# Debug issues (2 terminals)
./scripts/run-qemu.sh debug    # Terminal 1: Start QEMU in debug mode
./scripts/debug-kernel.sh      # Terminal 2: Attach GDB debugger
```

## 🦀 Rust Development

```bash
# Inside container
cd /workspace/linux

# Setup Rust development helpers (one-time)
/scripts/rust-kernel-setup.sh

# Rust development commands
./rust-dev.sh check    # Run Clippy lints
./rust-dev.sh fmt      # Format Rust code  
./rust-dev.sh doc      # Generate documentation
./rust-dev.sh clean    # Clean build artifacts

# Edit Rust kernel samples
vim samples/rust/rust_echo_server.rs
```

## 📋 Commands Reference

### Host Commands
| Command | Description |
|---------|-------------|
| `./run.sh start` | Enter development container |
| `./run.sh setup` | Download kernel sources |
| `./run.sh build` | Build kernel and rootfs |
| `./run.sh clean` | Clean workspace and Docker cache |

### Container Commands
| Command | Description |
|---------|-------------|
| `./scripts/run-qemu.sh` | Boot and test your kernel |
| `./scripts/run-qemu.sh debug` | Boot kernel in debug mode |
| `./scripts/debug-kernel.sh` | Attach GDB to running kernel |
| `./scripts/build-all.sh` | Rebuild kernel and rootfs |
| `/scripts/rust-kernel-setup.sh` | Setup Rust development tools |

## 🔍 Debugging Guide

### Basic Kernel Testing
```bash
# Boot your kernel
./scripts/run-qemu.sh

# Inside QEMU guest:
dmesg                    # View kernel messages
cat /proc/version        # Check kernel version
poweroff                 # Shutdown cleanly
```

### Advanced Debugging
```bash
# Terminal 1: Start kernel in debug mode (paused)
./scripts/run-qemu.sh debug

# Terminal 2: Attach debugger
./scripts/debug-kernel.sh

# In GDB:
(gdb) continue           # Start kernel execution
(gdb) break sys_open     # Set breakpoint on system call
(gdb) bt                 # Show call stack
(gdb) lx-ps              # List kernel processes (if available)
(gdb) lx-dmesg           # Show kernel log (if available)
```

### Performance Analysis
```bash
# Inside container, with kernel running
perf record -g sleep 5   # Profile system
perf report              # View results

# eBPF tracing (if bpftrace available)
bpftrace -e 'tracepoint:syscalls:sys_enter_open { printf("open: %s\n", str(args->filename)); }'
```

## 🧪 Testing and Fuzzing

### Manual Testing
```bash
# Test specific kernel features
./scripts/run-qemu.sh
# In guest: exercise your driver/subsystem
```

### Automated Fuzzing (Optional)
```bash
# During setup, choose 'y' for syzkaller
./run.sh setup

# Run fuzzer (inside container)
cd /workspace/syzkaller
./bin/syz-manager -config /configs/syzkaller.cfg

# View results at http://localhost:56741
```

## 📁 Project Structure

```
├── Dockerfile              # Development container definition
├── deploy.sh               # Environment setup script
├── run.sh                  # Main control script (generated)
├── README.md               # This file
├── configs/
│   └── syzkaller.cfg       # Kernel fuzzer configuration
├── scripts/
│   ├── build-all.sh        # Complete build script
│   ├── debug-kernel.sh     # GDB debugging helper
│   ├── init-workspace.sh   # Source code downloader
│   ├── run-qemu.sh         # QEMU launcher
│   └── rust-kernel-setup.sh # Rust development setup
└── workspace/              # Development workspace (created)
    ├── linux/              # Linux kernel source
    ├── busybox/            # Minimal userland
    ├── rootfs.img          # Built root filesystem
    └── syzkaller/          # Kernel fuzzer (optional)
```

## 🎯 What You Get

- **Complete Linux kernel source** with latest features and Rust support
- **Minimal busybox-based userland** for fast testing
- **QEMU virtualization** for safe development without host crashes
- **Full debugging support** with GDB and kernel debugging scripts
- **Modern build system** supporting both C and Rust development
- **Performance analysis tools** for optimization and profiling
- **Automated testing** via syzkaller for finding bugs

## 🚨 Requirements

- **Docker** 20.10+ (with BuildKit support)
- **8GB+ RAM** (16GB recommended for large builds)
- **50GB+ free disk space** (kernel source + builds + container)
- **KVM support** (optional, for faster QEMU virtualization)

## 💡 Tips

- **First build takes time**: Kernel compilation is CPU-intensive (~20-30 minutes)
- **Use KVM**: Much faster QEMU if `/dev/kvm` exists on host
- **Incremental builds**: Only changed files recompile after first build
- **Multiple terminals**: Use separate terminals for QEMU and debugging
- **Save your work**: Edit files in `workspace/` which persists outside container

## 🤝 Contributing

This environment supports the full Linux kernel development workflow:

1. **Clone/modify** kernel source in `workspace/linux/`
2. **Build and test** with the provided scripts
3. **Debug issues** using QEMU + GDB
4. **Submit patches** to Linux kernel mailing lists

---

**Happy kernel hacking!** 🐧🦀

*Built for the 2025 Linux kernel development ecosystem with modern tooling and best practices.*