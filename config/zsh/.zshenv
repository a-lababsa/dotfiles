# Environment variables for zsh
# This file is sourced on all invocations of the shell

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Editor configuration
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Path configuration
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Language and locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# History configuration
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=10000
export SAVEHIST=10000

# Less configuration
export LESS="-R"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

# Pager configuration
export PAGER="less"

# NVM directory (XDG-compliant)
export NVM_DIR="$HOME/.config/nvm"

# Python configuration
export PYTHONPATH="$HOME/.local/lib/python3/site-packages:$PYTHONPATH"

# Go configuration (if Go is installed)
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Rust/Cargo configuration
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export PATH="$CARGO_HOME/bin:$PATH"

# dotfiles location
export DOTFILES="$HOME/Documents/dotfiles"