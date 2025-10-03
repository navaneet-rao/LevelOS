#!/bin/bash
# LevelOS Debug Utilities
# Provides debugging and analysis tools for the kernel

set -e

# Configuration
KERNEL_BIN="build/level-os-*.bin"
BUILDDIR="build"
OBJDIR="build/obj"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo "LevelOS Debug Utilities"
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  size      - Show kernel binary size information"
    echo "  symbols   - Show kernel symbol table"
    echo "  sections  - Show kernel sections"
    echo "  objdump   - Show kernel disassembly"
    echo "  hexdump   - Show kernel hex dump (first 512 bytes)"
    echo "  info      - Show comprehensive kernel information"
    echo ""
}

# Function to find kernel binary
find_kernel() {
    local kernel_file=$(ls ${KERNEL_BIN} 2>/dev/null | head -1)
    if [ -z "$kernel_file" ]; then
        echo -e "${RED}Error: Kernel binary not found!${NC}"
        echo "Expected pattern: ${KERNEL_BIN}"
        exit 1
    fi
    echo "$kernel_file"
}

# Function to show kernel size information
show_size() {
    local kernel_file=$(find_kernel)
    
    echo -e "${BLUE}=== Kernel Size Information ===${NC}"
    echo -e "${GREEN}Kernel Binary:${NC} $kernel_file"
    echo ""
    
    # Basic file size
    if command -v ls >/dev/null 2>&1; then
        echo -e "${YELLOW}File Size:${NC}"
        ls -lh "$kernel_file" | awk '{print "  Total: " $5 " (" $5 " bytes)"}'
        echo ""
    fi
    
    # Detailed size information using 'size' command if available
    if command -v size >/dev/null 2>&1; then
        echo -e "${YELLOW}Section Sizes:${NC}"
        size "$kernel_file" | while read line; do
            echo "  $line"
        done
        echo ""
    fi
    
    # File type information
    if command -v file >/dev/null 2>&1; then
        echo -e "${YELLOW}File Type:${NC}"
        file "$kernel_file" | sed 's/^/  /'
        echo ""
    fi
    
    # Object file sizes
    if [ -d "$OBJDIR" ]; then
        echo -e "${YELLOW}Object File Sizes:${NC}"
        find "$OBJDIR" -name "*.o" -exec ls -lh {} \; | \
            awk '{print "  " $9 ": " $5}' | sort
        echo ""
    fi
}

# Function to show symbol table
show_symbols() {
    local kernel_file=$(find_kernel)
    
    echo -e "${BLUE}=== Kernel Symbol Table ===${NC}"
    echo -e "${GREEN}Kernel Binary:${NC} $kernel_file"
    echo ""
    
    if command -v nm >/dev/null 2>&1; then
        echo -e "${YELLOW}Symbols (first 50):${NC}"
        nm "$kernel_file" | head -50 | while read line; do
            echo "  $line"
        done
        echo ""
        
        echo -e "${YELLOW}Symbol Summary:${NC}"
        echo "  Total symbols: $(nm "$kernel_file" | wc -l)"
        echo "  Text symbols: $(nm "$kernel_file" | grep ' T ' | wc -l)"
        echo "  Data symbols: $(nm "$kernel_file" | grep ' D ' | wc -l)"
        echo "  BSS symbols: $(nm "$kernel_file" | grep ' B ' | wc -l)"
    else
        echo -e "${RED}Error: 'nm' command not available${NC}"
    fi
}

# Function to show sections
show_sections() {
    local kernel_file=$(find_kernel)
    
    echo -e "${BLUE}=== Kernel Sections ===${NC}"
    echo -e "${GREEN}Kernel Binary:${NC} $kernel_file"
    echo ""
    
    if command -v readelf >/dev/null 2>&1; then
        echo -e "${YELLOW}Section Headers:${NC}"
        readelf -S "$kernel_file" | while read line; do
            echo "  $line"
        done
    elif command -v objdump >/dev/null 2>&1; then
        echo -e "${YELLOW}Section Headers (objdump):${NC}"
        objdump -h "$kernel_file" | while read line; do
            echo "  $line"
        done
    else
        echo -e "${RED}Error: Neither 'readelf' nor 'objdump' available${NC}"
    fi
}

# Function to show disassembly
show_objdump() {
    local kernel_file=$(find_kernel)
    
    echo -e "${BLUE}=== Kernel Disassembly (first 100 instructions) ===${NC}"
    echo -e "${GREEN}Kernel Binary:${NC} $kernel_file"
    echo ""
    
    if command -v objdump >/dev/null 2>&1; then
        objdump -d "$kernel_file" | head -200 | while read line; do
            echo "  $line"
        done
    else
        echo -e "${RED}Error: 'objdump' command not available${NC}"
    fi
}

# Function to show hex dump
show_hexdump() {
    local kernel_file=$(find_kernel)
    
    echo -e "${BLUE}=== Kernel Hex Dump (first 512 bytes) ===${NC}"
    echo -e "${GREEN}Kernel Binary:${NC} $kernel_file"
    echo ""
    
    if command -v hexdump >/dev/null 2>&1; then
        hexdump -C "$kernel_file" | head -32 | while read line; do
            echo "  $line"
        done
    elif command -v xxd >/dev/null 2>&1; then
        xxd "$kernel_file" | head -32 | while read line; do
            echo "  $line"
        done
    else
        echo -e "${RED}Error: Neither 'hexdump' nor 'xxd' available${NC}"
    fi
}

# Function to show comprehensive information
show_info() {
    show_size
    echo ""
    show_sections
}

# Main script logic
case "${1:-}" in
    "size")
        show_size
        ;;
    "symbols")
        show_symbols
        ;;
    "sections")
        show_sections
        ;;
    "objdump")
        show_objdump
        ;;
    "hexdump")
        show_hexdump
        ;;
    "info")
        show_info
        ;;
    *)
        show_usage
        exit 1
        ;;
esac