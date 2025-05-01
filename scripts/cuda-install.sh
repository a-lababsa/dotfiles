#!/bin/bash
# CUDA installation script for WSL2

set -euo pipefail

CUDA_VERSION="${1:-12.8}"
CUDA_VERSION_DASHED="${CUDA_VERSION/./-}"
CUDA_DEB="cuda-repo-wsl-ubuntu-${CUDA_VERSION_DASHED}-local_${CUDA_VERSION}.0-1_amd64.deb"

echo "➡️  Début de l'installation de CUDA ${CUDA_VERSION}..."

# Vérifie si on est bien sous WSL2
if ! grep -qi microsoft /proc/version; then
  echo "❌ Ce script doit être exécuté sous WSL2"
  exit 1
fi

# Vérifie si CUDA est déjà installé
if command -v nvcc >/dev/null 2>&1; then
  current_version=$(nvcc --version | grep "release" | awk '{print $5}' | cut -c2-)
  echo "✅ CUDA déjà installé. Version actuelle : $current_version"
  read -p "Continuer quand même l'installation ? [y/N] " yn
  if [[ "$yn" != "y" && "$yn" != "Y" ]]; then
    echo "⏹️ Installation annulée."
    exit 0
  fi
fi

# Téléchargement des fichiers nécessaires
echo "📦 Téléchargement du fichier de configuration du dépôt..."
wget -q https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600

echo "📥 Téléchargement de l’installeur local CUDA $CUDA_VERSION..."
wget -q https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}.0/local_installers/${CUDA_DEB}

# Installation du dépôt CUDA
sudo dpkg -i ${CUDA_DEB}
sudo cp /var/cuda-repo-wsl-ubuntu-${CUDA_VERSION_DASHED}-local/cuda-*-keyring.gpg /usr/share/keyrings/

# Mise à jour et installation de CUDA
echo "🔄 Mise à jour des paquets..."
sudo apt-get update -y

echo "⚙️ Installation de CUDA Toolkit ${CUDA_VERSION}..."
sudo apt-get install -y cuda-toolkit-${CUDA_VERSION_DASHED}

# Nettoyage
rm -f ${CUDA_DEB}

# Vérification
echo "🔍 Vérification de l'installation..."
if nvcc --version; then
  echo "✅ CUDA ${CUDA_VERSION} installé avec succès"
else
  echo "⚠️ La commande 'nvcc' n'est pas disponible. Essayez de redémarrer votre terminal."
fi

# Configuration du PATH (Zsh)
ZSHRC="${HOME}/.zshrc"
if ! grep -q "/usr/local/cuda-${CUDA_VERSION}/bin" "$ZSHRC"; then
  echo "" >> "$ZSHRC"
  echo "# Ajout CUDA ${CUDA_VERSION} à PATH" >> "$ZSHRC"
  echo "export PATH=/usr/local/cuda-${CUDA_VERSION}/bin:\$PATH" >> "$ZSHRC"
  echo "export LD_LIBRARY_PATH=/usr/local/cuda-${CUDA_VERSION}/lib64:\$LD_LIBRARY_PATH" >> "$ZSHRC"
  echo "✅ Chemins CUDA ajoutés à votre .zshrc"
fi
