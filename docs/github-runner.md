# GitHub Actions Runner Management

## Quick Setup Commands

After running the setup script, complete the configuration:

```bash
# 1. Get the registration token from GitHub
# Go to: https://github.com/navaneet-rao/LevelOS/settings/actions/runners/new

# 2. Configure the runner (replace TOKEN with actual token from GitHub)
sudo -u github-runner -i
cd /opt/actions-runner
./config.sh --url https://github.com/navaneet-rao/LevelOS --token YOUR_TOKEN_HERE

# 3. Install and start the service
sudo /opt/actions-runner/svc.sh install github-runner
sudo /opt/actions-runner/svc.sh start
```

## Service Management

```bash
# Check runner status
sudo /opt/actions-runner/svc.sh status

# Start the runner
sudo /opt/actions-runner/svc.sh start

# Stop the runner
sudo /opt/actions-runner/svc.sh stop

# Restart the runner
sudo /opt/actions-runner/svc.sh stop
sudo /opt/actions-runner/svc.sh start

# View runner logs
sudo journalctl -u github-actions-runner -f
```

## Test the Build Environment

```bash
# Test as runner user
sudo -u github-runner -i
cd /tmp
git clone https://github.com/navaneet-rao/LevelOS.git
cd LevelOS
make clean
make

# Should build successfully and create levelOS.iso
```

## Troubleshooting

### Runner Not Appearing in GitHub
- Check if the service is running: `sudo systemctl status github-actions-runner`
- Check logs: `sudo journalctl -u github-actions-runner -n 50`
- Verify network connectivity: `curl -I https://github.com`

### Build Failures
- Ensure all dependencies are installed: `gcc-multilib`, `nasm`, `grub-pc-bin`, `xorriso`
- Check permissions: runner user should have access to build tools
- Test manual build as runner user

### Service Issues
- Reinstall service: `sudo /opt/actions-runner/svc.sh uninstall && sudo /opt/actions-runner/svc.sh install github-runner`
- Check runner user permissions: `sudo -u github-runner whoami`

## Runner Configuration

- **Location**: `/opt/actions-runner`
- **User**: `github-runner`
- **Service**: `github-actions-runner`
- **Logs**: `journalctl -u github-actions-runner`

## Security Notes

- Runner has limited sudo access for package management only
- Builds run in isolated workspace directories
- Runner automatically updates GitHub with job status
- Logs are available through systemd journal