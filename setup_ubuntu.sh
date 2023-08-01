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
apt-get install \
    apt-transport-https \
    apt-utils \
    asciinema \
    fzf \
    git \
    jq \
    nodejs \
    python3 \
    python3-pip \
    -y

printf "${YELLOW}Installing pnpm...${NC}\n"
curl -sS https://starship.rs/install.sh | sh

printf "${YELLOW}Installing pnpm...${NC}\n"
curl -fsSL https://get.pnpm.io/install.sh | sh -

printf "${YELLOW}Updating Python modules...${NC}\n"
pip install --user --upgrade pip

printf "${YELLOW}Cleaning up...${NC}\n"
apt autoremove -y

printf "${YELLOW}Updating bash...${NC}\n"
cp ubuntu.bashrc ~/.bashrc

printf "${BLUE}Done!${NC}\n"
