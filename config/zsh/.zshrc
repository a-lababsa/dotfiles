# Historique
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Auto-completion
autoload -Uz compinit
compinit

# Initialisation de Starship
eval "$(starship init zsh)"
