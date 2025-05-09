# Installation and Usage Guide

## Prerequisites

Before you begin, ensure you have:

- Windows 10 version 2004 or higher, or Windows 11
- WSL2 with Ubuntu installed
  - Run `wsl --install -d Ubuntu` in PowerShell with admin privileges if not installed
- Administrator privileges on your Windows machine and WSL2 instance

## Installation Options

### Quick Start (One Command Setup)

If you want to install everything in one go:

```bash
# Clone the repository
git clone https://github.com/a-lababsa/dotfiles.git
cd dotfiles

# Make scripts executable
chmod +x ./scripts/*.sh

# Install Task first (if not already installed)
./scripts/config-install.sh $(pwd) --install-task --only

# Install everything including all integrations
task full-setup
```

### Modular Installation

To pick and choose which components you want to install:

```bash
# Clone the repository
git clone https://github.com/a-lababsa/dotfiles.git
cd dotfiles

# Make scripts executable
chmod +x ./scripts/*.sh

# Install Task first (if not already installed)
./scripts/config-install.sh $(pwd) --install-task --only

# View available tasks
task

# Install only specific components
task setup:install-essential-packages  # Basic tools (zsh, git, etc.)
task env:nvm-setup                     # Node.js via NVM
task env:conda-setup                   # Python via Miniconda
task cuda:cuda-setup                   # CUDA for GPU computing
task env:ollama-setup                  # Ollama for local AI models
task integrations:docker-setup         # Docker and Docker Compose
task integrations:ssh-setup            # SSH keys and configuration
task integrations:vscode-setup         # VS Code integration
```

### Pre-defined Bundles

We've created some useful bundles for common use cases:

```bash
# Just the basics (shell, git, editors)
task setup:install-essential-packages

# Full development tools
task dev-tools

# Machine learning environment
task ml-env

# Configuration files only (zsh, git, vim, starship)
task config:install

# All integrations (Docker, SSH, VS Code)
task integrations:all-integrations
```

## After Installation

After installation, you should:

1. **Restart your terminal** or run `source ~/.zshrc` to apply changes
2. Verify the installation with `task test`
3. For Docker, you may need to run `wsl --shutdown` in PowerShell and restart WSL
4. For CUDA, verify with `nvcc --version` and `nvidia-smi`

## Customization

### User-specific Configuration

Your personal configurations won't be overwritten when updating:

```bash
# Set up user configuration files
task integrations:user-config
```

This creates files in `~/.config/dotfiles-local/` that are sourced from the main configuration files:

- `~/.config/dotfiles-local/zshrc.local`
- `~/.config/dotfiles-local/zsh_aliases.local`
- `~/.config/dotfiles-local/gitconfig.local` 

Edit these files to add your personal configurations.

### Customizing Installed Versions

To change the default versions of various tools, edit the `.env` file in the root directory:

```
CUDA_VERSION=12.8
NVM_VERSION=0.40.1
```

## Maintenance

### Updating the Environment

To update all installed tools:

```bash
task update
```

### Backup and Restore

```bash
# Backup your current configuration
task config:backup-config

# Restore from backup
task config:restore-config
```

## Troubleshooting

### Common Issues

1. **Task command not found**: Run `export PATH="$HOME/.local/bin:$PATH"`
2. **Permission denied**: Make sure scripts are executable with `chmod +x ./scripts/*.sh`
3. **CUDA installation fails**: Ensure your Windows host has the NVIDIA drivers installed
4. **Docker doesn't start**: Run `wsl --shutdown` in PowerShell and restart WSL

### Getting Help

For more detailed information about any task:

```bash
task help TASK_NAME
```

To see all available tasks:

```bash
task
```

## Uninstallation

To remove all installed components:

```bash
# Clean up installed files
task clean
```

Note: This doesn't uninstall system packages. To fully remove everything, you would need to:

1. Uninstall packages with `sudo apt remove package-name`
2. Remove configuration files with `rm -rf ~/.config/dotfiles-local`