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

# Create symlinks for Ubuntu-renamed binaries
create_compat_symlinks() {
    mkdir -p "$HOME/.local/bin"

    # batcat → bat
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        print_status "Creating bat symlink for batcat..."
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
        print_status "bat symlink created"
    fi

    # fdfind → fd
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        print_status "Creating fd symlink for fdfind..."
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        print_status "fd symlink created"
    fi
}

create_compat_symlinks

# Tools not in Ubuntu 24.04 repos — install from GitHub releases
# install_github_binary is defined in scripts/lib/utils.sh
install_github_binary "lazygit" "jesseduffield/lazygit" "Linux.*tar\.gz" "lazygit"
install_github_binary "dust" "bootandy/dust" "unknown-linux-gnu.*tar\.gz" "dust"
install_github_binary "glow" "charmbracelet/glow" "linux.*tar\.gz" "glow"
install_github_binary "topgrade" "topgrade-rs/topgrade" "linux.*tar\.gz" "topgrade"
install_github_binary "xh" "ducaale/xh" "linux.*tar\.gz" "xh"
install_github_binary "hyperfine" "sharkdp/hyperfine" "linux.*tar\.gz" "hyperfine"
install_github_binary "serpl" "yassinebridi/serpl" "linux.*tar\.gz" "serpl"
install_github_binary "vibecheck" "rshdhere/vibecheck" "Linux.*tar\.gz" "vibecheck"

# Install navi (interactive cheatsheet tool)
if ! command -v navi >/dev/null 2>&1; then
    print_status "Installing navi..."
    bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install) 2>/dev/null || {
        print_warning "Failed to install navi via script, trying cargo..."
        if command -v cargo >/dev/null 2>&1; then
            cargo install navi
        else
            print_warning "navi installation failed — requires Rust/cargo or manual installation"
        fi
    }
else
    print_status "navi is already installed"
fi

# Install Zsh plugins into XDG-compliant directory
install_zsh_plugin() {
    local name="$1"
    local repo="$2"
    local dest="$HOME/.local/share/zsh/plugins/$name"

    if [[ -d "$dest" ]]; then
        print_status "Zsh plugin $name already installed"
        return 0
    fi

    # Skip if already available via apt
    if [[ -f "/usr/share/$name/$name.zsh" ]]; then
        print_status "Zsh plugin $name available via system package"
        return 0
    fi

    mkdir -p "$HOME/.local/share/zsh/plugins"
    print_status "Installing Zsh plugin: $name..."
    git clone --depth 1 "https://github.com/$repo" "$dest" 2>/dev/null
    print_status "Zsh plugin $name installed"
}

install_zsh_plugin "zsh-autosuggestions" "zsh-users/zsh-autosuggestions"
install_zsh_plugin "zsh-syntax-highlighting" "zsh-users/zsh-syntax-highlighting"

# System configurations
print_status "Configuring system components..."

# Configure Git LFS (if installed)
if command -v git-lfs &> /dev/null; then
    print_status "Setting up Git LFS..."
    git lfs install
fi

# Install Flatpak (optional, for GUI apps)
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
