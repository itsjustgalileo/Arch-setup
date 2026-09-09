# \file install.sh
# \brief Arch/BlackArch automated setup script
# This script downloads and installs all the necessary
# tools to setup my devenv on any freshly installed 
# Arch Linux machine assuming that Linux was pacstraped
# with the following packages:
# pacstrap -K /mnt linux linux-firmware base base-devel networkmanager sof-firmware grub efibootmgr zsh vi man-db man-pages terminus-font
# and the user was added to sudoers and created with flags `-m -G wheel -s /bin/zsh`
# some packages up here might not make sense in the
# context of the setup, they are reminders to myself.
#! /bin/sh

set -e

# Color definitions (taken from Color Bash Prompt HowTo).
# Some colors might look different of some terminals.
# For example, I see 'Bold Red' as 'orange' on my screen,
# hence the 'Green' 'BRed' 'Red' sequence I often use in my prompt.


# Normal Colors
black='\e[0;30m'        # Black
red='\e[0;31m'          # Red
green='\e[0;32m'        # Green
yellow='\e[0;33m'       # Yellow
blue='\e[0;34m'         # Blue
magenta='\e[0;35m'      # Magenta
cyan='\e[0;36m'         # Cyan
white='\e[0;37m'        # White

# Bold
BLACK='\e[1;30m'       # Black
RED='\e[1;31m'         # Red
GREEN='\e[1;32m'       # Green
YELLOW='\e[1;33m'      # Yellow
BLUE='\e[1;34m'        # Blue
MAGENTA='\e[1;35m'     # Magenta
CYAN='\e[1;36m'        # Cyan
WHITE='\e[1;37m'       # White

# Background
Black='\e[40m'       # Black
Red='\e[41m'         # Red
Green='\e[42m'       # Green
Yellow='\e[43m'      # Yellow
Blue='\e[44m'        # Blue
Magenta='\e[45m'     # Magenta
Cyan='\e[46m'        # Cyan
White='\e[47m'       # White

NC="\e[m"               # Color Reset


ALERT=${WHITE}${Red} # Bold White on red background

echo -e "${GREEN}[INFO] - pacman: Downloading packages${NC}"
sudo pacman -Syyu --needed \
alacritty tmux wget clipmenu tree htop acpi unzip zip unrar arj p7zip ffmpeg openssh inetutils dhcpcd rsync mtools dosfstools xclip shellcheck dex network-manager-applet pulseaudio alsa-utils jack2 libwebp libxext xorg-server xorg-xinit xorg-xrandr xorg-xwininfo i3-wm i3status dmenu xss-lock feh picom imagemagick scrot vim emacs texlive-basic texlive-core texlive-bin texlive-latexextra texlive-langextra zathura zathura-pdf-mupdf tesseract-data-eng poppler poppler-glib git github-cli diff-so-fancy git-lfs llvm lldb gdb valgrind cmake ninja clang python3 ipython python-pip python-pipx jupyter-notebook jdk-openjdk rustup go gcc-ada ocaml dune coq hoogle doxygen libx11 mesa mesa-utils libvirt docker docker-compose otf-latin-modern otf-latinmodern-math noto-fonts noto-fonts-cjk noto-fonts-emoji pcmanfm vlc

# Brave browser
echo -e "${GREEN}[INFO] - Installing Brave${NC}"
curl -fsS https://dl.brave.com/install.sh | sh

# Black Arch
echo -e "${GREEN}[INFO] - Running Black Arch Bootstrap${NC}"
curl -O https://blackarch.org/strap.sh
sha1sum strap.sh
sudo chmod +x strap.sh
sudo ./strap.sh
sudo pacman -S --needed blackarch-officials 

# DevKitPro setup
echo -e "${GREEN}[INFO] - Post-install: Setting up DevKitPro${NC}"
echo "DEVKITPRO=/opt/devkitpro" | sudo tee -a ~/.profile
echo "DEVKITARM=/opt/devkitpro/devkitARM" | sudo tee -a ~/.profile
echo "DEVKITPROPPC=/opt/devkitpro/devkitPPC" | sudo tee -a ~/.profile

sudo pacman-key --recv BC26F752D25B92CE272E0F44F7FD5492264BB9D0 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign BC26F752D25B92CE272E0F44F7FD5492264BB9D0

sudo pacman -U https://pkg.devkitpro.org/devkitpro-keyring.pkg.tar.zst
sudo pacman-key --populate devkitpro

echo "[dkp-libs]" | sudo tee -a /etc/pacman.conf
echo "Server = https://pkg.devkitpro.org/packages" | sudo tee -a /etc/pacman.conf
echo "[dkp-linux]" | sudo tee -a /etc/pacman.conf
echo "Server = https://pkg.devkitpro.org/packages/linux/\$arch" | sudo tee -a /etc/pacman.conf

# System upgrade (optional: upgrade system packages and data)
echo -e "${GREEN}[INFO] - Post-install: Upgrading system packages${NC}"
sudo pacman --noconfirm -Syu

# Enable Docker and libvirtd services
echo -e "${GREEN}[INFO] - Post-install: Enabling systemd services${NC}"
sudo systemctl enable --now docker
sudo systemctl enable --now libvirtd

# Creating ~/code/external directory
echo -e "${GREEN}[INFO] - code: Making code directories${NC}"
mkdir -p ~/code/
mkdir -p ~/utils/
mkdir -p ~/code/external
mkdir -p ~/code/tools

# dotfiles setup
echo -e "${GREEN}[INFO] - st: Downloading dotfiles${NC}"
git clone https://github.com/itsjustgalileo/dotfiles ~/code/dotfiles

echo -e "${GREEN}[INFO] - dotfiles: Deploying dotfiles${NC}"
chmod +x ~/code/dotfiles/deploy.sh
~/code/dotfiles/deploy.sh

# Downloading NVM for node and npm management
echo -e "${GREEN}[INFO] - Downloading NVM for JS setup${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Downloading Haskell tools (equivalent to rustup)
echo -e "${GREEN}[INFO] - Downloading GHC up for Haskell setup${NC}"
echo -e "${ORANGE}[WARNING] - Choose 'N' for bashrc modification and 'Y' for the rest"
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

echo -e "${GREEN}[INFO] - Nim: Building Nim${NC}"
cd ~/code/external
git clone https://github.com/nim-lang/Nim
cd ./Nim
./build_all.sh

# Going back home
cd ~

echo -e "${GREEN}[INFO] - boomer: Builing boomer${NC}"
cd ~/utils/
git clone https://github.com/tsoding/boomer
cd boomer
~/code/external/Nim/bin/nimble build

# Going back home
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

# Download Monaspace font
echo -e "${YELLOW}[WARNING] - Please download and install Monaspace font from: ${NC}"
echo -e "${YELLOW}[WARNING] - https://github.com/githubnext/monaspace ${NC}"
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
