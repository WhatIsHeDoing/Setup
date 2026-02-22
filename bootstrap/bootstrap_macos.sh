#!/bin/bash
set -euo pipefail

echo "Bootstrapping macOS..."

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is on PATH for Apple Silicon and Intel
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

echo "Installing prerequisites Ansible and Just"
brew install ansible just

echo ""
echo "Bootstrap complete. Run 'just install' to set up this machine."
