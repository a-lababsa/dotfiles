#!/bin/bash
# Script to create user-specific configuration files that are sourced from the main configs

set -euo pipefail

# Create the directory for user-specific configs
USER_CONFIG_DIR="$HOME/.config/dotfiles-local"
mkdir -p "$USER_CONFIG_DIR"

# Create local config files if they don't exist
create_if_not_exists() {
  local file="$1"
  local content="$2"
  
  if [[ ! -f "$file" ]]; then
    echo "$content" > "$file"
    echo "✅ Created $file"
  else
    echo "ℹ️ $file already exists, skipping"
  fi
}

# Create .zshrc.local
create_if_not_exists "$USER_CONFIG_DIR/zshrc.local" "# User-specific ZSH configuration
# Add your customizations here

# Example: Add custom paths
# export PATH=\$PATH:\$HOME/bin

# Example: Custom aliases
# alias myalias='command'
"

# Create .zsh_aliases.local
create_if_not_exists "$USER_CONFIG_DIR/zsh_aliases.local" "# User-specific ZSH aliases
# Add your custom aliases here

# Example: 
# alias projects='cd ~/projects'
"

# Create .gitconfig.local
create_if_not_exists "$USER_CONFIG_DIR/gitconfig.local" "# User-specific Git configuration
# This file is loaded by the main .gitconfig

# Example:
# [user]
#   email = youremail@example.com
#   name = Your Name
# 
# [alias]
#   custom = your-custom-command
"

# Update the main configuration files to source the local ones
update_main_config() {
  local main_file="$1"
  local source_line="$2"
  local marker="# BEGIN DOTFILES-LOCAL"
  local end_marker="# END DOTFILES-LOCAL"
  
  # Remove existing inclusion if present
  if grep -q "$marker" "$main_file"; then
    sed -i "/$marker/,/$end_marker/d" "$main_file"
  fi
  
  # Add new inclusion at the end of the file
  cat >> "$main_file" << EOL

$marker
$source_line
$end_marker
EOL
  
  echo "✅ Updated $main_file to source local configuration"
}

# Update main config files
if [[ -f "$HOME/.zshrc" ]]; then
  update_main_config "$HOME/.zshrc" "# Source user-specific ZSH configuration
if [[ -f \"$USER_CONFIG_DIR/zshrc.local\" ]]; then
  source \"$USER_CONFIG_DIR/zshrc.local\"
fi"
fi

if [[ -f "$HOME/.zsh_aliases" ]]; then
  update_main_config "$HOME/.zsh_aliases" "# Source user-specific ZSH aliases
if [[ -f \"$USER_CONFIG_DIR/zsh_aliases.local\" ]]; then
  source \"$USER_CONFIG_DIR/zsh_aliases.local\"
fi"
fi

# Update .gitconfig to include .gitconfig.local
if [[ -f "$HOME/.gitconfig" ]]; then
  if ! grep -q "\[include\]" "$HOME/.gitconfig" || ! grep -q "path = $USER_CONFIG_DIR/gitconfig.local" "$HOME/.gitconfig"; then
    cat >> "$HOME/.gitconfig" << EOL

# BEGIN DOTFILES-LOCAL
[include]
  path = $USER_CONFIG_DIR/gitconfig.local
# END DOTFILES-LOCAL
EOL
    echo "✅ Updated .gitconfig to include local configuration"
  fi
fi

echo ""
echo "🎉 User-specific configuration files have been set up in $USER_CONFIG_DIR"
echo "You can customize these files without affecting the main configuration files."
echo "These files will be preserved when updating the main dotfiles."