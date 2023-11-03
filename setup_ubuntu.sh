#!/bin/bash
# shellcheck disable=SC2059
BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Colour
YELLOW="\033[1;33m"

echo "   _____      __            "
echo "  / ___/___  / /___  ______ "
echo "  \__ \/ _ \/ __/ / / / __ \\"
echo " ___/ /  __/ /_/ /_/ / /_/ /"
echo "/____/\___/\__/\__,_/ .___/ "
echo "                   /_/      "

echo ""
printf "${BLUE}Running Setup...${NC}\n"

echo ""
printf "${YELLOW}Updating and installing initial packages...${NC}\n"
sudo apt-get upgrade -y
sudo apt-get update

sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl

echo ""
printf "${YELLOW}Registering new package repositories...${NC}\n"

printf "${GREEN}asciinema...${NC}\n"
sudo apt-add-repository ppa:zanchey/asciinema -y

# https://github.com/nodesource/distributions#ubuntu-versions
printf "${GREEN}Node.js...${NC}\n"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg --yes
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
printf "${GREEN}Docker...${NC}\n"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# https://docs.docker.com/desktop/install/ubuntu/#install-docker-desktop
wget -nv -P /tmp/ https://desktop.docker.com/linux/main/amd64/docker-desktop-4.25.0-amd64.deb

echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list

# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
printf "${GREEN}kubetcl...${NC}\n"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg --yes
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo ""
printf "${YELLOW}Updating and installing extra packages...${NC}\n"
sudo apt update

sudo apt install -y \
    apt-utils \
    asciinema \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    fzf \
    git \
    gnupg \
    jq \
    kubectl \
    nodejs \
    python3 \
    python3-pip \
    shellcheck \
    upx-ucl \
    /tmp/docker-desktop-4.25.0-amd64.deb

printf "${YELLOW}Running Docker post-configuration...${NC}\n"
usermod -aG docker "$USER" && newgrp docker
rm /tmp/docker-desktop-4.25.0-amd64.deb

printf "${YELLOW}Installing and testing minikube...${NC}\n"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start
minikube addons enable metrics-server
minikube stop

printf "${YELLOW}Installing Helm...${NC}\n"
sudo snap install helm --classic

echo ""
printf "${YELLOW}Installing Snap packages...${NC}\n"
sudo snap install brave
sudo snap install code

echo ""
printf "${YELLOW}Installing Starship...${NC}\n"

if ! [ -x "$(command -v starship)" ]; then
    curl -sS https://starship.rs/install.sh | sh
else
    printf "${GREEN}Already installed${NC}\n"
fi

echo ""
printf "${YELLOW}Installing pnpm...${NC}\n"

if ! [ -x "$(command -v pnpm)" ]; then
    curl -fsSL https://get.pnpm.io/install.sh | sh -
else
    printf "${GREEN}Already installed${NC}\n"
fi

printf "${YELLOW}Installing global npm packages...${NC}\n"
sudo npm update --global --no-progress
sudo npm install --global npm-check-updates --no-progress

echo ""
printf "${YELLOW}Updating Python pip...${NC}\n"
pip install --user --upgrade ipykernel pip setuptools

echo ""
printf "${YELLOW}Installing Rust...${NC}\n"

if ! [ -x "$(command -v rustup)" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
else
    printf "${GREEN}Already installed${NC}\n"
fi

printf "${GREEN}Updating Rust...${NC}\n"
rustup update

printf "${YELLOW}Installing global VS Code extensions...${NC}\n"
code --install-extension eamodio.gitlens
code --install-extension sdras.night-owl
code --install-extension vscode-icons-team.vscode-icons

printf "${YELLOW}Configuring Git...${NC}\n"
git config --global init.defaultBranch main

printf "${YELLOW}Cleaning up...${NC}\n"
sudo apt autoremove -y

# printf "${YELLOW}Updating bash...${NC}\n"
# cp .bashrc ~/.bashrc

printf "${BLUE}Done!${NC}\n"
