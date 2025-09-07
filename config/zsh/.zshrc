# Performance optimizations (load first)
[[ -f ~/.dotfiles/config/zsh/.zsh_performance ]] && source ~/.dotfiles/config/zsh/.zsh_performance

# Basic PATH setup
export PATH="$HOME/.local/bin:$PATH"

# Initialize Starship prompt (fast)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Direnv hook (if installed)
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# Load aliases
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

# Cargo/Rust PATH
export PATH="$PATH:$HOME/.cargo/bin"

# NVM configuration
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# UV Python package manager
if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

# Zoxide (smart cd replacement)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi
