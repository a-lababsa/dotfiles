#!/bin/bash
# CUDA installation script for WSL2 with progress bar

set -euo pipefail

# Load progress bar functions
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/progress.sh"

CUDA_VERSION="${1:-12.8}"
CUDA_VERSION_DASHED="${CUDA_VERSION/./-}"
CUDA_DEB="cuda-repo-wsl-ubuntu-${CUDA_VERSION_DASHED}-local_${CUDA_VERSION}.0-1_amd64.deb"
LOG_FILE="/tmp/cuda_install_$(date +%Y%m%d_%H%M%S).log"

# Function for logging
log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOG_FILE"
  # Update progress message if progress bar is active
  if [[ "${PROGRESS_ACTIVE:-0}" -eq 1 ]]; then
    update_progress "$CURRENT_PROGRESS" "$1"
  fi
}

# Function for error handling
handle_error() {
  log "❌ Error occurred at line $1. Check $LOG_FILE for details."
  # Complete progress bar with error if active
  if [[ "${PROGRESS_ACTIVE:-0}" -eq 1 ]]; then
    complete_progress "Installation failed!"
  fi
  exit 1
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Initialize progress tracking
PROGRESS_ACTIVE=1
CURRENT_PROGRESS=0

# Initialize progress bar
init_progress "Installing CUDA ${CUDA_VERSION}" "\e[34m"  # Blue color
update_progress $CURRENT_PROGRESS "Starting installation..."

log "➡️  Starting CUDA ${CUDA_VERSION} installation..."

# Check for WSL2
if ! grep -qi microsoft /proc/version; then
  log "❌ This script must be run under WSL2"
  complete_progress "Installation failed: Not running in WSL2"
  exit 1
fi

# Update progress
CURRENT_PROGRESS=5
update_progress $CURRENT_PROGRESS "Checking environment..."

# GPU check
if ! grep -q "gpu" /proc/modules 2>/dev/null; then
  log "⚠️  GPU module not detected in kernel. This may indicate WSL2 GPU passthrough is not enabled."
  log "   Please ensure you have followed the NVIDIA GPU setup instructions for WSL2:"
  log "   https://docs.nvidia.com/cuda/wsl-user-guide/index.html"
  log "   Continuing installation anyway, but GPU passthrough may not work."
  sleep 2
fi

# Update progress
CURRENT_PROGRESS=10
update_progress $CURRENT_PROGRESS "Checking for existing CUDA installation..."

# Check if CUDA is already installed
if command -v nvcc >/dev/null 2>&1; then
  current_version=$(nvcc --version | grep "release" | awk '{print $5}' | cut -c2-)
  log "✅ CUDA already installed. Current version: $current_version"
  
  # Prompt to continue
  PROGRESS_ACTIVE=0  # Temporarily disable progress updates
  read -p "Continue with installation anyway? [y/N] " yn
  PROGRESS_ACTIVE=1  # Re-enable progress updates
  
  if [[ "$yn" != "y" && "$yn" != "Y" ]]; then
    complete_progress "Installation cancelled."
    exit 0
  fi
fi

# Update progress
CURRENT_PROGRESS=15
update_progress $CURRENT_PROGRESS "Downloading repository configuration..."

# Download necessary files
log "📦 Downloading repository configuration file..."
if ! wget -q https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin; then
  log "❌ Failed to download CUDA repository pin file. Check your internet connection."
  complete_progress "Installation failed: Download error"
  exit 1
fi
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600

# Update progress
CURRENT_PROGRESS=25
update_progress $CURRENT_PROGRESS "Downloading CUDA installer..."

log "📥 Downloading CUDA $CUDA_VERSION local installer..."
start_spinner "Downloading CUDA installer... This may take a while"
if ! wget -q https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}.0/local_installers/${CUDA_DEB}; then
  stop_spinner "Download failed"
  log "❌ Failed to download CUDA installer. Verify that version ${CUDA_VERSION} exists."
  log "   Visit https://developer.nvidia.com/cuda-downloads to check available versions."
  complete_progress "Installation failed: Download error"
  exit 1
fi
stop_spinner "Download complete"

# Update progress
CURRENT_PROGRESS=40
update_progress $CURRENT_PROGRESS "Installing CUDA repository..."

# Install CUDA repository
log "📦 Installing CUDA repository..."
if ! sudo dpkg -i ${CUDA_DEB}; then
  log "❌ Failed to install CUDA repository package. Check dpkg error above."
  complete_progress "Installation failed: Repository setup error"
  exit 1
fi

if [ -f "/var/cuda-repo-wsl-ubuntu-${CUDA_VERSION_DASHED}-local/cuda-*-keyring.gpg" ]; then
  sudo cp /var/cuda-repo-wsl-ubuntu-${CUDA_VERSION_DASHED}-local/cuda-*-keyring.gpg /usr/share/keyrings/
else
  log "⚠️  Could not find keyring file. Repository authentication may fail."
fi

# Update progress
CURRENT_PROGRESS=50
update_progress $CURRENT_PROGRESS "Updating package lists..."

# Update and install CUDA
log "🔄 Updating packages..."
if ! sudo apt-get update -y; then
  log "❌ Failed to update package list. Check apt error above."
  complete_progress "Installation failed: Package update error"
  exit 1
fi

# Update progress
CURRENT_PROGRESS=60
update_progress $CURRENT_PROGRESS "Installing CUDA Toolkit..."

log "⚙️ Installing CUDA Toolkit ${CUDA_VERSION}..."
start_spinner "Installing CUDA Toolkit... This may take several minutes"
if ! sudo apt-get install -y cuda-toolkit-${CUDA_VERSION_DASHED}; then
  stop_spinner "Installation failed"
  log "❌ Failed to install CUDA Toolkit. Check apt error above."
  complete_progress "Installation failed: CUDA Toolkit installation error"
  exit 1
fi
stop_spinner "Installation complete"

# Update progress
CURRENT_PROGRESS=80
update_progress $CURRENT_PROGRESS "Cleaning up..."

# Cleanup
rm -f ${CUDA_DEB}

# Update progress
CURRENT_PROGRESS=85
update_progress $CURRENT_PROGRESS "Verifying installation..."

# Verification
log "🔍 Verifying installation..."
if nvcc --version 2>/dev/null; then
  log "✅ CUDA ${CUDA_VERSION} command-line tools installed successfully"
else
  log "⚠️ The 'nvcc' command is not available. You may need to restart your terminal or check installation logs."
  log "   Adding CUDA to your PATH..."
fi

# Update progress
CURRENT_PROGRESS=90
update_progress $CURRENT_PROGRESS "Configuring PATH..."

# Configure PATH (Zsh)
ZSHRC="${HOME}/.zshrc"
if ! grep -q "/usr/local/cuda-${CUDA_VERSION}/bin" "$ZSHRC" 2>/dev/null; then
  echo "" >> "$ZSHRC"
  echo "# CUDA ${CUDA_VERSION} PATH configuration" >> "$ZSHRC"
  echo "export PATH=/usr/local/cuda-${CUDA_VERSION}/bin:\$PATH" >> "$ZSHRC"
  echo "export LD_LIBRARY_PATH=/usr/local/cuda-${CUDA_VERSION}/lib64:\$LD_LIBRARY_PATH" >> "$ZSHRC"
  log "✅ CUDA paths added to your .zshrc"
fi

# Update progress
CURRENT_PROGRESS=95
update_progress $CURRENT_PROGRESS "Testing CUDA installation..."

# Additional verification - compile and run a simple CUDA program
log "🧪 Running CUDA sample to verify GPU access..."
mkdir -p /tmp/cuda_test
cat > /tmp/cuda_test/test.cu << 'EOL'
#include <stdio.h>

int main() {
    int deviceCount;
    cudaGetDeviceCount(&deviceCount);
    printf("CUDA Device Count: %d\n", deviceCount);
    
    if (deviceCount > 0) {
        cudaDeviceProp deviceProp;
        cudaGetDeviceProperties(&deviceProp, 0);
        printf("CUDA Device Name: %s\n", deviceProp.name);
    }
    
    return 0;
}
EOL

cd /tmp/cuda_test
if nvcc test.cu -o cuda_test; then
  log "✅ CUDA sample compiled successfully"
  if ./cuda_test; then
    log "🎉 GPU access verified! CUDA installation complete."
  else
    log "⚠️ CUDA sample failed to run. GPU access may not be configured correctly in WSL2."
    log "   Please follow NVIDIA's WSL2 GPU setup guide: https://docs.nvidia.com/cuda/wsl-user-guide/index.html"
  fi
else
  log "⚠️ Could not compile CUDA sample. CUDA installation may be incomplete."
fi

# Complete progress bar
CURRENT_PROGRESS=100
complete_progress "CUDA ${CUDA_VERSION} installation complete!"

log "✅ CUDA installation process finished. Check $LOG_FILE for detailed logs."
log "🔄 Please restart your terminal session for all changes to take effect."