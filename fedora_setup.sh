BLUE="\033[0;34m"
NC="\033[0m" # No Colour
YELLOW="\033[1;33m"

echo -e "${BLUE}Running Setup${NC}"

echo -e "${YELLOW}Registering new repositories...${NC}"
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

echo -e "${YELLOW}Updating the package cache...${NC}"
dnf check-update

echo -e "${YELLOW}Installing applications...${NC}"
dnf install \
    chromium \
    code \
    git \
    nodejs \
    openssl-devel \
    openvpn \
    ruby \
    yum-utils

echo -e "${YELLOW}Updating applications...${NC}"
# Confirm interactively, rather than auto-accept!
dnf update

echo -e "${YELLOW}Installing runtime packages...${NC}"
gem install jekyll bundler --no-document
npm install gulp npm-check -g
pip3 install --upgrade pip
pip3 install flask pygments --user

echo -e "${YELLOW}Updating runtime packages...${NC}"
gem update --no-document
npm update -g

echo -e "${YELLOW}Cleaning up...${NC}"
dnf clean all

echo -e "${BLUE}Done!${NC}"
