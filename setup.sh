# Arch automated build script
# This script download and installs all necessary
# tools to setup my devenv on any freshly installed 
# Arch Linux machine assuming that Linux was pacstraped
# with the following packages:
# pacstrap -K /mnt linux linux-firmware base base-devel networkmanager sof-firmware grub efibootmgr vi man-db man-pages zsh terminus-font
# and the user was added with the flag `-s /bin/zsh`
# some packages up here might not make sense in the
# context of the setup, but they are just reminders to myself.
#! /bin/sh

set -e

# Color definitions
GREEN='\033[0;32m'     # Green
ORANGE='\033[0;33m'    # Orange
NC='\033[0m'           # No Color

echo -e "${GREEN}pacman: Downloading packages${NC}"
sudo pacman -Syyu tmux wget git github-cli diff-so-fancy git-lfs bat pulseaudio alsa-utils jack2 libwebp xorg-server xorg-xinit xorg-xrandr i3-wm i3status dmenu xwallpaper picom pcmanfm vifm clipmenu vim emacs llvm clang lldb gdb valgrind cmake ninja python3 python-pip ipython nasm jdk11-openjdk rustup go gcc-fortran wine wine-mono mingw-w64-binutils mingw-w64-crt mingw-w64-gcc mingw-w64-headers mingw-w64-winpthreads mesa mesa-utils libglvnd vulkan-icd-loader vulkan-intel vulkan-tools qemu-full libvirt virt-manager dnsmasq bridge-utils ttf-ibm-plex bpytop neofetch acpi unzip zip unrar arj p7zip ffmpeg openssh inetutils rsync mtools dosfstools xclip tree shellcheck chromium docker docker-compose

echo -e "${GREEN}code: Making code directories${NC}"
mkdir -p code/
mkdir -p code/bump
mkdir -p code/external

echo -e "${GREEN}st: Downloading st${NC}"
git clone https://git.suckless.org/st ~/code/external/st

echo -e "${GREEN}st: Building st${NC}"
cd ~/code/external/st
sudo make clean install
# Going back home
cd ~

# dotfiles setup
echo -e "${GREEN}st: Downloading dotfiles${NC}"
git clone https://github.com/itsjustgalileo/dotfiles ~/code/dotfiles

echo -e "${GREEN}dotfiles: Deploying dotfiles${NC}"
chmod +x ~/code/dotfiles/deploy.sh
~/code/dotfiles/deploy.sh

# Setting up VIM
echo -e "${GREEN}Setting up VIM${NC}"
echo -e "${GREEN}VIM: Cloning Ultimate vimrc${NC}"
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
echo -e "${GREEN}VIM: Making custom config${NC}"
touch ~/.vim_runtime/my_configs.vim
echo -e "${GREEN}VIM: Downloading VIM phoenix theme${NC}"
git clone https://github.com/widatama/vim-phoenix ~/.vim_runtime/my_plugins/vim-phoenix
echo -e "${GREEN}VIM: Line number/relative line number${NC}"
echo "set nu rnu" >> ~/.vim_runtime/my_configs.vim
echo -e "${GREEN}VIM: Remapping keys${NC}"
echo "inoremap jk <Esc>" >> ~/.vim_runtime/my_configs.vim
echo -e "${GREEN}VIM: Setting up NerdTree${NC}"
echo "let g:NerdTreeWinPos = 'left'" >> ~/.vim_runtime/my_configs.vim
echo -e "${GREEN}VIM: Setting up colorscheme${NC}"
echo "colo phoenix" >> ~/.vim_runtime/my_configs.vim
echo "PhoenixOrangeEighties" >> ~/.vim_runtime/my_configs.vim

echo -e "${GREEN}Cloning bump repos${NC}"
echo -e "${GREEN}bump: Cloning x-roulette${NC}"
git clone https://github.com/itsjustgalileo/x-roulette ~/code/bump/x-roulette
echo -e "${GREEN}bump: Cloning progen${NC}"
git clone https://github.com/itsjustgalileo/progen ~/code/bump/progen

echo -e "${GREEN}Downloading NVM for JS setup${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

echo -e "${GREEN}Downloading GHC up for Haskell setup${NC}"
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

echo -e "${GREEN}cc65: Downloading cc65 compiler toolchains${NC}"
git clone https://github.com/cc65/cc65 ~/code/external/cc65

echo -e "${GREEN}cc65: Building cc65${NC}"
cd ~/code/external/cc65
# building without install and not in sudo mode
make
# Going back home
cd ~

echo -e "${GREEN}Downloading post-install script${NC}"
curl -o ~/post-install.sh https://raw.githubusercontent.com/itsjustgalileo/Arch-setup/master/post-install.sh
chmod +x ~/post-install.sh

echo -e "${ORANGE}WARNING: System about to reboot to apply changes${NC}"
echo -e "${ORANGE}Don't forget to run the post-install script after reboot by running: ${NC}"
echo -e "${ORANGE}~/post-install.sh${NC}"

echo "..."
sleep 5

rm -rf ~/setup.sh

echo -e "${ORANGE}Rebooting system...${NC}"
reboot
