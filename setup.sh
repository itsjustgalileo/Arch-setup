#! /bin/sh

echo "Downloading packages"
sudo pacman -Syyu zsh tmux wget git github-cli pulseaudio alsa-utils jack2 libwebp xorg-server xorg-xinit xorg-xrandr xwallpaper xclip pcmanfm vifm clipmenu tree vim emacs llvm clang wine mingw-w64 lldb gdb cmake ninja python3 mesa mesa-utils valgrind libglvnd vulkan-icd-loader vulkan-intel vulkan-tools i3-wm i3status dmenu ttf-ibm-plex htop acpi unzip zip openssh rsync qemu-full libvirt virt-manager dnsmasq bridge-utils chromium picom nasm

echo "Setting the shell to zsh"
chsh -s /bin/zsh

echo "Making code directories"
mkdir -p code/
mkdir -p code/bump
mkdir -p code/external
mkdir -p code/study

echo "Downloading st"
# Clone st from suckless repo
git clone https://git.suckless.org/st ~/code/external/st

echo "Building st"
cd ~/code/external/st
sudo make clean install

echo "Downloading dotfiles"
# Clone dotfiles from your repository
git clone https://github.com/itsjustgalileo/dotfiles ~/code/dotfiles

echo "Deploying dotfiles"
# Make deploy script executable and run it
chmod +x ~/code/dotfiles/deploy.sh
~/code/dotfiles/deploy.sh

# Download vim setup https://github.com/amix/vimrc
echo "Setting up VIM"
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
touch ~/.vim_runtime/my_configs.vim
git clone https://github.com/widatama/vim-phoenix ~/.vim_runtime/my_plugins/vim-phoenix
echo "set nu rnu" >> ~/.vim_runtime/my_configs.vim
echo "colo phoenix" >> ~/.vim_runtime/my_configs.vim
echo "PhoenixOrangeEighties" >> ~/.vim_runtime/my_configs.vim

# Clone personal repos
echo "Cloning bump repos"
git clone https://github.com/itsjustgalileo/x-roulette ~/code/bump/x-roulette
git clone https://github.com/itsjustgalileo/progen ~/code/bump/progen

# Download NVM
echo "Downloadding NVM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# NVM node installation reminder
echo "System about to reboot to apply changes"
echo "Don't forget after reboot to: "
echo "nvm install node && nvm use node"
echo "gh auth login"

# Restarting system
echo "Rebooting system"
reboot
