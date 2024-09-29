#! /bin/sh

set -e  # Exit on error

# Log all output to setup.log
exec > >(tee -i ~/setup.log)
exec 2>&1

echo "pacman: Downloading packages"
sudo pacman -Syyu zsh tmux wget git github-cli diff-so-fancy git-lfs bat pulseaudio alsa-utils jack2 libwebp xorg-server xorg-xinit xorg-xrandr i3-wm i3status dmenu xwallpaper picom pcmanfm vifm clipmenu vim emacs llvm clang lldb gdb valgrind cmake ninja python3 python-pip ipython nasm jdk11-openjdk rustup go wine mingw-w64-binutils mingw-w64-crt mingw-w64-gcc mingw-w64-headers mingw-w64-winpthreads mesa mesa-utils libglvnd vulkan-icd-loader vulkan-intel vulkan-tools qemu-full libvirt virt-manager dnsmasq bridge-utils ttf-ibm-plex bpytop neofetch acpi unzip zip unrar arj p7zip ffmpeg openssh inetutils rsync xclip tree shellcheck chromium docker docker-compose

# Set the default shell to zsh
echo "zsh: Setting the shell to zsh"
chsh -s /bin/zsh $USER

echo "code: Making code directories"
mkdir -p ~/code/{bump,external}

# Clone and build st
echo "st: Downloading st"
if [ ! -d ~/code/external/st ]; then
    git clone https://git.suckless.org/st ~/code/external/st
else
    echo "st already cloned"
fi

echo "st: Building st"
cd ~/code/external/st
sudo make clean install
cd ~

# VIM setup
echo "Setting up VIM"
echo "VIM: Cloning Ultimate vimrc"
if [ ! -d ~/.vim_runtime ]; then
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
else
    echo "VIM already set up"
fi

echo "VIM: Making custom config"
touch ~/.vim_runtime/my_configs.vim

echo "VIM: Downloading VIM phoenix theme"
git clone https://github.com/widatama/vim-phoenix ~/.vim_runtime/my_plugins/vim-phoenix

echo "VIM: Line number/relative line number"
echo "set nu rnu" >> ~/.vim_runtime/my_configs.vim

echo "VIM: Remapping keys"
echo "inoremap jk <Esc>" >> ~/.vim_runtime/my_configs.vim

echo "VIM: Setting up NerdTree"
echo "let g:NerdTreeWinPos = 'left'" >> ~/.vim_runtime/my_configs.vim

echo "VIM: Setting up colorscheme"
echo "colo phoenix" >> ~/.vim_runtime/my_configs.vim
echo "PhoenixOrangeEighties" >> ~/.vim_runtime/my_configs.vim

# Clone personal repos
echo "Cloning bump repos"
if [ ! -d ~/code/bump/x-roulette ]; then
    git clone https://github.com/itsjustgalileo/x-roulette ~/code/bump/x-roulette
fi

if [ ! -d ~/code/bump/progen ]; then
    git clone https://github.com/itsjustgalileo/progen ~/code/bump/progen
fi

# Download NVM
echo "Downloading NVM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Download post-install script
echo "Downloading post-install script"
curl -o ~/post-install.sh https://raw.githubusercontent.com/itsjustgalileo/Arch-setup/master/post-install.sh
chmod +x ~/post-install.sh

# Setup background image
echo "Downloading background image"
mkdir -p ~/Pictures
curl -o ~/Pictures/bg.png https://i.imgur.com/bLxcjh3.png

echo "Setting background image in i3 config"
mkdir -p ~/.config/i3
echo 'exec --no-startup-id xwallpaper --zoom ~/Pictures/bg.png' >> ~/.config/i3/config

# Enable and start essential services
echo "Enabling NetworkManager, Docker, and libvirt"
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now docker
sudo systemctl enable --now libvirtd

# Reminder to run post-install script after reboot
echo "System about to reboot to apply changes"
echo "Don't forget to run the post-install script after reboot by running: ~/post-install.sh"
echo "..."

sleep 5
echo "Rebooting system"
reboot
