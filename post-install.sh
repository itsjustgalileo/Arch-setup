#! /bin/sh

# Ensure the script exits if any command fails
set -e

echo "Post-install: Setting up environment"

# Ensure NVM is loaded
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo "Post-install: Loading NVM"
    . "$HOME/.nvm/nvm.sh"
else
    echo "NVM not found, skipping NVM setup."
fi

# Install and use the latest stable Node.js via NVM
if command -v nvm > /dev/null; then
    echo "Post-install: Installing and using the latest Node.js with NVM"
    nvm install node
    nvm use node
else
    echo "NVM command not found, skipping Node.js setup."
fi

# Log in to GitHub CLI
if command -v gh > /dev/null; then
    echo "Post-install: Logging into GitHub CLI"
    gh auth login
else
    echo "GitHub CLI (gh) not found, skipping GitHub login."
fi

# Update Rust and set the stable toolchain
if command -v rustup > /dev/null; then
    echo "Post-install: Updating Rust toolchain to the latest stable version"
    rustup update stable
    rustup self upgrade-data
else
    echo "Rustup not found, skipping Rust update."
fi

# DevKitPro
sudo pacman-key --recv BC26F752D25B92CE272E0F44F7FD5492264BB9D0 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign BC26F752D25B92CE272E0F44F7FD5492264BB9D0
wget https://pkg.devkitpro.org/devkitpro-keyring.pkg.tar.xz
sudo pacman -U devkitpro-keyring.pkg.tar.xz
echo "[dkp-libs]" | sudo tee -a /etc/pacman.conf
echo "Server = https://pkg.devkitpro.org/packages" | sudo tee -a /etc/pacman.conf
echo "[dkp-linux]" | sudo tee -a /etc/pacman.conf
echo "Server = https://pkg.devkitpro.org/packages/linux/$arch" | sudo tee -a /etc/pacman.conf
rm -rf devkitpro-keyring.pkg.tar.xz
# System upgrade (optional: upgrade system packages and data)
echo "Post-install: Upgrading system packages"
sudo pacman -Syu

echo "Post-install: Script finished"
