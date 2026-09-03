#!/bin/bash
set -euo pipefail

echo "Bootstrapping Ubuntu..."

sudo apt-get update -y
sudo apt-get install -y python3 python3-pip pipx ansible-core

if ! command -v just &>/dev/null; then
    echo "Installing just..."
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh |
        sudo bash -s -- --to /usr/local/bin
fi

if ! command -v pre-commit &>/dev/null; then
    echo "Installing pre-commit..."
    pipx install pre-commit
fi

ansible-galaxy collection install -r ansible/requirements.yml

echo ""
echo "Bootstrap complete. Run 'just install' to set up this machine."
