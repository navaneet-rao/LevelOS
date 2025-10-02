# LevelOS Documentation Index

Welcome to the LevelOS documentation! This index provides an overview of all available documentation for the LevelOS educational operating system kernel.

## 📚 Documentation Structure

### Core Documentation
- **[README.md](../README.md)** - Project overview, quick start guide, and general information
- **[api.md](./api.md)** - Comprehensive API documentation for all kernel functions
- **[architecture.md](./architecture.md)** - System architecture, memory layout, and design decisions
- **[development.md](./development.md)** - Development guidelines, coding standards, and contribution guide

### Configuration Documentation
- **[config/build.conf](../config/build.conf)** - Build system configuration
- **[config/test.conf](../config/test.conf)** - Testing framework configuration
- **[config/linker.ld](../config/linker.ld)** - GNU LD linker script with comments

## 🎯 Quick Navigation

### For New Contributors
1. Start with [README.md](../README.md) for project overview
2. Read [development.md](./development.md) for coding standards
3. Review [architecture.md](./architecture.md) for system understanding
4. Reference [api.md](./api.md) for function documentation

### For Users
1. [README.md](../README.md) - Setup and usage instructions
2. `make help` - Available build targets
3. `make info` - Current build information

### For Developers
1. [development.md](./development.md) - Development workflow
2. [api.md](./api.md) - Function references
3. [architecture.md](./architecture.md) - System internals

## 📖 Documentation Standards

### Format
- **Markdown**: All documentation uses GitHub-flavored Markdown
- **Code Blocks**: Syntax highlighting for C, assembly, and shell commands
- **Cross-references**: Links between related documentation sections

### Content Guidelines
- **Comprehensive**: Cover all public APIs and interfaces
- **Up-to-date**: Synchronized with code changes
- **Examples**: Include practical usage examples
- **Accessible**: Clear explanations for educational purposes

## 🔧 Maintenance

### Updating Documentation
When making code changes:
1. Update relevant API documentation in `api.md`
2. Modify architecture documentation if design changes
3. Update development guidelines for new processes
4. Refresh README if user interface changes

### Documentation Build
```bash
# Verify all documentation links work
make info                    # Check current project status
find docs/ -name "*.md"     # List all documentation files
```

## 📊 Documentation Coverage

### Current Status: ✅ Complete

| Component | API Docs | Architecture | Development |
|-----------|----------|--------------|-------------|
| Kernel Core | ✅ | ✅ | ✅ |
| Terminal Driver | ✅ | ✅ | ✅ |
| String Library | ✅ | ✅ | ✅ |
| Build System | ✅ | ✅ | ✅ |
| Testing Framework | ✅ | ✅ | ✅ |

### Planned Documentation (v0.2.0)
- [ ] Interrupt handling documentation
- [ ] Keyboard driver API
- [ ] Memory management interface
- [ ] Debug procedures

## 🎓 Learning Path

### Beginner (New to OS Development)
1. **[README.md](../README.md)** - Project overview
2. **[development.md](./development.md)** - Setup environment  
3. **[architecture.md](./architecture.md)** - Basic concepts
4. **Hands-on**: `make setup && make && make run-vnc`

### Intermediate (Some C/Assembly Experience)
1. **[architecture.md](./architecture.md)** - System design
2. **[api.md](./api.md)** - Function interfaces
3. **[development.md](./development.md)** - Contribution process
4. **Practice**: Add new terminal colors or string functions

### Advanced (Experienced Systems Programmer)
1. **[architecture.md](./architecture.md)** - Implementation details
2. **[api.md](./api.md)** - Complete reference
3. **Source Code**: Direct examination of implementation
4. **Extension**: Add interrupt handling or memory management

## 🔗 External References

### OS Development Resources
- [OSDev Wiki](https://wiki.osdev.org/) - Primary reference for OS development
- [Intel x86 Manuals](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html) - CPU architecture reference
- [Multiboot Specification](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html) - Bootloader interface

### Development Tools
- [GCC Manual](https://gcc.gnu.org/onlinedocs/) - Compiler documentation
- [NASM Manual](https://www.nasm.us/docs.php) - Assembler documentation  
- [GNU Make Manual](https://www.gnu.org/software/make/manual/) - Build system
- [QEMU Documentation](https://www.qemu.org/docs/master/) - Emulator/virtualization

### Educational Resources
- [Operating Systems: Three Easy Pieces](http://pages.cs.wisc.edu/~remzi/OSTEP/) - OS theory
- [Computer Systems: A Programmer's Perspective](http://csapp.cs.cmu.edu/) - Systems programming
- [The C Programming Language](https://en.wikipedia.org/wiki/The_C_Programming_Language) - C reference

## 🏗️ Project Information

- **Version**: 0.1.0
- **License**: MIT
- **Language**: C (GNU99) + Assembly (NASM)
- **Target**: i686 (32-bit x86)
- **Last Updated**: October 2025

---

**Questions or suggestions about documentation?** 
Open an issue or submit a pull request with improvements!