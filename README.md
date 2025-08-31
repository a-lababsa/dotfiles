# Dotfiles

Automated configuration for cross-platform development environment (macOS, Linux, WSL2).

## Installation

```bash
git clone <your-repo> ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## Options

- `./install.sh --dry-run` - Preview without changes
- `./install.sh --skip-deps` - Skip dependencies, only create links
- `./install.sh --only-symlinks` - Create symbolic links only

## What gets installed

### Development tools
- **Zsh** with Oh My Zsh and Starship prompt
- **Node.js** via NVM (LTS version)
- **Python** via uv (ultra-fast modern package manager)
- **Git** with custom configuration
- **Modern CLI tools**: ripgrep, fd, bat, exa, etc.

### Configurations
- **Zsh**: history, auto-completion, aliases
- **Git**: global configuration and gitignore
- **Starship**: custom prompt
- **Ghostty**: terminal configuration
- **Zed**: IDE settings and keybindings

### Multi-OS support
- **macOS**: Homebrew + system configurations
- **Ubuntu/Debian**: APT + Flatpak
- **WSL2**: Windows integration

## Structure

```
├── install.sh              # Main installation script
├── Brewfile                # macOS packages (Homebrew)
├── packages/               # Package lists by OS
├── config/                 # Configuration files
│   ├── git/               # Git configuration
│   ├── starship/          # Starship configuration
│   ├── zsh/               # Zsh configuration
│   ├── ghostty/           # Ghostty terminal config
│   └── zed/               # Zed IDE configuration
└── scripts/               # OS-specific scripts
    ├── macos.sh
    ├── ubuntu.sh
    └── wsl.sh
```

## Customization

Existing configurations are automatically backed up with `.backup` extension.

## License

BSD 3-Clause