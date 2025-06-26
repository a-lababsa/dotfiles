#!/bin/bash
# Docker installation for WSL2

set -euo pipefail

echo "➡️  Installing Docker in WSL2..."

# Check if we're in WSL2
if ! grep -qi microsoft /proc/version; then
  echo "❌ This script must be run under WSL2"
  exit 1
fi

# Check if Docker is already installed
if command -v docker >/dev/null 2>&1; then
  echo "✅ Docker is already installed. Current version:"
  docker --version
  read -p "Continue with reinstallation? [y/N] " yn
  if [[ "$yn" != "y" && "$yn" != "Y" ]]; then
    echo "⏹️ Installation cancelled."
    exit 0
  fi
fi

# Update package lists
echo "🔄 Updating package lists..."
sudo apt-get update

# Install prerequisites
echo "📦 Installing prerequisites..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
echo "🔑 Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo "📋 Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again
echo "🔄 Updating package lists with Docker repository..."
sudo apt-get update

# Install Docker
echo "⚙️ Installing Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to the docker group
echo "👤 Adding user to the docker group..."
sudo usermod -aG docker $USER
echo "🔄 Note: You'll need to log out and back in for this to take effect"

# Enable the Docker service
echo "🔌 Starting Docker service..."
if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service
  sudo systemctl start docker
else
  # For older Ubuntu versions that don't use systemd
  sudo service docker start
fi

# Install Docker Compose
echo "📦 Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Configure Docker to start on WSL startup
echo "⚙️ Configuring Docker to start automatically in WSL..."
if [ ! -f /etc/wsl.conf ]; then
  sudo bash -c "cat > /etc/wsl.conf << 'EOL'
[boot]
command=service docker start
EOL"
elif ! grep -q "\[boot\]" /etc/wsl.conf; then
  sudo bash -c "cat >> /etc/wsl.conf << 'EOL'
[boot]
command=service docker start
EOL"
elif ! grep -q "command=.*docker" /etc/wsl.conf; then
  # Add the docker start command to the existing boot section
  sudo sed -i '/\[boot\]/a command=service docker start' /etc/wsl.conf
fi

# Test Docker installation
echo "🧪 Testing Docker installation..."
if ! docker run hello-world > /dev/null 2>&1; then
  echo "⚠️ Docker test failed. You may need to restart your WSL session."
  echo "   Try running: 'wsl --shutdown' in PowerShell and then restart WSL."
else
  echo "✅ Docker successfully installed and tested!"
fi

# Add Docker configuration to .zshrc
if [ -f ~/.zshrc ]; then
  if ! grep -q "# Docker configuration" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Docker configuration" >> ~/.zshrc
    echo "export DOCKER_HOST=unix:///var/run/docker.sock" >> ~/.zshrc
    echo "✅ Added Docker configuration to .zshrc"
  fi
fi

echo ""
echo "🎉 Docker installation completed!"
echo "You may need to restart your WSL session for all changes to take effect."
echo "To verify installation after restart, run: docker --version"