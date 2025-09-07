#!/bin/bash

# WSL-specific configuration

print_status "Applying WSL configurations..."

# Configure WSL for Windows
if grep -q Microsoft /proc/version; then
    print_status "WSL detected - Applying special configuration..."
    
    # Enable Windows interoperability
    echo -e "[interop]\nappendWindowsPath = true" | sudo tee -a /etc/wsl.conf
    
    # Network configuration
    echo -e "[network]\ngenerateResolvConf = false" | sudo tee -a /etc/wsl.conf
    
    # Create symbolic link to Windows directory (optional)
    if [[ ! -L "$HOME/windows" ]]; then
        ln -s /mnt/c/Users/$(whoami) "$HOME/windows" 2>/dev/null || true
    fi
fi

print_status "WSL configuration applied!"
print_warning "Restart WSL to apply some changes (wsl --shutdown from PowerShell)"