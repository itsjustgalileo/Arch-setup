#! /bin/sh

echo "Downloading packages"
sudo pacman -Syyu zsh tmux wget git github-cli pulseaudio pulsemixer xorg-server xorg-xinit xwallpaper xclip pcmanfm clipmenu llvm lldb wine mingw-w64 clang cmake ninja emacs python3 mesa mesa-utils valgrind libglvnd vulkan-icd-loader vulkan-intel vulkan-tools i3-wm i3status dmenu ttf-ibm-plex htop acpi unzip zip openssh rsync gdb qemu-full libvirt virt-manager dnsmasq bridge-utils chromium picom nasm

echo "Setting the shell to zsh"
chsh -s /bin/zsh

echo "Making code directories"
mkdir -p code/
mkdir -p code/bump
mkdir -p code/external
mkdir -p code/study

echo "Downloading background"
curl -O https://i.imgur.com/bLxcjh3.png
mv bLxcjh3.png code/bg.png

echo "Downloading st"
# Clone st from suckless repo
git clone https://git.suckless.org/st ~/code/st

echo "Building st"
cd ~/code/st
sudo make clean install

echo "Downloading dotfiles"
# Clone dotfiles from your repository
git clone https://github.com/itsjustgalileo/dotfiles ~/code/dotfiles

echo "Deploying dotfiles"
# Make deploy script executable and run it
chmod +x ~/code/dotfiles/deploy.sh
~/code/dotfiles/deploy.sh

echo "Downloadding NVM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source .zshrc
nvm install node
nvm use node

echo "Rebooting system"
reboot
