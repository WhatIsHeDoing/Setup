#!/bin/bash
# shellcheck disable=SC2059
set -e

IS_CONTAINER=$1

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

if [ -z "$IS_CONTAINER" ]; then
    printf "🐧 ${BLUE}Not running in a container.${NC}\n"

else
    printf "🐋 ${BLUE}Running in a container.${NC}\n"
fi

echo ""
printf "📦 ${YELLOW}Updating and installing initial packages...${NC}\n"
sudo apt-get update -y
sudo apt-get autoremove -y
sudo apt-get full-upgrade -y

# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
TZ="Europe/London"

sudo apt-get install -y \
    apt-utils \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    software-properties-common \
    snapd \
    tzdata \
    wget

echo ""
printf "🗒  ${YELLOW}Registering new package repositories...${NC}\n"

echo ""
printf "${GREEN}asciinema...${NC}\n"
sudo apt-add-repository ppa:zanchey/asciinema -y

# https://github.com/nodesource/distributions#ubuntu-versions
echo ""
printf "${GREEN}Node.js...${NC}\n"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg --yes
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
echo ""
printf "${GREEN}Docker...${NC}\n"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# https://docs.docker.com/desktop/install/ubuntu/#install-docker-desktopdocker-desktop
wget -nv -P /tmp/ https://desktop.docker.com/linux/main/amd64/docker-desktop-4.25.0-amd64.deb

# shellcheck source=/dev/null
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list

# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
echo ""
printf "${GREEN}kubetcl...${NC}\n"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg --yes
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# https://github.com/sharkdp/bat
echo ""
printf "${GREEN}bat...${NC}\n"
wget -nv -P /tmp/ https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-musl_0.24.0_amd64.deb

echo ""
printf "📦 ${YELLOW}Updating and installing extra packages...${NC}\n"
sudo apt-get update -y

sudo apt-get install -y \
    apt-utils \
    aptitude \
    asciinema \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-ce-rootless-extras \
    docker-compose-plugin \
    emacs \
    fzf \
    git \
    gnupg \
    jq \
    lld \
    kubectl \
    libpq-dev \
    nodejs \
    pkg-config \
    python3 \
    python3-pip \
    ripgrep \
    shellcheck \
    upx-ucl \
    /tmp/bat-musl_0.24.0_amd64.deb

if [ -z "$IS_CONTAINER" ]; then
    sudo apt-get install -y /tmp/docker-desktop-4.25.0-amd64.deb
else
    printf "${GREEN}Skipping Docker Desktop for containers.${NC}\n"
fi

echo ""
printf "${GREEN}Running Docker post-configuration...${NC}\n"

if [ -z "$IS_CONTAINER" ]; then
    sudo usermod -aG docker "$USER"
else
    printf "${GREEN}Skipping for containers.NC}\n"
fi

echo ""
printf "${GREEN}Installing and testing minikube...${NC}\n"

if [ -z "$IS_CONTAINER" ]; then
    if ! [ -x "$(command -v minikube)" ]; then
        curl -sLO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        minikube start
        minikube addons enable metrics-server
        minikube stop
    else
        printf "${GREEN}Already installed.${NC}\n"
    fi
else
    printf "${GREEN}Skipping for containers.NC}\n"
fi

echo ""
printf "${GREEN}Installing Helm...${NC}\n"

if [ -z "$IS_CONTAINER" ]; then
    sudo snap install helm --classic
else
    printf "${GREEN}Already installed.${NC}\n"
fi

echo ""
printf "${GREEN}Installing Grype...${NC}\n"
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin

echo ""
printf "${GREEN}Installing Container Structure Tests...${NC}\n"

curl -sLO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-linux-amd64 &&
    chmod +x container-structure-test-linux-amd64 &&
    sudo mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test

if [ -z "$IS_CONTAINER" ]; then
    printf "${GREEN}Installing Snap packages...${NC}\n"
    sudo snap install brave
    sudo snap install code
else
    printf "${GREEN}Skipping for containers.${NC}\n"
fi

echo ""
printf "${GREEN}Installing Starship...${NC}\n"

if ! [ -x "$(command -v starship)" ]; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
else
    printf "${GREEN}Already installed${NC}\n"
fi

echo ""
printf "${GREEN}Installing pnpm...${NC}\n"

if ! [ -x "$(command -v pnpm)" ]; then
    # https://github.com/pnpm/pnpm/issues/6217#issuecomment-1723206626
    wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -
else
    printf "${GREEN}Already installed${NC}\n"
fi

echo ""
printf "${GREEN}Installing Rust...${NC}\n"

if ! [ -x "$(command -v rustup)" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    if [ -z "$IS_CONTAINER" ]; then
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
    else
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
else
    printf "${GREEN}Already installed${NC}\n"
fi

echo ""
printf "${YELLOW}Updating Rust...${NC}\n"
rustup update

echo ""
printf "${YELLOW}Installing language packages...${NC}\n"

echo ""
printf "${GREEN}Installing global npm packages...${NC}\n"
sudo npm update --global --no-progress
sudo npm install --global npm-check-updates --no-progress

echo ""
printf "${GREEN}Updating Python packages...${NC}\n"
pip install --no-cache-dir --no-color --progress-bar off --user --upgrade ipykernel pip setuptools

echo ""
printf "${GREEN}Installing VS Code extensions...${NC}\n"

if [ -z "$IS_CONTAINER" ]; then
    code --install-extension davidanson.vscode-markdownlint
    code --install-extension eamodio.gitlens
    code --install-extension editorconfig.editorconfig
    code --install-extension sdras.night-owl
    code --install-extension vscode-icons-team.vscode-icons
else
    printf "${GREEN}Skipping for containers.${NC}\n"
fi

echo ""
printf "${YELLOW}Configuring...${NC}\n"

echo ""
printf "${GREEN}Configuring Git...${NC}\n"
git config --global init.defaultBranch main

echo ""
printf "${GREEN}Copying scripts...${NC}\n"
sudo cp --verbose scripts/rfv /usr/bin/

echo ""
printf "${GREEN}Updating bash...${NC}\n"
cp --verbose .bashrc ~/.bashrc

echo ""
printf "${GREEN}Cleaning up...${NC}\n"
sudo apt-get autoclean -y
rm --verbose /tmp/bat-musl_0.24.0_amd64.deb
rm --verbose /tmp/docker-desktop-4.25.0-amd64.deb

echo ""
printf "${BLUE}Done!${NC}\n"
