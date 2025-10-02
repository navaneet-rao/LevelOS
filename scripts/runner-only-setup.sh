#!/bin/bash
# GitHub Actions Runner Only Setup - No System Dependencies
# This script only sets up the GitHub runner itself
# Build dependencies are installed automatically by the workflows

set -e

echo "========================================"
echo "  GitHub Actions Runner Setup (Minimal)"
echo "========================================"
echo

# Configuration
RUNNER_USER="github-runner"
RUNNER_HOME="/opt/actions-runner"

echo "This script will:"
echo "1. Create a dedicated user for the GitHub runner"
echo "2. Download and install the GitHub Actions runner"
echo "3. Set up the runner as a systemd service"
echo "4. Configure basic permissions"
echo
echo "Build dependencies will be installed automatically by workflows!"
echo
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 1
fi

echo
echo "Step 1: Creating runner user and directories..."

# Create runner user if it doesn't exist
if ! id "$RUNNER_USER" &>/dev/null; then
    sudo useradd -r -m -d "$RUNNER_HOME" -s /bin/bash "$RUNNER_USER"
    echo "✓ Created user: $RUNNER_USER"
else
    echo "✓ User $RUNNER_USER already exists"
fi

# Create runner directory
sudo mkdir -p "$RUNNER_HOME"
sudo chown "$RUNNER_USER:$RUNNER_USER" "$RUNNER_HOME"

echo
echo "Step 2: Installing basic requirements..."

# Just install curl, wget, tar for runner itself
sudo apt update
sudo apt install -y curl wget tar libicu-dev

echo "✓ Basic requirements installed"

echo
echo "Step 3: Downloading GitHub Actions runner..."

# Get the latest runner version
RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep -o '"tag_name": "v[^"]*' | cut -d'"' -f4 | sed 's/v//')
RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

echo "Latest runner version: $RUNNER_VERSION"

# Download and extract runner
cd /tmp
wget -q "$RUNNER_URL" -O actions-runner.tar.gz
sudo -u "$RUNNER_USER" tar xzf actions-runner.tar.gz -C "$RUNNER_HOME"
rm actions-runner.tar.gz

echo "✓ Runner downloaded and extracted"

echo
echo "Step 4: Setting up permissions..."

# Add runner user to sudo group for workflow dependency installation
sudo usermod -aG sudo "$RUNNER_USER"

# Create sudoers rule for runner (no password for package management)
sudo tee /etc/sudoers.d/github-runner > /dev/null << 'EOF'
# GitHub Actions runner permissions for LevelOS workflows
github-runner ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get, /usr/bin/dpkg, /bin/systemctl
EOF

echo "✓ Permissions configured"

echo
echo "Step 5: Installing runner dependencies..."

# Install runner dependencies
cd "$RUNNER_HOME"
sudo -u "$RUNNER_USER" ./bin/installdependencies.sh

echo "✓ Runner dependencies installed"

echo
echo "============================================"
echo "  Runner Configuration Steps"
echo "============================================"
echo
echo "🎯 Your runner is ready! Now configure it:"
echo
echo "1. Get your registration token:"
echo "   → Go to: https://github.com/navaneet-rao/LevelOS/settings/actions/runners"
echo "   → Click 'New self-hosted runner'"
echo "   → Select 'Linux' and 'x64'"
echo "   → Copy the token from the ./config.sh command"
echo
echo "2. Configure the runner:"
echo "   sudo -u $RUNNER_USER -i"
echo "   cd $RUNNER_HOME"
echo "   ./config.sh --url https://github.com/navaneet-rao/LevelOS --token YOUR_TOKEN_HERE"
echo
echo "   Configuration prompts:"
echo "   → Runner group: [Enter] (default)"
echo "   → Runner name: levelOS-builder (or your choice)"
echo "   → Work folder: [Enter] (default)"
echo "   → Labels: [Enter] (default)"
echo
echo "3. Install and start the service:"
echo "   sudo $RUNNER_HOME/svc.sh install $RUNNER_USER"
echo "   sudo $RUNNER_HOME/svc.sh start"
echo "   sudo $RUNNER_HOME/svc.sh status"
echo
echo "4. Verify runner status:"
echo "   → Check GitHub: Repository → Settings → Actions → Runners"
echo "   → Runner should show as 'Online'"
echo
echo "============================================"
echo
echo "🚀 IMPORTANT: Build dependencies (gcc, nasm, etc.) will be"
echo "   installed automatically when workflows run!"
echo
echo "Runner location: $RUNNER_HOME"
echo "Runner user: $RUNNER_USER"
echo "Service name: github-actions-runner"
echo
echo "Ready for LevelOS automated builds! 🎉"