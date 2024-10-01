# \file post-install.sh
# \brief post installation patches
# This script should only exist on your fs
# if it was downloaded via the install.sh script
# Do not run it if it was not!
#! /bin/sh

# Color definitions
RED='\033[0;31m'     # Red
GREEN='\033[0;32m'     # Green
ORANGE='\033[0;33m'    # Orange
NC='\033[0m'           # No Color

# Ensure the script exits if any command fails
set -e

echo -e "${GREEN}[INFO] - Post-install: Setting up environment${NC}"

chmod 444 ~/.zshrc

# Ensure NVM is loaded
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo -e "${GREEN}[INFO] - Post-install: Loading NVM${NC}"
    . "$HOME/.nvm/nvm.sh"
else
    echo -e "${RED}[ERROR] - NVM not found, skipping NVM setup.${NC}"
fi

# Install and use the latest stable Node.js via NVM
if command -v nvm > /dev/null; then
    echo -e "${GREEN}[INFO] - Post-install: Installing and using the latest Node.js with NVM${NC}"
    nvm install node
    nvm use node
else
    echo -e "${RED}[ERROR] - NVM command not found, skipping Node.js setup.${NC}"
fi

# Installing Bun JS (Just in case)
echo -e "Post-install: Installing BunJS"
curl -fsSL https://bun.sh/install | bash

# Installing Deno JS (Just in case)
echo -e "Post-install: Installing DenoJS"
curl -fsSL https://deno.land/install.sh | sh

chmod 644 ~/.zshrc

# Update Rust and set the stable toolchain
if command -v rustup > /dev/null; then
    echo -e "${GREEN}[INFO] - Post-install: Updating Rust toolchain to the latest stable version${NC}"
    rustup update stable
    rustup self upgrade-data
else
    echo -e "${RED}[ERROR] - Rustup not found, skipping Rust update.${NC}"
fi

# Log in to GitHub CLI
if command -v gh > /dev/null; then
    echo -e "${GREEN}[INFO] - Post-install: Logging into GitHub CLI${NC}"
    gh auth login
else
    echo -e "${RED}[ERROR] - GitHub CLI (gh) not found, skipping GitHub login.${NC}"
fi

echo -e "${GREEN}[INFO] - Creating bump directory${NC}"
mkdir -p ~/code/bump

echo -e "${GREEN}[INFO] - Cloning bump repos${NC}"
echo -e "${GREEN}[INFO] - bump: Cloning x-roulette${NC}"
git clone https://github.com/itsjustgalileo/x-roulette ~/code/bump/x-roulette
echo -e "${GREEN}[INFO] - bump: Cloning progen${NC}"
git clone https://github.com/itsjustgalileo/progen ~/code/bump/progen
echo -e "${GREEN}[INFO] - bump: Cloning quest${NC}"
git clone https://github.com/itsjustgalileo/progen ~/code/bump/quest

source ~/.zshrc

echo -e "${GREEN}[INFO] - Post-install: installing ghcid"
cabal update && cabal ghcid

echo -e "${GREEN}[INFO] - Post-install: Script finished${NC}"

# Clean up the post-install script once done
rm -rf ~/post-install.sh

# Optional: Reboot after post-install configuration
echo -e "${ORANGE}[INFO] - Post-install script finished. Rebooting...${NC}"
reboot
