# \file install.sh
# \brief Arch/BlackArch automated build script
# This script download and installs all necessary
# tools to setup my devenv on any freshly installed 
# Arch Linux machine assuming that Linux was pacstraped
# with the following packages:
# pacstrap -K /mnt linux linux-firmware base base-devel networkmanager sof-firmware grub efibootmgr vi man-db man-pages zsh terminus-font
# and the user was added with the flag `-s /bin/zsh`
# some packages up here might not make sense in the
# context of the setup, they are reminders to myself.
#! /bin/sh

set -e

# Color definitions
RED='\033[0;31m'     # Green
GREEN='\033[0;32m'     # Green
ORANGE='\033[0;33m'    # Orange
NC='\033[0m'           # No Color

echo -e "${GREEN}[INFO] - pacman: Downloading packages${NC}"
sudo pacman -Syyu --needed tmux wget git github-cli diff-so-fancy git-lfs bat pulseaudio alsa-utils jack2 libwebp xorg-server xorg-xinit xorg-xrandr xorg-xwininfo imagemagick libx11 i3-wm i3status dmenu feh picom pcmanfm vifm clipmenu vim emacs texlive-basic zathura zathura-pdf-mupdf tesseract-data-eng poppler poppler-glib llvm clang lldb gdb valgrind cmake ninja python3 python-pip ipython python-pytest nasm jdk11-openjdk rustup go gcc-fortran gcc-ada freebasic hoogle doxygen wine wine-mono mingw-w64-binutils mingw-w64-crt mingw-w64-gcc mingw-w64-headers mingw-w64-winpthreads mesa mesa-utils libglvnd vulkan-icd-loader vulkan-intel vulkan-tools qemu-full libvirt virt-manager dnsmasq bridge-utils ttf-ibm-plex bpytop neofetch acpi unzip zip unrar arj p7zip ffmpeg openssh inetutils dhcpcd rsync mtools dosfstools xclip tree shellcheck chromium docker docker-compose qt6-3d qt6-5compat qt6-base qt6-charts qt6-connectivity qt6-datavis3d qt6-declarative qt6-doc qt6-examples qt6-graphs qt6-grpc qt6-httpserver qt6-imageformats qt6-languageserver qt6-location qt6-lottie qt6-multimedia qt6-networkauth qt6-positioning qt6-quick3d qt6-quick3dphysics qt6-quickeffectmaker qt6-quicktimeline qt6-remoteobjects qt6-scxml qt6-sensors qt6-serialbus qt6-serialport qt6-shadertools qt6-speech qt6-svg qt6-tools qt6-translations qt6-virtualkeyboard qt6-wayland qt6-webchannel qt6-webengine qt6-websockets qt6-webview qt6-multimedia-ffmpeg

# Black Arch
echo -e "${GREEN}[INFO] - Running Black Arch Bootstrap${NC}"
curl -o ~/strap.sh https://blackarch.org/strap.sh
echo 26849980b35a42e6e192c6d9ed8c46f0d6d06047 ~/strap.sh | sha1sum -c
chmod +x ~/strap.sh
sudo ~/strap.sh
rm -rf ~/strap.sh

# DevKitPro setup
echo -e "${GREEN}[INFO] - Post-install: Setting up DevKitPro${NC}"
sudo pacman-key --recv BC26F752D25B92CE272E0F44F7FD5492264BB9D0 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign BC26F752D25B92CE272E0F44F7FD5492264BB9D0
wget https://pkg.devkitpro.org/devkitpro-keyring.pkg.tar.xz
sudo pacman -U devkitpro-keyring.pkg.tar.xz
echo "[dkp-libs]" | sudo tee -a /etc/pacman.conf
echo "Server = https://pkg.devkitpro.org/packages" | sudo tee -a /etc/pacman.conf
echo "[dkp-linux]" | sudo tee -a /etc/pacman.conf
echo "Server = https://pkg.devkitpro.org/packages/linux/\$arch" | sudo tee -a /etc/pacman.conf
rm -rf devkitpro-keyring.pkg.tar.xz

# System upgrade (optional: upgrade system packages and data)
echo -e "${GREEN}[INFO] - Post-install: Upgrading system packages${NC}"
sudo pacman --noconfirm -Syu

# Enable Docker and libvirtd services
echo -e "${GREEN}[INFO] - Post-install: Enabling Docker and libvirt services${NC}"
sudo systemctl enable --now docker
sudo systemctl enable --now libvirtd

# dotfiles setup
echo -e "${GREEN}[INFO] - st: Downloading dotfiles${NC}"
git clone https://github.com/itsjustgalileo/dotfiles ~/code/dotfiles

echo -e "${GREEN}[INFO] - dotfiles: Deploying dotfiles${NC}"
chmod +x ~/code/dotfiles/deploy.sh
~/code/dotfiles/deploy.sh

# Creating ~/code/external directory
echo -e "${GREEN}[INFO] - code: Making code directories${NC}"
mkdir -p ~/code/
mkdir -p ~/code/external
mkdir -p ~/code/tools

# Grabbing ourselves a terminal
echo -e "${GREEN}[INFO] - st: Downloading st${NC}"
git clone https://git.suckless.org/st ~/code/external/st
echo -e "${GREEN}[INFO] - st: Building st${NC}"
cd ~/code/external/st
sudo make clean install
echo -e "${GREEN}[INFO] - st: Configuring st${NC}"
sed -i 's/Liberation/IBM Plex/' config.h
sed -i 's/pixelsize=12/pixelsize=14/' config.h
sed -i 's/sh\"/zsh\"/' config.h
sed -i 's/termname = \"st-256color\"/termname = \"st\"/' config.h
sed -i 's/tabspaces = 8/tabspaces = 4/' config.h
echo -e "${GREEN}[INFO] - st: Rebuilding st${NC}"
sudo make clean install
# Going back home
cd ~

# Downloading NVM for node and npm management
echo -e "${GREEN}[INFO] - Downloading NVM for JS setup${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Downloading Haskell tools (equivalent to rustup)
echo -e "${GREEN}[INFO] - Downloading GHC up for Haskell setup${NC}"
echo -e "${ORANGE}[WARNING] - Choose 'N' for zshrc modification and 'Y' for the rest"
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# cc65 compiler toolchain for 65x cpu development
echo -e "${GREEN}[INFO] - cc65: Downloading cc65 compiler toolchains${NC}"
git clone https://github.com/cc65/cc65 ~/code/external/cc65

echo -e "${GREEN}[INFO] - cc65: Building cc65${NC}"
cd ~/code/external/cc65
# building without install and not in sudo mode
make
# Going back home
cd ~

# Aseprite setup
echo -e "${GREEN}[INFO] - Aseprite: Downloading Aseprite${NC}"
cd ~/code/tools/aseprite wget https://bonfi96.altervista.org/files/aseprites_builds/Aseprite_v1.1.5.6_LNX.zip
unzip Aseprite_v1.1.5.6_LNX.zip
rm -rf Aseprite_v1.1.5.6_LNX.zip
cd ~

# fceux setup
echo -e "${GREEN}[INFO] - FCEUX: Downloading FCEUX${NC}"
git clone https://github.com/TASEmulators/fceux ~/code/tools/fceux
echo -e "${GREEN}[INFO] - FCEUX: Building FCEUX${NC}"
cd ~/code/external/fceux
cmake -Bbuild .
cmake --build build
cd ~

# YY-CHR
echo -e "${GREEN}[INFO] - YY-CHR: Downloading YY-CHR"
cd ~/code/tools/
mkdir yychr
cd yychr
wget https://dl.smwcentral.net/27208/yychr20210606.zip
unzip yychr20210606.zip
mv yychr20210606/* .
rm -rf yychr20210606/ yychr20210606.zip
cd ~

# Setting up VIM
# Stolen from https://github.com/amix/vimrc for convinience
echo -e "${GREEN}[INFO] - Setting up VIM${NC}"
echo -e "${GREEN}[INFO] - VIM: Cloning Ultimate vimrc${NC}"
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
echo -e "${GREEN}[INFO] - VIM: Making custom config${NC}"
touch ~/.vim_runtime/my_configs.vim
echo -e "${GREEN}[INFO] - VIM: Grabbing protanopia theme${NC}"
git clone https://github.com/itsjustgalileo/protanopia-vim ~/.vim_runtime/my_plugins/protanopia-vim/
echo -e "${GREEN}[INFO] - VIM: Setting up NerdTree${NC}"
echo -e "${RED} WHO PUTS A FILE EXPLORER ON THE RIGHT?"
sed -i 's/let g:NERDTreeWinPos = "right"/let g:NERDTreeWinPos = "left"/' ~/.vim_runtime/vimrcs/plugins_config.vim
echo -e "${GREEN}[INFO] - VIM: Line number/relative line number${NC}"
echo "set nu rnu" >> ~/.vim_runtime/my_configs.vim
echo -e "${GREEN}[INFO] - VIM: Remapping keys${NC}"
echo "inoremap jk <Esc>" >> ~/.vim_runtime/my_configs.vim
echo -e "${GREEN}[INFO] - VIM: Setting up colorscheme${NC}"
echo "colo protanopia" >> ~/.vim_runtime/my_configs.vim

# Create the emacs.service file if it doesn't exist
echo -e "${GREEN}[INFO] - Setting up daemon service${NC}"

# restarting binfmt for wine
sudo systemctl restart systemd-binfmt

# Reload systemd user services
systemctl --user daemon-reload

# Enable the Emacs daemon service
systemctl --user enable emacs.service

# Downloading post-install script
echo -e "${GREEN}[INFO] - Downloading post-install script${NC}"
curl -o ~/post-install.sh https://raw.githubusercontent.com/itsjustgalileo/Arch-setup/master/post-install.sh
chmod +x ~/post-install.sh

# Cleaning up install.sh itself
echo -e "${GREEN}[INFO] - Cleaning up install.sh${NC}"
rm -rf ~/install.sh

# Reboot to finalize the setup
echo -e "${ORANGE}[WARNING] - Rebooting system to apply changes${NC}"
sleep 5
reboot
