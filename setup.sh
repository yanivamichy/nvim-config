#!/bin/bash

echo "Installing C compilers and essential build tools..."
sudo apt install -y gcc g++ build-essential

echo "Veryfing C compilers installation..."
gcc --version
g++ --version

echo "Installing Neovim..."
sudo snap install nvim --classic

echo "Installing Zip/Unzip tools..."
sudo apt install -y zip
sudo apt install -y unzip

echo "Installing Lua package manager..."
sudo apt install -y luarocks

echo "Installing RipGrep..."
sudo apt install -y ripgrep

echo "Installing clipboard tool..."
sudo apt install xclip

echo "Install Node Version Manager & Node..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 22

echo "Installing Python & dependencies..."
sudo apt install python3-venv

