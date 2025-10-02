#!/bin/bash
# LevelOS Debug Helper
# Provides debugging utilities for development

set -e

KERNEL_BIN="build/level-os-0.1.0.bin"

case "$1" in
    "objdump")
        echo "Disassembling kernel binary..."
        objdump -D -m i386 "$KERNEL_BIN" | less
        ;;
    "readelf")
        echo "Reading ELF headers..."
        readelf -a "$KERNEL_BIN" | less
        ;;
    "size")
        echo "Binary size information:"
        size "$KERNEL_BIN"
        ;;
    "symbols")
        echo "Symbol table:"
        nm "$KERNEL_BIN" | sort
        ;;
    "gdb")
        echo "Starting GDB with QEMU..."
        qemu-system-i386 -kernel "$KERNEL_BIN" -s -S &
        gdb -ex "target remote localhost:1234" -ex "symbol-file $KERNEL_BIN"
        ;;
    *)
        echo "LevelOS Debug Helper"
        echo "==================="
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  objdump  - Disassemble kernel binary"
        echo "  readelf  - Show ELF headers"
        echo "  size     - Show binary size information"
        echo "  symbols  - Show symbol table"
        echo "  gdb      - Start GDB debugging session"
        ;;
esac