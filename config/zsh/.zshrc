# Historique
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Auto-completion
autoload -Uz compinit
compinit

export PATH="$HOME/.local/bin:$PATH"

# Initialisation de Starship
eval "$(starship init zsh)"
eval "$(task --completion zsh)"
