#!/bin/bash

cat banner.txt
echo

# Upgrade current packages and install common utils for other installs.
apt-get upgrade -y
apt-get install apt-transport-https apt-utils -y

# Debian contrib package feed.
cp debian_contrib.list /etc/apt/sources.list.d/

# Node.js package feed.
curl -sL https://deb.nodesource.com/setup_13.x | bash -

# VS Code package feed.
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# Update package feeds, install apps, and remove unnecesary ones.
apt-get update

apt-get install \
    code \
    fonts-firacode \
    fonts-powerline \
    fzf \
    git \
    jq \
    nodejs \
    python-pip \
    -y

apt autoremove -y

# Update VS Code settings.
CODE_SETTINGS="$HOME"/.config/Code/User/settings.json
jq -rs 'reduce .[] as $item ({}; . * $item)' vscode_settings.json "$CODE_SETTINGS" >tmpfile && mv tmpfile "$CODE_SETTINGS"

# https://github.com/wernight/powerline-web-fonts
# Python modules.
pip install --upgrade pip
sudo -H pip install powerline-shell

# Update bash settings.
cp .bashrc ~/.bashrc
