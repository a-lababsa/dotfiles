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
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Ollama optimizations for M4 Pro (24GB)
export OLLAMA_NUM_CTX=32768
export OLLAMA_KEEP_ALIVE=5m
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_MAX_LOADED_MODELS=1

# Sherpa-ONNX TTS
export SHERPA_ONNX_RUNTIME_DIR="$HOME/Library/Python/3.9/lib/python/site-packages/sherpa_onnx"
export SHERPA_ONNX_MODEL_DIR="$HOME/.local/share/sherpa-onnx/models/vits-piper-en_US-lessac-medium"

# YouTube summary via fabric
ytsummary() {
  local url="$1"
  local pattern="${2:-summarize}"
  local tmpdir=$(mktemp -d)

  yt-dlp --write-auto-sub --sub-format vtt --skip-download -o "$tmpdir/vid" "$url" 2>/dev/null
  cat "$tmpdir"/*.vtt | sed '/^[0-9]/d; /^$/d; /-->/d' | fabric -p "$pattern" --stream
  rm -rf "$tmpdir"
}
