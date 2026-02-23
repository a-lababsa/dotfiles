#!/bin/bash

set -euo pipefail

# Load configuration
if [[ -f "install.conf" ]]; then
    source install.conf
fi

# Error trap
trap 'print_error "❌ Failed at line $LINENO. See install.log for details."' ERR

# Dry-run mode and options
DRY_RUN=false
SKIP_DEPS=false
ONLY_SYMLINKS=false

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --skip-deps) SKIP_DEPS=true ;;
        --only-symlinks) ONLY_SYMLINKS=true ;;
    esac
done

if [[ "$DRY_RUN" == true ]]; then
    echo "🧪 DRY-RUN MODE ENABLED - No changes will be made"
    echo
fi

# Logging
exec > >(tee -a install.log) 2>&1

# Source configuration and utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/install.conf"
source "$SCRIPT_DIR/scripts/lib/utils.sh"


# OS Detection
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        export OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version 2>/dev/null; then
            export OS="wsl"
        elif [[ -f /etc/os-release ]]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian) OS="ubuntu" ;;
                *) 
                    print_error "Unsupported distribution: $ID"
                    print_warning "Only Ubuntu and Debian are supported on Linux"
                    exit 1 
                    ;;
            esac
        else
            print_error "Unrecognized Linux distribution"
            exit 1
        fi
    else
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
    print_status "Detected OS: $OS"
}

# Dependencies installation
install_dependencies() {
    [[ "$SKIP_DEPS" == true ]] && { print_warning "⏭️  Dependencies skipped (--skip-deps)"; return; }

    print_status "Installing dependencies for $OS..."

    case $OS in
        "macos")
            if ! command -v brew &> /dev/null; then
                print_status "Installing Homebrew..."
                run_cmd '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
            fi
            run_cmd "brew bundle --file=Brewfile"
            ;;
        "ubuntu"|"wsl")
            run_cmd "sudo apt update && sudo apt upgrade -y"
            if [[ -f "packages/packages-ubuntu.txt" ]]; then
                run_cmd "xargs sudo apt install -y < packages/packages-ubuntu.txt"
            fi
            ;;
        *)
            print_error "Unsupported distribution: $OS"
            print_warning "Only macOS, Ubuntu, Debian and WSL2 are supported"
            exit 1
            ;;
    esac
}

# Starship installation
install_starship() {
    if ! command -v starship &> /dev/null; then
        print_status "Installing Starship..."
        run_cmd "curl -sS https://starship.rs/install.sh | sh -s -- -y"
    fi
}

# Zsh setup
setup_zsh() {
    print_status "Configuring Zsh..."

    # Create Zsh history directory (XDG compliance)
    if [[ ! -d "$HOME/.local/state/zsh" ]]; then
        print_status "Creating Zsh history directory..."
        run_cmd "mkdir -p $HOME/.local/state/zsh"
    fi

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_status "Installing Oh My Zsh..."
        run_cmd 'sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
    fi
    if [[ "$SHELL" != *"zsh" ]]; then
        print_status "Setting Zsh as default shell..."
        run_cmd "chsh -s $(which zsh)"
    fi
}

# NVM and Node.js installation
install_nvm() {
    # Check both .nvm and .config/nvm directories
    if [[ ! -d "$HOME/.nvm" && ! -d "$HOME/.config/nvm" ]]; then
        print_status "Installing NVM..."
        # Read version from .env if available
        NVM_VERSION="v0.40.1"
        if [[ -f ".env" ]]; then
            source .env
        fi
        
        # Set NVM_DIR to use .config/nvm for cleaner home directory
        export NVM_DIR="$HOME/.config/nvm"
        run_cmd "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | NVM_DIR=\"$HOME/.config/nvm\" bash"
        
        # Load NVM for immediate use
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        
        # Wait a moment for NVM to be available
        sleep 1
        
        NODE_VERSION="${NODE_VERSION:-lts/*}"

        print_status "Installing Node.js LTS ($NODE_VERSION)..."
        if command -v nvm &> /dev/null; then
            run_cmd "nvm install $NODE_VERSION"
            run_cmd "nvm use $NODE_VERSION"

            # Fix alias bug en utilisant le numéro de version réel
            CURRENT_VERSION=$(nvm current)
            if [ -n "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" != "system" ]; then
                run_cmd "nvm alias default $CURRENT_VERSION"
            else
                print_error "Failed to get current Node version for default alias"
            fi
        else
            print_error "NVM installation failed or not available in current session"
            return 1
        fi
    else
        print_status "NVM is already installed"
        # Load existing NVM
        if [[ -d "$HOME/.config/nvm" ]]; then
            export NVM_DIR="$HOME/.config/nvm"
        else
            export NVM_DIR="$HOME/.nvm"
        fi
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        # Update NVM to latest version
        print_status "Updating NVM to latest version..."
        if [[ -d "$NVM_DIR/.git" ]]; then
            cd "$NVM_DIR"
            git fetch --tags origin >/dev/null 2>&1
            LATEST_TAG=$(git describe --abbrev=0 --tags 2>/dev/null || echo "master")
            git checkout "$LATEST_TAG" >/dev/null 2>&1
            cd - >/dev/null
            print_status "NVM updated to $LATEST_TAG"
        fi
    fi
}

# uv installation (modern Python package manager)
install_uv() {
    if ! command -v uv &> /dev/null; then
        print_status "Installing uv (modern Python package manager)..."
        run_cmd "curl -LsSf https://astral.sh/uv/install.sh | sh"
        
        # Add uv to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"
        
        print_status "Installing Python 3.12 via uv..."
        run_cmd "uv python install 3.12"
    else
        print_status "uv is already installed"
    fi
}

# Symbolic links
create_symlinks() {
    print_status "Creating symbolic links..."

    link_file() {
        local src=$1
        local dest=$2

        # Validate source file exists
        if [[ ! -e "$src" && ! -d "$src" ]]; then
            print_error "Source not found: $src"
            return 1
        fi

        # Validate source is readable
        if [[ ! -r "$src" ]]; then
            print_error "Source not readable: $src"
            return 1
        fi

        # Backup existing destination if it's not a symlink
        if [[ -e "$dest" && ! -L "$dest" ]]; then
            print_warning "Backing up existing file: $dest -> $dest.backup"
            run_cmd "mv '$dest' '$dest.backup'"
            print_warning "Backed up: $dest -> $dest.backup"
        fi

        run_cmd "ln -sfn '$src' '$dest'"
        print_status "Linked: $src -> $dest"
    }

    # Configuration files
    link_file "$PWD/config/zsh/.zshrc" "$HOME/.zshrc"
    link_file "$PWD/config/zsh/.zshenv" "$HOME/.zshenv"
    link_file "$PWD/config/zsh/.zsh_aliases" "$HOME/.zsh_aliases"
    link_file "$PWD/config/git/.gitconfig" "$HOME/.gitconfig"
    link_file "$PWD/config/git/.gitignore_global" "$HOME/.gitignore_global"
    
    # Configuration directories
    mkdir -p "$HOME/.config"
    link_file "$PWD/config/starship/starship.toml" "$HOME/.config/starship.toml"
    [[ -d "config/nvim" ]] && link_file "$PWD/config/nvim" "$HOME/.config/nvim"

    # VS Code configuration
    if [[ -d "config/vscode" ]]; then
        if [[ "$OS" == "macos" ]]; then
            mkdir -p "$HOME/Library/Application Support/Code/User"
            link_file "$PWD/config/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
        else
            mkdir -p "$HOME/.config/Code/User"
            link_file "$PWD/config/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
        fi
    fi
    
    # Ghostty configuration
    if [[ -d "config/ghostty" ]]; then
        if [[ "$OS" == "macos" ]]; then
            mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
            link_file "$PWD/config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
        else
            mkdir -p "$HOME/.config/ghostty"
            link_file "$PWD/config/ghostty/config" "$HOME/.config/ghostty/config"
        fi
    fi
    
    # Zed configuration
    if [[ -d "config/zed" ]]; then
        if [[ "$OS" == "macos" ]]; then
            mkdir -p "$HOME/Library/Application Support/Zed"
            link_file "$PWD/config/zed/settings.json" "$HOME/Library/Application Support/Zed/settings.json"
            link_file "$PWD/config/zed/keymap.json" "$HOME/Library/Application Support/Zed/keymap.json"
        else
            mkdir -p "$HOME/.config/zed"
            link_file "$PWD/config/zed/settings.json" "$HOME/.config/zed/settings.json"
            link_file "$PWD/config/zed/keymap.json" "$HOME/.config/zed/keymap.json"
        fi
    fi
    
    # Navi configuration
    if [[ -d "config/navi" ]]; then
        mkdir -p "$HOME/.config/navi"
        link_file "$PWD/config/navi/cheats" "$HOME/.config/navi/cheats"
    fi

    if [[ -d "bin" ]]; then
        mkdir -p "$HOME/.local/bin"
        for script in bin/*; do
            if [[ -f "$script" ]]; then
                dest="$HOME/.local/bin/$(basename "$script")"
                link_file "$PWD/$script" "$dest"
                run_cmd "chmod +x '$dest'"
            fi
        done
    fi
}

# Main function
main() {
    print_status "🚀 Installing dotfiles..."
    [[ ! -d ".git" ]] && { print_error "This script must be run from the dotfiles repository"; exit 1; }

    # Ensure .config directory exists for all tools that need it
    mkdir -p "$HOME/.config"
    
    detect_os
    
    if [[ "$ONLY_SYMLINKS" == false ]]; then
        install_dependencies
        install_starship
        setup_zsh
        install_nvm
        install_uv
    fi
    
    create_symlinks

    # Execute OS-specific script if it exists
    [[ -f "scripts/$OS.sh" ]] && run_cmd "bash scripts/$OS.sh"

    print_status "✅ Installation completed!"
    print_warning "Restart your terminal or run 'source ~/.zshrc'"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi