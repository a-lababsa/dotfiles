# Performance optimizations (load first)
[[ -f "$DOTFILES/config/zsh/.zsh_performance" ]] && source "$DOTFILES/config/zsh/.zsh_performance"

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

# History options (HISTFILE/HISTSIZE/SAVEHIST set in .zshenv)
setopt APPEND_HISTORY        # Append to history file, don't overwrite
setopt INC_APPEND_HISTORY    # Write to history immediately, not on shell exit
setopt HIST_IGNORE_DUPS      # Don't record duplicate consecutive commands
setopt HIST_IGNORE_ALL_DUPS  # Remove older duplicate entries
setopt HIST_IGNORE_SPACE     # Don't record commands starting with a space
setopt HIST_REDUCE_BLANKS    # Remove extra blanks from commands
setopt SHARE_HISTORY         # Share history between all sessions

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

# FZF integration (Ctrl+R for history search, Ctrl+T for file search)
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
fi

# Zoxide (smart cd replacement)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi
# Docker CLI completions (cross-platform)
if [[ -d "$HOME/.docker/completions" ]]; then
    fpath=($HOME/.docker/completions $fpath)
fi
autoload -Uz compinit
compinit

# Zsh plugins (must be after compinit, syntax-highlighting must be last)
# Try: Homebrew (macOS) → /usr/share (apt) → Oh My Zsh custom plugins
_load_zsh_plugin() {
    local plugin_name="$1"
    local plugin_file="$plugin_name.zsh"

    # Homebrew (macOS)
    if [[ -d "$(brew --prefix 2>/dev/null)/share/$plugin_name" ]]; then
        source "$(brew --prefix)/share/$plugin_name/$plugin_file"
    # APT (Ubuntu/Debian)
    elif [[ -f "/usr/share/$plugin_name/$plugin_file" ]]; then
        source "/usr/share/$plugin_name/$plugin_file"
    # Oh My Zsh custom plugins
    elif [[ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name/$plugin_file" ]]; then
        source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name/$plugin_file"
    fi
}

_load_zsh_plugin "zsh-autosuggestions"
_load_zsh_plugin "zsh-syntax-highlighting"
unset -f _load_zsh_plugin

# macOS-specific configurations
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Ollama optimizations for Apple Silicon
    export OLLAMA_NUM_CTX=32768
    export OLLAMA_KEEP_ALIVE=5m
    export OLLAMA_NUM_PARALLEL=1
    export OLLAMA_MAX_LOADED_MODELS=1

    # Sherpa-ONNX TTS
    export SHERPA_ONNX_RUNTIME_DIR="$HOME/Library/Python/3.9/lib/python/site-packages/sherpa_onnx"
    export SHERPA_ONNX_MODEL_DIR="$HOME/.local/share/sherpa-onnx/models/vits-piper-en_US-lessac-medium"
fi

# YouTube summary via fabric
ytsummary() {
  local url="$1"
  local pattern="${2:-summarize}"
  local tmpdir=$(mktemp -d)

  yt-dlp --write-auto-sub --sub-format vtt --skip-download -o "$tmpdir/vid" "$url" 2>/dev/null
  cat "$tmpdir"/*.vtt | sed '/^[0-9]/d; /^$/d; /-->/d' | fabric -p "$pattern" --stream
  rm -rf "$tmpdir"
}
