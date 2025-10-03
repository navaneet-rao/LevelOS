# Level OS - Makefile
# Build system for Level OS kernel

# ============================================================================
# VERSION MANAGEMENT
# ============================================================================
# Single source of truth for versioning
# - CODE VERSION: Read from VERSION file (semantic versioning: major.minor.patch)
# - BUILD NUMBER: Read from BUILD_NUMBER file (incremental build counter)
# ============================================================================

# Read version from VERSION file
VERSION := $(shell cat VERSION 2>/dev/null || echo "0.1.1")
VERSION_MAJOR := $(shell cat VERSION 2>/dev/null | cut -d. -f1 || echo "0")
VERSION_MINOR := $(shell cat VERSION 2>/dev/null | cut -d. -f2 || echo "1")
VERSION_PATCH := $(shell cat VERSION 2>/dev/null | cut -d. -f3 || echo "1")

# Read build number from BUILD_NUMBER file
BUILD_NUMBER := $(shell cat BUILD_NUMBER 2>/dev/null || echo "1")

# Full version string with build number
FULL_VERSION = $(VERSION)+build$(BUILD_NUMBER)

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
         -DVERSION_MAJOR=$(VERSION_MAJOR) -DVERSION_MINOR=$(VERSION_MINOR) \
         -DVERSION_PATCH=$(VERSION_PATCH) -DBUILD_NUMBER=$(BUILD_NUMBER)
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

# ============================================================================
# VERSION MANAGEMENT TARGETS
# ============================================================================

# Show version information
version:
	@echo "╔════════════════════════════════════════════════════╗"
	@echo "║          LevelOS Version Information               ║"
	@echo "╠════════════════════════════════════════════════════╣"
	@echo "║ Code Version:   $(VERSION)                              ║"
	@echo "║ Build Number:   $(BUILD_NUMBER)                                  ║"
	@echo "║ Full Version:   $(FULL_VERSION)                       ║"
	@echo "╚════════════════════════════════════════════════════╝"

# Increment build number (call this before each build)
bump-build:
	@echo "Current build: $(BUILD_NUMBER)"
	@echo $$(($(BUILD_NUMBER) + 1)) > BUILD_NUMBER
	@echo "New build: $$(cat BUILD_NUMBER)"

# Update patch version (e.g., 0.1.1 -> 0.1.2)
bump-patch:
	@echo "Current version: $(VERSION)"
	@echo "$(VERSION_MAJOR).$(VERSION_MINOR).$$(($(VERSION_PATCH) + 1))" > VERSION
	@echo "1" > BUILD_NUMBER
	@echo "New version: $$(cat VERSION) (build reset to 1)"

# Update minor version (e.g., 0.1.1 -> 0.2.0)
bump-minor:
	@echo "Current version: $(VERSION)"
	@echo "$(VERSION_MAJOR).$$(($(VERSION_MINOR) + 1)).0" > VERSION
	@echo "1" > BUILD_NUMBER
	@echo "New version: $$(cat VERSION) (build reset to 1)"

# Update major version (e.g., 0.1.1 -> 1.0.0)
bump-major:
	@echo "Current version: $(VERSION)"
	@echo "$$(($(VERSION_MAJOR) + 1)).0.0" > VERSION
	@echo "1" > BUILD_NUMBER
	@echo "New version: $$(cat VERSION) (build reset to 1)"

# Update documentation files with current version
update-docs:
	@echo "Updating documentation to version $(VERSION)..."
	@if [ -f README.md.bak ]; then rm README.md.bak; fi
	@if [ -f docs/development.md.bak ]; then rm docs/development.md.bak; fi
	@if [ -f config/build.conf.bak ]; then rm config/build.conf.bak; fi
	@# Find old version in README (look for badge version)
	@OLD_VERSION=$$(grep -oP 'version-\K[0-9]+\.[0-9]+\.[0-9]+' README.md | head -1); \
	if [ -n "$$OLD_VERSION" ]; then \
		echo "  Old version: $$OLD_VERSION"; \
		echo "  New version: $(VERSION)"; \
		sed -i.bak "s/$$OLD_VERSION/$(VERSION)/g" README.md && \
		sed -i.bak "s/level-os-$$OLD_VERSION/level-os-$(VERSION)/g" README.md && \
		sed -i.bak "s/$$OLD_VERSION/$(VERSION)/g" docs/development.md && \
		sed -i.bak "s/level-os-$$OLD_VERSION/level-os-$(VERSION)/g" docs/development.md && \
		sed -i.bak "s/VERSION_MAJOR=[0-9]*/VERSION_MAJOR=$(VERSION_MAJOR)/g" config/build.conf && \
		sed -i.bak "s/VERSION_MINOR=[0-9]*/VERSION_MINOR=$(VERSION_MINOR)/g" config/build.conf && \
		sed -i.bak "s/VERSION_PATCH=[0-9]*/VERSION_PATCH=$(VERSION_PATCH)/g" config/build.conf && \
		echo "  ✓ README.md updated"; \
		echo "  ✓ docs/development.md updated"; \
		echo "  ✓ config/build.conf updated"; \
		rm -f README.md.bak docs/development.md.bak config/build.conf.bak; \
	else \
		echo "  ✗ Could not detect old version"; \
	fi

# Bump version and automatically update docs
bump-patch-docs: bump-patch update-docs
bump-minor-docs: bump-minor update-docs
bump-major-docs: bump-major update-docs

# ============================================================================

# Show comprehensive system information  
info:
	@echo "=================================="
	@echo "      LevelOS Build Information"
	@echo "=================================="
	@echo "Code Version: $(VERSION)"
	@echo "Build Number: $(BUILD_NUMBER)"
	@echo "Full Version: $(FULL_VERSION)"
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
	@echo "LevelOS Build System v$(FULL_VERSION)"
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
	@echo "Version Management:"
	@echo "  version       - Show current version"
	@echo "  bump-build    - Increment build number"
	@echo "  bump-patch    - Increment patch version (0.1.1 -> 0.1.2)"
	@echo "  bump-minor    - Increment minor version (0.1.1 -> 0.2.0)"
	@echo "  bump-major    - Increment major version (0.1.1 -> 1.0.0)"
	@echo ""
	@echo "Documentation Updates:"
	@echo "  update-docs        - Update README & docs with current VERSION"
	@echo "  bump-patch-docs    - Bump patch + auto-update docs"
	@echo "  bump-minor-docs    - Bump minor + auto-update docs"
	@echo "  bump-major-docs    - Bump major + auto-update docs"
	@echo ""
	@echo "Development:"
	@echo "  setup      - Setup development environment"
	@echo "  debug      - Show debug options"
	@echo "  info       - Show build information"
	@echo ""
	@echo "Quick Start:"
	@echo "  make setup     # First time setup"
	@echo "  make && make run-vnc"
	@echo "  Include Dir: $(INCDIR)"
	@echo "  Build Dir: $(BUILDDIR)"