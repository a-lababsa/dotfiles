#!/bin/bash
# Configuration files installation script

set -euo pipefail

BASE_DIR="${1:-${PWD}}"
OPTION="${2:-}"
OPTION_ARG="${3:-}"

# Source version utilities
source "$BASE_DIR/scripts/version-utils.sh"

echo "➡️ Lancement du script d'installation de la configuration..."

# Fonction pour installer Task (taskfile.dev)
install_task() {
  local latest_version
  latest_version=$(get_latest_github_version "go-task/task")
  
  if check_version "task" "$latest_version" "task --version"; then
    return 0
  fi

  echo "🔧 Installation de Task v$latest_version..."
  
  local install_script
  install_script=$(download_with_cache "https://taskfile.dev/install.sh" "task-install.sh")
  
  if [[ -f "$install_script" ]]; then
    sh "$install_script" -d -b ~/.local/bin "v${latest_version}"
  else
    echo "❌ Failed to download Task installer"
    return 1
  fi

  if command -v task &>/dev/null; then
    echo "✅ Task installé avec succès (v$(task --version))"
  else
    export PATH="$HOME/.local/bin:$PATH"
    if command -v task &>/dev/null; then
      echo "✅ Task installé avec succès après mise à jour du PATH"

      if ! grep -q 'export PATH="\$HOME/.local/bin:\$PATH"' ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
        echo "🛠️ PATH mis à jour dans .zshrc"
      fi
    else
      echo "❌ Échec de l'installation de Task."
      return 1
    fi
  fi
}

# Exécute l'installation de Task si demandé
if [[ "$OPTION" == "--install-task" || "$OPTION" == "-t" ]]; then
  install_task
  [[ "$OPTION_ARG" == "--only" ]] && exit 0
fi

echo "🔧 Installation des fichiers de configuration..."

mkdir -p ~/.config
mkdir -p ~/miniconda3

backup_if_needed() {
  local file="$1"
  if [[ -f "$file" && ! -L "$file" ]]; then
    echo "🗂️ Sauvegarde de $file vers ${file}.bak"
    cp -f "$file" "${file}.bak"
  fi
  rm -f "$file" 2>/dev/null || true
}

copy_config() {
  local src="$1"
  local dest="$2"
  if [[ -f "$src" ]]; then
    cp -f "$src" "$dest" && echo "✅ Copié : $(basename $dest)" || { echo "❌ Échec de copie de $(basename $src)"; exit 1; }
  else
    echo "⏭️ $(basename $src) non trouvé, ignoré."
  fi
}

# Liste des fichiers à sauvegarder et copier
for file in ~/.zshrc ~/.zsh_aliases ~/.gitconfig ~/.gitignore ~/.config/starship.toml; do
  backup_if_needed "$file"
done

copy_config "$BASE_DIR/config/zsh/.zshrc" ~/.zshrc
copy_config "$BASE_DIR/config/zsh/.zsh_aliases" ~/.zsh_aliases
copy_config "$BASE_DIR/config/git/.gitconfig" ~/.gitconfig
copy_config "$BASE_DIR/config/git/.gitignore" ~/.gitignore
copy_config "$BASE_DIR/config/starship/starship.toml" ~/.config/starship.toml

# NVM : set default LTS if installé
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  . "$HOME/.nvm/nvm.sh"
  nvm alias default 'lts/*'
  echo "🟢 NVM configuré avec la version LTS par défaut"
else
  echo "⚠️ NVM n'est pas installé. Exécute : task nvm-setup"
fi

echo "✅ Tous les fichiers de configuration ont été installés avec succès !"
