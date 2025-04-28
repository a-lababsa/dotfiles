#!/bin/bash
# Configuration files installation script

# Exit on error
set -e

# Function to install Task
install_task() {
  if ! command -v task &> /dev/null; then
    echo "Installing Task (taskfile.dev)..."
    
    # Determine the latest version
    TASK_VERSION=$(curl -s https://api.github.com/repos/go-task/task/releases/latest | grep "tag_name" | cut -d '"' -f 4)
    
    # Remove 'v' prefix if present
    TASK_VERSION=${TASK_VERSION#v}
    
    # Download and install task binary
    echo "Installing Task version ${TASK_VERSION}..."
    sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin "v${TASK_VERSION}"
    
    # Verify installation
    if command -v task &> /dev/null; then
      echo "Task has been installed successfully. Version: $(task --version)"
    else
      # Try to add ~/.local/bin to PATH for the current session
      export PATH="$HOME/.local/bin:$PATH"
      
      if command -v task &> /dev/null; then
        echo "Task has been installed successfully. Version: $(task --version)"
        echo "Make sure ~/.local/bin is in your PATH."
        
        # Add to .zshrc if not already there
        if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" ~/.zshrc 2>/dev/null; then
          echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
          echo "Added ~/.local/bin to PATH in .zshrc"
        fi
      else
        echo "Failed to install Task. Please check error messages or install manually."
      fi
    fi
  else
    echo "Task is already installed. Version: $(task --version)"
  fi
}

# Check if Task installation is requested
if [ "${2}" = "--install-task" ] || [ "${2}" = "-t" ]; then
  install_task
  
  # If only installing Task, exit after finishing
  if [ "${3}" = "--only" ]; then
    exit 0
  fi
fi

echo "Installing configuration files..."

# Create necessary directories
mkdir -p ~/.config
mkdir -p ~/miniconda3

# Base directory from where to copy files
BASE_DIR=${1:-${PWD}}

# Remove existing files/symlinks if they exist and backup if needed
backup_if_needed() {
  local file=$1
  if [ -f "$file" ] && [ ! -L "$file" ]; then
    echo "Backing up $file to ${file}.bak"
    cp -f "$file" "${file}.bak"
  fi
  rm -f "$file" 2>/dev/null || true
}

# List of config files to handle
backup_if_needed ~/.zshrc
backup_if_needed ~/.zsh_aliases
backup_if_needed ~/.gitconfig
backup_if_needed ~/.gitignore
backup_if_needed ~/.config/starship.toml

# Function to copy a config file
copy_config() {
  local src=$1
  local dest=$2
  
  if [ -f "$src" ]; then
    cp -f "$src" "$dest" || { echo "Failed to copy $(basename $src)"; exit 1; }
    echo "Installed: $(basename $dest)"
  else
    echo "No $(basename $src) found, skipping..."
  fi
}

# ZSH
copy_config "${BASE_DIR}/config/zsh/.zshrc" ~/.zshrc
copy_config "${BASE_DIR}/config/zsh/.zsh_aliases" ~/.zsh_aliases

# Git
copy_config "${BASE_DIR}/config/git/.gitconfig" ~/.gitconfig
copy_config "${BASE_DIR}/config/git/.gitignore" ~/.gitignore

# Starship
copy_config "${BASE_DIR}/config/starship/starship.toml" ~/.config/starship.toml

# NVM configuration
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  . "$HOME/.nvm/nvm.sh" && nvm alias default 'lts/*'
  echo "NVM configured with latest LTS version as default"
else
  echo "NVM is not yet installed, run 'task nvm-setup'"
fi

echo "Configuration files installed successfully"