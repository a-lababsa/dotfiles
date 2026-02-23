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

# Install tools not available via APT on Ubuntu 24.04
# Uses GitHub releases to fetch latest binaries

install_github_binary() {
    local name="$1"
    local repo="$2"
    local asset_pattern="$3"
    local binary_name="${4:-$name}"

    if command -v "$binary_name" >/dev/null 2>&1; then
        print_status "$name is already installed"
        return 0
    fi

    print_status "Installing $name from GitHub releases..."

    local tmpdir
    tmpdir=$(mktemp -d)
    local arch
    arch=$(dpkg --print-architecture)

    # Map architecture names
    local arch_pattern
    case "$arch" in
        amd64) arch_pattern="x86_64|amd64" ;;
        arm64) arch_pattern="aarch64|arm64" ;;
        *) print_warning "Unsupported architecture: $arch"; rm -rf "$tmpdir"; return 1 ;;
    esac

    # Get latest release asset URL
    local download_url
    download_url=$(curl -sL "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oP '"browser_download_url":\s*"\K[^"]+' \
        | grep -iE "$asset_pattern" \
        | grep -iE "$arch_pattern" \
        | grep -iv "musl\|\.sha256\|\.sig\|\.asc" \
        | head -1)

    if [[ -z "$download_url" ]]; then
        print_warning "Could not find $name release for $arch"
        rm -rf "$tmpdir"
        return 1
    fi

    local filename
    filename=$(basename "$download_url")

    curl -sL "$download_url" -o "$tmpdir/$filename"

    # Extract and install based on file type
    case "$filename" in
        *.tar.gz|*.tgz)
            tar -xzf "$tmpdir/$filename" -C "$tmpdir"
            local bin_path
            bin_path=$(find "$tmpdir" -name "$binary_name" -type f -executable 2>/dev/null | head -1)
            if [[ -z "$bin_path" ]]; then
                bin_path=$(find "$tmpdir" -name "$binary_name" -type f 2>/dev/null | head -1)
            fi
            if [[ -n "$bin_path" ]]; then
                install -m 755 "$bin_path" "$HOME/.local/bin/$binary_name"
            else
                print_warning "Binary $binary_name not found in archive"
                rm -rf "$tmpdir"
                return 1
            fi
            ;;
        *.deb)
            sudo dpkg -i "$tmpdir/$filename"
            ;;
        *.zip)
            unzip -o "$tmpdir/$filename" -d "$tmpdir"
            local bin_path
            bin_path=$(find "$tmpdir" -name "$binary_name" -type f -executable 2>/dev/null | head -1)
            if [[ -n "$bin_path" ]]; then
                install -m 755 "$bin_path" "$HOME/.local/bin/$binary_name"
            fi
            ;;
        *)
            install -m 755 "$tmpdir/$filename" "$HOME/.local/bin/$binary_name"
            ;;
    esac

    rm -rf "$tmpdir"

    if command -v "$binary_name" >/dev/null 2>&1; then
        print_status "$name installed successfully"
    else
        print_warning "$name installation may have failed"
    fi
}

# Tools not in Ubuntu 24.04 repos — install from GitHub releases
install_github_binary "lazygit" "jesseduffield/lazygit" "Linux.*tar\.gz" "lazygit"
install_github_binary "dust" "bootandy/dust" "unknown-linux-gnu.*tar\.gz" "dust"
install_github_binary "glow" "charmbracelet/glow" "linux.*tar\.gz" "glow"
install_github_binary "topgrade" "topgrade-rs/topgrade" "linux.*tar\.gz" "topgrade"
install_github_binary "xh" "ducaale/xh" "linux.*tar\.gz" "xh"

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

# Install Zsh plugins via Oh My Zsh custom directory
install_zsh_plugin() {
    local name="$1"
    local repo="$2"
    local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"

    if [[ -d "$dest" ]]; then
        print_status "Zsh plugin $name already installed"
        return 0
    fi

    # Skip if already available via apt
    if [[ -f "/usr/share/$name/$name.zsh" ]]; then
        print_status "Zsh plugin $name available via system package"
        return 0
    fi

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
