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
apt-get upgrade -y
apt-get update

apt install -y \
    apt-transport-https \
    ca-certificates \
    curl

echo ""
printf "${YELLOW}Registering new package repositories...${NC}\n"

printf "${GREEN}asciinema...${NC}\n"
apt-add-repository ppa:zanchey/asciinema -y

# https://github.com/nodesource/distributions#ubuntu-versions
printf "${GREEN}Node.js...${NC}\n"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg --yes
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
printf "${GREEN}Docker...${NC}\n"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list

# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
printf "${GREEN}kubetcl...${NC}\n"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg --yes
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

echo ""
printf "${YELLOW}Updating and installing extra packages...${NC}\n"
apt update

apt install -y \
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
    upx-ucl

echo ""
printf "${YELLOW}Installing Snap packages...${NC}\n"
snap install brave
snap install code

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

echo ""
printf "${YELLOW}Updating Python pip...${NC}\n"
pip install --user --upgrade pip

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
code --install-extension sdras.night-owl
code --install-extension vscode-icons-team.vscode-icons

printf "${YELLOW}Cleaning up...${NC}\n"
apt autoremove -y

# printf "${YELLOW}Updating bash...${NC}\n"
# cp .bashrc ~/.bashrc

printf "${BLUE}Done!${NC}\n"
