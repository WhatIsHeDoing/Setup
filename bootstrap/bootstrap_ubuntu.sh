#!/bin/bash
set -euo pipefail

echo "Bootstrapping Ubuntu..."

sudo apt-get update -y
sudo apt-get install -y python3 python3-pip pipx ansible-core

# Install just via the official binary installer
if ! command -v just &>/dev/null; then
    echo "Installing just..."
    # Downloads over HTTPS with TLS 1.2 minimum from just.systems (official source).
    # The installer fetches a signed release binary from github.com/casey/just.
    # Review the installer at https://github.com/casey/just before running.
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
        | sudo bash -s -- --to /usr/local/bin
fi

# Install pre-commit
if ! command -v pre-commit &>/dev/null; then
    echo "Installing pre-commit..."
    pipx install pre-commit
fi

# Install Ansible collections
ansible-galaxy collection install -r ansible/requirements.yml

echo ""
echo "Bootstrap complete. Run 'just install' to set up this machine."
