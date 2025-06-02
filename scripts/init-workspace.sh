#!/bin/bash
set -e

echo "🔧 Setting up lightweight kernel workspace..."
cd /workspace

# Download only what we need
for repo in "linux:git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git" \
            "busybox:github.com/mirror/busybox.git"; do
    name=${repo%:*}
    url=${repo#*:}
    
    if [ ! -d "$name" ]; then
        echo "📥 Downloading $name..."
        git clone --depth=1 "https://$url" "$name"
    else
        echo "✅ $name exists"
    fi
done

# Optional: syzkaller (only if fuzzing needed)
read -p "📝 Download syzkaller for fuzzing? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ ! -d "syzkaller" ]; then
        echo "📥 Downloading syzkaller..."
        git clone --depth=1 https://github.com/google/syzkaller.git
        cd syzkaller && make && cd ..
    fi
fi

echo "✅ Workspace ready for development!"