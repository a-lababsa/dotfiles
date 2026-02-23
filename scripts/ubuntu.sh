#!/bin/bash

# Ubuntu-specific configuration

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

print_status "Applying Ubuntu configurations..."

# Ensure ~/.local/bin is in PATH for user-installed tools
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    # Only add to .bashrc if not already present
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    # Don't add to .zshrc as it's already configured in dotfiles
    print_status "Added ~/.local/bin to PATH"
fi

# Install eza from official repository
if ! command -v eza >/dev/null 2>&1; then
    print_status "Installing eza from official repository..."
    
    # Add the eza repository (gpg from packages-ubuntu.txt)
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

# Install navi (interactive cheatsheet tool)
if ! command -v navi >/dev/null 2>&1; then
    print_status "Installing navi (interactive cheatsheet tool)..."
    
    # Install using the official script
    bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install) 2>/dev/null || {
        print_warning "Failed to install navi via script, trying alternative method..."
        
        # Alternative: Install via cargo if Rust is available
        if command -v cargo >/dev/null 2>&1; then
            cargo install navi
            print_status "navi installed via cargo"
        else
            print_warning "navi installation failed - requires Rust/cargo or manual installation"
        fi
    }
    
    print_status "navi installed successfully"
else
    print_status "navi is already installed"
fi

# System configurations
print_status "Configuring system components..."

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

# Update snaps (if snapd is installed)
if command -v snap &> /dev/null; then
    print_status "Updating snaps..."
    sudo snap refresh
fi

print_status "Ubuntu configuration applied!"