# Branch Protection Configuration
# This file documents the recommended branch protection settings for LevelOS
# Apply these settings in your GitHub repository settings

## Main/Master Branch Protection

### Required Settings:
- **Restrict pushes that create files**: Enabled
- **Require pull request reviews before merging**: Enabled
  - Required approving reviews: 1
  - Dismiss stale reviews when new commits are pushed: Enabled
  - Require review from code owners: Disabled (unless CODEOWNERS file exists)

### Status Checks:
- **Require status checks to pass before merging**: Enabled
- **Required status checks**:
  - `build-and-test` (from CI workflow)
  - `build-and-release` (from release workflow)
- **Require branches to be up to date before merging**: Enabled

### Additional Restrictions:
- **Restrict pushes that create files**: Enabled
- **Allow force pushes**: Disabled
- **Allow deletions**: Disabled

### Auto-merge Settings:
- **Enable auto-merge**: Optional (recommended for trusted contributors)
- **Automatically delete head branches**: Enabled

## Workflow Configuration

### Self-Hosted Runner Requirements:
1. **Runner Labels**: `self-hosted`
2. **Required Software**:
   - Git
   - Make
   - GCC with multilib support  
   - NASM
   - GRUB tools
   - QEMU (for testing)
   - Standard build tools

3. **Runner Setup Commands**:
   ```bash
   # Install dependencies
   sudo apt update
   sudo apt install -y git make gcc gcc-multilib nasm \
       grub-pc-bin grub-common xorriso qemu-system-x86 mtools

   # Verify installation
   make --version && gcc --version && nasm --version
   ```

### GitHub Secrets Required:
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions
- No additional secrets required for basic functionality

### Repository Settings:
- **Issues**: Enabled
- **Wiki**: Optional
- **Projects**: Optional  
- **Discussions**: Optional
- **Packages**: Enabled (for GitHub Packages publishing)

## Workflow Triggers

### Release Workflow (`release.yml`):
- **Push to main/master**: Automatic release
- **Merged pull request**: Automatic release
- **Manual trigger**: Via workflow_dispatch (optional)

### CI Workflow (`ci.yml`):
- **Pull request opened/updated**: Automatic build and test
- **Manual trigger**: Via workflow_dispatch

## Release Process

### Automatic Release Flow:
1. Developer creates feature branch
2. Developer opens pull request to main/master
3. CI workflow runs automatically (build + test)
4. Code review and approval required
5. Pull request merged to main/master
6. Release workflow triggers automatically
7. Builds kernel and ISO
8. Creates GitHub release with assets
9. Publishes to GitHub Packages

### Manual Release Process:
1. Update version numbers in Makefile
2. Commit version bump
3. Push to main/master branch
4. Release workflow creates tagged release automatically

## Asset Management

### Release Assets Include:
- **Kernel Binary**: `level-os-X.Y.Z.bin`
- **Bootable ISO**: `level-os-X.Y.Z.iso`  
- **Checksums**: `checksums.txt`
- **Build Info**: `build-info.txt`

### Package Publishing:
- **GitHub Packages**: NPM-compatible package
- **Package Name**: `@levelos/kernel`
- **Versioning**: Semantic versioning (X.Y.Z)

## Security Considerations

### Runner Security:
- Use dedicated self-hosted runner for LevelOS builds
- Isolate runner environment from sensitive systems
- Regular security updates on runner machine
- Monitor runner logs for suspicious activity

### Asset Security:
- All releases signed with checksums
- Multiboot compliance verification
- Build reproducibility checks
- Source code integrity verification

## Troubleshooting

### Common Issues:
1. **Build fails on runner**: Check dependency installation
2. **Release already exists**: Version not incremented
3. **Permission denied**: Check GitHub token permissions
4. **Asset upload fails**: Check file paths and permissions

### Debug Commands:
```bash
# Check runner environment
make info
make debug-size

# Verify build manually
make clean && make && make iso

# Check multiboot compliance
grub-file --is-x86-multiboot build/level-os-*.bin
```

---

**Note**: This configuration ensures reliable, automated releases while maintaining code quality through required reviews and automated testing.