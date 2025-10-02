# LevelOS Development Guide

## Development Environment Setup

### Prerequisites

#### Operating System
- **Recommended**: Ubuntu 20.04+ or Debian 11+
- **Supported**: Any Linux distribution with package management
- **Minimum Requirements**: 2GB RAM, 5GB disk space

#### Dependencies
```bash
# Automated setup (recommended)
make setup

# Manual installation
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
```

### Verification
```bash
# Verify toolchain installation
gcc --version       # Should show GCC 9.0+
nasm --version      # Should show NASM 2.14+
qemu-system-i386 --version  # Should show QEMU 4.0+
grub-mkrescue --version     # Should show GRUB 2.04+
```

## Development Workflow

### Getting Started
```bash
# 1. Clone repository
git clone <repository-url>
cd LevelOS

# 2. Setup environment
make setup

# 3. Build and test
make clean && make
make run-vnc

# 4. Verify build
make info
```

### Development Cycle
1. **Edit source code** in appropriate `src/` directory
2. **Update headers** in corresponding `include/` directory
3. **Add tests** in `tests/` directory
4. **Build and test** using `make test`
5. **Debug** using `make debug-*` targets
6. **Commit changes** with descriptive messages

## Coding Standards

### C Code Style

#### Formatting
```c
// 4-space indentation, no tabs
void example_function(int parameter) {
    if (condition) {
        do_something();
    }
    
    for (int i = 0; i < count; i++) {
        process_item(i);
    }
}
```

#### Naming Conventions
```c
// Functions: snake_case
void terminal_write_string(const char* str);

// Variables: snake_case
size_t string_length;
uint8_t terminal_color;

// Constants: UPPER_CASE
#define VGA_COLOR_WHITE 15
#define KERNEL_STACK_SIZE 16384

// Types: snake_case with _t suffix
typedef struct {
    uint16_t* buffer;
    size_t row;
} terminal_state_t;
```

#### Header Guards
```c
#ifndef KERNEL_TERMINAL_H
#define KERNEL_TERMINAL_H

// Header content here

#endif // KERNEL_TERMINAL_H
```

### Assembly Code Style

#### NASM Formatting
```asm
; Use lowercase for instructions
mov eax, ebx
call kernel_main

; Use uppercase for constants
MAGIC    equ 0x1BADB002
FLAGS    equ MBALIGN | MEMINFO

; Align sections properly
section .text
align 4
```

#### Comments
```asm
; Single line comments
; Explain complex operations

;; Section headers
;; Major code sections
```

### Documentation Standards

#### Function Documentation
```c
/**
 * @brief Writes a string to the terminal
 * @param str Null-terminated string to write
 * @return Number of characters written
 */
size_t terminal_writestring(const char* str);
```

#### File Headers
```c
/* LevelOS - Terminal Driver
 * VGA text mode terminal implementation
 * 
 * Author: LevelOS Team
 * Version: 0.1.0
 */
```

## Build System

### Makefile Structure

#### Core Variables
```makefile
VERSION_MAJOR = 0
VERSION_MINOR = 1
VERSION_PATCH = 0

SRCDIR = src
INCDIR = include  
BUILDDIR = build
```

#### Target Categories
1. **Build Targets**: `all`, `lib`, `clean`
2. **Run Targets**: `run`, `run-vnc`, `test`
3. **Distribution Targets**: `iso`
4. **Development Targets**: `debug`, `info`, `help`

### Configuration Management

#### Build Configuration (`config/build.conf`)
```properties
# Version control
VERSION_MAJOR=0
VERSION_MINOR=1
VERSION_PATCH=0

# Compiler settings
CC=gcc
CFLAGS=-std=gnu99 -ffreestanding -O2 -Wall -Wextra -m32

# Target architecture
TARGET_ARCH=i686
TARGET_FORMAT=elf
```

#### Linker Script (`config/linker.ld`)
- Defines memory layout
- Sets entry point
- Configures section alignment
- Ensures multiboot compliance

## Testing Framework

### Unit Testing

#### Test Structure
```c
#include "test_framework.h"
#include "lib/string.h"

void test_strlen(void) {
    TEST_ASSERT_EQ(strlen("hello"), 5, "strlen basic test");
    TEST_ASSERT_EQ(strlen(""), 0, "strlen empty string");
}

void run_string_tests(void) {
    test_init();
    test_strlen();
    test_summary();
}
```

#### Test Macros
```c
TEST_ASSERT(condition, name)        // Basic assertion
TEST_ASSERT_EQ(a, b, name)         // Equality test
TEST_ASSERT_NEQ(a, b, name)        // Inequality test
```

### Integration Testing

#### QEMU Testing
```bash
# Automated testing
make test

# Manual testing with timeout
timeout 30s make run-vnc
```

#### Test Configuration (`config/test.conf`)
```ini
[unit_tests]
enabled = true
framework = custom
output_dir = build/tests

[integration_tests]
enabled = true
qemu_path = qemu-system-i386
timeout = 30
```

## Debugging

### Debug Workflow

#### Build Analysis
```bash
# Check binary size and sections
make debug-size

# Examine symbol table
make debug-symbols

# Disassemble kernel
tools/debug.sh objdump
```

#### QEMU Debugging
```bash
# Run with GDB server
qemu-system-i386 -kernel build/level-os-0.1.0.bin -s -S

# In another terminal
gdb -ex "target remote localhost:1234" \
    -ex "symbol-file build/level-os-0.1.0.bin"
```

### Common Debug Commands

#### GDB Commands
```gdb
(gdb) info registers     # Show CPU registers
(gdb) x/10i $eip        # Disassemble at current instruction
(gdb) bt                # Show stack trace
(gdb) p variable_name   # Print variable value
```

#### Memory Analysis
```bash
# Examine ELF headers
readelf -a build/level-os-0.1.0.bin

# Check multiboot compliance  
grub-file --is-x86-multiboot build/level-os-0.1.0.bin

# Hexdump binary
hexdump -C build/level-os-0.1.0.bin | head
```

## Adding New Features

### Adding a New Driver

#### 1. Create Source Files
```bash
# Create driver source
touch src/drivers/keyboard.c
touch include/drivers/keyboard.h
```

#### 2. Implement Driver Interface
```c
// include/drivers/keyboard.h
#ifndef DRIVERS_KEYBOARD_H
#define DRIVERS_KEYBOARD_H

void keyboard_initialize(void);
char keyboard_getchar(void);
bool keyboard_available(void);

#endif
```

#### 3. Update Build System
The Makefile automatically discovers new `.c` files in `src/`, no changes needed.

#### 4. Add Tests
```c
// tests/test_keyboard.c
#include "test_framework.h"
#include "drivers/keyboard.h"

void test_keyboard_init(void) {
    keyboard_initialize();
    TEST_ASSERT(keyboard_available() == false, "keyboard initial state");
}
```

### Adding System Calls

#### 1. Define Interface
```c
// include/kernel/syscalls.h
#define SYS_WRITE 1
#define SYS_READ  2

int syscall(int number, ...);
```

#### 2. Implement Handler
```c
// src/kernel/syscalls.c
int syscall_handler(int number, int arg1, int arg2, int arg3) {
    switch (number) {
        case SYS_WRITE:
            return sys_write(arg1, arg2, arg3);
        default:
            return -1;
    }
}
```

#### 3. Update Interrupt Handling
```asm
; src/boot/interrupts.s
int_0x80:
    push eax
    call syscall_handler
    pop eax
    iret
```

## Contribution Guidelines

### Code Review Process

#### Before Submitting
1. **Build successfully**: `make clean && make`
2. **Pass all tests**: `make test`  
3. **Follow coding standards**: Check style consistency
4. **Update documentation**: Add/update relevant docs
5. **Add tests**: Cover new functionality

#### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature  
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
```

### Git Workflow

#### Branch Naming
```bash
feature/keyboard-driver     # New features
bugfix/terminal-colors      # Bug fixes  
docs/architecture-update    # Documentation
refactor/memory-management  # Code refactoring
```

#### Commit Messages
```bash
# Format: type(scope): description
feat(drivers): add PS/2 keyboard driver
fix(terminal): correct color attribute calculation  
docs(readme): update build instructions
refactor(lib): optimize string length function
```

## Performance Guidelines

### Memory Management
- **Stack Usage**: Keep local variables minimal
- **Global Variables**: Use sparingly, prefer local scope
- **Buffer Sizes**: Use appropriate sizes for functionality

### Code Optimization
```c
// Prefer register variables for frequently used data
register uint32_t counter;

// Use inline for small, frequently called functions
static inline uint16_t vga_entry(char c, uint8_t color) {
    return (uint16_t)c | (uint16_t)color << 8;
}

// Avoid unnecessary function calls in loops
size_t len = strlen(str);  // Calculate once
for (size_t i = 0; i < len; i++) {
    // Process str[i]
}
```

### Build Optimization
```makefile
# Debug build (default)
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -m32

# Release build  
CFLAGS = -std=gnu99 -ffreestanding -O3 -m32 -DNDEBUG
```

## Troubleshooting

### Common Build Issues

#### Multiboot Error
```bash
# Problem: "Warning: Not a valid multiboot file"
# Solution: Check boot.s multiboot header
grub-file --is-x86-multiboot build/level-os-0.1.0.bin
```

#### Linking Errors
```bash
# Problem: Undefined reference to 'function_name'
# Solution: Check function implementation and header includes
nm build/obj/module.o | grep function_name
```

#### VNC Connection Failed
```bash
# Problem: Can't connect to VNC
# Solution: Check if QEMU is running and port is open
ss -tlnp | grep 5900
make clean && make run-vnc
```

### Debug Checklist

1. **Build Clean**: `make clean && make`
2. **Check Symbols**: `make debug-symbols`
3. **Verify Size**: `make debug-size`
4. **Test Basic Boot**: `make run`
5. **Check Multiboot**: `grub-file --is-x86-multiboot <binary>`

## Resources

### Official Documentation
- [GNU GCC Manual](https://gcc.gnu.org/onlinedocs/)
- [NASM Documentation](https://www.nasm.us/docs.php)
- [GNU Make Manual](https://www.gnu.org/software/make/manual/)
- [QEMU Documentation](https://www.qemu.org/docs/master/)

### OS Development Resources
- [OSDev Wiki](https://wiki.osdev.org/) - Primary reference
- [Intel x86 Manuals](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html)
- [Multiboot Specification](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html)

### Learning Materials
- [Operating Systems: Three Easy Pieces](http://pages.cs.wisc.edu/~remzi/OSTEP/)
- [The Design and Implementation of the FreeBSD Operating System](https://www.freebsd.org/docs/)
- [Linux Kernel Development](https://www.kernel.org/doc/htmldocs/kernel-locking/)

---

For additional help, consult the project documentation in `docs/` or open an issue on the project repository.
