#!/bin/bash
# LevelOS GitHub Runner - One-Line Setup (Direct from GitHub)
# Run this on your build server: curl -sSL https://raw.githubusercontent.com/navaneet-rao/LevelOS/main/scripts/quick-setup.sh | sudo bash

set -e

echo "🚀 LevelOS GitHub Runner Quick Setup"
echo "======================================"
echo "Build dependencies will be installed automatically by workflows!"
echo ""

# Download the runner-only setup script directly
echo "📦 Downloading runner setup script..."
if command -v wget >/dev/null 2>&1; then
    wget -q https://raw.githubusercontent.com/navaneet-rao/LevelOS/main/scripts/runner-only-setup.sh -O /tmp/runner-setup.sh
elif command -v curl >/dev/null 2>&1; then
    curl -sSL https://raw.githubusercontent.com/navaneet-rao/LevelOS/main/scripts/runner-only-setup.sh -o /tmp/runner-setup.sh
else
    echo "❌ Error: wget or curl required"
    exit 1
fi

echo "🔧 Running runner setup..."
chmod +x /tmp/runner-setup.sh

# Auto-answer 'y' to the setup prompt
echo "y" | /tmp/runner-setup.sh

echo ""
echo "🎉 Quick setup complete!"
echo ""
echo "Final steps:"
echo "1. Get token: https://github.com/navaneet-rao/LevelOS/settings/actions/runners"
echo "2. Configure: sudo -u github-runner -i && cd /opt/actions-runner"
echo "3. Register: ./config.sh --url https://github.com/navaneet-rao/LevelOS --token YOUR_TOKEN"
echo "4. Start: sudo /opt/actions-runner/svc.sh install github-runner && sudo /opt/actions-runner/svc.sh start"
echo ""
echo "🔥 Your workflows will automatically install build dependencies!"