#!/bin/bash
# CUDA installation script for WSL2

# Exit on error
set -e

# Check if running in WSL2
if [ -z "$(uname -r | grep -i microsoft)" ]; then
  echo "Error: This script must be run in WSL2"
  exit 1
fi

# Check CUDA installation status
if command -v nvcc >/dev/null 2>&1; then
  current_version=$(nvcc --version | grep "release" | awk '{print $5}' | cut -c2-)
  echo "CUDA is already installed. Current version: $current_version"
  read -p "Continue with installation? [y/N] " yn
  if [ "$yn" != "y" ]; then
    exit 1
  fi
fi

# Define CUDA version
CUDA_VERSION=${1:-12.8}
echo "Installing CUDA ${CUDA_VERSION}..."

# Download CUDA repository configuration
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600

# Download and install CUDA package
wget https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}.0/local_installers/cuda-repo-wsl-ubuntu-${CUDA_VERSION/./-}-local_${CUDA_VERSION}.0-1_amd64.deb
sudo dpkg -i cuda-repo-wsl-ubuntu-${CUDA_VERSION/./-}-local_${CUDA_VERSION}.0-1_amd64.deb
sudo cp /var/cuda-repo-wsl-ubuntu-${CUDA_VERSION/./-}-local/cuda-*-keyring.gpg /usr/share/keyrings/

# Update package list and install CUDA toolkit
sudo apt-get update
sudo apt-get -y install cuda-toolkit-${CUDA_VERSION/./-}

# Cleanup downloaded package
rm -f cuda-repo-wsl-ubuntu-${CUDA_VERSION/./-}-local_${CUDA_VERSION}.0-1_amd64.deb

# Verify installation
echo "Verifying CUDA installation..."
nvcc --version || echo "CUDA installation may have failed or needs a terminal restart"

# Add CUDA to PATH if not already there
if ! grep -q "export PATH=/usr/local/cuda-${CUDA_VERSION}/bin" ~/.zshrc; then
  echo "export PATH=/usr/local/cuda-${CUDA_VERSION}/bin:\$PATH" >> ~/.zshrc
  echo "export LD_LIBRARY_PATH=/usr/local/cuda-${CUDA_VERSION}/lib64:\$LD_LIBRARY_PATH" >> ~/.zshrc
  echo "Added CUDA to PATH in .zshrc"
fi

echo "CUDA ${CUDA_VERSION} installed successfully"