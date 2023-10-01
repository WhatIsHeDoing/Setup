#!/bin/bash
# shellcheck disable=SC2059
BLUE="\033[0;34m"
NC="\033[0m" # No Colour
YELLOW="\033[1;33m"

printf "${BLUE}Running Setup${NC}\n"

printf "${YELLOW}Adding package repositories...${NC}\n"
apt-add-repository ppa:zanchey/asciinema -y

printf "${YELLOW}Updating the package cache...${NC}\n"
apt-get upgrade -y
apt-get update

printf "${YELLOW}Installing packages...${NC}\n"

apt install -y \
    apt-transport-https \
    apt-utils \
    asciinema \
    ca-certificates \
    curl \
    fzf \
    git \
    gnupg \
    jq \
    nodejs \
    python3 \
    python3-pip \
    shellcheck \
    upx-ucl

# https://github.com/nodesource/distributions#ubuntu-versions
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
apt update
apt install nodejs -y

printf "${YELLOW}Installing Starship...${NC}\n"
curl -sS https://starship.rs/install.sh | sh

printf "${YELLOW}Installing pnpm...${NC}\n"
curl -fsSL https://get.pnpm.io/install.sh | sh -

printf "${YELLOW}Updating Python modules...${NC}\n"
pip install --user --upgrade pip

printf "${YELLOW}Installing Rust...${NC}\n"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# shellcheck source=/dev/null
source $HOME/.cargo/env
rustup update

printf "${YELLOW}Cleaning up...${NC}\n"
apt autoremove -y

printf "${YELLOW}Updating bash...${NC}\n"
cp .bashrc ~/.bashrc

printf "${BLUE}Done!${NC}\n"
