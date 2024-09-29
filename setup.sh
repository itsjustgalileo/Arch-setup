#! /bin/sh

set -e

echo "pacman: Downloading packages"
sudo pacman -S zsh tmux wget git github-cli pulseaudio alsa-utils jack2 libwebp xorg-server xorg-xinit xorg-xrandr i3-wm i3status dmenu xwallpaper picom pcmanfm vifm clipmenu vim emacs llvm clang lldb gdb valgrind cmake ninja python3 python-pip ipython nasm jdk11-openjdk rustup cargo go wine mingw-w64-binutils mingw-w64-crt mingw-w64-gcc mingw-w64-headers mingw-w64-winpthreads mesa mesa-utils libglvnd vulkan-icd-loader vulkan-intel vulkan-tools qemu-full libvirt virt-manager dnsmasq bridge-utils ttf-ibm-plex htop neofetch acpi unzip zip openssh rsync xclip tree chromium 

echo "zsh: Setting the shell to zsh"
chsh -s /bin/zsh

echo "code: Making code directories"
mkdir -p code/
mkdir -p code/bump
mkdir -p code/external
mkdir -p code/study

echo "st: Downloading st"
git clone https://git.suckless.org/st ~/code/external/st

echo "st: Building st"
cd ~/code/external/st
sudo make clean install
# Going back home
cd ~

echo "st: Downloading dotfiles"
git clone https://github.com/itsjustgalileo/dotfiles ~/code/dotfiles

echo "dotfiles: Deploying dotfiles"
chmod +x ~/code/dotfiles/deploy.sh
~/code/dotfiles/deploy.sh

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
echo "VIM: Remapping keys"
echo "inoremap jk <Esc>" >> ~/.vim_runtime/my_configs.vim
echo "VIM: Setting up NerdTree"
echo "let g:NerdTreeWinPos = 'left'" >> ~/.vim_runtime/my_configs.vim
echo "VIM: Setting up colorscheme"
echo "colo phoenix" >> ~/.vim_runtime/my_configs.vim
echo "PhoenixOrangeEighties" >> ~/.vim_runtime/my_configs.vim

echo "Cloning bump repos"
echo "bump: Cloning x-roulette"
git clone https://github.com/itsjustgalileo/x-roulette ~/code/bump/x-roulette
echo "bump: Cloning progen"
git clone https://github.com/itsjustgalileo/progen ~/code/bump/progen

echo "Downloading NVM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

echo "Downloading post-install script"
curl -O https://raw.githubusercontent.com/itsjustgalileo/Arch-setup/master/post-install.sh
chmod +x ./post-install.sh

echo "System about to reboot to apply changes"
echo "Don't forget to run the post-install script after reboot by running: "
echo "./post-install.sh"

echo "..."
sleep 5

echo "Rebooting system"
reboot
