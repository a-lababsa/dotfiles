#!/bin/bash

# Secrets management for dotfiles
# Handles private configurations that shouldn't be versioned

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

SECRETS_DIR="$HOME/.dotfiles-secrets"
PRIVATE_CONFIG_DIR="$PWD/config/private"

# Initialize secrets directory
init_secrets() {
    if [[ ! -d "$SECRETS_DIR" ]]; then
        print_status "Initializing secrets directory at $SECRETS_DIR"
        mkdir -p "$SECRETS_DIR"
        cat > "$SECRETS_DIR/README.md" << 'EOF'
# Dotfiles Secrets

This directory contains private configurations that are symlinked to your dotfiles
but not versioned in git.

## Usage
- Add sensitive configs here
- Use `secrets_manager.sh link` to create symlinks
- Files here will be linked to `config/private/` in your dotfiles

## Examples
- SSH keys and configs
- API keys and tokens  
- Private git configurations
- Environment variables with secrets
EOF
        print_success "Secrets directory initialized"
    fi
}

# Link secrets to private config
link_secrets() {
    init_secrets
    
    if [[ ! -d "$SECRETS_DIR" ]]; then
        print_error "Secrets directory not found: $SECRETS_DIR"
        return 1
    fi
    
    print_status "Linking secrets to private config..."
    
    for secret_file in "$SECRETS_DIR"/*; do
        if [[ -f "$secret_file" && "$(basename "$secret_file")" != "README.md" ]]; then
            local filename=$(basename "$secret_file")
            local target="$PRIVATE_CONFIG_DIR/$filename"
            
            if [[ -L "$target" ]]; then
                print_warning "Symlink already exists: $target"
                continue
            fi
            
            if [[ -f "$target" ]]; then
                print_warning "File exists, creating backup: $target"
                mv "$target" "$target.backup"
            fi
            
            ln -sf "$secret_file" "$target"
            print_success "Linked: $filename"
        fi
    done
}

# List available secrets
list_secrets() {
    init_secrets
    
    print_status "Available secrets:"
    if [[ -d "$SECRETS_DIR" ]]; then
        find "$SECRETS_DIR" -type f -not -name "README.md" -exec basename {} \; | sort
    fi
    
    print_status "Linked private configs:"
    if [[ -d "$PRIVATE_CONFIG_DIR" ]]; then
        find "$PRIVATE_CONFIG_DIR" -type l -exec basename {} \; | sort
    fi
}

# Add a new secret
add_secret() {
    local file="$1"
    
    if [[ -z "$file" ]]; then
        print_error "Usage: $0 add <filename>"
        return 1
    fi
    
    init_secrets
    
    local target="$SECRETS_DIR/$file"
    
    if [[ -f "$target" ]]; then
        print_warning "Secret already exists: $file"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    print_status "Creating secret file: $target"
    print_status "Edit the file with your preferred editor"
    touch "$target"
    chmod 600 "$target"  # Secure permissions
    
    # Try to open with common editors
    if command_exists code; then
        code "$target"
    elif command_exists nvim; then
        nvim "$target"
    elif command_exists vim; then
        vim "$target"
    else
        print_status "Open $target in your editor to add the secret content"
    fi
}

# Main command dispatcher
case "$1" in
    "init")
        init_secrets
        ;;
    "link")
        link_secrets
        ;;
    "list")
        list_secrets
        ;;
    "add")
        add_secret "$2"
        ;;
    *)
        echo "Usage: $0 {init|link|list|add <filename>}"
        echo ""
        echo "Commands:"
        echo "  init     Initialize secrets directory"
        echo "  link     Link secrets to private config"
        echo "  list     List available secrets and links"
        echo "  add      Add a new secret file"
        exit 1
        ;;
esac