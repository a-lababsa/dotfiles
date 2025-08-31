# Historique
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Auto-completion
autoload -Uz compinit
compinit

export PATH="$HOME/.local/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# uv (Python package manager)
export PATH="$HOME/.local/bin:$PATH"

# Initialisation de Starship
eval "$(starship init zsh)"

# Charger les alias
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
