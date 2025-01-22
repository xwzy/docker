#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# Get the username of the user who invoked sudo
REAL_USER=$(logname || echo $SUDO_USER)
if [ -z "$REAL_USER" ]; then
    echo "Could not determine the real user"
    exit 1
fi

# Remove existing zsh and oh-my-zsh installation
apt-get remove -y zsh
rm -rf /home/$REAL_USER/.oh-my-zsh
rm -f /home/$REAL_USER/.zshrc*

# Install zsh
apt-get update
apt-get install -y zsh curl

# Create initial .zshrc to prevent zsh-newuser-install prompt
su - $REAL_USER -c 'echo "# Initial .zshrc" > ~/.zshrc'

# Install Oh My Zsh for the real user
su - $REAL_USER -c 'RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

# Change shell for the real user
chsh -s $(which zsh) $REAL_USER

echo "Zsh and Oh My Zsh have been installed and configured:"
echo "- Previous Zsh installation removed"
echo "- Default shell changed to Zsh"
echo "- Oh My Zsh installed"
echo "Please log out and log back in to start using Zsh" 