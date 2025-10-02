# LevelOS Architecture Documentation

## System Overview

LevelOS is a monolithic kernel design focused on simplicity and educational value. The kernel runs in 32-bit protected mode and provides basic operating system functionality.

## Boot Process

### 1. GRUB Bootloader
- **Multiboot Compliance**: Follows Multiboot specification 0.6.96
- **Entry Point**: `_start` symbol in `src/boot/boot.s`
- **Multiboot Header**: Located at beginning of kernel image

### 2. Initial Setup (boot.s)
```asm
; Multiboot header structure:
MAGIC    = 0x1BADB002      ; Multiboot magic number
FLAGS    = MBALIGN | MEMINFO
CHECKSUM = -(MAGIC + FLAGS)
```

**Boot Sequence:**
1. **Stack Initialization**: 16KB stack allocated in BSS section
2. **Multiboot Information**: Available in EBX register
3. **Protected Mode**: Already enabled by GRUB
4. **Control Transfer**: Jump to `kernel_main()` in C code

### 3. Kernel Initialization (kernel.c)
```c
void kernel_main(void) {
    terminal_initialize();    // Setup VGA text mode
    // Display boot messages
    // Enter infinite loop with HLT
}
```

## Memory Layout

### Virtual Memory Map
```
0x00000000 - 0x000FFFFF  Real Mode Memory (unused)
0x00100000 - 0x003FFFFF  Kernel Image (.text, .data, .bss)
0x000B8000 - 0x000B8FFF  VGA Text Buffer
0x000C0000 - 0x000FFFFF  BIOS ROM Area
```

### Kernel Sections
- **.text**: Executable code (boot.s, kernel.c, drivers)
- **.data**: Initialized global variables
- **.bss**: Uninitialized data (stack, buffers)

### Stack Layout
```
High Address: stack_top (0x4000 bytes from stack_bottom)
              [16KB stack space]
Low Address:  stack_bottom
```

## Component Architecture

### Core Components

#### 1. Boot Module (`src/boot/`)
- **Purpose**: System initialization and bootloader interface
- **Language**: NASM Assembly
- **Key Functions**: 
  - Multiboot header definition
  - Stack setup
  - Kernel entry point

#### 2. Kernel Core (`src/kernel/`)
- **Purpose**: Main kernel logic and initialization
- **Language**: C (GNU99 standard)
- **Key Functions**:
  - `kernel_main()`: Primary entry point
  - `kernel_panic()`: Error handling
  - System initialization

#### 3. Drivers (`src/drivers/`)
- **Purpose**: Hardware abstraction layer
- **Current Drivers**:
  - **Terminal Driver**: VGA text mode interface
    - 80x25 character display
    - 16-color support
    - Cursor management
    - String output functions

#### 4. Library (`src/lib/`)
- **Purpose**: Standard library functions for kernel
- **Functions**:
  - `strlen()`: String length calculation
  - `memset()`: Memory initialization
  - `memcpy()`: Memory copying
  - `memcmp()`: Memory comparison

## Data Structures

### Terminal Driver
```c
struct terminal_state {
    size_t row;           // Current cursor row
    size_t column;        // Current cursor column
    uint8_t color;        // Current text color
    uint16_t* buffer;     // VGA text buffer pointer
};
```

### VGA Text Mode
```c
// VGA color constants
enum vga_color {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    // ... (16 colors total)
};

// VGA entry format: [Background:4][Foreground:4][Character:8]
uint16_t vga_entry(unsigned char uc, uint8_t color);
```

## Build System Architecture

### Configuration Management
- **build.conf**: Central build configuration
- **test.conf**: Testing framework settings
- **linker.ld**: Memory layout specification

### Build Pipeline
1. **Assembly**: NASM compiles boot.s to ELF object
2. **C Compilation**: GCC compiles C sources with kernel flags
3. **Linking**: GNU LD links all objects using custom linker script
4. **Verification**: GRUB tools verify multiboot compliance

### Versioning System
- **Version Format**: MAJOR.MINOR.PATCH
- **Integration**: Version embedded in kernel binary
- **Build Artifacts**: Versioned filenames for tracking

## Interrupt and Exception Handling

### Current State
- **Status**: Not implemented (planned for v0.2.0)
- **IDT**: Interrupt Descriptor Table not configured
- **ISRs**: Interrupt Service Routines not present

### Planned Implementation
```c
// Future interrupt descriptor structure
struct idt_entry {
    uint16_t base_low;
    uint16_t selector;
    uint8_t always0;
    uint8_t flags;
    uint16_t base_high;
} __attribute__((packed));
```

## Device Management

### VGA Text Mode Terminal
- **Base Address**: 0xB8000
- **Format**: 16-bit entries (character + attribute)
- **Dimensions**: 80 columns × 25 rows
- **Color Model**: 4-bit background, 4-bit foreground

**Memory Layout:**
```
Buffer[0] = Character at (0,0) + Color attributes
Buffer[1] = Character at (1,0) + Color attributes
...
Buffer[80] = Character at (0,1) + Color attributes
```

## Testing Architecture

### Unit Testing Framework
- **Location**: `tests/test_framework.c`
- **Macros**: TEST_ASSERT, TEST_ASSERT_EQ, TEST_ASSERT_NEQ
- **Coverage**: String library functions

### Integration Testing
- **QEMU Integration**: Automated testing in virtual environment
- **Timeout Handling**: 30-second test execution limit
- **Result Reporting**: Console output with pass/fail status

## Debugging Infrastructure

### Debug Tools
- **Objdump Integration**: Disassembly analysis
- **Symbol Table**: Kernel symbol debugging
- **Size Analysis**: Binary size breakdown
- **GDB Support**: Remote debugging capability

### Debug Information
```bash
# Binary analysis
objdump -D kernel.bin    # Full disassembly
nm kernel.bin           # Symbol table
size kernel.bin         # Section sizes
```

## Security Considerations

### Current Security Model
- **Ring Level**: Kernel runs in Ring 0 (highest privilege)
- **Memory Protection**: Not implemented (planned)
- **User Mode**: Not supported (planned for future)

### Planned Security Features
- **Paging**: Virtual memory management
- **User/Kernel Separation**: Ring 3 user processes
- **System Calls**: Controlled kernel access

## Performance Characteristics

### Memory Usage
- **Kernel Size**: ~9.2KB total
- **Code Section**: ~2.9KB
- **Data Section**: ~156 bytes
- **BSS Section**: ~16.4KB (mostly stack)

### Boot Time
- **QEMU Boot**: < 1 second
- **Real Hardware**: 2-3 seconds (typical)

## Future Architecture Plans

### Version 0.2.0 Goals
1. **Interrupt Handling**: IDT setup and basic ISRs
2. **Keyboard Driver**: PS/2 keyboard support
3. **Memory Manager**: Basic heap allocation

### Version 0.3.0 Goals
1. **Process Management**: Basic task switching
2. **System Calls**: User/kernel interface
3. **File System**: Simple file operations

## References

- [Intel Software Developer Manual](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html)
- [Multiboot Specification](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html)
- [OSDev Wiki](https://wiki.osdev.org/)
- [System V ABI](https://software.intel.com/sites/default/files/article/402129/mpx-linux64-abi.pdf)
