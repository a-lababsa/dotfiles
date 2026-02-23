# Dotfiles

Cross-platform development environment for macOS, Ubuntu, Debian and WSL2.

## Installation

```bash
git clone https://github.com/a-lababsa/dotfiles ~/Documents/dotfiles
cd ~/Documents/dotfiles
./install.sh --dry-run  # preview changes
./install.sh            # install
```

**Options:**

| Flag | Description |
|---|---|
| `--dry-run` | Preview all changes without applying them |
| `--skip-deps` | Skip package installation (symlinks only + tools) |
| `--only-symlinks` | Create symlinks only, skip everything else |

## Tools

**CLI:** bat, eza, fd, ripgrep, fzf, delta, zoxide, lazygit, glow, btop, dust, hyperfine, xh, serpl, navi, tldr, vibecheck
**Git:** delta (better diffs), lazygit (TUI), gh (GitHub CLI)
**Shell:** Zsh + Starship, zsh-autosuggestions, zsh-syntax-highlighting
**Editors:** Neovim, VS Code, Zed
**Terminal:** Ghostty
**Languages:** Node.js (NVM), Python (uv)

## Key Aliases

```bash
# Navigation
..        # cd ..
z <dir>   # jump to directory (zoxide)

# Git
gs        # git status
ga        # git add
gc        # git commit
gp        # git push
gl        # git log --oneline --graph
vc        # AI commit message (vibecheck + Ollama)

# Modern replacements
cat       # bat (syntax highlighting)
ls / ll   # eza (with git status)
find      # fd
grep      # rg (ripgrep)
man       # tldr
```

## AI Commit Messages (vibecheck)

```bash
git add .
vc        # generates: feat(scope): description
```

Uses Ollama locally (`gpt-oss:20b`). Format: `type(scope): description`.

**Prerequisites:** [Ollama](https://ollama.ai) installed and running.

## Utilities

```bash
health-check              # system diagnostic
dev-setup init app node   # scaffold a new project
backup-dots create        # backup current configs
update-all                # update all tools
```

## Structure

```
config/
  zsh/          # .zshrc, .zshenv, .zsh_aliases, .zsh_performance
  git/          # .gitconfig, .gitignore_global
  starship/     # starship.toml
  ghostty/      # terminal config
  zed/          # editor settings + keymap
  vscode/       # editor settings
  navi/         # cheatsheets (docker, git, macos…)
scripts/
  macos.sh      # macOS system defaults
  ubuntu.sh     # GitHub releases installs + compat symlinks
  wsl.sh        # WSL-specific config (sources ubuntu.sh)
  lib/          # shared utils and colors
bin/            # health-check, dev-setup, backup-dots, update-all
Brewfile        # macOS packages (brew bundle)
install.sh      # main entrypoint
install.conf    # versions and paths
```

## Platform notes

- **macOS** — packages via Homebrew (`brew bundle`)
- **Ubuntu/Debian** — packages via APT + GitHub releases for tools not in repos
- **WSL2** — inherits Ubuntu setup + Windows interop config

Performance optimized with lazy loading (NVM, uv, cargo, rbenv). Secrets managed separately via `~/.dotfiles-secrets`.
