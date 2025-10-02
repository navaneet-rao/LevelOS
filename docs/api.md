# LevelOS API Documentation

## Overview

This document provides comprehensive API documentation for LevelOS kernel functions, data structures, and interfaces.

## Core APIs

### Kernel Core (`include/kernel/kernel.h`)

#### Functions

##### `void kernel_main(void)`
**Description**: Main kernel entry point called from boot assembly code.

**Parameters**: None

**Returns**: Never returns (infinite loop)

**Usage**:
```c
// Called automatically from boot.s
// User code should not call directly
```

**Implementation Details**:
- Initializes terminal subsystem
- Displays boot messages with version information
- Enters infinite loop with HLT instruction

---

##### `void kernel_panic(const char* message)`
**Description**: Handles fatal kernel errors and halts the system.

**Parameters**:
- `message`: Error message to display

**Returns**: Never returns (system halt)

**Usage**:
```c
if (critical_error) {
    kernel_panic("Critical memory error");
}
```

## Terminal Driver API (`include/drivers/terminal.h`)

### Data Structures

#### `enum vga_color`
```c
enum vga_color {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
};
```

### Functions

#### Color Management

##### `uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg)`
**Description**: Creates a VGA color attribute byte.

**Parameters**:
- `fg`: Foreground color (text color)
- `bg`: Background color

**Returns**: 8-bit color attribute value

**Usage**:
```c
uint8_t red_on_black = vga_entry_color(VGA_COLOR_RED, VGA_COLOR_BLACK);
terminal_setcolor(red_on_black);
```

---

##### `uint16_t vga_entry(unsigned char uc, uint8_t color)`
**Description**: Creates a complete VGA text entry (character + color).

**Parameters**:
- `uc`: Character to display
- `color`: Color attribute from `vga_entry_color()`

**Returns**: 16-bit VGA entry value

**Usage**:
```c
uint8_t color = vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
uint16_t entry = vga_entry('A', color);
```

#### Terminal Control

##### `void terminal_initialize(void)`
**Description**: Initializes the terminal subsystem.

**Parameters**: None

**Returns**: void

**Usage**:
```c
// Called once during kernel initialization
terminal_initialize();
```

**Implementation Details**:
- Sets cursor to (0,0)
- Sets default color scheme
- Clears entire screen
- Initializes VGA buffer pointer

---

##### `void terminal_setcolor(uint8_t color)`
**Description**: Sets the current text color for subsequent output.

**Parameters**:
- `color`: Color attribute from `vga_entry_color()`

**Returns**: void

**Usage**:
```c
// Set green text on black background
terminal_setcolor(vga_entry_color(VGA_COLOR_GREEN, VGA_COLOR_BLACK));
terminal_writestring("This text is green");
```

---

##### `void terminal_putentryat(char c, uint8_t color, size_t x, size_t y)`
**Description**: Places a character at specific screen coordinates.

**Parameters**:
- `c`: Character to place
- `color`: Color attribute
- `x`: Column position (0-79)
- `y`: Row position (0-24)

**Returns**: void

**Usage**:
```c
// Place red 'X' at position (10, 5)
uint8_t red = vga_entry_color(VGA_COLOR_RED, VGA_COLOR_BLACK);
terminal_putentryat('X', red, 10, 5);
```

**Constraints**:
- `x` must be in range [0, 79]
- `y` must be in range [0, 24]
- No bounds checking performed

---

##### `void terminal_putchar(char c)`
**Description**: Outputs a character at the current cursor position.

**Parameters**:
- `c`: Character to output

**Returns**: void

**Usage**:
```c
terminal_putchar('H');
terminal_putchar('i');
// Outputs: "Hi"
```

**Behavior**:
- Advances cursor automatically
- Handles newline (`\n`) character
- Scrolls screen when reaching bottom

---

##### `void terminal_write(const char* data, size_t size)`
**Description**: Outputs a buffer of characters.

**Parameters**:
- `data`: Pointer to character buffer
- `size`: Number of characters to output

**Returns**: void

**Usage**:
```c
char buffer[] = "Hello";
terminal_write(buffer, 5);
```

**Notes**:
- Does not require null-terminated string
- Outputs exactly `size` characters
- No bounds checking on buffer

---

##### `void terminal_writestring(const char* data)`
**Description**: Outputs a null-terminated string.

**Parameters**:
- `data`: Pointer to null-terminated string

**Returns**: void

**Usage**:
```c
terminal_writestring("Hello, World!");
```

**Notes**:
- String must be null-terminated
- Most commonly used output function
- Handles newlines and cursor advancement

## Standard Library API (`include/lib/string.h`)

### Data Types

#### `size_t`
**Description**: Unsigned integer type for sizes and counts.
**Definition**: `typedef uint32_t size_t;`
**Range**: 0 to 4,294,967,295

### String Functions

##### `size_t strlen(const char* str)`
**Description**: Calculates the length of a null-terminated string.

**Parameters**:
- `str`: Pointer to null-terminated string

**Returns**: Number of characters in string (excluding null terminator)

**Usage**:
```c
size_t len = strlen("Hello");  // Returns 5
size_t empty = strlen("");     // Returns 0
```

**Time Complexity**: O(n) where n is string length

**Notes**:
- String must be null-terminated
- Does not validate pointer

### Memory Functions

##### `void* memset(void* dest, int value, size_t count)`
**Description**: Sets memory region to specified value.

**Parameters**:
- `dest`: Pointer to destination memory
- `value`: Value to set (converted to unsigned char)
- `count`: Number of bytes to set

**Returns**: Pointer to destination memory

**Usage**:
```c
char buffer[100];
memset(buffer, 0, sizeof(buffer));    // Zero-fill buffer
memset(buffer, 'A', 10);              // Fill first 10 bytes with 'A'
```

**Notes**:
- Only lower 8 bits of `value` are used
- Destination memory must be writable
- No bounds checking performed

---

##### `void* memcpy(void* dest, const void* src, size_t count)`
**Description**: Copies memory from source to destination.

**Parameters**:
- `dest`: Pointer to destination memory
- `src`: Pointer to source memory  
- `count`: Number of bytes to copy

**Returns**: Pointer to destination memory

**Usage**:
```c
char src[] = "Hello";
char dest[10];
memcpy(dest, src, 6);  // Copy including null terminator
```

**Notes**:
- Behavior undefined if memory regions overlap
- No bounds checking performed
- Both pointers must be valid for `count` bytes

---

##### `int memcmp(const void* ptr1, const void* ptr2, size_t count)`
**Description**: Compares two memory regions byte by byte.

**Parameters**:
- `ptr1`: Pointer to first memory region
- `ptr2`: Pointer to second memory region
- `count`: Number of bytes to compare

**Returns**:
- `< 0` if first differing byte in ptr1 is less than ptr2
- `0` if memory regions are identical
- `> 0` if first differing byte in ptr1 is greater than ptr2

**Usage**:
```c
char str1[] = "Hello";
char str2[] = "Hello";
char str3[] = "World";

int result1 = memcmp(str1, str2, 5);  // Returns 0 (equal)
int result2 = memcmp(str1, str3, 5);  // Returns < 0 (str1 < str3)
```

## Type Definitions (`include/lib/types.h`)

### Basic Integer Types

```c
typedef unsigned char uint8_t;        // 8-bit unsigned integer
typedef unsigned short uint16_t;      // 16-bit unsigned integer  
typedef unsigned int uint32_t;        // 32-bit unsigned integer
typedef unsigned long long uint64_t;  // 64-bit unsigned integer

typedef signed char int8_t;           // 8-bit signed integer
typedef signed short int16_t;         // 16-bit signed integer
typedef signed int int32_t;           // 32-bit signed integer
typedef signed long long int64_t;     // 64-bit signed integer
```

### System Types

```c
typedef uint32_t size_t;              // Size type for memory operations
typedef uint32_t uintptr_t;           // Pointer-sized unsigned integer
```

### Boolean Type

```c
typedef enum {
    false = 0,
    true = 1
} bool;
```

## Build System Configuration API

### Build Configuration (`config/build.conf`)

#### Version Control
```properties
VERSION_MAJOR=0    # Major version number
VERSION_MINOR=1    # Minor version number
VERSION_PATCH=0    # Patch version number
```

#### Architecture Settings
```properties
TARGET_ARCH=i686         # Target architecture
TARGET_FORMAT=elf        # Output format
```

#### Compiler Configuration
```properties
CC=gcc                   # C compiler
AS=nasm                  # Assembler  
LD=gcc                   # Linker
```

#### Build Flags
```properties
CFLAGS=-std=gnu99 -ffreestanding -O2 -Wall -Wextra -m32
ASFLAGS=-felf32
LDFLAGS=-ffreestanding -O2 -nostdlib -lgcc -m32
```

### Test Configuration (`config/test.conf`)

#### Unit Test Settings
```ini
[unit_tests]
enabled = true           # Enable unit testing
framework = custom       # Test framework type
output_dir = build/tests # Test output directory
```

#### Integration Test Settings
```ini
[integration_tests]
enabled = true           # Enable integration testing
qemu_path = qemu-system-i386  # QEMU executable path
timeout = 30            # Test timeout in seconds
```

## Constants and Macros

### Terminal Constants
```c
#define VGA_WIDTH 80           // Terminal width in characters
#define VGA_HEIGHT 25          // Terminal height in characters
#define VGA_MEMORY 0xB8000     // VGA text buffer address
```

### Version Macros
```c
#define VERSION_MAJOR 0        // Defined by build system
#define VERSION_MINOR 1        // Defined by build system  
#define VERSION_PATCH 0        // Defined by build system
```

### Multiboot Constants
```asm
MBALIGN  equ  1 << 0          ; Align loaded modules on page boundaries
MEMINFO  equ  1 << 1          ; Provide memory map
FLAGS    equ  MBALIGN | MEMINFO ; Multiboot flag field
MAGIC    equ  0x1BADB002      ; Multiboot magic number
```

## Error Handling

### Error Codes
Currently, LevelOS uses simple error handling:

- **Success**: Function completion without error
- **Panic**: Fatal error causing system halt via `kernel_panic()`

### Future Error Handling (Planned)
```c
typedef enum {
    KERNEL_SUCCESS = 0,
    KERNEL_ERROR_INVALID_PARAM = -1,
    KERNEL_ERROR_OUT_OF_MEMORY = -2,
    KERNEL_ERROR_HARDWARE_FAILURE = -3
} kernel_error_t;
```

## Memory Layout

### VGA Text Buffer Layout
```c
// Each character entry is 16 bits:
// Bits 0-7:   Character code
// Bits 8-11:  Foreground color
// Bits 12-15: Background color

uint16_t* vga_buffer = (uint16_t*)0xB8000;
```

### Kernel Memory Layout
```
0x00100000: _start (kernel entry point)
0x00100000: .text section (code)
0x00101000: .data section (initialized data)  
0x00102000: .bss section (uninitialized data)
0x00102000: stack_bottom
0x00106000: stack_top (16KB stack)
```

## Platform-Specific Information

### Target Architecture: i686 (32-bit x86)
- **Word Size**: 32 bits
- **Byte Order**: Little-endian
- **Stack Growth**: Downward (high to low addresses)
- **Calling Convention**: System V ABI

### Hardware Dependencies
- **VGA Compatible**: Requires VGA text mode support
- **Multiboot Loader**: Requires GRUB or compatible bootloader
- **Protected Mode**: Requires 386+ processor

---

## Usage Examples

### Complete Terminal Example
```c
#include "drivers/terminal.h"

void demo_terminal(void) {
    // Initialize terminal
    terminal_initialize();
    
    // Set colors and display messages
    terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK));
    terminal_writestring("System Starting...\n");
    
    terminal_setcolor(vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK));
    terminal_writestring("LevelOS v0.1.0\n");
    
    terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_BLUE, VGA_COLOR_BLACK));
    terminal_writestring("Ready for operation.\n");
}
```

### String Library Example
```c
#include "lib/string.h"

void demo_string_ops(void) {
    char buffer[100];
    char message[] = "Hello, LevelOS!";
    
    // Get string length
    size_t len = strlen(message);
    
    // Clear buffer
    memset(buffer, 0, sizeof(buffer));
    
    // Copy message to buffer
    memcpy(buffer, message, len + 1);
    
    // Compare strings
    if (memcmp(buffer, message, len) == 0) {
        terminal_writestring("Strings match!\n");
    }
}
```

---

For implementation details and source code, refer to the individual header files in the `include/` directory.