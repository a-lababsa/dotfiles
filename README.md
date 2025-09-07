# Dotfiles

Cross-platform development environment with modern tooling.

## Installation

```bash
git clone <your-repo> ~/.dotfiles
cd ~/.dotfiles
./install.sh --dry-run  # preview changes
./install.sh            # install
```

## Tools

**CLI:** lazygit, fzf, ripgrep, delta, zoxide, btop, bat, eza  
**Languages:** Node.js (NVM), Python (uv), Rust, Go  
**Config:** Zsh + Starship, Git, Ghostty, Zed

## Utilities

```bash
health-check              # system diagnostic
dev-setup init app node   # create project
backup-dots create        # backup configs
update-all                # update everything
```

## Structure

```
config/     # configurations
scripts/    # OS-specific setup
bin/        # utility scripts
```

Performance optimized with lazy loading. Secrets managed separately.