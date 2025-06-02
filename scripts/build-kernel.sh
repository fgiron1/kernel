#!/bin/bash
set -e

cd /workspace/linux

# Check if Rust is available
make LLVM=1 rustavailable

# Build kernel with LLVM for better debugging and Rust support
make LLVM=1 -j$(nproc) 2>&1 | tee build.log

# Build modules
make LLVM=1 modules -j$(nproc)

# Build Rust documentation
make LLVM=1 rustdoc

# Generate compile_commands.json for IDE support
make LLVM=1 compile_commands.json

echo "Kernel build completed successfully"
echo "Built kernel: $(file arch/x86/boot/bzImage)"
echo "Rust docs available at: rust/doc/kernel/index.html"