#!/bin/bash

# WSL-specific configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

print_status "Applying WSL configurations..."

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
fi

mkdir -p "$HOME/.local/bin"

# Compat symlinks (Ubuntu renames some binaries)
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    print_status "bat symlink created"
fi
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    print_status "fd symlink created"
fi

# Install tools from GitHub releases (install_github_binary is defined in lib/utils.sh)
install_github_binary "lazygit"   "jesseduffield/lazygit"     "Linux.*tar\.gz"             "lazygit"
install_github_binary "dust"      "bootandy/dust"             "unknown-linux-gnu.*tar\.gz" "dust"
install_github_binary "glow"      "charmbracelet/glow"        "linux.*tar\.gz"             "glow"
install_github_binary "topgrade"  "topgrade-rs/topgrade"      "linux.*tar\.gz"             "topgrade"
install_github_binary "xh"        "ducaale/xh"                "linux.*tar\.gz"             "xh"
install_github_binary "hyperfine" "sharkdp/hyperfine"         "linux.*tar\.gz"             "hyperfine"
install_github_binary "serpl"     "yassinebridi/serpl"        "linux.*tar\.gz"             "serpl"
install_github_binary "vibecheck" "rshdhere/vibecheck"        "Linux.*tar\.gz"             "vibecheck"

# Zsh plugins
install_zsh_plugin() {
    local name="$1"
    local repo="$2"
    local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"
    [[ -d "$dest" ]] && { print_status "Zsh plugin $name already installed"; return 0; }
    [[ -f "/usr/share/$name/$name.zsh" ]] && { print_status "Zsh plugin $name available via system package"; return 0; }
    print_status "Installing Zsh plugin: $name..."
    git clone --depth 1 "https://github.com/$repo" "$dest" 2>/dev/null
    print_status "Zsh plugin $name installed"
}

install_zsh_plugin "zsh-autosuggestions" "zsh-users/zsh-autosuggestions"
install_zsh_plugin "zsh-syntax-highlighting" "zsh-users/zsh-syntax-highlighting"

# WSL-specific settings
if grep -q Microsoft /proc/version 2>/dev/null; then
    print_status "Applying WSL interop settings..."

    # Only append if not already configured
    if ! grep -q '\[interop\]' /etc/wsl.conf 2>/dev/null; then
        echo -e "[interop]\nappendWindowsPath = true" | sudo tee -a /etc/wsl.conf >/dev/null
    fi
    if ! grep -q '\[network\]' /etc/wsl.conf 2>/dev/null; then
        echo -e "[network]\ngenerateResolvConf = false" | sudo tee -a /etc/wsl.conf >/dev/null
    fi

    # Symlink to Windows user directory
    if [[ ! -L "$HOME/windows" ]]; then
        ln -s "/mnt/c/Users/$(whoami)" "$HOME/windows" 2>/dev/null || true
    fi
fi

print_status "WSL configuration applied!"
print_warning "Restart WSL to apply some changes (wsl --shutdown from PowerShell)"