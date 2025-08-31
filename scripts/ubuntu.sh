#!/bin/bash

# Ubuntu-specific configuration

print_status "Applying Ubuntu configurations..."

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