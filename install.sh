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
sudo pacman -Syyu tmux wget git github-cli diff-so-fancy git-lfs bat pulseaudio alsa-utils jack2 libwebp xorg-server xorg-xinit xorg-xrandr libx11 i3-wm i3status dmenu feh picom pcmanfm vifm clipmenu vim emacs texlive-basic zathura zathura-pdf-mupdf llvm clang lldb gdb valgrind cmake ninja python3 python-pip ipython python-pytest nasm jdk11-openjdk rustup go gcc-fortran gcc-ada hoogle doxygen wine wine-mono mingw-w64-binutils mingw-w64-crt mingw-w64-gcc mingw-w64-headers mingw-w64-winpthreads mesa mesa-utils libglvnd vulkan-icd-loader vulkan-intel vulkan-tools qemu-full libvirt virt-manager dnsmasq bridge-utils ttf-ibm-plex bpytop neofetch acpi unzip zip unrar arj p7zip ffmpeg openssh inetutils dhcpcd rsync mtools dosfstools xclip tree shellcheck chromium docker docker-compose

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
sudo pacman -Syu

sudo systemctl restart systemd-binfmt

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

echo -e "${GREEN}[INFO] - code: Making code directories${NC}"
mkdir -p code/
mkdir -p code/external

echo -e "${GREEN}[INFO] - st: Downloading st${NC}"
git clone https://git.suckless.org/st ~/code/external/st

echo -e "${GREEN}[INFO] - st: Building st${NC}"
cd ~/code/external/st
sudo make clean install
# Going back home
cd ~

# Downloading NVM for node and npm management
echo -e "${GREEN}[INFO] - Downloading NVM for JS setup${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Downloading Haskell tools
echo -e "${GREEN}[INFO] - Downloading GHC up for Haskell setup${NC}"
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

echo -e "${GREEN}[INFO] - Downloading ghcid${NC}"
cabal-update && cabal install ghcid

# cc65 compiler toolchain for 65x cpu development
echo -e "${GREEN}[INFO] - cc65: Downloading cc65 compiler toolchains${NC}"
git clone https://github.com/cc65/cc65 ~/code/external/cc65

echo -e "${GREEN}[INFO] - cc65: Building cc65${NC}"
cd ~/code/external/cc65
# building without install and not in sudo mode
make
# Going back home
cd ~

# Setting up VIM
echo -e "${GREEN}[INFO] - Setting up VIM${NC}"
echo -e "${GREEN}[INFO] - VIM: Cloning Ultimate vimrc${NC}"
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
echo -e "${GREEN}[INFO] - VIM: Making custom config${NC}"
touch ~/.vim_runtime/my_configs.vim
echo -e "${GREEN}[INFO] - VIM: Downloading VIM phoenix theme${NC}"
git clone https://github.com/widatama/vim-phoenix ~/.vim_runtime/my_plugins/vim-phoenix
echo -e "${GREEN}[INFO] - VIM: Line number/relative line number${NC}"
echo "set nu rnu" >> ~/.vim_runtime/my_configs.vim
echo -e "${GREEN}[INFO] - VIM: Remapping keys${NC}"
echo "inoremap jk <Esc>" >> ~/.vim_runtime/my_configs.vim
echo -e "${GREEN}[INFO] - VIM: Setting up NerdTree${NC}"
echo "let g:NerdTreeWinPos = 'left'" >> ~/.vim_runtime/my_configs.vim
echo -e "${GREEN}[INFO] - VIM: Setting up colorscheme${NC}"
echo "colo phoenix" >> ~/.vim_runtime/my_configs.vim
echo "PhoenixBlueEighties" >> ~/.vim_runtime/my_configs.vim

# Create the emacs.service file if it doesn't exist
echo -e "${GREEN}[INFO] - Setting up Emacs daemon service${NC}"

mkdir -p ~/.config/systemd/user

cat <<EOF > ~/.config/systemd/user/emacs.service
[Unit]
Description=Emacs: the extensible, self-documenting text editor
Documentation=info:emacs man:emacs(1) https://gnu.org/software/emacs/
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/emacs --daemon
ExecStop=/usr/bin/emacsclient --eval "(kill-emacs)"
Restart=on-failure

[Install]
WantedBy=default.target
EOF

# Setting up the post-install systemd service
echo -e "${GREEN}[INFO] - Setting up post-install service${NC}"

# Create the post-install.service file
[Unit]
Description=Post-Install Script
After=network.target

[Service]
Type=oneshot
ExecStartPre=/bin/sh -c 'while [ -z "$(pgrep i3)" ] || [ -z "$(pgrep chromium)" ]; do sleep 1; done'
ExecStart=/bin/sh /home/galileo/post-install.sh
ExecStartPost=/bin/rm /home/galileo/post-install.sh
ExecStartPost=/bin/systemctl --user disable post-install.service
RemainAfterExit=true

[Install]
WantedBy=default.target
EOF

# Reload systemd user services
systemctl --user daemon-reload

# Enable the Emacs daemon service
systemctl --user enable emacs.service

# Enable the post-install service
systemctl --user enable post-install.service

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
