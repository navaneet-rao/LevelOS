# LevelOS

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![Version](https://img.shields.io/badge/version-0.2.0-blue)]()
[![License](https://img.shields.io/badge/license-MIT-green)]()
[![Architecture](https://img.shields.io/badge/arch-i686-orange)]()

A modern, educational operating system kernel written in C and Assembly for learning OS development fundamentals.

## 🚀 Quick Start

### Prerequisites
- Linux-based development environment (Ubuntu/Debian recommended)
- Administrative privileges for dependency installation

### Setup & Build
```bash
# Clone and navigate to project
cd /path/to/LevelOS

# Setup development environment (first time only)
make setup

# Build the kernel
make

# Run in QEMU with VNC access
make run-vnc
```

**Connect to VNC:** Open your VNC client and connect to `<server-ip>:5900` to see LevelOS boot!

## 📁 Project Structure

```
LevelOS/
├── 📂 src/                    # Source code
│   ├── boot/                  # Bootloader assembly code
│   │   └── boot.s            # Multiboot-compliant boot code
│   ├── kernel/               # Kernel core implementation
│   │   └── kernel.c          # Main kernel entry point
│   ├── drivers/              # Hardware drivers
│   │   └── terminal.c        # VGA text mode terminal
│   └── lib/                  # Standard library implementations
│       └── string.c          # String manipulation functions
├── 📂 include/               # Header files
│   ├── drivers/              # Driver interface headers
│   ├── kernel/               # Kernel API headers  
│   └── lib/                  # Library headers (types.h, string.h)
├── 📂 config/                # Configuration files
├── VERSION                   # Version file (single source of truth)
│   ├── build.conf           # Build system configuration
│   ├── test.conf            # Testing framework configuration
│   └── linker.ld            # GNU LD linker script
├── 📂 tests/                 # Test suite
│   ├── test_framework.h/.c  # Custom testing framework
│   └── test_string.c        # String library unit tests
├── 📂 tools/                 # Development utilities
│   └── debug.sh             # Debugging helper script
├── 📂 scripts/               # Build automation scripts
│   └── setup-dev.sh         # Development environment setup
├── 📂 docs/                  # Documentation
│   ├── architecture.md      # System architecture documentation
│   └── development.md       # Development guidelines
└── 📂 build/                 # Build output (auto-generated)
    ├── level-os-0.2.0.bin   # Final kernel binary
    ├── level-os-0.2.0.iso   # Bootable ISO image
    └── obj/                  # Object files
```

## 🛠️ Build System

LevelOS uses a modern, versioned Makefile-based build system:

### Core Targets
```bash
make                # Build the kernel (default)
make clean          # Remove all build artifacts
make lib            # Build only the standard library
```

### Testing & Debugging  
```bash
make run            # Run kernel locally in QEMU
make run-vnc        # Run with network-accessible VNC
make test           # Clean, build, and run pipeline

make debug          # Show available debug options
make debug-size     # Display binary size information
make debug-symbols  # Show kernel symbol table
```

### Distribution
```bash
make iso            # Create bootable ISO image
```

### Development
```bash
make setup          # Setup development environment
make version        # Display current version
make info           # Show comprehensive build information
make help           # Display all available targets
```

## 🏗️ Architecture

### Boot Process
1. **GRUB Multiboot**: Compliant multiboot header for GRUB bootloader
2. **Protected Mode**: 32-bit protected mode initialization
3. **Stack Setup**: 16KB stack allocation with proper alignment
4. **Kernel Entry**: Transfer control to `kernel_main()`

### Memory Layout
- **Text Segment**: Kernel code and read-only data
- **Data Segment**: Initialized global variables
- **BSS Segment**: Uninitialized data (stack, heap)
- **VGA Buffer**: Memory-mapped display buffer at 0xB8000

### Key Components
- **Terminal Driver**: VGA text mode with color support
- **String Library**: Essential string manipulation functions
- **Memory Management**: Basic memory operations (memset, memcpy, memcmp)

## 🔧 Configuration

### Build Configuration (`config/build.conf`)
```properties
VERSION_MAJOR=0        # Major version number
VERSION_MINOR=1        # Minor version number  
VERSION_PATCH=0        # Patch version number
TARGET_ARCH=i686       # Target architecture
TARGET_FORMAT=elf      # Output format
```

### Test Configuration (`config/test.conf`)
```ini
[unit_tests]
enabled = true         # Enable unit testing
framework = custom     # Use custom test framework

[integration_tests]
enabled = true         # Enable integration tests
qemu_path = qemu-system-i386
timeout = 30          # Test timeout in seconds
```

## 🧪 Testing

LevelOS includes a custom testing framework for kernel development:

```bash
# Run all tests
make test

# Build test framework only
make lib
```

### Test Structure
- **Unit Tests**: Test individual functions (string library, memory operations)
- **Integration Tests**: Test kernel components working together
- **Hardware Tests**: Test driver functionality in QEMU

## 🚀 Running LevelOS

### Local Development
```bash
make run              # Local QEMU window
```

### Remote Development (VNC)
```bash
make run-vnc          # Network-accessible VNC server
```
Then connect with any VNC client to `<server-ip>:5900`

### Physical Hardware
1. Create bootable ISO: `make iso`
2. Burn `build/level-os-0.2.0.iso` to USB/CD
3. Boot from USB/CD on target machine

## 📊 Development Status

### Current Version: 0.2.0

**Implemented Features:**
- ✅ Multiboot-compliant bootloader
- ✅ VGA text mode terminal with colors
- ✅ Basic string manipulation library
- ✅ Memory management utilities
- ✅ Versioned build system
- ✅ QEMU testing environment
- ✅ Bootable ISO generation

**Planned Features:**
- 🔄 Interrupt handling (IDT setup)
- 🔄 Keyboard driver
- 🔄 Basic memory allocator
- 🔄 Process management
- 🔄 File system support

### Build Metrics
- **Kernel Size**: ~9.2KB
- **Components**: 4 (Boot, Kernel, Drivers, Library)
- **Test Coverage**: String library functions
- **Supported Architectures**: i686 (32-bit x86)

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes following the coding standards
4. Add tests for new functionality
5. Run `make test` to ensure all tests pass
6. Submit a pull request

### Coding Standards
- **C Standard**: GNU99
- **Formatting**: 4-space indentation, no tabs
- **Naming**: snake_case for functions, UPPER_CASE for constants
- **Comments**: Doxygen-style documentation for functions

### Adding New Features
1. Update version in `config/build.conf`
2. Add source files to appropriate `src/` subdirectory
3. Create corresponding headers in `include/`
4. Add unit tests in `tests/`
5. Update documentation

## 📚 Learning Resources

### OS Development
- [OSDev Wiki](https://wiki.osdev.org/) - Comprehensive OS development resource
- [Intel Software Developer Manuals](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html)
- [Multiboot Specification](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html)

### Tools & Debugging
- [QEMU Documentation](https://www.qemu.org/docs/master/)
- [GDB for Kernel Debugging](https://wiki.osdev.org/Kernel_Debugging#Using_GDB)
- [NASM Documentation](https://www.nasm.us/docs.php)

## 🐛 Troubleshooting

### Common Issues

**Build Fails - Missing Dependencies**
```bash
make setup    # Install required build tools
```

**QEMU Won't Start**
```bash
# Check QEMU installation
qemu-system-i386 --version

# Install if missing
sudo apt install qemu-system-x86
```

**VNC Connection Failed**
```bash
# Check if VNC server is running
ss -tlnp | grep 5900

# Restart with VNC
make clean && make run-vnc
```

**Multiboot Error**
```bash
# Verify multiboot compliance
grub-file --is-x86-multiboot build/level-os-0.2.0.bin
```

### Debug Information
```bash
make debug-size     # Check binary size
make debug-symbols  # Examine symbol table
tools/debug.sh objdump  # Disassemble kernel
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OSDev Community** - For excellent documentation and tutorials
- **GRUB Project** - For the multiboot specification
- **QEMU Project** - For providing excellent emulation capabilities
- **GNU Project** - For GCC, binutils, and development tools

---

**Happy OS Development! 🎉**

For questions, issues, or contributions, please open an issue or pull request on the project repository.
- Kernel architecture

## Architecture

- **Language**: C with Assembly for low-level operations
- **Target**: x86 architecture (32-bit initially)
- **Build System**: Cross-compilation with GCC

## Project Structure

```
LevelOS/
├── src/
│   ├── boot/          # Boot loader and initialization
│   │   └── boot.asm   # Assembly boot code
│   └── kernel/        # Kernel source code
│       ├── kernel.c   # Main kernel entry point
│       ├── kernel.h   # Kernel headers
│       ├── memory.c   # Memory management
│       ├── memory.h
│       ├── terminal.c # Terminal/display functions
│       ├── terminal.h
│       └── linker.ld  # Linker script
├── tools/             # Development tools
│   ├── setup-cross-compiler.sh
│   └── setup-windows.ps1
├── Makefile          # Build configuration
└── README.md         # This file
```

## Getting Started

### Prerequisites

1. Cross-compiler (i686-elf-gcc)
2. NASM assembler
3. QEMU for testing (optional but recommended)

### Building

```bash
make all
```

### Running

```bash
make run
```

## Learning Journey

This project follows a step-by-step approach:

1. **Phase 1**: Basic boot loader and "Hello World" kernel
2. **Phase 2**: Terminal output and basic I/O
3. **Phase 3**: Memory management basics
4. **Phase 4**: Interrupt handling
5. **Phase 5**: Simple shell and user input

## Resources

- [OSDev Wiki](https://wiki.osdev.org/)
- [James Molloy's Kernel Development Tutorial](http://www.jamesmolloy.co.uk/tutorial_html/)
- [Little OS Book](https://littleosbook.github.io/)

## License

This project is for educational purposes.