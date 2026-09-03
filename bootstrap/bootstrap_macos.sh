#!/bin/bash
set -euo pipefail

echo "Bootstrapping macOS..."

if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

echo "Installing prerequisites Ansible and Just"
brew install ansible just

echo ""
echo "Bootstrap complete. Run 'just install' to set up this machine."
