#!/bin/bash
# LevelOS Development Setup Script
# Sets up the development environment

set -e

echo "================================="
echo "  LevelOS Development Setup"
echo "================================="

# Check if running on supported system
if [ ! -f /etc/debian_version ]; then
    echo "Warning: This script is designed for Debian/Ubuntu systems"
    echo "You may need to adapt package names for your distribution"
fi

echo "Installing build dependencies..."
sudo apt update
sudo apt install -y \
    build-essential \
    nasm \
    gcc-multilib \
    grub-pc-bin \
    grub-common \
    xorriso \
    qemu-system-x86 \
    mtools \
    git

echo "Verifying installation..."
gcc --version > /dev/null && echo "✓ GCC installed"
nasm --version > /dev/null && echo "✓ NASM installed"
qemu-system-i386 --version > /dev/null && echo "✓ QEMU installed"
grub-mkrescue --version > /dev/null && echo "✓ GRUB tools installed"

echo ""
echo "Development environment setup complete!"
echo "You can now build LevelOS with: make"