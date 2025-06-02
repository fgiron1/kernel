#!/bin/bash
set -e

cd /workspace/linux

# Generate rust-analyzer configuration
make LLVM=1 rust-analyzer

# Create Rust development helpers
cat > rust-dev.sh << 'EOF'
#!/bin/bash
# Rust kernel development helpers

case "$1" in
    "check")
        make LLVM=1 CLIPPY=1 -j$(nproc)
        ;;
    "fmt")
        make LLVM=1 rustfmt
        ;;
    "doc")
        make LLVM=1 rustdoc
        echo "Documentation available at: rust/doc/kernel/index.html"
        ;;
    "clean")
        make LLVM=1 clean
        ;;
    *)
        echo "Usage: $0 [check|fmt|doc|clean]"
        echo "  check - Run Clippy lints"
        echo "  fmt   - Format Rust code"
        echo "  doc   - Generate documentation"
        echo "  clean - Clean build artifacts"
        ;;
esac
EOF

chmod +x rust-dev.sh

echo "Rust development environment configured"
echo "Use ./rust-dev.sh for common Rust tasks"