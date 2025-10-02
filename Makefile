# Level OS - Makefile
# Build system for Level OS kernel

# Version information
VERSION_MAJOR = 0
VERSION_MINOR = 1
VERSION_PATCH = 0
VERSION = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)

# Default target architecture
DEFAULT_HOST = i686-elf
HOST ?= $(DEFAULT_HOST)
HOSTARCH = i686

# Directories
SRCDIR = src
INCDIR = include
BUILDDIR = build
OBJDIR = $(BUILDDIR)/obj
CONFIGDIR = config
TESTSDIR = tests
TOOLSDIR = tools
SCRIPTSDIR = scripts

# Compiler and tools (Windows compatible)
# For now, we'll use the system GCC and try to make it work for kernel development
CC = gcc
AS = nasm
LD = gcc

# Compiler flags
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -I$(INCDIR) -m32 \
         -DVERSION_MAJOR=$(VERSION_MAJOR) -DVERSION_MINOR=$(VERSION_MINOR) -DVERSION_PATCH=$(VERSION_PATCH)
ASFLAGS = -felf32
LDFLAGS = -ffreestanding -O2 -nostdlib -lgcc -m32

# Source files
BOOT_SRC = $(SRCDIR)/boot/boot.s
KERNEL_SOURCES = $(shell find $(SRCDIR) -name "*.c" -not -path "$(SRCDIR)/lib/*")
LIB_SOURCES = $(shell find $(SRCDIR)/lib -name "*.c" 2>/dev/null || true)
TEST_SOURCES = $(shell find $(TESTSDIR) -name "*.c" 2>/dev/null || true)

KERNEL_OBJECTS = $(KERNEL_SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)
LIB_OBJECTS = $(LIB_SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)
TEST_OBJECTS = $(TEST_SOURCES:$(TESTSDIR)/%.c=$(OBJDIR)/tests/%.o)
BOOT_OBJECT = $(OBJDIR)/boot/boot.o

# Linker script
LINKER_SCRIPT = $(CONFIGDIR)/linker.ld

# Target
KERNEL_BIN = $(BUILDDIR)/level-os-$(VERSION).bin
ISO_FILE = $(BUILDDIR)/level-os-$(VERSION).iso

# Default target
.PHONY: all clean run run-vnc test iso version info help debug setup lib-only

all: version lib $(KERNEL_BIN)

# Build only the library
lib: $(LIB_OBJECTS)

# Create object directories
$(OBJDIR):
	mkdir -p $(OBJDIR)
	mkdir -p $(OBJDIR)/boot
	mkdir -p $(OBJDIR)/kernel
	mkdir -p $(OBJDIR)/drivers
	mkdir -p $(OBJDIR)/lib
	mkdir -p $(OBJDIR)/tests

# Compile assembly boot code
$(BOOT_OBJECT): $(BOOT_SRC) | $(OBJDIR)
	$(AS) $(ASFLAGS) $< -o $@

# Compile C source files
$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Link kernel
$(KERNEL_BIN): $(BOOT_OBJECT) $(KERNEL_OBJECTS) $(LIB_OBJECTS) $(LINKER_SCRIPT) | $(OBJDIR)
	$(LD) -T $(LINKER_SCRIPT) -o $@ $(BOOT_OBJECT) $(KERNEL_OBJECTS) $(LIB_OBJECTS) $(LDFLAGS)
	grub-file --is-x86-multiboot $(KERNEL_BIN) || echo "Warning: Not a valid multiboot file"

# Clean build files
clean:
	rm -rf $(BUILDDIR)

# Run in QEMU locally
run: $(KERNEL_BIN)
	@echo "Starting LevelOS $(VERSION) in QEMU..."
	qemu-system-i386 -kernel $(KERNEL_BIN)

# Run in QEMU with VNC accessible from network
run-vnc: $(KERNEL_BIN)
	@echo "Starting LevelOS $(VERSION) with VNC access..."
	@echo "VNC Address: $$(hostname -I | awk '{print $$1}'):5900"
	@echo "Press Ctrl+C to stop"
	qemu-system-i386 -kernel $(KERNEL_BIN) -vnc 0.0.0.0:0

# Quick test build and run
test: clean all run

# Run setup script
setup:
	@echo "Running development environment setup..."
	$(SCRIPTSDIR)/setup-dev.sh

# Debug utilities
debug:
	@echo "Available debug commands:"
	@echo "  make debug-objdump  - Disassemble kernel"
	@echo "  make debug-size     - Show binary size"
	@echo "  make debug-symbols  - Show symbol table"
	$(TOOLSDIR)/debug.sh

debug-objdump: $(KERNEL_BIN)
	$(TOOLSDIR)/debug.sh objdump

debug-size: $(KERNEL_BIN)
	$(TOOLSDIR)/debug.sh size

debug-symbols: $(KERNEL_BIN)
	$(TOOLSDIR)/debug.sh symbols

# Create ISO image (requires grub tools)
iso: $(KERNEL_BIN)
	@echo "Creating bootable ISO for LevelOS $(VERSION)..."
	mkdir -p $(BUILDDIR)/iso/boot/grub
	cp $(KERNEL_BIN) $(BUILDDIR)/iso/boot/level-os.bin
	echo 'menuentry "Level OS $(VERSION)" {' > $(BUILDDIR)/iso/boot/grub/grub.cfg
	echo '    multiboot /boot/level-os.bin' >> $(BUILDDIR)/iso/boot/grub/grub.cfg
	echo '}' >> $(BUILDDIR)/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO_FILE) $(BUILDDIR)/iso
	@echo "ISO created: $(ISO_FILE)"

# Install dependencies (for Ubuntu/Debian)
install-deps:
	sudo apt update
	sudo apt install build-essential nasm grub-pc-bin grub-common xorriso qemu-system-x86

# Show version information
version:
	@echo "LevelOS Version $(VERSION)"

# Show comprehensive system information  
info:
	@echo "=================================="
	@echo "      LevelOS Build Information"
	@echo "=================================="
	@echo "Version: $(VERSION)"
	@echo "Kernel Binary: $(KERNEL_BIN)"
	@echo "ISO File: $(ISO_FILE)"
	@echo ""
	@echo "Build Tools:"
	@echo "  GCC: $$(gcc --version | head -1)"
	@echo "  NASM: $$(nasm --version)"
	@echo "  Make: $$(make --version | head -1)"
	@echo "  QEMU: $$(qemu-system-i386 --version | head -1)"
	@echo ""
	@echo "Build Configuration:"
	@echo "  Host: $(HOST)"
	@echo "  Architecture: $(HOSTARCH)"
	@echo "  Source Dir: $(SRCDIR)"
	@echo "  Include Dir: $(INCDIR)"
	@echo "  Build Dir: $(BUILDDIR)"
	@echo ""
	@if [ -f "$(KERNEL_BIN)" ]; then \
		echo "Current Build:"; \
		echo "  Kernel: $$(ls -lh $(KERNEL_BIN) | awk '{print $$5}') ($$(file $(KERNEL_BIN) | cut -d: -f2 | cut -d, -f1-2))"; \
	else \
		echo "Status: Not built (run 'make' to build)"; \
	fi
	@if [ -f "$(ISO_FILE)" ]; then \
		echo "  ISO: $$(ls -lh $(ISO_FILE) | awk '{print $$5}')"; \
	fi

# Help target
help:
	@echo "LevelOS Build System v$(VERSION)"
	@echo "================================"
	@echo "Build Targets:"
	@echo "  all        - Build the kernel (default)"
	@echo "  lib        - Build only the library"
	@echo "  clean      - Remove build files"
	@echo ""
	@echo "Run Targets:"
	@echo "  run        - Run kernel in QEMU locally"
	@echo "  run-vnc    - Run kernel with VNC access"
	@echo "  test       - Clean, build, and run"
	@echo ""
	@echo "Distribution:"
	@echo "  iso        - Create bootable ISO"
	@echo ""
	@echo "Development:"
	@echo "  setup      - Setup development environment"
	@echo "  debug      - Show debug options"
	@echo "  version    - Show version"
	@echo "  info       - Show build information"
	@echo ""
	@echo "Quick Start:"
	@echo "  make setup     # First time setup"
	@echo "  make && make run-vnc"
	@echo "  Include Dir: $(INCDIR)"
	@echo "  Build Dir: $(BUILDDIR)"