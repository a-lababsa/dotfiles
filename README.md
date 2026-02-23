# Dotfiles

Cross-platform development environment for macOS, Ubuntu, Debian and WSL2.

## Prerequisites

- **macOS** — Homebrew (installed automatically), `curl`, `git`
- **Ubuntu/Debian/WSL2** — `curl`, `git`, `sudo` access

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

## Aliases & Functions

### Navigation
```bash
..               # cd ..
...              # cd ../..
dev              # cd ~/workspace
docs             # cd ~/Documents
z <dir>          # smart jump (zoxide)
```

### Files & search
```bash
cat              # bat (syntax highlighting)
ls / ll / l      # eza (with git status)
tree             # eza --tree
find             # fd
grep             # rg (ripgrep)
man              # tldr
```

### Git
```bash
gs               # git status
ga               # git add
gc               # git commit
gp               # git push
gl               # git log --oneline --graph --decorate
gcm              # git checkout main
gcd              # git checkout develop
vc               # AI commit message (vibecheck + Ollama)
git-fix-email <old> <new>  # rewrite author/committer email across history
```

### Docker
```bash
dps              # docker ps
dimg             # docker images
dc               # docker-compose
```

### Development
```bash
py               # python3
pip              # pip3
serve            # python3 -m http.server
nrun             # npm run
npmls            # npm list -g --depth=0
```

### System
```bash
update           # brew upgrade (macOS) / apt upgrade (Linux)
cleanup          # brew cleanup (macOS) / apt autoremove (Linux)
ports            # list listening ports
reload           # source ~/.zshrc
path             # print PATH entries one per line
```

### Functions
```bash
# Requires: yt-dlp + fabric (not installed by this repo)
ytsummary <url> [pattern]  # summarize a YouTube video via fabric (default: summarize)
```

### Shell shortcuts
```bash
Ctrl+R           # fuzzy history search (fzf)
Ctrl+T           # fuzzy file search (fzf)
```

### WSL only
```bash
explorer / notepad / clip / pwsh / cmd
```

## AI Commit Messages (vibecheck)

Requires [Ollama](https://ollama.ai) running locally.

```bash
git add .
vc        # generates: feat(scope): description
```

Format: `type(scope): description` — uses `gpt-oss:20b` via Ollama.

## Interactive Cheatsheets (navi)

`navi` is an interactive cheatsheet tool with fuzzy search. Run it and type a few letters to filter available commands.

```bash
navi                  # open interactive UI
navi --query docker   # filter by topic directly
```

Cheatsheets included in this repo (`config/navi/cheats/`):

| File | Content |
|---|---|
| `development.cheat` | fd, rg, fzf, zoxide, bat, eza, lazygit, dev-setup, backup-dots |
| `docker.cheat` | build, run, exec, logs, compose, prune — with live container/image autocomplete |
| `ghostty.cheat` | all keyboard shortcuts (windows, tabs, splits, font…) |
| `macos.cheat` | system shortcuts, Finder, screenshots |
| `vscode.cheat` | navigation, editing, multi-cursor, debug, git |
| `zed.cheat` | navigation, splits, AI, vim mode, git, settings |

> Variables in commands (e.g. `<container_name>`) are filled dynamically by navi from the actual system state.

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
  private/      # local overrides, not tracked (use with secrets_manager.sh)
scripts/
  macos.sh      # macOS system defaults
  ubuntu.sh     # GitHub releases installs + compat symlinks
  wsl.sh        # WSL-specific config
  lib/          # shared utils, colors, install_github_binary
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
