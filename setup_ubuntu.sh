#!/bin/bash
# shellcheck disable=SC2059
set -e

IS_CONTAINER=$1

BLUE="\033[0;34m"
GREEN="\033[0;32m"
NC="\033[0m" # No Colour
YELLOW="\033[1;33m"

cat banner.txt
echo

if [ -z "$IS_CONTAINER" ]; then
    printf "🐧 ${BLUE}Not running in a container.${NC}\n"

else
    printf "🐋 ${BLUE}Running in a container.${NC}\n"
fi

echo
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
    gpg \
    software-properties-common \
    snapd \
    tzdata \
    wget

echo
printf "🗒  ${YELLOW}Registering new package repositories...${NC}\n"

echo
printf "${GREEN}asciinema...${NC}\n"
sudo apt-add-repository ppa:zanchey/asciinema -y

# https://www.flatpak.org/setup/Ubuntu
echo
printf "${GREEN}Flatpack...${NC}\n"
sudo apt-add-repository ppa:flatpak/stable -y

echo
printf "🗒  ${YELLOW}Downloading packages without repositories...${NC}\n"

# https://docs.makedeb.org/prebuilt-mpr/getting-started/#setting-up-the-repository
echo
printf "${GREEN}makedb...${NC}\n"
wget -qO - 'https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub' | gpg --dearmor | sudo tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1>/dev/null
echo "deb [arch=all,$(dpkg --print-architecture) signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.makedeb.org prebuilt-mpr $(lsb_release -cs)" | sudo tee /etc/apt/sources.list.d/prebuilt-mpr.list

# https://github.com/nodesource/distributions#ubuntu-versions
echo
printf "${GREEN}Node.js...${NC}\n"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg --yes
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
# https://docs.docker.com/desktop/release-notes/
echo
printf "${GREEN}Docker...${NC}\n"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# shellcheck source=/dev/null
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# https://docs.docker.com/desktop/install/ubuntu/#install-docker-desktopdocker-desktop
DOCKER_DESKTOP_VERSION=4.26.1
wget -nv -P /tmp/ https://desktop.docker.com/linux/main/amd64/docker-desktop-$DOCKER_DESKTOP_VERSION-amd64.deb

# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
echo
printf "${GREEN}kubetcl...${NC}\n"
K8S_VERSION=1.29
curl -fsSL https://pkgs.k8s.io/core:/stable:/v$K8S_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg --yes
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v'$K8S_VERSION'/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# https://learn.microsoft.com/en-gb/powershell/scripting/install/install-ubuntu?view=powershell-7.3
echo
printf "${GREEN}PowerShell...${NC}\n"
wget -nv -P /tmp/ https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb
rm --verbose /tmp/packages-microsoft-prod.deb

echo
printf "${GREEN}eza...${NC}\n"
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg --yes
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# https://github.com/sharkdp/bat
# https://github.com/sharkdp/bat/releases
echo
printf "${GREEN}bat...${NC}\n"
BAT_VERSION=0.24.0
wget -nv -P /tmp/ https://github.com/sharkdp/bat/releases/download/v$BAT_VERSION/bat-musl_"$BAT_VERSION"_amd64.deb

# https://docs.warp.dev/getting-started/getting-started-with-warp#installing-warp
echo
printf "${GREEN}Warp...${NC}\n"
wget -nv -O /tmp/warp.deb https://app.warp.dev/download?package=deb

echo
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
    dotnet-sdk-6.0 \
    emacs \
    eza \
    ffmpeg \
    flatpak \
    fzf \
    git \
    git-lfs \
    gnome-software-plugin-flatpak \
    gnupg \
    jid \
    jq \
    just \
    lld \
    kubectl \
    libpq-dev \
    nodejs \
    p7zip-full \
    p7zip-rar \
    pandoc \
    pkg-config \
    poppler-utils \
    powershell \
    python3 \
    python3-pip \
    ripgrep \
    shellcheck \
    upx-ucl \
    /tmp/bat-musl_"$BAT_VERSION"_amd64.deb \
    /tmp/warp.deb

echo
printf "${GREEN}Enabling Git Large File Storage...${NC}\n"
git lfs install

# https://www.flatpak.org/setup/Ubuntu
# https://flathub.org/apps/io.bassi.Amberol
echo
printf "${GREEN}Installing Flatpak apps...${NC}\n"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y \
    flathub \
    io.bassi.Amberol

echo
printf "${GREEN}Installing Docker Desktop...${NC}\n"

if [ -z "$IS_CONTAINER" ]; then
    sudo apt-get install -y /tmp/docker-desktop-$DOCKER_DESKTOP_VERSION-amd64.deb
else
    printf "${GREEN}Skipping for containers.NC}\n"
fi

echo
printf "${GREEN}Running Docker post-configuration...${NC}\n"

if [ -z "$IS_CONTAINER" ]; then
    sudo usermod -aG docker "$USER"
else
    printf "${GREEN}Skipping for containers.NC}\n"
fi

echo
printf "${GREEN}Installing the Zed editor...${NC}\n"
curl -sSfL https://zed.dev/install.sh | sh

echo
printf "${GREEN}Installing Earthly...${NC}\n"

if ! [ -x "$(command -v earthly)" ]; then
    # https://earthly.dev/get-earthly
    sudo wget -nv https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64 -O /usr/local/bin/earthly
    sudo chmod +x /usr/local/bin/earthly
    sudo /usr/local/bin/earthly bootstrap --with-autocomplete
else
    printf "${GREEN}Already installed${NC}\n"
fi

echo
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

echo
printf "${GREEN}Installing Helm...${NC}\n"

if [ -z "$IS_CONTAINER" ]; then
    sudo snap install helm --classic
else
    printf "${GREEN}Already installed.${NC}\n"
fi

echo
printf "${GREEN}Installing Grype...${NC}\n"
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin

echo
printf "${GREEN}Installing Container Structure Tests...${NC}\n"

curl -sLO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-linux-amd64 &&
    chmod +x container-structure-test-linux-amd64 &&
    sudo mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test

if [ -z "$IS_CONTAINER" ]; then
    printf "${GREEN}Installing Snap packages...${NC}\n"
    sudo snap install bottom
    sudo snap install brave
    sudo snap install code
    sudo snap install k9s
    sudo snap install spotify

    sudo snap connect bottom:mount-observe
    sudo snap connect bottom:hardware-observe
    sudo snap connect bottom:system-observe
    sudo snap connect bottom:process-control
else
    printf "${GREEN}Skipping for containers.${NC}\n"
fi

echo
printf "${GREEN}Installing Starship...${NC}\n"

if ! [ -x "$(command -v starship)" ]; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
else
    printf "${GREEN}Already installed${NC}\n"
fi

echo
printf "${GREEN}Installing pnpm...${NC}\n"

if ! [ -x "$(command -v pnpm)" ]; then
    # https://github.com/pnpm/pnpm/issues/6217#issuecomment-1723206626
    wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -
else
    printf "${GREEN}Already installed${NC}\n"
fi

echo
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

echo
printf "${YELLOW}Updating Rust...${NC}\n"
rustup update

echo
printf "${YELLOW}Installing and updating global language packages...${NC}\n"

echo
printf "${GREEN}npm...${NC}\n"
sudo npm update --global --no-progress
sudo npm install --global --no-progress npm npm-check-updates

echo
printf "${GREEN}Python...${NC}\n"
pip install --no-cache-dir --no-color --progress-bar off --user --upgrade ipykernel pip setuptools

echo
printf "${GREEN}Rust...${NC}\n"
cargo install cargo-outdated cargo-update diskonaut wasm-pack
cargo install-update -a

echo
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

echo
printf "${YELLOW}Configuring...${NC}\n"

echo
printf "${GREEN}Configuring Git...${NC}\n"
git config --global init.defaultBranch main
git config --global fetch.prune true

echo
printf "${GREEN}Configuring bottom...${NC}\n"
mkdir -p ~/.config/bottom/
cp --verbose config/bottom.toml ~/.config/bottom/bottom.toml

echo
printf "${GREEN}Copying scripts...${NC}\n"
sudo cp --verbose scripts/ff /usr/bin/

echo
printf "${GREEN}Updating bash...${NC}\n"
cp --verbose .bashrc ~/.bashrc

echo
printf "${GREEN}Cleaning up...${NC}\n"
sudo apt-get autoclean -y
rm --verbose /tmp/bat-musl_"$BAT_VERSION"_amd64.deb
rm --verbose /tmp/docker-desktop-$DOCKER_DESKTOP_VERSION-amd64.deb

echo
printf "${BLUE}Done!${NC}\n"
