#!/bin/bash

BLUE="\033[0;34m"
NC="\033[0m" # No Colour
YELLOW="\033[1;33m"

cat banner.txt
echo

echo -e "${YELLOW}Registering new repositories...${NC}"
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

echo -e "${YELLOW}Updating the package cache...${NC}"
dnf check-update --assumeyes

echo -e "${YELLOW}Updating applications...${NC}"
dnf autoremove --assumeyes
dnf update --assumeyes

echo -e "${YELLOW}Installing applications...${NC}"
dnf install --assumeyes \
    chromium \
    code \
    git \
    nodejs \
    openssl-devel \
    openvpn \
    python3-pip \
    yum-utils

echo -e "${YELLOW}Updating runtime packages...${NC}"
pip3 install --upgrade pip
npm update -g

echo -e "${YELLOW}Installing runtime packages...${NC}"
npm install gulp npm-check -g

echo -e "${YELLOW}Cleaning up...${NC}"
dnf clean all

echo -e "${BLUE}Done!${NC}"
