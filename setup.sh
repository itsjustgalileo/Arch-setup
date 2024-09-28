#! /bin/sh

set -e

echo "pacman: Downloading packages"
sudo pacman -Syyu zsh tmux wget git github-cli pulseaudio alsa-utils jack2 libwebp xorg-server xorg-xinit xorg-xrandr xwallpaper xclip pcmanfm vifm clipmenu tree vim emacs llvm clang wine mingw-w64 lldb gdb cmake ninja python3 python-pip mesa mesa-utils valgrind libglvnd vulkan-icd-loader vulkan-intel vulkan-tools i3-wm i3status dmenu ttf-ibm-plex htop acpi unzip zip openssh rsync qemu-full libvirt virt-manager dnsmasq bridge-utils chromium picom nasm jdk11-openjdk rustc cargo go

echo "zsh: Setting the shell to zsh"
chsh -s /bin/zsh

echo "code: Making code directories"
mkdir -p code/
mkdir -p code/bump
mkdir -p code/external
mkdir -p code/study

echo "st: Downloading st"
# Clone st from suckless repo
git clone https://git.suckless.org/st ~/code/external/st

echo "st: Building st"
cd ~/code/external/st
sudo make clean install

echo "st: Downloading dotfiles"
# Clone dotfiles from your repository
git clone https://github.com/itsjustgalileo/dotfiles ~/code/dotfiles

echo "dofiles: Deploying dotfiles"
# Make deploy script executable and run it
chmod +x ~/code/dotfiles/deploy.sh
~/code/dotfiles/deploy.sh

# Download vim setup https://github.com/amix/vimrc
echo "Setting up VIM"
echo "VIM: Cloning Ultimate vimrc"
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
echo "VIM: Making custom config"
touch ~/.vim_runtime/my_configs.vim
echo "VIM: Downloading VIM phoenix theme"
git clone https://github.com/widatama/vim-phoenix ~/.vim_runtime/my_plugins/vim-phoenix
echo "VIM: Line number/relative line number"
echo "set nu rnu" >> ~/.vim_runtime/my_configs.vim
echo "VIM: Setting up colorscheme"
echo "colo phoenix" >> ~/.vim_runtime/my_configs.vim
echo "PhoenixOrangeEighties" >> ~/.vim_runtime/my_configs.vim

# Clone personal repos
echo "Cloning bump repos"
echo "bump: Cloning x-roulette"
git clone https://github.com/itsjustgalileo/x-roulette ~/code/bump/x-roulette
echo "bump: Cloning progen"
git clone https://github.com/itsjustgalileo/progen ~/code/bump/progen

# Download NVM
echo "Downloading NVM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# NVM node installation reminder
echo "System about to reboot to apply changes"
echo "Don't forget after reboot to: "
echo "nvm install node && nvm use node"
echo "gh auth login"

# Restarting system
echo "Rebooting system"
reboot
