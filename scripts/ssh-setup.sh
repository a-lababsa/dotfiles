#!/bin/bash
# SSH setup script for WSL2 environment

set -euo pipefail

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"

echo "➡️  Setting up SSH configuration..."

# Create SSH directory with correct permissions
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Check if SSH key already exists
if [ -f "$SSH_DIR/id_ed25519" ]; then
  echo "✅ SSH key already exists at $SSH_DIR/id_ed25519"
  read -p "Generate a new key anyway? [y/N] " yn
  if [[ "$yn" != "y" && "$yn" != "Y" ]]; then
    echo "⏹️ Key generation skipped."
  else
    generate_key=true
  fi
else
  generate_key=true
fi

# Generate a new SSH key
if [ "${generate_key:-false}" = true ]; then
  echo "🔑 Generating new SSH key..."
  
  # Get user email
  read -p "Enter your email (for SSH key comment): " user_email
  
  if [ -z "$user_email" ]; then
    user_email="$(whoami)@$(hostname)"
  fi
  
  # Let user choose key type
  echo "Select key type:"
  echo "1) ED25519 (recommended, newer, secure and faster)"
  echo "2) RSA (4096 bit, more compatible with older systems)"
  read -p "Choose [1/2]: " key_choice
  
  case $key_choice in
    2)
      ssh-keygen -t rsa -b 4096 -C "$user_email" -f "$SSH_DIR/id_rsa"
      key_file="$SSH_DIR/id_rsa"
      ;;
    *)
      ssh-keygen -t ed25519 -C "$user_email" -f "$SSH_DIR/id_ed25519"
      key_file="$SSH_DIR/id_ed25519"
      ;;
  esac
  
  echo "✅ SSH key generated successfully!"
fi

# Set up SSH config file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  echo "📝 Creating SSH config file..."
  cat > "$CONFIG_FILE" << 'EOL'
# SSH Configuration File

# Default settings for all hosts
Host *
  AddKeysToAgent yes
  IdentitiesOnly yes
  ServerAliveInterval 60
  
# Example GitHub configuration
Host github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  
# Example BitBucket configuration
Host bitbucket.org
  User git
  IdentityFile ~/.ssh/id_ed25519
  
# Example for custom server
# Host myserver
#   HostName example.com
#   User username
#   Port 22
#   IdentityFile ~/.ssh/id_ed25519
EOL

  chmod 600 "$CONFIG_FILE"
  echo "✅ SSH config file created at $CONFIG_FILE"
else
  echo "ℹ️ SSH config file already exists at $CONFIG_FILE"
fi

# Start ssh-agent and add key
if ! pgrep -x "ssh-agent" > /dev/null; then
  echo "🔌 Starting SSH agent..."
  eval "$(ssh-agent -s)"
else
  echo "ℹ️ SSH agent is already running"
fi

# Add key to ssh-agent
if [ -f "${key_file:-}" ]; then
  ssh-add "${key_file}"
  echo "✅ Added SSH key to agent"
elif [ -f "$SSH_DIR/id_ed25519" ]; then
  ssh-add "$SSH_DIR/id_ed25519"
  echo "✅ Added existing ED25519 key to agent"
elif [ -f "$SSH_DIR/id_rsa" ]; then
  ssh-add "$SSH_DIR/id_rsa"
  echo "✅ Added existing RSA key to agent"
fi

# Configure SSH agent autostart in .zshrc
if [ -f ~/.zshrc ]; then
  if ! grep -q "# SSH agent configuration" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# SSH agent configuration" >> ~/.zshrc
    echo 'if [ -z "$SSH_AUTH_SOCK" ]; then' >> ~/.zshrc
    echo '  eval "$(ssh-agent -s)" > /dev/null' >> ~/.zshrc
    echo '  ssh-add ~/.ssh/id_ed25519 2>/dev/null || ssh-add ~/.ssh/id_rsa 2>/dev/null || true' >> ~/.zshrc
    echo 'fi' >> ~/.zshrc
    echo "✅ Added SSH agent configuration to .zshrc"
  fi
fi

# Display public key
if [ -f "${key_file:-}.pub" ]; then
  public_key="${key_file}.pub"
elif [ -f "$SSH_DIR/id_ed25519.pub" ]; then
  public_key="$SSH_DIR/id_ed25519.pub"
elif [ -f "$SSH_DIR/id_rsa.pub" ]; then
  public_key="$SSH_DIR/id_rsa.pub"
fi

if [ -n "${public_key:-}" ]; then
  echo ""
  echo "🔑 Your public SSH key:"
  echo ""
  cat "$public_key"
  echo ""
  echo "Add this key to your GitHub/GitLab/BitBucket account or remote servers."
  
  # Copy to clipboard if possible
  if command -v clip.exe > /dev/null; then
    cat "$public_key" | clip.exe
    echo "✅ Public key copied to clipboard!"
  fi
fi

echo ""
echo "🎉 SSH setup completed!"
echo "You may need to restart your terminal for all changes to take effect."