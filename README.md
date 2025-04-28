# WSL2 Development Environment Setup

A comprehensive toolkit for setting up a full-featured development environment in WSL2 (Windows Subsystem for Linux).

## Overview

This project provides a set of automated tasks and scripts to configure a complete development environment on WSL2 Ubuntu. It installs and configures common development tools, programming language environments, and utilities required for software development.

## Features

- **Configuration Management**: ZSH, Git, Vim, Starship prompt
- **Development Tools**: Node.js (via NVM), Python (via Miniconda)
- **AI & GPU Acceleration**: CUDA for GPU computing, Ollama for local AI models
- **Interactive Installation**: Confirmation prompts before making system changes
- **Modular Design**: Tasks can be run individually or all at once

## Prerequisites

- WSL2 with Ubuntu installed
- Administrator privileges on your WSL2 instance

## Installation

### Quick Start (If you already have Task installed)

```bash
# View available tasks
task

# Install everything
task all

# Or choose specific components
task install-essential-packages
task nvm-setup
task cuda-setup
```

### First-time Setup (Without Task)

```bash
# Clone this repository
git clone https://github.com/yourusername/wsl2-dev-setup.git
cd wsl2-dev-setup

# Make the script executable
chmod +x ./scripts/config-install.sh

# Install Task first
./scripts/config-install.sh $(pwd) --install-task --only

# Then install everything
task all
```

## Available Tasks

| Task | Description |
|------|-------------|
| `install` | Install configuration files |
| `install-task` | Install Task (taskfile.dev) task runner |
| `task-only` | Only install Task without configuration files |
| `install-essential-packages` | Install essential packages (zsh, vim, git, curl, etc.) |
| `install-starship` | Install Starship prompt |
| `wsl-setup` | Setup basic WSL2 development environment |
| `nvm-setup` | Install NVM (Node Version Manager) |
| `conda-setup` | Setup Miniconda for Python |
| `ollama-setup` | Install Ollama (local AI models) |
| `cuda-setup` | Setup CUDA for GPU computing |
| `all` | Install everything |

## Configuration Files

The project installs and configures:

- ZSH shell with aliases
- Git global configuration
- Vim settings
- Starship prompt customization

All configuration files are stored in the `config/` directory, organized by tool.

## CUDA Setup

The CUDA installation is handled by a dedicated script that:

1. Verifies WSL2 compatibility
2. Checks for existing CUDA installations
3. Downloads and installs the appropriate CUDA version
4. Updates your PATH in `.zshrc`

## Customization

### Changing Default Versions

You can modify the versions of installed tools by editing the variables at the top of `Taskfile.yml`:

```yaml
vars:
  CUDA_VERSION: 12.8
  NVM_VERSION: 0.40.1
```

### Adding Custom Configuration

1. Add your custom configuration files to the appropriate subdirectory in `config/`
2. Run `task install` to apply changes

## Troubleshooting

### Task not found after installation

If you installed Task but the `task` command isn't recognized:

```bash
export PATH="$HOME/.local/bin:$PATH"
source ~/.zshrc
```

### Permission issues during installation

Try running with sudo for specific commands that require elevated privileges:

```bash
sudo apt update && sudo apt upgrade -y
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Taskfile](https://taskfile.dev/) for the task execution framework
- [Starship](https://starship.rs/) for the cross-shell prompt
- [NVM](https://github.com/nvm-sh/nvm) for Node.js version management
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html) for Python environment management
- [Ollama](https://ollama.ai/) for local AI model deployment