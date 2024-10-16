# \file install.sh
# \brief Arch/BlackArch automated setup script
# This script downloads and installs all the necessary
# tools to setup my devenv on any freshly installed 
# Arch Linux machine assuming that Linux was pacstraped
# with the following packages:
# pacstrap -K /mnt linux linux-firmware base base-devel networkmanager sof-firmware grub efibootmgr vi man-db man-pages terminus-font
# and the user was added to sudoers and created with flags `-m -G wheel -s /bin/zsh`
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
sudo pacman -Syyu --needed \
alacritty tmux wget clipmenu tree htop neofetch acpi unzip zip unrar arj p7zip ffmpeg openssh inetutils dhcpcd rsync mtools dosfstools xclip shellcheck slock pulseaudio alsa-utils jack2 libwebp libxext xorg-server xorg-xinit xorg-xrandr xorg-xwininfo arc-gtk-theme i3-wm i3status dmenu feh picom imagemagick scrot vim emacs texlive-basic texlive-core texlive-bin texlive-latexextra zathura zathura-pdf-mupdf tesseract-data-eng poppler poppler-glib git github-cli diff-so-fancy git-lfs llvm lldb gdb valgrind cmake ninja clang python3 ipython python-pip python-pipx jupyter-notebook jdk-openjdk rustup go nim gcc-ada clojure erlang ocaml dune coq hoogle doxygen wine wine-mono mingw-w64-binutils mingw-w64-gcc mingw-w64-crt mingw-w64-winpthreads mingw-w64-headers libx11 mesa mesa-utils libglvnd vulkan-icd-loader vulkan-intel vulkan-tools libvirt docker docker-compose otf-latin-modern otf-latinmodern-math noto-fonts noto-fonts-cjk noto-fonts-emoji pcmanfm chromium vlc reaper obs inkscape gimp qt6-multimedia-ffmpeg

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
echo -e "${GREEN}[INFO] - Post-install: Enabling systemd services${NC}"
sudo systemctl enable --now docker
sudo systemctl enable --now libvirtd
# restarting binfmt for wine
sudo systemctl restart systemd-binfmt

# Creating ~/code/external directory
echo -e "${GREEN}[INFO] - code: Making code directories${NC}"
mkdir -p ~/code/
mkdir -p ~/utils/
mkdir -p ~/code/external
mkdir -p ~/code/tools
mkdir -p ~/software/aseprite

# dotfiles setup
echo -e "${GREEN}[INFO] - st: Downloading dotfiles${NC}"
git clone https://github.com/itsjustgalileo/dotfiles ~/code/dotfiles

echo -e "${GREEN}[INFO] - dotfiles: Deploying dotfiles${NC}"
chmod +x ~/code/dotfiles/deploy.sh
~/code/dotfiles/deploy.sh

# Desktop zooming
echo -e "${GREEN}[INFO] - OK BOOMER${NC}"
git clone https://github.com/tsoding/boomer ~/utils/boomer
cd ~/utils/boomer
nimble build
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
cd ~/software/aseprite 
wget https://bonfi96.altervista.org/files/aseprites_builds/Aseprite_v1.1.5.6_LNX.zip
unzip Aseprite_v1.1.5.6_LNX.zip
rm -rf Aseprite_v1.1.5.6_LNX.zip
chmod +x aseprite
cd ~

# fceux setup
echo -e "${GREEN}[INFO] - FCEUX: Downloading FCEUX${NC}"
git clone https://github.com/TASEmulators/fceux ~/code/tools/fceux
echo -e "${GREEN}[INFO] - FCEUX: Building FCEUX${NC}"
cd ~/code/tools/fceux
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
echo "colorscheme protanopia" >> ~/.vim_runtime/my_configs.vim

# Refreshing fonts
echo -r "${GREEN}[INFO] - Refreshing fonts${NC}"
fc-cache -f -v

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
