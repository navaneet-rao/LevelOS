# LevelOS GitHub Runner Deployment Guide

## 🚀 Automated Setup for Build Server

**NEW: Build dependencies are now installed automatically by GitHub Actions!**
You only need to set up the runner itself.

### Option 1: One-Line Setup (Easiest)
```bash
# On your build server, run:
curl -sSL https://raw.githubusercontent.com/navaneet-rao/LevelOS/main/scripts/runner-only-setup.sh | sudo bash
```

### Option 2: Manual Download and Setup
```bash
# Download the runner setup script
wget https://raw.githubusercontent.com/navaneet-rao/LevelOS/main/scripts/runner-only-setup.sh
chmod +x runner-only-setup.sh
sudo ./runner-only-setup.sh
```

### 3. Configure Runner with GitHub
After the setup script completes, you need to register the runner:

1. **Get Registration Token:**
   - Go to: https://github.com/navaneet-rao/LevelOS/settings/actions/runners
   - Click "New self-hosted runner"
   - Select "Linux" and "x64"
   - Copy the token from the configuration command

2. **Register Runner:**
```bash
# On your build server:
sudo -u github-runner -i
cd /opt/actions-runner
./config.sh --url https://github.com/navaneet-rao/LevelOS --token YOUR_TOKEN_HERE

# When prompted:
# - Runner group: [Enter] (default)
# - Runner name: levelOS-build-server (or your choice)
# - Work folder: [Enter] (default)  
# - Labels: [Enter] (default)
```

3. **Install and Start Service:**
```bash
sudo /opt/actions-runner/svc.sh install github-runner
sudo /opt/actions-runner/svc.sh start
sudo /opt/actions-runner/svc.sh status
```

### 4. Test the Setup
```bash
# Test build environment:
sudo -u github-runner -i
cd /tmp
git clone https://github.com/navaneet-rao/LevelOS.git
cd LevelOS
make clean && make
ls -la levelOS.iso  # Should exist if build successful
```

### 5. Verify GitHub Integration
1. Check GitHub repository settings → Actions → Runners
2. Your runner should appear as "Online"
3. Create a test pull request to trigger the CI workflow
4. Merge to main branch to trigger the release workflow

## Build Server Requirements

**Minimum Specs:**
- 2+ CPU cores
- 4GB+ RAM  
- 20GB+ free disk space
- Internet connection

**Supported OS:**
- Ubuntu 20.04+ LTS
- Debian 11+
- CentOS 8+
- RHEL 8+

## Security Notes

- Runner runs as dedicated `github-runner` user
- Limited sudo permissions for package management
- Builds run in isolated workspaces
- Automatic cleanup after builds

## Troubleshooting

**Runner Offline:**
```bash
sudo systemctl status github-actions-runner
sudo journalctl -u github-actions-runner -f
```

**Build Failures:**
```bash
# Check dependencies
dpkg -l | grep -E "gcc|nasm|grub|xorriso"

# Test manual build
sudo -u github-runner make -C /path/to/levelOS clean all
```

**Permission Issues:**
```bash
# Fix runner permissions
sudo chown -R github-runner:github-runner /opt/actions-runner
sudo chmod +x /opt/actions-runner/run.sh
```