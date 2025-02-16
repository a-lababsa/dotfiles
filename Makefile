

# Check if running in WSL2
check-wsl:
	@if [ -z "$$(uname -r | grep -i microsoft)" ]; then \
		echo "Error: This script must be run in WSL2"; \
		exit 1; \
	fi

install:
 	# Create necessary directories
	mkdir -p ~/.config

	# Remove existing files/symlinks if they exist
	rm -f ~/.zshrc
	rm -f ~/.zsh_aliases
	rm -f ~/.gitconfig
	rm -f ~/.gitignore
	rm -f ~/.vimrc
	rm -f ~/.config/starship.toml

 	# ZSH
	cp -f ${PWD}/config/zsh/.zshrc ~/.zshrc
	cp -f ${PWD}/config/zsh/.zsh_aliases ~/.zsh_aliases
	
 	# Git
	cp -f ${PWD}/config/git/.gitconfig ~/.gitconfig
	cp -f ${PWD}/config/git/.gitignore ~/.gitignore
	
 	# Vim
	# cp -f ${PWD}/config/vim/.vimrc ~/.vimrc
	
 	# Starship
	cp -f ${PWD}/config/starship/starship.toml ~/.config/starship.toml

wsl-setup:
	sudo apt update && sudo apt upgrade -y
	
	sudo apt install -y \
		zsh \
		vim \
		git \
		curl \
		wget \
		build-essential \
		wslu \
		python3 \
		python3-pip


	curl -sS https://starship.rs/install.sh | sh

ollama-setup: check-wsl
	@if command -v ollama >/dev/null 2>&1; then \
		echo "Ollama is already installed. Current version:"; \
		ollama --version; \
		read -p "Continue with installation? [y/N] " yn; \
		if [ "$$yn" != "y" ]; then \
			exit 1; \
		fi \
	fi
	
	# Install Ollama
	curl https://ollama.ai/install.sh | sh
	
	# Verify installation
	@echo "Verifying Ollama installation..."
	@ollama --version || echo "Error: Ollama installation failed"

# Check CUDA installation status
check-cuda:
	@if command -v nvcc >/dev/null 2>&1; then \
		echo "CUDA is already installed. Current version:"; \
		nvcc --version | grep "release" | awk '{print $$5}' | cut -c2-; \
		read -p "Continue with installation? [y/N] " yn; \
		if [ "$$yn" != "y" ]; then \
			exit 1; \
		fi \
	fi


cuda-setup: check-wsl check-cuda
 	# Download CUDA repository configuration
	wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
	sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
	
 	# Download and install CUDA 12.8 package
	wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb
	sudo dpkg -i cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb
	sudo cp /var/cuda-repo-wsl-ubuntu-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
	
 	# Update package list and install CUDA toolkit
	sudo apt-get update
	sudo apt-get -y install cuda-toolkit-12-8
	
 	# Cleanup downloaded package
	rm -f cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb
	
 	# Verify installation
	@echo "Verifying CUDA installation..."
	@nvcc --version || echo "Error: CUDA installation failed"

# Help target
help:
	@echo "Available targets:"
	@echo "  install      - Install configuration files"
	@echo "  wsl-setup    - Setup basic WSL2 development environment"
	@echo "  cuda-setup   - Install CUDA 12.8"
	@echo "  ollama-setup - Install Ollama"
	@echo "  help         - Show this help message"

.PHONY: check-wsl check-cuda install wsl-setup cuda-setup ollama-setup help