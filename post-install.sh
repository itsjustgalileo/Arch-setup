# This script should only exist on your fs
# if it was downloaded via the setup.sh script
# Do not run it if it was not!
#! /bin/sh

# Color definitions
GREEN='\033[0;32m'     # Green
ORANGE='\033[0;33m'    # Orange
NC='\033[0m'           # No Color

# Ensure the script exits if any command fails
set -e

echo -e "${GREEN}Post-install: Setting up environment${NC}"

# Ensure NVM is loaded
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo -e "${GREEN}Post-install: Loading NVM${NC}"
    . "$HOME/.nvm/nvm.sh"
else
    echo -e "${ORANGE}NVM not found, skipping NVM setup.${NC}"
fi

# Install and use the latest stable Node.js via NVM
if command -v nvm > /dev/null; then
    echo -e "${GREEN}Post-install: Installing and using the latest Node.js with NVM${NC}"
    nvm install node
    nvm use node
else
    echo -e "${ORANGE}NVM command not found, skipping Node.js setup.${NC}"
fi

# Update Rust and set the stable toolchain
if command -v rustup > /dev/null; then
    echo -e "${GREEN}Post-install: Updating Rust toolchain to the latest stable version${NC}"
    rustup update stable
    rustup self upgrade-data
else
    echo -e "${ORANGE}Rustup not found, skipping Rust update.${NC}"
fi

# Log in to GitHub CLI
if command -v gh > /dev/null; then
    echo -e "${GREEN}Post-install: Logging into GitHub CLI${NC}"
    gh auth login
else
    echo -e "${ORANGE}GitHub CLI (gh) not found, skipping GitHub login.${NC}"
fi

# Black Arch
echo -e "${GREEN}Running Black Arch Bootstrap${NC}"
curl -o ~/strap.sh https://blackarch.org/strap.sh
# Verify the SHA1 sum
echo 26849980b35a42e6e192c6d9ed8c46f0d6d06047 ~/strap.sh | sha1sum -c
chmod +x ~/strap.sh
sudo ~/strap.sh
rm -rf ~/script.sh

# DevKitPro setup
echo -e "${GREEN}Post-install: Setting up DevKitPro${NC}"
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
echo -e "${GREEN}Post-install: Upgrading system packages${NC}"
sudo pacman -Syu

sudo systemctl restart systemd-binfmt

# Enable Docker and libvirtd services
echo -e "${GREEN}Post-install: Enabling Docker and libvirt services${NC}"
sudo systemctl enable --now docker
sudo systemctl enable --now libvirtd

# Loading emacs config
echo -e "${GREEN}Post-install: Running emacs to load config${NC}"
echo -e "${GREEN}Post-install: Wait for emacs to finish loading and close it."
emacs

echo -e "${GREEN}Post-install: Script finished${NC}"

# Clean up
rm -rf ~/post-install.sh
