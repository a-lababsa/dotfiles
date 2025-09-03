#!/bin/bash

# Ubuntu-specific configuration

print_status "Applying Ubuntu configurations..."

# Install eza from official repository
if ! command -v eza >/dev/null 2>&1; then
    print_status "Installing eza from official repository..."
    
    # Install GPG if needed
    sudo apt install -y gpg
    
    # Add the eza repository
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    
    # Update and install eza
    sudo apt update
    sudo apt install -y eza
    
    print_status "eza installed successfully"
else
    print_status "eza is already installed"
fi

# Create bat symlink if batcat exists but bat doesn't
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    print_status "Creating bat symlink for batcat..."
    mkdir -p "$HOME/.local/bin"
    ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
    print_status "bat symlink created successfully"
fi

# Update snaps (if snapd is installed)
if command -v snap &> /dev/null; then
    print_status "Updating snaps..."
    sudo snap refresh
fi

# Configure Git LFS (if installed)
if command -v git-lfs &> /dev/null; then
    print_status "Setting up Git LFS..."
    git lfs install
fi

# Install Flatpak (optional)
if ! command -v flatpak &> /dev/null; then
    print_status "Installing Flatpak..."
    sudo apt install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

print_status "Ubuntu configuration applied!"