# Configuration parameters
CUDA_VERSION = 12.8
NVM_VERSION = 0.40.1

# Check if running in WSL2
check-wsl:
	@if [ -z "$$(uname -r | grep -i microsoft)" ]; then \
		echo "Error: This script must be run in WSL2"; \
		exit 1; \
	fi

install:
	@echo "Installing configuration files..."
 	# Create necessary directories
	mkdir -p ~/.config
	mkdir -p ~/miniconda3

	# Remove existing files/symlinks if they exist
	[ -f ~/.zshrc ] && rm -f ~/.zshrc || true
	[ -f ~/.zsh_aliases ] && rm -f ~/.zsh_aliases || true
	[ -f ~/.gitconfig ] && rm -f ~/.gitconfig || true
	[ -f ~/.gitignore ] && rm -f ~/.gitignore || true
	[ -f ~/.vimrc ] && rm -f ~/.vimrc || true
	[ -f ~/.config/starship.toml ] && rm -f ~/.config/starship.toml || true

 	# ZSH
	cp -f ${PWD}/config/zsh/.zshrc ~/.zshrc || { echo "Failed to copy .zshrc"; exit 1; }
	cp -f ${PWD}/config/zsh/.zsh_aliases ~/.zsh_aliases || { echo "Failed to copy .zsh_aliases"; exit 1; }
	
 	# Git
	cp -f ${PWD}/config/git/.gitconfig ~/.gitconfig || { echo "Failed to copy .gitconfig"; exit 1; }
	cp -f ${PWD}/config/git/.gitignore ~/.gitignore || { echo "Failed to copy .gitignore"; exit 1; }
	
 	# Vim configuration (conditional)
	if [ -f "${PWD}/config/vim/.vimrc" ]; then \
		cp -f ${PWD}/config/vim/.vimrc ~/.vimrc || { echo "Failed to copy .vimrc"; exit 1; }; \
	else \
		echo "No .vimrc found in config/vim, skipping..."; \
	fi

 	# Starship
	cp -f ${PWD}/config/starship/starship.toml ~/.config/starship.toml || { echo "Failed to copy starship.toml"; exit 1; }

	# NVM configuration
	@if [ -s "$$HOME/.nvm/nvm.sh" ]; then \
		. "$$HOME/.nvm/nvm.sh" && nvm alias default 'lts/*' && \
		echo "NVM configured with latest LTS version as default"; \
	else \
		echo "NVM is not yet installed, run 'make nvm-setup'"; \
	fi

	@echo "Configuration files installed successfully"

# Setup basic WSL2 development environment
wsl-setup: install-essential-packages install-starship

# Install essential packages
install-essential-packages:
	@echo "Updating and installing essential packages..."
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
	
	@echo "Would you like to set zsh as your default shell? [y/N] "
	@read yn; if [ "$$yn" = "y" ]; then \
		chsh -s $$(which zsh); \
		echo "Shell changed to zsh. Please log out and log back in for changes to take effect."; \
	fi

# Install Starship prompt
install-starship:
	@echo "Installing Starship prompt..."
	curl -sS https://starship.rs/install.sh | sh
	@echo "Starship prompt installed"

# Install NVM (Node Version Manager)
nvm-setup:
	@echo "Installing NVM version $(NVM_VERSION)..."
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$(NVM_VERSION)/install.sh | bash
	@echo "NVM installed. Please restart your terminal or run 'source ~/.zshrc' to use NVM"
	@echo "You can install Node.js with: 'nvm install --lts'"

ollama-setup: check-wsl
	@if command -v ollama >/dev/null 2>&1; then \
		echo "Ollama is already installed. Current version:"; \
		ollama --version; \
		read -p "Continue with installation? [y/N] " yn; \
		if [ "$$yn" != "y" ]; then \
			exit 1; \
		fi \
	fi
	
	@echo "Installing Ollama..."
	curl https://ollama.ai/install.sh | sh
	
		# Verify installation
	@echo "Verifying Ollama installation..."
	@ollama --version || echo "Error: Ollama installation failed"
	@echo "Ollama installed successfully"

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

# Setup Miniconda
conda-setup:
	@echo "Installing Miniconda3..."
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
	bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
	rm ~/miniconda3/miniconda.sh
	@echo "Miniconda installed to ~/miniconda3"
	@echo "Please run 'eval \"$$(~/miniconda3/bin/conda shell.bash hook)\"' to initialize conda"
	@echo "You may want to add this to your .bashrc or .zshrc"

cuda-setup: check-wsl check-cuda
	@echo "Installing CUDA $(CUDA_VERSION)..."
 	# Download CUDA repository configuration
	wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
	sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
	
 	# Download and install CUDA package
	wget https://developer.download.nvidia.com/compute/cuda/$(CUDA_VERSION).0/local_installers/cuda-repo-wsl-ubuntu-$(CUDA_VERSION)-local_$(CUDA_VERSION).0-1_amd64.deb
	sudo dpkg -i cuda-repo-wsl-ubuntu-$(CUDA_VERSION)-local_$(CUDA_VERSION).0-1_amd64.deb
	sudo cp /var/cuda-repo-wsl-ubuntu-$(CUDA_VERSION)-local/cuda-*-keyring.gpg /usr/share/keyrings/

	# Update package list and install CUDA toolkit
	sudo apt-get update
	sudo apt-get -y install cuda-toolkit-$(CUDA_VERSION)
	
	# Cleanup downloaded package
	rm -f cuda-repo-wsl-ubuntu-$(CUDA_VERSION)-local_$(CUDA_VERSION).0-1_amd64.deb
	
	# Verify installation
	@echo "Verifying CUDA installation..."
	@nvcc --version || echo "Error: CUDA installation failed"

	# Add CUDA to PATH if not already there
	@if ! grep -q "export PATH=/usr/local/cuda-$(CUDA_VERSION)/bin" ~/.zshrc; then \
		echo 'export PATH=/usr/local/cuda-$(CUDA_VERSION)/bin:$$PATH' >> ~/.zshrc; \
		echo 'export LD_LIBRARY_PATH=/usr/local/cuda-$(CUDA_VERSION)/lib64:$$LD_LIBRARY_PATH' >> ~/.zshrc; \
		echo "Added CUDA to PATH in .zshrc"; \
	fi
	
	@echo "CUDA $(CUDA_VERSION) installed successfully"

# Install everything
all: check-wsl wsl-setup nvm-setup conda-setup cuda-setup ollama-setup
	@echo "Complete development environment setup finished!"
	@echo "Please restart your terminal for all changes to take effect."

# Help target
help:
	@echo "┌─────────────────────────────────────────────────────────┐"
	@echo "│          WSL2 Development Environment Setup             │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│ Available targets:                                      │"
	@echo "│                                                         │"
	@echo "│  make install         - Install configuration files     │"
	@echo "│  make wsl-setup       - Setup basic WSL2 dev env        │"
	@echo "│  make nvm-setup       - Install NVM ($(NVM_VERSION))    │"
	@echo "│  make conda-setup     - Install Miniconda3              │"
	@echo "│  make cuda-setup      - Install CUDA $(CUDA_VERSION)    │"
	@echo "│  make ollama-setup    - Install Ollama                  │"
	@echo "│  make all             - Install everything              │"
	@echo "│  make help            - Show this help message          │"
	@echo "└─────────────────────────────────────────────────────────┘"

.PHONY: check-wsl check-cuda install wsl-setup install-essential-packages install-starship nvm-setup ollama-setup conda-setup cuda-setup all help