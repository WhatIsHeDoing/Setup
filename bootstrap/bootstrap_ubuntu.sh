#!/bin/bash
set -euo pipefail

echo "Bootstrapping Ubuntu..."

sudo apt-get update -y
sudo apt-get install -y python3 python3-pip pipx

echo "Installing Ansible..."
pipx install ansible
pipx ensurepath

# Install just via the official binary installer
if ! command -v just &>/dev/null; then
    echo "Installing just..."
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
        | sudo bash -s -- --to /usr/local/bin
fi

# Install Ansible collections
export PATH="$HOME/.local/bin:$PATH"
ansible-galaxy collection install -r ansible/requirements.yml

echo ""
echo "Bootstrap complete. Run 'just install' to set up this machine."
echo "Note: If 'just' is not found, reload your shell: source ~/.bashrc"
