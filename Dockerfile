FROM ubuntu:24.04

# Install base packages
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential bc bison flex libssl-dev libelf-dev \
    libncurses-dev git fakeroot xz-utils \
    # LLVM/Clang toolchain for Rust and modern features
    clang llvm lld llvm-dev libclang-dev \
    # Debugging and analysis
    gdb addr2line crash \
    # Performance tools
    linux-tools-generic perf-tools-unstable \
    # Python for various tools
    python3 python3-pip python3-dev \
    # Rust dependencies
    curl \
    # Network tools for QEMU
    netcat-openbsd socat \
    # Additional utilities
    vim tmux htop tree jq \
    # Static analysis tools
    sparse cppcheck \
    # Documentation tools
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Rust components for kernel development
RUN rustup toolchain install nightly-2024-09-05 && \
    rustup component add rust-src rustfmt clippy rust-analyzer

# Install bindgen for Rust FFI
RUN cargo install bindgen-cli --version 0.65.1

# Install bpftrace and BCC for eBPF development
RUN apt-get update && apt-get install -y \
    bpftrace libbpfcc-dev python3-bpfcc-tools \
    && rm -rf /var/lib/apt/lists/*

# Install syzkaller dependencies
RUN go_version="1.21.5" && \
    wget -O go.tar.gz "https://golang.org/dl/go${go_version}.linux-amd64.tar.gz" && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Set up workspace
WORKDIR /workspace
RUN mkdir -p /workspace/{linux,buildroot,syzkaller,scripts}

# Clone essential repositories
RUN git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git /workspace/linux && \
    git clone --depth=1 https://github.com/google/syzkaller.git /workspace/syzkaller && \
    git clone --depth=1 https://github.com/buildroot/buildroot.git /workspace/buildroot

# Build syzkaller
WORKDIR /workspace/syzkaller
RUN make

WORKDIR /workspace