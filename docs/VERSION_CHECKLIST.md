# Version Management Checklist for LevelOS

## 📋 Overview

LevelOS uses a **dual version system**:
- **Code Version** (Semantic Versioning): `MAJOR.MINOR.PATCH` (e.g., `0.1.1`)
- **Build Number**: Incremental counter for each build (e.g., `1`, `2`, `3`...)

**Full Version Format**: `0.1.1+build5`

---

## 🎯 Single Source of Truth

All version information is managed through **TWO simple files**:

### 1. `VERSION` file (at project root)
```
0.1.1
```
Contains: `MAJOR.MINOR.PATCH`

### 2. `BUILD_NUMBER` file (at project root)
```
1
```
Contains: Single integer representing the build number

**These files are automatically read by the Makefile!**

---

## 🔄 Version Bump Workflows

### For Regular Development Builds
```bash
# Increment build number before each build
make bump-build
make
```
Result: `0.1.1+build1` → `0.1.1+build2`

---

### For Bug Fixes (Patch Release)
```bash
# Bump patch version (resets build to 1)
make bump-patch

# Update documentation
# See "Files to Update" section below

# Commit and tag
git add VERSION BUILD_NUMBER
git commit -m "Bump version to $(cat VERSION)"
git tag -a v$(cat VERSION) -m "Release version $(cat VERSION)"
```
Result: `0.1.1` → `0.1.2` (build resets to 1)

---

### For New Features (Minor Release)
```bash
# Bump minor version (resets patch and build to 0 and 1)
make bump-minor

# Update documentation
# See "Files to Update" section below

# Commit and tag
git add VERSION BUILD_NUMBER
git commit -m "Bump version to $(cat VERSION)"
git tag -a v$(cat VERSION) -m "Release version $(cat VERSION)"
```
Result: `0.1.1` → `0.2.0` (build resets to 1)

---

### For Breaking Changes (Major Release)
```bash
# Bump major version (resets minor, patch, and build)
make bump-major

# Update documentation
# See "Files to Update" section below

# Commit and tag
git add VERSION BUILD_NUMBER
git commit -m "Bump version to $(cat VERSION)"
git tag -a v$(cat VERSION) -m "Release version $(cat VERSION)"
```
Result: `0.1.1` → `1.0.0` (build resets to 1)

---

## 📝 Files to Update for Version Releases

When you run `make bump-patch`, `make bump-minor`, or `make bump-major`, you **MUST** manually update these files:

### ✅ Checklist for Version Bumps

#### 1. **VERSION file** (✅ Updated automatically by Makefile)
- Location: `/root/Projects/OS/LevelOS/VERSION`
- Action: None needed - handled by `make bump-*` commands

#### 2. **BUILD_NUMBER file** (✅ Updated automatically by Makefile)
- Location: `/root/Projects/OS/LevelOS/BUILD_NUMBER`
- Action: None needed - reset to 1 by `make bump-*` commands

#### 3. **README.md** (⚠️ MANUAL UPDATE REQUIRED)
- Location: `/root/Projects/OS/LevelOS/README.md`
- Lines to update:
  - **Line 4**: Version badge
    ```markdown
    [![Version](https://img.shields.io/badge/version-X.Y.Z-blue)]()
    ```
  - **Line ~67**: Build output filenames
    ```markdown
    ├── level-os-X.Y.Z.bin   # Final kernel binary
    ├── level-os-X.Y.Z.iso   # Bootable ISO image
    ```
  - **Line ~180**: ISO filename in physical hardware section
    ```bash
    2. Burn `build/level-os-X.Y.Z.iso` to USB/CD
    ```
  - **Line ~187**: Development status version
    ```markdown
    ### Current Version: X.Y.Z
    ```
  - **Line ~274**: Multiboot check command
    ```bash
    grub-file --is-x86-multiboot build/level-os-X.Y.Z.bin
    ```

#### 4. **docs/development.md** (⚠️ MANUAL UPDATE REQUIRED)
- Location: `/root/Projects/OS/LevelOS/docs/development.md`
- Lines to update:
  - **Line ~279**: QEMU debug command
    ```bash
    qemu-system-i386 -kernel build/level-os-X.Y.Z.bin -s -S
    ```
  - **Line ~283**: GDB symbol file
    ```bash
    -ex "symbol-file build/level-os-X.Y.Z.bin"
    ```
  - **Line ~299**: readelf command
    ```bash
    readelf -a build/level-os-X.Y.Z.bin
    ```
  - **Line ~302**: grub-file check
    ```bash
    grub-file --is-x86-multiboot build/level-os-X.Y.Z.bin
    ```
  - **Line ~305**: hexdump command
    ```bash
    hexdump -C build/level-os-X.Y.Z.bin | head
    ```
  - **Line ~474**: Another grub-file check
    ```bash
    grub-file --is-x86-multiboot build/level-os-X.Y.Z.bin
    ```

#### 5. **config/build.conf** (ℹ️ For reference only)
- Location: `/root/Projects/OS/LevelOS/config/build.conf`
- Note: This file is READ-ONLY and for reference. Version is managed by VERSION file.
- You can update it manually to keep it in sync, but it's not used by the build system.

---

## 🔍 Quick Search Command

To find all version references in documentation:

```bash
# Search for old version references
grep -r "0\.1\.1" README.md docs/

# After bumping to new version (e.g., 0.1.2), search and replace
# Use your editor's find-and-replace or:
sed -i 's/0\.1\.1/0.1.2/g' README.md
sed -i 's/0\.1\.1/0.1.2/g' docs/development.md
```

---

## 🚀 Quick Reference Commands

```bash
# Check current version
make version

# Show detailed build info
make info

# Increment build number (for regular builds)
make bump-build

# Version bumps (for releases)
make bump-patch    # Bug fixes: 0.1.1 -> 0.1.2
make bump-minor    # New features: 0.1.1 -> 0.2.0
make bump-major    # Breaking changes: 0.1.1 -> 1.0.0

# Help (shows all commands)
make help
```

---

## 📊 Version Info in Code

The version numbers are automatically passed to your C code as preprocessor macros:

```c
// Available in all C source files:
VERSION_MAJOR      // e.g., 0
VERSION_MINOR      // e.g., 1
VERSION_PATCH      // e.g., 1
BUILD_NUMBER       // e.g., 5

// Example usage in kernel.c:
void kernel_main(void) {
    // Use these macros to display version at boot
    terminal_writestring("LevelOS ");
    // ... convert VERSION_MAJOR to string and display
}
```

---

## ✨ Best Practices

1. **Regular Development**:
   - Use `make bump-build` before each build during development
   - Build number auto-increments: easy tracking

2. **Before Releases**:
   - Run appropriate `make bump-*` command
   - Update all documentation files (use checklist above)
   - Test the build: `make clean && make`
   - Commit version files and docs together
   - Create git tag: `git tag -a vX.Y.Z -m "Release X.Y.Z"`

3. **After Major Changes**:
   - Use grep/sed to find and replace old version strings
   - Review CHANGELOG (if you create one)
   - Update BUILD_NUMBER to 1 for fresh releases

4. **Never**:
   - Don't edit version numbers in Makefile directly
   - Don't manually edit BUILD_NUMBER unless resetting
   - Don't forget to update documentation files

---

## 📦 Release Workflow Example

```bash
# 1. Finish your feature/bugfix
git add src/
git commit -m "Add new terminal color support"

# 2. Bump version appropriately
make bump-minor  # New feature -> minor bump

# 3. Update documentation files
# Edit README.md and docs/development.md with new version
# Use find-replace: 0.1.1 → 0.2.0

# 4. Commit version bump
git add VERSION BUILD_NUMBER README.md docs/
git commit -m "Bump version to 0.2.0"

# 5. Tag the release
git tag -a v0.2.0 -m "Release version 0.2.0 - Terminal color support"

# 6. Build and test
make clean
make
make run-vnc

# 7. Push (if using remote)
git push origin main
git push origin v0.2.0
```

---

## 🎓 Understanding Semantic Versioning

- **MAJOR** (X.0.0): Breaking changes, incompatible API changes
- **MINOR** (0.X.0): New features, backwards compatible
- **PATCH** (0.0.X): Bug fixes, backwards compatible

For LevelOS as an OS kernel:
- **MAJOR**: Architecture changes, major rewrites
- **MINOR**: New drivers, new system calls, new features
- **PATCH**: Bug fixes, small improvements, documentation

---

## 🔗 Related Files

- `VERSION` - Code version (semantic versioning)
- `BUILD_NUMBER` - Build counter
- `Makefile` - Build system that reads version files
- `config/build.conf` - Configuration reference (not used by build)
- `README.md` - Main documentation
- `docs/development.md` - Development guide

---

## 📞 Need Help?

Run `make help` to see all available commands!

---

**Last Updated**: 2025-10-03  
**Current Version System**: Dual (Code + Build Number)
