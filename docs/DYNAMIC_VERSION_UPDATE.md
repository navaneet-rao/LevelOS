# Dynamic Version Management - Complete Guide

## 🎉 Yes, It's Dynamic Now!

Your documentation **automatically updates** when you change the version!

---

## 📁 Files That Auto-Update

When you run `make update-docs`, these files are **automatically synchronized**:

1. ✅ **`README.md`**
   - Version badge
   - Binary filenames (level-os-X.Y.Z.bin)
   - ISO filenames
   - All version references

2. ✅ **`docs/development.md`**
   - Command examples with version numbers
   - Binary paths in debug commands
   - All version references

3. ✅ **`config/build.conf`**
   - VERSION_MAJOR
   - VERSION_MINOR
   - VERSION_PATCH

---

## 🚀 How to Use

### **Option 1: Automatic (Recommended)**

Bump version AND update all docs in one command:

```bash
# For bug fixes (0.2.0 → 0.2.1)
make bump-patch-docs

# For new features (0.2.0 → 0.3.0)
make bump-minor-docs

# For breaking changes (0.2.0 → 1.0.0)
make bump-major-docs
```

This does EVERYTHING:
- ✅ Updates VERSION file
- ✅ Resets BUILD_NUMBER to 1
- ✅ Updates README.md
- ✅ Updates docs/development.md
- ✅ Updates config/build.conf

### **Option 2: Manual Control**

If you want more control:

```bash
# Step 1: Bump version
make bump-minor        # 0.2.0 → 0.3.0

# Step 2: Update docs
make update-docs       # Updates all documentation
```

### **Option 3: Direct File Edit**

If you manually edit VERSION file:

```bash
# Edit VERSION file
echo "0.5.0" > VERSION

# Update all docs to match
make update-docs
```

---

## 🔄 What Happens Automatically

When you run `make update-docs`:

```
1. Reads VERSION file        → 0.2.0
2. Detects old version       → 0.1.1 (from README badge)
3. Updates README.md         → All 0.1.1 → 0.2.0
4. Updates development.md    → All 0.1.1 → 0.2.0
5. Updates build.conf        → VERSION_MAJOR=0, MINOR=2, PATCH=0
6. Shows confirmation        → ✓ All files updated
```

**Smart Features**:
- ✅ Auto-detects old version from README badge
- ✅ Replaces ALL occurrences in all files
- ✅ Updates binary names: `level-os-0.1.1.bin` → `level-os-0.2.0.bin`
- ✅ Creates backups before replacing (auto-cleaned)
- ✅ Shows what changed

---

## 📊 Single Source of Truth

```
          VERSION file (0.2.0)
          BUILD_NUMBER (1)
                 ↓
        ┌────────┴────────┐
        ↓                  ↓
   Makefile reads     make update-docs
        ↓                  ↓
   Compiler gets     Documentation
   -DVERSION_*       gets updated
        ↓                  ↓
   kernel.c          README.md
   displays          docs/*.md
   at boot           build.conf
```

---

## 🎯 Complete Workflow Examples

### **Release Workflow (Automated)**

```bash
# 1. Finish your work
git add src/
git commit -m "Add awesome new feature"

# 2. Bump version and update docs automatically
make bump-minor-docs

# 3. Verify
make version
cat README.md | grep version-

# 4. Build and test
make clean && make
make run-vnc

# 5. Commit and tag
git add VERSION BUILD_NUMBER README.md docs/ config/
git commit -m "Release v$(cat VERSION)"
git tag -a v$(cat VERSION) -m "Release $(cat VERSION)"
git push origin main --tags
```

### **Development Workflow (Build Numbers)**

```bash
# Regular development - just increment build
make bump-build    # 0.2.0+build1 → 0.2.0+build2
make               # Build
make run-vnc       # Test

# No need to update docs for build number changes!
```

### **Hotfix Workflow**

```bash
# Quick patch release
make bump-patch-docs    # 0.2.0 → 0.2.1 + updates docs
make clean && make      # Build
make run-vnc            # Test

# Commit
git add .
git commit -m "Hotfix v$(cat VERSION)"
git tag -a v$(cat VERSION)
```

---

## 🛠️ New Make Targets

### Version Management
```bash
make version            # Show current version
make bump-build         # Increment build: 1 → 2
make bump-patch         # 0.2.0 → 0.2.1
make bump-minor         # 0.2.0 → 0.3.0
make bump-major         # 0.2.0 → 1.0.0
```

### Documentation Updates (NEW!)
```bash
make update-docs        # Update all docs to match VERSION
make bump-patch-docs    # Bump patch + update docs
make bump-minor-docs    # Bump minor + update docs
make bump-major-docs    # Bump major + update docs
```

---

## 📋 What Gets Updated in Each File

### **README.md**
- Line 4: `[![Version](https://img.shields.io/badge/version-X.Y.Z-blue)]()`
- Line ~66-67: `level-os-X.Y.Z.bin` and `level-os-X.Y.Z.iso`
- Line ~180: ISO filename in instructions
- Line ~185: `### Current Version: X.Y.Z`
- Line ~274: Binary filename in commands

### **docs/development.md**
- Line ~279: QEMU command with binary path
- Line ~283: GDB symbol file path
- Line ~299: readelf command
- Line ~302: grub-file command
- Line ~305: hexdump command
- Line ~474: Another grub-file command

### **config/build.conf**
- Line 6: `VERSION_MAJOR=X`
- Line 7: `VERSION_MINOR=Y`
- Line 8: `VERSION_PATCH=Z`

---

## ✅ Benefits

✅ **Fully Automatic** - One command updates everything  
✅ **No Manual Editing** - No more searching through files  
✅ **Always In Sync** - VERSION file is single source of truth  
✅ **Smart Detection** - Auto-finds old version  
✅ **Safe** - Creates backups (auto-cleaned)  
✅ **Fast** - Updates in seconds  
✅ **Complete** - All version references updated  
✅ **No Scripts** - Built into Makefile  

---

## 🔍 Verification

Check that everything is in sync:

```bash
# Show version
make version

# Check each file
grep "version-" README.md                # Should show current version
grep "VERSION_" config/build.conf        # Should show current version
grep "level-os-" docs/development.md     # Should show current version
```

---

## 📝 Manual Updates (If Needed)

If you prefer to update manually:

```bash
# Get current version
VERSION=$(cat VERSION)

# Manual sed commands (what make update-docs does)
sed -i "s/0\.1\.1/$VERSION/g" README.md
sed -i "s/level-os-0\.1\.1/level-os-$VERSION/g" README.md
sed -i "s/0\.1\.1/$VERSION/g" docs/development.md
```

But why? Just use `make update-docs`! 😄

---

## 🎓 Key Points

1. **VERSION and BUILD_NUMBER files** are the ONLY source of truth
2. **Makefile reads** these files and distributes version info
3. **Documentation files** (README, docs, build.conf) are auto-updated
4. **Use `make bump-*-docs`** for automated version bumps
5. **Use `make update-docs`** if you manually edit VERSION

---

## ⚡ Quick Reference

| Action | Command | Updates Docs? |
|--------|---------|--------------|
| Bump build | `make bump-build` | No |
| Bump patch | `make bump-patch` | No |
| Bump minor | `make bump-minor` | No |
| Bump major | `make bump-major` | No |
| Update docs | `make update-docs` | ✅ Yes |
| Bump + docs | `make bump-patch-docs` | ✅ Yes |
| Bump + docs | `make bump-minor-docs` | ✅ Yes |
| Bump + docs | `make bump-major-docs` | ✅ Yes |

---

## 🎉 Summary

**Before**: Manual updates to 6 places in 3 files  
**After**: One command: `make bump-minor-docs`  

**Before**: Risk of forgetting to update a file  
**After**: Everything syncs automatically  

**Before**: Search and replace through multiple files  
**After**: Smart auto-detection and update  

---

**Status**: ✅ Fully Dynamic  
**Tested**: ✅ Working  
**Current Version**: 0.2.0+build1  
**Date**: 2025-10-04

Run `make help` to see all available commands!
