# LevelOS Version Management - Quick Reference

## 📍 What Changed

All version inconsistencies have been fixed and a **dual version system** is now in place!

### ✅ What Was Done

1. **✅ Fixed Version Inconsistencies**
   - Synced all documentation from `0.1.0` → `0.1.1`
   - Updated: `README.md`, `docs/development.md`, `config/build.conf`
   - All version references now point to `0.1.1`

2. **✅ Implemented Dual Version System**
   - **Code Version**: Semantic versioning (e.g., `0.1.1`)
   - **Build Number**: Incremental counter (e.g., `1`, `2`, `3`...)
   - **Full Version**: Combined format (e.g., `0.1.1+build1`)

3. **✅ Created VERSION File Approach**
   - `VERSION` file: Contains semantic version (`0.1.1`)
   - `BUILD_NUMBER` file: Contains build counter (`1`)
   - Makefile automatically reads these files

4. **✅ Created VERSION_CHECKLIST.md**
   - Comprehensive guide for version management
   - Step-by-step workflows
   - Complete file update checklist
   - Best practices and examples

---

## 🚀 Quick Start

### Check Current Version
```bash
make version
```

### Increment Build Number (Regular Builds)
```bash
make bump-build
```

### Bump Version (Releases)
```bash
make bump-patch    # Bug fixes: 0.1.1 → 0.1.2
make bump-minor    # Features: 0.1.1 → 0.2.0
make bump-major    # Breaking: 0.1.1 → 1.0.0
```

---

## 📁 Version Files Location

```
/root/Projects/OS/LevelOS/
├── VERSION              ← Code version (0.1.1)
├── BUILD_NUMBER         ← Build counter (1)
└── VERSION_CHECKLIST.md ← Complete guide
```

---

## 🎯 How It Works

### Single Source of Truth
```
VERSION file (0.1.1)
       ↓
   Makefile reads it
       ↓
   Passes to compiler as -DVERSION_MAJOR=0 -DVERSION_MINOR=1 -DVERSION_PATCH=1
       ↓
   Available in C code as VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH
       ↓
   Displayed at boot: "Welcome to Level OS v0.1.1+build1"
```

### Build Number Flow
```
BUILD_NUMBER file (1)
       ↓
   Makefile reads it
       ↓
   Passes to compiler as -DBUILD_NUMBER=1
       ↓
   Available in C code as BUILD_NUMBER
       ↓
   Displayed at boot
```

---

## 📋 Files That Need Manual Updates

When you bump version (patch/minor/major), update these files manually:

1. **README.md** - Version badge and examples
2. **docs/development.md** - Command examples with version numbers

**See `VERSION_CHECKLIST.md` for exact line numbers and details!**

---

## 🎨 New Features

### In Makefile
- `make version` - Beautiful formatted version display
- `make bump-build` - Increment build number
- `make bump-patch` - Bump patch version (0.1.1 → 0.1.2)
- `make bump-minor` - Bump minor version (0.1.1 → 0.2.0)
- `make bump-major` - Bump major version (0.1.1 → 1.0.0)
- `make info` - Shows full version in build info

### In Kernel Code
- Updated `kernel.c` to display full version with build number
- Boot message now shows: `"Welcome to Level OS v0.1.1+build1"`

---

## 📖 Complete Documentation

Read **`VERSION_CHECKLIST.md`** for:
- Detailed workflows
- File update checklist
- Release process
- Best practices
- Examples and troubleshooting

---

## 💡 Usage Examples

### Daily Development Workflow
```bash
# Make some code changes
vim src/kernel/kernel.c

# Bump build and compile
make bump-build
make

# Test
make run-vnc
```

### Release Workflow
```bash
# Ready for release
make bump-minor

# Update docs (see VERSION_CHECKLIST.md)
vim README.md
vim docs/development.md

# Commit
git add VERSION BUILD_NUMBER README.md docs/
git commit -m "Bump version to $(cat VERSION)"
git tag -a v$(cat VERSION) -m "Release $(cat VERSION)"

# Build and test
make clean && make
make run-vnc
```

---

## 🔍 Verify Setup

```bash
# Check files exist
ls -la VERSION BUILD_NUMBER VERSION_CHECKLIST.md

# Check version
make version

# Check help
make help

# Check build info
make info
```

---

## ✨ Benefits

✅ **No scripts needed** - Simple text files and Makefile targets  
✅ **Single source of truth** - VERSION and BUILD_NUMBER files only  
✅ **Automatic** - Makefile reads files and injects into code  
✅ **Clear separation** - Code version vs Build number  
✅ **Easy to track** - Build number increments with each build  
✅ **Git-friendly** - Simple text files easy to version control  
✅ **Documented** - Complete checklist for manual updates  

---

**Status**: ✅ All implemented and tested  
**Date**: 2025-10-03  
**Current Version**: 0.1.1+build1
