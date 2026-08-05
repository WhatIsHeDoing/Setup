# Aliases.
#
# `cd` is aliased to zoxide's `z`, which falls back to plain cd for a path that
# exists and otherwise jumps to the best-matching directory from its database.
#
# eza's --icons takes an optional WHEN value, so a bare `--icons` swallows the
# next argument: `ls /tmp` failed with "invalid value '/tmp' for --icons".
# Spelling it `--icons=auto` binds the value and frees the positional path.

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cat='bat --pager=never'
alias cd='z'
alias ll='eza -lah --icons=auto --git'
alias ls='eza --icons=auto'
alias lt='eza --tree --icons=auto -L 2'
