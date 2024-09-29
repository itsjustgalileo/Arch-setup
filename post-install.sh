#! /bin/sh

set -e  # Exit on error

# Log all output to post-install.log
exec > >(tee -i ~/post-install.log)
exec 2>&1

echo "Post-install: Setting up environment"

# Dotfiles setup
echo "dotfiles: Downloading dotfiles"
if [ ! -d ~/code/dotfiles ]; then
    git clone https://github.com/itsjustgalileo/dotfiles ~/code/dotfiles
else
    echo "Dotfiles already cloned"
fi

echo "dotfiles: Deploying dotfiles"
chmod +x ~/code/dotfiles/deploy.sh
~/code/dotfiles/deploy.sh

# Load NVM and install latest Node.js
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo "Post-install: Loading NVM"
    . "$HOME/.nvm/nvm.sh"
    echo "Post-install: Installing and using the latest Node.js with NVM"
    nvm install node
    nvm use node
else
    echo "NVM not found, skipping Node.js setup."
fi

# Log in to GitHub CLI
if command -v gh > /dev/null; then
    echo "Post-install: Logging into GitHub CLI"
    gh auth login
else
    echo "GitHub CLI (gh) not found, skipping GitHub login."
fi

# Update Rust and set stable toolchain
if command -v rustup > /dev/null; then
    echo "Post-install: Updating Rust toolchain to the latest stable version"
    rustup update stable
    rustup self upgrade-data
else
    echo "Rustup not found, skipping Rust update."
fi

# DevKitPro setup
echo "Setting up DevKitPro"
sudo pacman-key --recv BC26F752D25B92CE272E0F44F7FD5492264BB9D0 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign BC26F752D25B92CE272E0F44F7FD5492264BB9D0
wget https://pkg.devkitpro.org/devkitpro-keyring.pkg.tar.xz
sudo pacman -U devkitpro-keyring.pkg.tar.xz
echo "[dkp-libs]" | sudo tee -a /etc/pacman.conf
echo "Server = https://pkg.devkitpro.org/packages" | sudo tee -a /etc/pacman.conf
echo "[dkp-linux]" | sudo tee -a /etc/pacman.conf
echo "Server = https://pkg.devkitpro.org/packages/linux/\$arch" | sudo tee -a /etc/pacman.conf
rm -rf devkitpro-keyring.pkg.tar.xz

# Upgrade system
echo "Post-install: Upgrading system packages"
sudo pacman -Syu

# Restart binfmt for any cross-platform setups
sudo systemctl restart systemd-binfmt

echo "Post-install: Script finished"

# Clean up setup files
rm -rf ~/setup.sh ~/post-install.sh

source ~/.zshrc
